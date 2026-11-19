const cron = require('node-cron');
const { Appointment, AvailabilitySlot, Doctor, Profile, User } = require('../models');
const { Op } = require('sequelize');
const NotificationService = require('../services/service-notification');

/**
 * Scheduler Service
 * PRD §10: Automated Reminders
 */
class Scheduler {
  static init() {
    console.log('⏰ Scheduler initialized...');

    // Job 1: Appointment Reminders (Every hour)
    // Sends reminders for appointments starting in exactly 24 hours (+/- 30 mins)
    cron.schedule('0 * * * *', async () => {
      console.log('🔍 Checking for upcoming appointments (24h reminder)...');
      await this.sendAppointmentReminders(24);
    });

    // Job 2: Medicine Reminders (Mock logic for daily reminders)
    cron.schedule('0 9 * * *', async () => {
      console.log('💊 Sending morning medicine reminders...');
      await this.sendMedicineReminders();
    });
  }

  static async sendAppointmentReminders(hoursAhead) {
    try {
      const targetTime = new Date(Date.now() + hoursAhead * 60 * 60 * 1000);
      const windowStart = new Date(targetTime.getTime() - 30 * 60 * 1000);
      const windowEnd = new Date(targetTime.getTime() + 30 * 60 * 1000);

      const appointments = await Appointment.findAll({
        where: {
          status: 'confirmed',
          startTimeSnapshot: {
            [Op.between]: [windowStart, windowEnd]
          }
        },
        include: [
          { model: Profile, as: 'patient' },
          { model: AvailabilitySlot, include: [Doctor] }
        ]
      });

      console.log(`Found ${appointments.length} appointments for ${hoursAhead}h reminder.`);

      for (const appt of appointments) {
        await NotificationService.notify(
          appt.bookedById,
          'Appointment Reminder',
          `Friendly reminder: You have an appointment tomorrow at ${appt.startTimeSnapshot.toLocaleTimeString()} with Dr. ${appt.AvailabilitySlot.Doctor.id}.`
        );
      }
    } catch (error) {
      console.error('Error in appointment reminder job:', error);
    }
  }

  static async sendMedicineReminders() {
    try {
      const { Prescription } = require('../models');
      const activePrescriptions = await Prescription.findAll({
        where: { status: 'active' },
        include: [{ model: Profile }]
      });

      for (const rx of activePrescriptions) {
        if (rx.Profile && rx.Profile.accountId) {
          await NotificationService.notify(
            rx.Profile.accountId,
            'Medicine Reminder',
            `It's time for your medication: ${rx.medicationName} (${rx.dosage}). Instructions: ${rx.instructions}`
          );
        }
      }
    } catch (error) {
      console.error('Error in medicine reminder job:', error);
    }
  }
}

module.exports = Scheduler;
