const express = require('express');
const doctorController = require('../controllers/controller-doctor');
const authMiddleware = require('../middleware/middleware-auth');

const router = express.Router();

// Publicly available (or at least logged-in patient)
router.use(authMiddleware.protect);

router.get('/', doctorController.searchDoctors);
router.get('/favorites', authMiddleware.restrictTo('patient'), doctorController.getFavorites);
router.get('/:id', doctorController.getDoctor);
router.post('/:id/favorite', authMiddleware.restrictTo('patient'), doctorController.toggleFavorite);
router.put('/me', authMiddleware.restrictTo('doctor'), doctorController.updateMyProfile);
router.get('/me/revenue', authMiddleware.restrictTo('doctor'), doctorController.getRevenueStats);

// Office Management
const locationController = require('../controllers/controller-location');
router.get('/me/offices', authMiddleware.restrictTo('doctor'), locationController.getMyOffices);
router.post('/me/offices', authMiddleware.restrictTo('doctor'), locationController.addOffice);
router.delete('/me/offices/:locationId', authMiddleware.restrictTo('doctor'), locationController.removeOffice);

module.exports = router;
