const express = require('express');
const router = express.Router();
const reminderController = require('../controllers/controller-reminder');
const authMiddleware = require('../middleware/middleware-auth');

// All reminder routes require authentication
router.use(authMiddleware.protect);

router.route('/')
  .get(reminderController.getMyReminders)
  .post(reminderController.createReminder);

router.route('/:id')
  .patch(reminderController.updateReminder)
  .delete(reminderController.deleteReminder);

module.exports = router;
