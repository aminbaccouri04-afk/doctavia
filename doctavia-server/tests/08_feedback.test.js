const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const { Appointment, AvailabilitySlot, Doctor, Notification } = require('../src/models');

describe('Flow 08: Experience & Feedback', () => {
  let doctorToken, patientToken;
  let patientProfileId, appointmentId, notificationId;

  beforeAll(async () => {
    await clearDatabase();
    
    // 1. Setup Doctor
    const drSignup = await request(app).post('/api/v1/auth/signup').send({
      email: 'dr.feedback@test.com', password: 'Password123!', role: 'doctor', fullName: 'Dr. Feedback', dateOfBirth: '1970-01-01'
    });
    const drLogin = await request(app).post('/api/v1/auth/login').send({ email: 'dr.feedback@test.com', password: 'Password123!' });
    doctorToken = drLogin.body.token;
    const dr = await Doctor.findOne({ where: { userId: drSignup.body.data.user.id } });

    // 2. Setup Patient
    const patSignup = await request(app).post('/api/v1/auth/signup').send({
      email: 'pat.feedback@test.com', password: 'Password123!', role: 'patient', fullName: 'Bob Feedback', dateOfBirth: '1985-10-10'
    });
    const patLogin = await request(app).post('/api/v1/auth/login').send({ email: 'pat.feedback@test.com', password: 'Password123!' });
    patientToken = patLogin.body.token;
    patientProfileId = patLogin.body.data.user.profiles[0].id;

    // 3. Create a COMPLETED appointment
    const slot = await AvailabilitySlot.create({ doctorId: dr.id, startTime: new Date(), endTime: new Date(), isBooked: true });
    const appt = await Appointment.create({
      slotId: slot.id, patientProfileId, bookedById: patSignup.body.data.user.id,
      startTimeSnapshot: new Date(), endTimeSnapshot: new Date(), status: 'completed'
    });
    appointmentId = appt.id;

    // 4. Trigger a notification
    const note = await Notification.create({ userId: patSignup.body.data.user.id, title: 'Test', message: 'Message' });
    notificationId = note.id;
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('5.1 Ratings & Reviews - should allow patient to submit a review', async () => {
    const res = await request(app)
      .post('/api/v1/reviews')
      .set('Authorization', `Bearer ${patientToken}`)
      .send({
        appointmentId,
        rating: 5,
        comment: 'Great experience!'
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.data.review.rating).toBe(5);
  });

  it('5.2 Notifications - should allow marking as read', async () => {
    const res = await request(app)
      .patch(`/api/v1/notifications/${notificationId}/read`)
      .set('Authorization', `Bearer ${patientToken}`)
      .send({ isRead: true });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.notification.isRead).toBe(true);
  });
});
