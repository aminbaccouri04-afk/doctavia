const express = require('express');
const availabilityController = require('../controllers/controller-availability');
const authMiddleware = require('../middleware/middleware-auth');

const router = express.Router();

router.use(authMiddleware.protect);
router.use(authMiddleware.restrictTo('doctor'));

router.post('/', availabilityController.createSlots);
router.delete('/:id', availabilityController.deleteSlot);

module.exports = router;
