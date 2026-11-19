const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const { AvailabilitySlot, Doctor } = require('../src/models');

describe('Flow 04: Doctor Availability Management', () => {
  let doctorToken;
  let doctorId;

  beforeAll(async () => {
    await clearDatabase();
    
    const signup = await request(app).post('/api/v1/auth/signup').send({
      email: 'dr.slots@test.com', password: 'Password123!', role: 'doctor', fullName: 'Dr. Slots', dateOfBirth: '1970-01-01'
    });
    const login = await request(app).post('/api/v1/auth/login').send({ email: 'dr.slots@test.com', password: 'Password123!' });
    doctorToken = login.body.token;
    
    const dr = await Doctor.findOne({ where: { userId: signup.body.data.user.id } });
    doctorId = dr.id;
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('should allow doctor to batch-create availability slots', async () => {
    const res = await request(app)
      .post('/api/v1/availability')
      .set('Authorization', `Bearer ${doctorToken}`)
      .send({
        slots: [
          { startTime: '2025-12-01T09:00:00Z', endTime: '2025-12-01T09:30:00Z' },
          { startTime: '2025-12-01T10:00:00Z', endTime: '2025-12-01T10:30:00Z' }
        ]
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.data.slots.length).toBe(2);
  });

  it('should allow deleting an unbooked slot', async () => {
    const slots = await AvailabilitySlot.findAll({ where: { doctorId } });
    const slotId = slots[0].id;

    const res = await request(app)
      .delete(`/api/v1/availability/${slotId}`)
      .set('Authorization', `Bearer ${doctorToken}`);

    expect(res.statusCode).toBe(204);
    
    const check = await AvailabilitySlot.findByPk(slotId);
    expect(check).toBeNull();
  });

  it('should prevent deleting a booked slot', async () => {
    const slots = await AvailabilitySlot.findAll({ where: { doctorId } });
    const slotId = slots[0].id;
    
    // Manually mark as booked
    await AvailabilitySlot.update({ isBooked: true }, { where: { id: slotId } });

    const res = await request(app)
      .delete(`/api/v1/availability/${slotId}`)
      .set('Authorization', `Bearer ${doctorToken}`);

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toContain('active booking');
  });
});
