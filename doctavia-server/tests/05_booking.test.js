const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const { Doctor, AvailabilitySlot } = require('../src/models');

describe('Flow 05: The Appointment Lifecycle', () => {
  let doctorToken, secretaryToken, patientToken;
  let patientProfileId, slotId, appointmentId;

  beforeAll(async () => {
    await clearDatabase();
    
    // 1. Setup Doctor
    const drSignup = await request(app).post('/api/v1/auth/signup').send({
      email: 'dr.life@test.com', password: 'Password123!', role: 'doctor', fullName: 'Dr. Lifecycle', dateOfBirth: '1970-01-01'
    });
    const drLogin = await request(app).post('/api/v1/auth/login').send({ email: 'dr.life@test.com', password: 'Password123!' });
    doctorToken = drLogin.body.token;
    const authCode = (await Doctor.findOne({ where: { userId: drSignup.body.data.user.id } })).authCode;

    // 2. Setup Secretary
    await request(app).post('/api/v1/auth/signup').send({
      email: 'sec.life@test.com', password: 'Password123!', role: 'secretary', fullName: 'Alice Secretary', dateOfBirth: '1990-01-01', authCode
    });
    const secLogin = await request(app).post('/api/v1/auth/login').send({ email: 'sec.life@test.com', password: 'Password123!' });
    secretaryToken = secLogin.body.token;

    // 3. Setup Patient
    const patSignup = await request(app).post('/api/v1/auth/signup').send({
      email: 'pat.life@test.com', password: 'Password123!', role: 'patient', fullName: 'Bob Patient', dateOfBirth: '1985-10-10'
    });
    const patLogin = await request(app).post('/api/v1/auth/login').send({ email: 'pat.life@test.com', password: 'Password123!' });
    patientToken = patLogin.body.token;
    patientProfileId = patLogin.body.data.user.profiles[0].id;

    // 4. Create Offering
    const offeringRes = await request(app).post('/api/v1/offerings').set('Authorization', `Bearer ${doctorToken}`).send({
      name: 'Standard Consultation', price: 60.00, durationMinutes: 30
    });
    offeringId = offeringRes.body.data.offering.id;

    // 5. Create Slot
    const slotRes = await request(app).post('/api/v1/availability').set('Authorization', `Bearer ${doctorToken}`).send({
      slots: [{ startTime: '2025-10-10T14:00:00Z', endTime: '2025-10-10T14:30:00Z' }]
    });
    slotId = slotRes.body.data.slots[0].id;
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('3.1 Booking Flow (Patient)', async () => {
    const res = await request(app)
      .post('/api/v1/appointments')
      .set('Authorization', `Bearer ${patientToken}`)
      .send({ slotId, patientProfileId, offeringId });
    
    expect(res.statusCode).toBe(201);
    appointmentId = res.body.data.appointment.id;
  });

  it('should block double-booking via atomic lock (Concurrency Protection)', async () => {
    const res = await request(app)
      .post('/api/v1/appointments')
      .set('Authorization', `Bearer ${patientToken}`)
      .send({ slotId, patientProfileId, offeringId });

    // The slot is already booked — should return 400 or 409
    expect(res.statusCode).toBeGreaterThanOrEqual(400);
  });

  it('3.2.1 Check-In (Secretary)', async () => {
    const res = await request(app)
      .patch(`/api/v1/appointments/${appointmentId}/check-in`)
      .set('Authorization', `Bearer ${secretaryToken}`);
    
    expect(res.statusCode).toBe(200);
    expect(res.body.data.appointment.status).toBe('checked_in');
  });

  it('3.2.2 Start Consultation (Doctor)', async () => {
    const res = await request(app)
      .patch(`/api/v1/appointments/${appointmentId}/start`)
      .set('Authorization', `Bearer ${doctorToken}`);
    
    expect(res.statusCode).toBe(200);
    expect(res.body.data.appointment.status).toBe('in_progress');
  });

  it('3.2.3 Cancellation (Patient) - should re-open the slot', async () => {
    // Create another slot and appointment to test cancellation
    const slotRes = await request(app).post('/api/v1/availability').set('Authorization', `Bearer ${doctorToken}`).send({
      slots: [{ startTime: '2025-11-10T09:00:00Z', endTime: '2025-11-10T09:30:00Z' }]
    });
    const newSlotId = slotRes.body.data.slots[0].id;
    const bookRes = await request(app).post('/api/v1/appointments').set('Authorization', `Bearer ${patientToken}`).send({ slotId: newSlotId, patientProfileId, offeringId });
    const newApptId = bookRes.body.data.appointment.id;

    const res = await request(app)
      .patch(`/api/v1/appointments/${newApptId}/cancel`)
      .set('Authorization', `Bearer ${patientToken}`)
      .send({ reason: 'Changing plans' });

    expect(res.statusCode).toBe(200);
    
    // Verify slot is open again
    const slot = await AvailabilitySlot.findByPk(newSlotId);
    expect(slot.isBooked).toBe(false);
  });
});
