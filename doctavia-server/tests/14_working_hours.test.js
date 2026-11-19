const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const { WorkingHour, AvailabilitySlot, Doctor } = require('../src/models');

describe('Flow 14: Working Hours & Schedule Management', () => {
  let doctorToken;
  let doctorId;

  beforeAll(async () => {
    await clearDatabase();
    
    const signup = await request(app).post('/api/v1/auth/signup').send({
      email: 'dr.schedule@test.com', password: 'Password123!', role: 'doctor', fullName: 'Dr. Schedule', dateOfBirth: '1975-01-01'
    });
    const login = await request(app).post('/api/v1/auth/login').send({ email: 'dr.schedule@test.com', password: 'Password123!' });
    doctorToken = login.body.token;
    
    const dr = await Doctor.findOne({ where: { userId: signup.body.data.user.id } });
    doctorId = dr.id;
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('should allow doctor to update their weekly working hours', async () => {
    const res = await request(app)
      .put('/api/v1/working-hours')
      .set('Authorization', `Bearer ${doctorToken}`)
      .send({
        workingHours: [
          { dayOfWeek: 1, startTime: '09:00', endTime: '12:00' }, // Monday Morning
          { dayOfWeek: 1, startTime: '14:00', endTime: '17:00' }, // Monday Afternoon
          { dayOfWeek: 2, isClosed: true } // Tuesday Closed
        ]
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.length).toBe(3);
  });

  it('should allow doctor to retrieve their working hours', async () => {
    const res = await request(app)
      .get('/api/v1/working-hours')
      .set('Authorization', `Bearer ${doctorToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.data.find(wh => wh.dayOfWeek === 1)).toBeDefined();
  });

  it('should generate availability slots based on working hours', async () => {
    // Generate slots for next Monday
    const nextMonday = new Date();
    nextMonday.setDate(nextMonday.getDate() + ((1 + 7 - nextMonday.getDay()) % 7 || 7));
    const nextMondayStr = nextMonday.toISOString().split('T')[0];

    const res = await request(app)
      .post('/api/v1/working-hours/generate-slots')
      .set('Authorization', `Bearer ${doctorToken}`)
      .send({
        startDate: nextMondayStr,
        endDate: nextMondayStr,
        slotDurationMinutes: 60
      });

    expect(res.statusCode).toBe(201);
    // 09:00-12:00 (3 slots) + 14:00-17:00 (3 slots) = 6 slots
    expect(res.body.results).toBe(6);

    const slots = await AvailabilitySlot.findAll({ where: { doctorId } });
    expect(slots.length).toBeGreaterThanOrEqual(6);
  });
});
