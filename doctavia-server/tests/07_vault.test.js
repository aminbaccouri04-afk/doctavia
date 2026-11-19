const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const path = require('path');
const fs = require('fs');

describe('Flow 07: Patient Health Vault', () => {
  let patientToken;
  let patientProfileId;

  beforeAll(async () => {
    await clearDatabase();
    
    // Setup Patient
    const signup = await request(app).post('/api/v1/auth/signup').send({
      email: 'pat.vault@test.com', password: 'Password123!', role: 'patient', fullName: 'Bob Vault', dateOfBirth: '1985-10-10'
    });
    const login = await request(app).post('/api/v1/auth/login').send({ email: 'pat.vault@test.com', password: 'Password123!' });
    patientToken = login.body.token;
    patientProfileId = login.body.data.user.profiles[0].id;

    // Create a dummy file for upload tests
    const testFile = path.join(__dirname, 'test-record.pdf');
    fs.writeFileSync(testFile, 'dummy content');
  });

  afterAll(async () => {
    // Cleanup dummy file
    const testFile = path.join(__dirname, 'test-record.pdf');
    if (fs.existsSync(testFile)) fs.unlinkSync(testFile);
    await sequelize.close();
  });

  it('4.1 Medical Records (Vault) - should allow uploading a record', async () => {
    const testFile = path.join(__dirname, 'test-record.pdf');
    
    const res = await request(app)
      .post(`/api/v1/records/${patientProfileId}`)
      .set('Authorization', `Bearer ${patientToken}`)
      .attach('document', testFile)
      .field('description', 'Annual checkup result');

    expect(res.statusCode).toBe(201);
    expect(res.body.data.record.fileName).toBe('test-record.pdf');
  });

  it('4.2 Prescriptions - should list all patient medications', async () => {
    const res = await request(app)
      .get(`/api/v1/consultations/prescriptions/${patientProfileId}`)
      .set('Authorization', `Bearer ${patientToken}`);

    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data.prescriptions)).toBe(true);
  });
});
