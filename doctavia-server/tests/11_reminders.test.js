const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const { Reminder } = require('../src/models');

describe('Flow 11: Medicine Reminders Management', () => {
  let userToken;
  let reminderId;

  beforeAll(async () => {
    await clearDatabase();
    
    // 1. Signup a test patient
    await request(app).post('/api/v1/auth/signup').send({
      email: 'patient.remind@test.com',
      password: 'Password123!',
      role: 'patient',
      fullName: 'John Remind',
      dateOfBirth: '1995-05-15'
    });

    // 2. Login to get token
    const loginRes = await request(app).post('/api/v1/auth/login').send({
      email: 'patient.remind@test.com',
      password: 'Password123!'
    });
    userToken = loginRes.body.token;
  });

  afterAll(async () => {
    await sequelize.close();
  });

  describe('11.1 Reminder Creation', () => {
    it('should create a new medication reminder', async () => {
      const res = await request(app)
        .post('/api/v1/reminders')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          medicationName: 'Paracetamol',
          dosage: '500mg',
          frequency: 'Twice daily',
          times: ['08:00', '20:00']
        });

      expect(res.statusCode).toEqual(201);
      expect(res.body.data.reminder.medicationName).toBe('Paracetamol');
      expect(res.body.data.reminder.isActive).toBe(true);
      reminderId = res.body.data.reminder.id;
    });

    it('should fail if medicationName is missing', async () => {
      const res = await request(app)
        .post('/api/v1/reminders')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          times: ['09:00']
        });

      expect(res.statusCode).toBe(400);
    });
  });

  describe('11.2 Reminder Retrieval', () => {
    it('should list all reminders for the user', async () => {
      const res = await request(app)
        .get('/api/v1/reminders')
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body.data.reminders)).toBe(true);
      expect(res.body.data.reminders.length).toBe(1);
    });
  });

  describe('11.3 Reminder Updates', () => {
    it('should update an existing reminder (toggle status)', async () => {
      const res = await request(app)
        .patch(`/api/v1/reminders/${reminderId}`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          isActive: false,
          dosage: '1000mg'
        });

      expect(res.statusCode).toBe(200);
      expect(res.body.data.reminder.isActive).toBe(false);
      expect(res.body.data.reminder.dosage).toBe('1000mg');
    });

    it('should return 404 for non-existent reminder', async () => {
      const res = await request(app)
        .patch('/api/v1/reminders/00000000-0000-0000-0000-000000000000')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ isActive: true });

      expect(res.statusCode).toBe(404);
    });
  });

  describe('11.4 Reminder Deletion', () => {
    it('should delete a reminder', async () => {
      const res = await request(app)
        .delete(`/api/v1/reminders/${reminderId}`)
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.statusCode).toBe(204);

      // Verify deletion
      const check = await Reminder.findByPk(reminderId);
      expect(check).toBeNull();
    });
  });
});
