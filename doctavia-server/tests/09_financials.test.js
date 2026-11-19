const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const { Doctor, Invoice } = require('../src/models');

describe('Flow 09: Insights & Financials', () => {
  let doctorToken, patientToken;
  let doctorId, invoiceId;

  beforeAll(async () => {
    await clearDatabase();
    
    // 1. Setup Doctor
    const drSignup = await request(app).post('/api/v1/auth/signup').send({
      email: 'dr.money@test.com', password: 'Password123!', role: 'doctor', fullName: 'Dr. Money', dateOfBirth: '1970-01-01'
    });
    const drLogin = await request(app).post('/api/v1/auth/login').send({ email: 'dr.money@test.com', password: 'Password123!' });
    doctorToken = drLogin.body.token;
    const dr = await Doctor.findOne({ where: { userId: drSignup.body.data.user.id } });
    doctorId = dr.id;

    // 2. Setup Patient
    const patSignup = await request(app).post('/api/v1/auth/signup').send({
      email: 'pat.money@test.com', password: 'Password123!', role: 'patient', fullName: 'Bob Money', dateOfBirth: '1985-10-10'
    });
    const patLogin = await request(app).post('/api/v1/auth/login').send({ email: 'pat.money@test.com', password: 'Password123!' });
    patientToken = patLogin.body.token;
    const patientProfileId = patLogin.body.data.user.profiles[0].id;

    // 3. Create an appointment
    const { Appointment, AvailabilitySlot } = require('../src/models');
    const slot = await AvailabilitySlot.create({ doctorId: dr.id, startTime: new Date(), endTime: new Date(), isBooked: true });
    const appt = await Appointment.create({
      slotId: slot.id, patientProfileId, bookedById: patSignup.body.data.user.id,
      startTimeSnapshot: new Date(), endTimeSnapshot: new Date(), status: 'completed'
    });

    // 4. Create an invoice
    const inv = await Invoice.create({
      appointmentId: appt.id, patientProfileId, doctorId: dr.id, amount: 100, status: 'pending', issuedAt: new Date()
    });
    invoiceId = inv.id;
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('6.1 Analytics (KPIs) - should return dashboard metrics', async () => {
    const res = await request(app)
      .get('/api/v1/analytics')
      .set('Authorization', `Bearer ${doctorToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.data.kpis).toBeDefined();
  });

  it('6.2.2 Revenue Stats - should return doctor revenue breakdown', async () => {
    const res = await request(app)
      .get('/api/v1/doctors/me/revenue')
      .set('Authorization', `Bearer ${doctorToken}`);

    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data.stats)).toBe(true);
  });

  it('6.2.3 Payment - should allow paying an invoice', async () => {
    const res = await request(app)
      .post(`/api/v1/billing/invoices/${invoiceId}/pay`)
      .set('Authorization', `Bearer ${patientToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.data.invoice.status).toBe('paid');
  });
});
