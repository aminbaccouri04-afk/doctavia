const { Invoice, Appointment, AvailabilitySlot, sequelize } = require('../models');
const AppError = require('../utils/util-app-error');

class BillingService {
  /**
   * Automatically generates an invoice for a completed appointment.
   * PRD §9
   */
  static async generateInvoice(appointmentId) {
    try {
      const { Offering } = require('../models');
      const appointment = await Appointment.findByPk(appointmentId, {
        include: [
          { model: AvailabilitySlot },
          { model: Offering, as: 'offering' }
        ]
      });

      if (!appointment) return;

      // Use the price from the specific offering, fallback to default if not set
      const amount = appointment.offering?.price || 50.00; 

      return await Invoice.create({
        appointmentId,
        patientProfileId: appointment.patientProfileId,
        doctorId: appointment.AvailabilitySlot.doctorId,
        amount,
        status: 'pending',
        issuedAt: new Date()
      });
    } catch (error) {
      console.error('Failed to generate invoice:', error);
    }
  }

  /**
   * Fetches revenue statistics for a doctor.
   */
  static async getDoctorRevenueStats(doctorId) {
    const stats = await Invoice.findAll({
      where: { doctorId },
      attributes: [
        [sequelize.fn('SUM', sequelize.col('amount')), 'totalRevenue'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'invoiceCount'],
        'status'
      ],
      group: ['status']
    });

    return stats;
  }
}

module.exports = BillingService;
