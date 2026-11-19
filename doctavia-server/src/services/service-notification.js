const { Notification } = require('../models');

/**
 * NotificationService (PRD §2)
 * Centralized service to trigger system notifications.
 */
class NotificationService {
  /**
   * Helper to create a notification for a user.
   */
  static async notify(userId, title, message) {
    try {
      return await Notification.create({
        userId,
        title,
        message,
        isRead: false
      });
    } catch (error) {
      console.error('Failed to create notification:', error);
    }
  }

  /**
   * Triggers dual notifications for appointment events.
   */
  static async notifyAppointment(patientUserId, doctorUserId, title, message) {
    return Promise.all([
      this.notify(patientUserId, title, message),
      this.notify(doctorUserId, title, message)
    ]);
  }
}

module.exports = NotificationService;
