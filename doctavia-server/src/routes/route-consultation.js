const express = require('express');
const consultationController = require('../controllers/controller-consultation');
const { protect } = require('../middleware/middleware-auth');

const router = express.Router();

router.use(protect);

// Clinical actions (Doctor only - in high security mode, we'd add restrictTo('doctor'))
router.post('/:appointmentId/save', consultationController.saveConsultation);
router.get('/:appointmentId', consultationController.getConsultationDetails);

// Prescription viewer (Patient / Doctor / Secretary)
router.get('/prescriptions/:profileId', consultationController.getPatientPrescriptions);

module.exports = router;
