const request = require('supertest');
const app = require('../src/app');
const { sequelize, User, Doctor, PracticeStaff, Notification, Appointment, Offering, AvailabilitySlot } = require('../src/models');
const { createTestUser, clearDatabase } = require('./utils');

describe('Flow 13: Infrastructure & Management (Staff, Analytics, Notifications)', () => {
  let doctorToken, secretaryToken, patientToken, secretary2Token;
  let doctorId, doctorUserId, secretaryId, patientId, secretary2Id;
  let offeringId;

  beforeAll(async () => {
    await clearDatabase();

    // 1. Setup Doctor
    const dr = await createTestUser('doctor@infra.com', 'Password123!', 'doctor');
    doctorToken = dr.token;
    doctorUserId = dr.user.id;
    const docRecord = await Doctor.findOne({ where: { userId: dr.user.id } });
    doctorId = docRecord.id;
    const authCode = docRecord.authCode;

    // 2. Setup Secretary (linked to Doctor via signup)
    const sec = await createTestUser('secretary@infra.com', 'Password123!', 'secretary', { authCode });
    secretaryToken = sec.token;
    secretaryId = sec.user.id;

    // 3. Setup a second Secretary (linked to doctor2, will manually link to doctor1)
    const dr2 = await createTestUser('doctor2@infra.com', 'Password123!', 'doctor');
    const authCode2 = (await Doctor.findOne({ where: { userId: dr2.user.id } })).authCode;
    
    const sec2 = await createTestUser('secretary2@infra.com', 'Password123!', 'secretary', { authCode: authCode2 });
    secretary2Token = sec2.token;
    secretary2Id = sec2.user.id;

    // 3. Setup Patient
    const pat = await createTestUser('patient@infra.com', 'Password123!', 'patient');
    patientToken = pat.token;
    patientId = pat.user.id;

    // 2. Setup an offering and slot for analytics/notification testing
    const offering = await Offering.create({
      doctorId,
      name: 'Standard Visit',
      price: 150.00,
      durationMinutes: 30
    });
    offeringId = offering.id;

    await AvailabilitySlot.create({
      doctorId,
      startTime: new Date(Date.now() + 86400000),
      endTime: new Date(Date.now() + 86400000 + 1800000),
      isBooked: false
    });
  });

  afterAll(async () => {
    await sequelize.close();
  });

  describe('Staff Delegation', () => {
    let authCode;

    it('should allow a doctor to generate a staff auth code', async () => {
      const res = await request(app)
        .get('/api/v1/staff/code')
        .set('Authorization', `Bearer ${doctorToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data.authCode).toBeDefined();
      authCode = res.body.data.authCode;
    });

    it('should allow a secretary to link using the code', async () => {
      const res = await request(app)
        .post('/api/v1/staff/link')
        .set('Authorization', `Bearer ${secretary2Token}`)
        .send({ authCode });

      expect(res.statusCode).toBe(200);
      expect(res.body.status).toBe('success');

      // Verify link in DB
      const link = await PracticeStaff.findOne({ where: { userId: secretary2Id, doctorId } });
      expect(link).toBeDefined();
    });

    it('should allow secretary to fetch the registry of managed patients/appointments', async () => {
      const res = await request(app)
        .get('/api/v1/staff/registry')
        .set('Authorization', `Bearer ${secretaryToken}`);

      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body.data.appointments)).toBe(true);
    });
  });

  describe('Notifications Inbox', () => {
    let notificationId;

    it('should have received a notification (from secretary signup)', async () => {
      const res = await request(app)
        .get('/api/v1/notifications')
        .set('Authorization', `Bearer ${doctorToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data.notifications.length).toBeGreaterThan(0);
      notificationId = res.body.data.notifications[0].id;
    });

    it('should allow marking a notification as read', async () => {
      const res = await request(app)
        .patch(`/api/v1/notifications/${notificationId}/read`)
        .set('Authorization', `Bearer ${doctorToken}`);

      expect(res.statusCode).toBe(200);
      
      const n = await Notification.findByPk(notificationId);
      expect(n.isRead).toBe(true);
    });

    it('should allow marking all notifications as read', async () => {
      const res = await request(app)
        .patch('/api/v1/notifications/mark-all-read')
        .set('Authorization', `Bearer ${doctorToken}`);

      expect(res.statusCode).toBe(200);
    });
  });

  describe('Analytics', () => {
    it('should allow doctor to fetch dashboard KPIs', async () => {
      const res = await request(app)
        .get('/api/v1/analytics')
        .set('Authorization', `Bearer ${doctorToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data.kpis).toBeDefined();
      expect(res.body.data.kpis.revenue).toBeDefined();
    });

    it('should allow secretary to fetch analytics for their linked doctors', async () => {
        const res = await request(app)
          .get('/api/v1/analytics')
          .set('Authorization', `Bearer ${secretaryToken}`);
  
        expect(res.statusCode).toBe(200);
        expect(res.body.data.kpis).toBeDefined();
      });
  });
});
