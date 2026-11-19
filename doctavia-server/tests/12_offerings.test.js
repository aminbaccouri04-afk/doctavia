const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const { Offering, Doctor } = require('../src/models');

describe('Flow 12: Doctor Offering Management', () => {
  let doctorToken, patientToken, doctorId;
  let offeringId;

  beforeAll(async () => {
    await clearDatabase();
    
    // 1. Setup Doctor
    const drSignup = await request(app).post('/api/v1/auth/signup').send({
      email: 'dr.offering@test.com', password: 'Password123!', role: 'doctor', fullName: 'Dr. Merchant', dateOfBirth: '1970-01-01'
    });
    const drLogin = await request(app).post('/api/v1/auth/login').send({ email: 'dr.offering@test.com', password: 'Password123!' });
    doctorToken = drLogin.body.token;
    
    const dr = await Doctor.findOne({ where: { userId: drSignup.body.data.user.id } });
    doctorId = dr.id;

    // 2. Setup Patient
    await request(app).post('/api/v1/auth/signup').send({
      email: 'pat.offering@test.com', password: 'Password123!', role: 'patient', fullName: 'Bob Shopper', dateOfBirth: '1985-10-10'
    });
    const patLogin = await request(app).post('/api/v1/auth/login').send({ email: 'pat.offering@test.com', password: 'Password123!' });
    patientToken = patLogin.body.token;
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('should allow a doctor to create an offering', async () => {
    const res = await request(app)
      .post('/api/v1/offerings')
      .set('Authorization', `Bearer ${doctorToken}`)
      .send({
        name: 'Standard Checkup',
        description: 'A basic medical examination',
        price: 45.00,
        durationMinutes: 20
      });
    
    expect(res.statusCode).toBe(201);
    expect(res.body.data.offering.name).toBe('Standard Checkup');
    offeringId = res.body.data.offering.id;
  });

  it('should allow a doctor to see their offerings', async () => {
    const res = await request(app)
      .get('/api/v1/offerings')
      .set('Authorization', `Bearer ${doctorToken}`);
    
    expect(res.statusCode).toBe(200);
    expect(res.body.results).toBeGreaterThan(0);
    expect(res.body.data.offerings[0].name).toBe('Standard Checkup');
  });

  it('should allow a doctor to update their offering', async () => {
    const res = await request(app)
      .patch(`/api/v1/offerings/${offeringId}`)
      .set('Authorization', `Bearer ${doctorToken}`)
      .send({ price: 50.00 });
    
    expect(res.statusCode).toBe(200);
    expect(Number(res.body.data.offering.price)).toBe(50.00);
  });

  it('should block a patient from creating an offering', async () => {
    const res = await request(app)
      .post('/api/v1/offerings')
      .set('Authorization', `Bearer ${patientToken}`)
      .send({ name: 'Illegal Service', price: 100 });
    
    expect(res.statusCode).toBe(403); // Restricted to doctor
  });

  it('should include offerings in doctor search results', async () => {
    const res = await request(app)
      .get('/api/v1/doctors')
      .set('Authorization', `Bearer ${patientToken}`);
    
    expect(res.statusCode).toBe(200);
    const dr = res.body.data.doctors.find(d => d.id === doctorId);
    expect(dr.offerings).toBeDefined();
    expect(dr.offerings.length).toBeGreaterThan(0);
    expect(dr.offerings[0].name).toBe('Standard Checkup');
  });

  it('should allow a doctor to delete an offering', async () => {
    const res = await request(app)
      .delete(`/api/v1/offerings/${offeringId}`)
      .set('Authorization', `Bearer ${doctorToken}`);
    
    expect(res.statusCode).toBe(204);
    
    const check = await Offering.findByPk(offeringId);
    expect(check).toBeNull();
  });
});
