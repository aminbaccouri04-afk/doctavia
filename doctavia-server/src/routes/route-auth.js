const express = require('express');
const authController = require('../controllers/controller-auth');
const { protect } = require('../middleware/middleware-auth');

const router = express.Router();

router.post('/signup', authController.signup);
router.post('/login', authController.login);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);

router.patch('/change-password', protect, authController.changePassword);

module.exports = router;
