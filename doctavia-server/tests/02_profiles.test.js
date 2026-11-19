const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');

describe('Flow 02: Family Profile Management', () => {
  let token;
  let profileId;

  beforeAll(async () => {
    await clearDatabase();
    // Setup patient user
    await request(app).post('/api/v1/auth/signup').send({
      email: 'patient.profile@test.com',
      password: 'Password123!',
      role: 'patient',
      fullName: 'Main Account',
      dateOfBirth: '1980-01-01'
    });
    const login = await request(app).post('/api/v1/auth/login').send({
      email: 'patient.profile@test.com',
      password: 'Password123!'
    });
    token = login.body.token;
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('should allow patient to add a sub-profile (Family Member)', async () => {
    const res = await request(app)
      .post('/api/v1/profiles')
      .set('Authorization', `Bearer ${token}`)
      .send({
        fullName: 'Junior Account',
        dateOfBirth: '2015-05-15',
        relationship: 'Child'
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.data.profile.fullName).toBe('Junior Account');
    profileId = res.body.data.profile.id;
  });

  it('should list all profiles linked to the account', async () => {
    const res = await request(app)
      .get('/api/v1/profiles')
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.data.profiles.length).toBe(2); // Self + Child
  });

  it('should allow updating a profile', async () => {
    const res = await request(app)
      .patch(`/api/v1/profiles/${profileId}`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        fullName: 'Junior Updated'
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.profile.fullName).toBe('Junior Updated');
  });

  it('should block creation of an additional Self profile', async () => {
    const res = await request(app)
      .post('/api/v1/profiles')
      .set('Authorization', `Bearer ${token}`)
      .send({
        fullName: 'Another Me',
        dateOfBirth: '1980-01-01',
        relationship: 'Self'
      });

    expect(res.statusCode).toBe(400);
  });
});
