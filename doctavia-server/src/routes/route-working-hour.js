const express = require('express');
const workingHourController = require('../controllers/controller-working-hour');
const { protect, restrictTo } = require('../middleware/middleware-auth');

const router = express.Router();

// All routes are protected and restricted to doctors
router.use(protect);
router.use(restrictTo('doctor'));

router.get('/', workingHourController.getWorkingHours);
router.put('/', workingHourController.updateWorkingHours);
router.post('/generate-slots', workingHourController.generateSlots);

module.exports = router;
