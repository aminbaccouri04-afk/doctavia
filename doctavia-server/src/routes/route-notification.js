const express = require('express');
const notificationController = require('../controllers/controller-notification');
const authMiddleware = require('../middleware/middleware-auth');

const router = express.Router();

router.use(authMiddleware.protect);

router.get('/', notificationController.getMyNotifications);
router.patch('/mark-all-read', notificationController.markAllAsRead);
router.patch('/:id/read', notificationController.markAsRead);

module.exports = router;
