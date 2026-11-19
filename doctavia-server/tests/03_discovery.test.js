const request = require('supertest');
const app = require('../src/app');
const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const { Doctor, Location, Specialty } = require('../src/models');

describe('Flow 03: Doctor Discovery & Search', () => {
  let token;
  let doctorId;

  beforeAll(async () => {
    await clearDatabase();
    
    // 1. Create Patient
    await request(app).post('/api/v1/auth/signup').send({
      email: 'patient.search@test.com', password: 'Password123!', role: 'patient', fullName: 'Searcher', dateOfBirth: '1990-01-01'
    });
    const login = await request(app).post('/api/v1/auth/login').send({ email: 'patient.search@test.com', password: 'Password123!' });
    token = login.body.token;

    // 2. Create Doctor with Location and Specialty
    const signup = await request(app).post('/api/v1/auth/signup').send({
      email: 'dr.search@test.com', password: 'Password123!', role: 'doctor', fullName: 'Dr. Finder', dateOfBirth: '1970-01-01'
    });
    
    const dr = await Doctor.findOne({ where: { userId: signup.body.data.user.id } });
    doctorId = dr.id;
    
    // Set Specialties via association
    const cardiology = await Specialty.findOrCreate({ where: { name: 'Cardiology' } }).then(([s]) => s);
    const general = await Specialty.findOrCreate({ where: { name: 'General' } }).then(([s]) => s);
    await dr.setSpecialties([cardiology, general]);

    // Link a location
    const loc = await Location.create({
      name: 'Central Clinic',
      address: '123 Main St',
      city: 'New York',
      latitude: 40.7128,
      longitude: -74.0060 // New York
    });
    await dr.setOffices([loc]);
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('should find doctors by specialty', async () => {
    const res = await request(app)
      .get('/api/v1/doctors?specialty=Cardiology')
      .set('Authorization', `Bearer ${token}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.results).toBeGreaterThan(0);
  });

  it('should find doctors by proximity (Geospatial)', async () => {
    // Search near New York (40.7, -74.0)
    const res = await request(app)
      .get('/api/v1/doctors?lat=40.71&lng=-74.00&radius=10')
      .set('Authorization', `Bearer ${token}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.results).toBeGreaterThan(0);
  });

  it('should toggle doctor as favorite', async () => {
    const res = await request(app)
      .post(`/api/v1/doctors/${doctorId}/favorite`)
      .set('Authorization', `Bearer ${token}`);
    
    expect(res.statusCode).toBe(200);
    expect(res.body.data.isFavorite).toBe(true);

    const listRes = await request(app)
      .get('/api/v1/doctors/favorites')
      .set('Authorization', `Bearer ${token}`);
    expect(listRes.body.data.favorites.length).toBe(1);
  });

  it('should list all available specialties', async () => {
    await Specialty.create({ name: 'Dermatology' });
    const res = await request(app).get('/api/v1/lookup/specialties');
    expect(res.statusCode).toBe(200);
    expect(res.body.data.specialties.some(s => s.name === 'Dermatology')).toBe(true);
  });
});
