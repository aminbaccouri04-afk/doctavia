const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const { Appointment, Prescription, Invoice } = require('../src/models');

describe('Flow 06: Clinical Consultation & Unified Save', () => {
  let doctorToken, patientToken;
  let patientProfileId, slotId, appointmentId;

  beforeAll(async () => {
    await clearDatabase();
    
    // 1. Setup Doctor
    await request(app).post('/api/v1/auth/signup').send({
      email: 'dr.clinic@test.com', password: 'Password123!', role: 'doctor', fullName: 'Dr. Clinical', dateOfBirth: '1970-01-01'
    });
    const drLogin = await request(app).post('/api/v1/auth/login').send({ email: 'dr.clinic@test.com', password: 'Password123!' });
    doctorToken = drLogin.body.token;

    // 2. Setup Patient
    const patSignup = await request(app).post('/api/v1/auth/signup').send({
      email: 'pat.clinic@test.com', password: 'Password123!', role: 'patient', fullName: 'Bob Clinic', dateOfBirth: '1985-10-10'
    });
    const patLogin = await request(app).post('/api/v1/auth/login').send({ email: 'pat.clinic@test.com', password: 'Password123!' });
    patientToken = patLogin.body.token;
    patientProfileId = patLogin.body.data.user.profiles[0].id;

    // 3. Create Slot & Appointment
    const slotRes = await request(app).post('/api/v1/availability').set('Authorization', `Bearer ${doctorToken}`).send({
      slots: [{ startTime: '2025-10-10T14:00:00Z', endTime: '2025-10-10T14:30:00Z' }]
    });
    slotId = slotRes.body.data.slots[0].id;
    const bookRes = await request(app).post('/api/v1/appointments').set('Authorization', `Bearer ${patientToken}`).send({ slotId, patientProfileId });
    appointmentId = bookRes.body.data.appointment.id;
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('should execute Unified Save: Notes, Prescriptions, Completion, and Billing', async () => {
    const res = await request(app)
      .post(`/api/v1/consultations/${appointmentId}/save`)
      .set('Authorization', `Bearer ${doctorToken}`)
      .send({
        subjective: 'Patient has a cough',
        objective: 'Lungs are clear',
        assessment: 'Common cold',
        plan: 'Rest and hydration',
        prescriptions: [
          { medicationName: 'Cough Syrup', dosage: '10ml', frequency: 'Bedtime', duration: '5 days' }
        ]
      });

    expect(res.statusCode).toBe(200);

    // 1. Check Appointment status
    const appt = await Appointment.findByPk(appointmentId);
    expect(appt.status).toBe('completed');

    // 2. Check Prescriptions
    const meds = await Prescription.findAll({ where: { appointmentId } });
    expect(meds.length).toBe(1);
    expect(meds[0].medicationName).toBe('Cough Syrup');

    // 3. Check Invoice generation
    const invoice = await Invoice.findOne({ where: { appointmentId } });
    expect(invoice).toBeDefined();
    expect(invoice.status).toBe('pending');
  });
});
