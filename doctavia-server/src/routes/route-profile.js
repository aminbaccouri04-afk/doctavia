const express = require('express');
const profileController = require('../controllers/controller-profile');
const authMiddleware = require('../middleware/middleware-auth');

const avatarUpload = require('../middleware/middleware-avatar-upload');

const router = express.Router();

router.use(authMiddleware.protect);
router.use(authMiddleware.restrictTo('patient', 'doctor')); // allow doctors to hit this for their own profiles!

router.get('/', profileController.getMyProfiles);
router.post('/', profileController.createProfile);
router.patch('/:id', profileController.updateProfile);
router.delete('/:id', profileController.deleteProfile);
router.get('/:id/trends', profileController.getTrends);

// Avatar Route (Doctors and Patients can upload to their own profiles)
router.post('/:id/avatar', avatarUpload.single('avatar'), profileController.uploadAvatar);

module.exports = router;
