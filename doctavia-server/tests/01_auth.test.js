const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const { User, Doctor, PracticeStaff, Profile } = require('../src/models');

describe('Flow 01: Identity & Access Management', () => {
  beforeAll(async () => {
    await clearDatabase();
  });

  afterAll(async () => {
    await sequelize.close();
  });

  describe('1.1 Account Onboarding (Signup)', () => {
    it('should register a new doctor and automatically create a "Self" profile', async () => {
      const res = await request(app).post('/api/v1/auth/signup').send({
        email: 'dr.review@test.com',
        password: 'Password123!',
        role: 'doctor',
        fullName: 'Dr. Reviewer',
        dateOfBirth: '1980-01-01'
      });

      expect(res.statusCode).toEqual(201);
      expect(res.body.data.user.email).toBe('dr.review@test.com');
      
      // Verify Profile creation
      const profiles = await Profile.findAll({ where: { accountId: res.body.data.user.id } });
      expect(profiles.length).toBe(1);
      expect(profiles[0].relationship).toBe('Self');
      
      // Verify Doctor creation
      const doctor = await Doctor.findOne({ where: { userId: res.body.data.user.id } });
      expect(doctor).toBeDefined();
    });

    it('should register a secretary only with a valid doctor authCode', async () => {
      // 1. Get authCode from existing doctor
      const dr = await User.findOne({ where: { email: 'dr.review@test.com' }, include: [{ model: Doctor, as: 'doctorProfile' }] });
      const authCode = dr.doctorProfile.authCode;

      // 2. Try with WRONG authCode
      const failRes = await request(app).post('/api/v1/auth/signup').send({
        email: 'sec.fail@test.com',
        password: 'Password123!',
        role: 'secretary',
        fullName: 'Alice Secretary',
        dateOfBirth: '1990-01-01',
        authCode: 'WRONG123'
      });
      expect(failRes.statusCode).toBe(400);

      // 3. Try with CORRECT authCode
      const successRes = await request(app).post('/api/v1/auth/signup').send({
        email: 'sec.success@test.com',
        password: 'Password123!',
        role: 'secretary',
        fullName: 'Alice Secretary',
        dateOfBirth: '1990-01-01',
        authCode
      });
      expect(successRes.statusCode).toBe(201);

      // Verify Link
      const staff = await PracticeStaff.findOne({ where: { userId: successRes.body.data.user.id } });
      expect(staff.doctorId).toBe(dr.doctorProfile.id);
    });
  });

  describe('1.2 Access Control (Login)', () => {
    it('should issue a JWT token on successful login', async () => {
      const res = await request(app).post('/api/v1/auth/login').send({
        email: 'dr.review@test.com',
        password: 'Password123!'
      });

      expect(res.statusCode).toBe(200);
      expect(res.body.token).toBeDefined();
    });

    it('should reject invalid credentials', async () => {
      const res = await request(app).post('/api/v1/auth/login').send({
        email: 'dr.review@test.com',
        password: 'WrongPassword'
      });

      expect(res.statusCode).toBe(401);
    });
  });

  describe('1.3 Password Recovery', () => {
    let resetToken;

    it('should generate a 6-digit numeric token for forgot-password', async () => {
      const res = await request(app).post('/api/v1/auth/forgot-password').send({
        email: 'dr.review@test.com'
      });

      expect(res.statusCode).toBe(200);
      expect(res.body.data.resetToken).toMatch(/^\d{6}$/);
      resetToken = res.body.data.resetToken;
    });

    it('should reset password using the token', async () => {
      const res = await request(app).post('/api/v1/auth/reset-password').send({
        email: 'dr.review@test.com',
        token: resetToken,
        newPassword: 'NewPassword123!'
      });

      expect(res.statusCode).toBe(200);

      // Verify login with new password
      const loginRes = await request(app).post('/api/v1/auth/login').send({
        email: 'dr.review@test.com',
        password: 'NewPassword123!'
      });
      expect(loginRes.statusCode).toBe(200);
    });
  });

  describe('1.4 Secure Password Update (Change Password)', () => {
    let authToken;

    beforeAll(async () => {
      const login = await request(app).post('/api/v1/auth/login').send({
        email: 'dr.review@test.com',
        password: 'NewPassword123!'
      });
      authToken = login.body.token;
    });

    it('should allow user to change password by providing old and new password', async () => {
      const res = await request(app)
        .patch('/api/v1/auth/change-password')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          oldPassword: 'NewPassword123!',
          newPassword: 'FinalPassword123!'
        });

      expect(res.statusCode).toBe(200);
      expect(res.body.status).toBe('success');

      // Verify login with latest password
      const loginRes = await request(app).post('/api/v1/auth/login').send({
        email: 'dr.review@test.com',
        password: 'FinalPassword123!'
      });
      expect(loginRes.statusCode).toBe(200);
    });

    it('should reject password change if old password is incorrect', async () => {
      const res = await request(app)
        .patch('/api/v1/auth/change-password')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          oldPassword: 'WrongOldPassword',
          newPassword: 'NextPassword123!'
        });

      expect(res.statusCode).toBe(401);
    });
  });
});
