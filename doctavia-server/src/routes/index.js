const express = require('express');
const authRoutes = require('./route-auth');
const profileRoutes = require('./route-profile');
const medicalRecordRoutes = require('./route-medical-record');
const doctorRoutes = require('./route-doctor');
const appointmentRoutes = require('./route-appointment');
const availabilityRoutes = require('./route-availability');
const workingHourRoutes = require('./route-working-hour');
const staffRoutes = require('./route-staff');
const analyticsRoutes = require('./route-analytics');
const reviewRoutes = require('./route-review');
const notificationRoutes = require('./route-notification');
const specialtyRoutes = require('./route-specialty');
const consultationRoutes = require('./route-consultation');
const billingRoutes = require('./route-billing');
const reminderRoutes = require('./route-reminder');
const offeringRoutes = require('./route-offering');

const router = express.Router();

router.use('/auth', authRoutes);
router.use('/profiles', profileRoutes);
router.use('/records', medicalRecordRoutes);
router.use('/doctors', doctorRoutes);
router.use('/appointments', appointmentRoutes);
router.use('/availability', availabilityRoutes);
router.use('/working-hours', workingHourRoutes);
router.use('/staff', staffRoutes);
router.use('/analytics', analyticsRoutes);
router.use('/reviews', reviewRoutes);
router.use('/notifications', notificationRoutes);
router.use('/lookup/specialties', specialtyRoutes);
router.use('/consultations', consultationRoutes);
router.use('/billing', billingRoutes);
router.use('/reminders', reminderRoutes);
router.use('/offerings', offeringRoutes);

module.exports = router;
