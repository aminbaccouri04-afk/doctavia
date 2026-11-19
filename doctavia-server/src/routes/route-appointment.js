const express = require('express');
const appointmentController = require('../controllers/controller-appointment');
const authMiddleware = require('../middleware/middleware-auth');

const noteRoutes = require('./route-note');

const router = express.Router();

router.use(authMiddleware.protect);

// Nested routes
router.use('/:appointmentId/notes', noteRoutes);

router.post('/', appointmentController.bookAppointment);
router.get('/me', appointmentController.getMyBookings);
router.patch('/:id/cancel', appointmentController.cancelAppointment);
router.patch('/:id/complete', authMiddleware.restrictTo('doctor'), appointmentController.completeAppointment);
router.patch('/:id/check-in', authMiddleware.restrictTo('doctor', 'secretary'), appointmentController.checkInPatient);
router.patch('/:id/start', authMiddleware.restrictTo('doctor'), appointmentController.startConsultation);

module.exports = router;
