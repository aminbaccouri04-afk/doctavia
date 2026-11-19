const request = require('supertest');
const app = require('../src/app');
const { sequelize, Doctor } = require('../src/models');
const { createTestUser, clearDatabase } = require('./utils');
const path = require('path');
const fs = require('fs');

describe('Flow 15: Doctor Professional Profile Updates', () => {
  let doctorToken;
  let doctorUserId;

  beforeAll(async () => {
    await clearDatabase();
    const dr = await createTestUser('doctor.updates@test.com', 'Password123!', 'doctor');
    doctorToken = dr.token;
    doctorUserId = dr.user.id;
  });

  afterAll(async () => {
    await sequelize.close();
  });

  describe('Doctor Profile Updates (New Fields)', () => {
    it('should allow a doctor to update their professional details with granular fields', async () => {
      const updateData = {
        bio: 'Expert in advanced cardiology.',
        categories: ['Cardiology', 'Heart Surgery'],
        experienceYears: 15,
        education: 'Harvard Medical School',
        services: ['Echocardiogram', 'Stress Test'],
        equipment: ['State-of-the-art MRI', 'Digital X-Ray'],
        languages: ['English', 'French', 'Spanish']
      };

      const res = await request(app)
        .put('/api/v1/doctors/me')
        .set('Authorization', `Bearer ${doctorToken}`)
        .send(updateData);

      expect(res.statusCode).toBe(200);
      expect(res.body.status).toBe('success');
      
      // Verify in DB with associations
      const { Specialty, Category, Equipment, Language } = require('../src/models');
      const doctor = await Doctor.findOne({ 
        where: { userId: doctorUserId },
        include: [
          { model: Specialty, as: 'specialties' },
          { model: Category, as: 'categories' },
          { model: Equipment, as: 'equipment' },
          { model: Language, as: 'languages' }
        ]
      });

      expect(doctor.experienceYears).toBe(15);
      expect(doctor.education).toBe('Harvard Medical School');
      
      const langNames = doctor.languages.map(l => l.name);
      const equipNames = doctor.equipment.map(e => e.name);
      const catNames = doctor.categories.map(c => c.name); // mapped from 'services' in input

      expect(langNames).toContain('French');
      expect(equipNames).toContain('Digital X-Ray');
      expect(catNames).toContain('Stress Test');
    });

    it('should not allow updating non-allowed fields', async () => {
      const res = await request(app)
        .put('/api/v1/doctors/me')
        .set('Authorization', `Bearer ${doctorToken}`)
        .send({
          authCode: 'HACKED_CODE',
          experienceYears: 20
        });

      expect(res.statusCode).toBe(200);
      const doctor = await Doctor.findOne({ where: { userId: doctorUserId } });
      expect(doctor.authCode).not.toBe('HACKED_CODE');
      expect(doctor.experienceYears).toBe(20);
    });
  });
});
