const { AvailabilitySlot, Doctor } = require('../models');
const AppError = require('../utils/util-app-error');

class AvailabilityService {
  static async createSlots(userId, slots) {
    const doctor = await Doctor.findOne({ where: { userId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    const mappedSlots = slots.map(slot => ({
      ...slot,
      doctorId: doctor.id
    }));

    return await AvailabilitySlot.bulkCreate(mappedSlots);
  }

  /**
   * Deletes an availability slot if it's not already booked.
   * PRD §3 Logic: "Doctors cannot delete slots with active bookings..."
   */
  static async deleteSlot(userId, slotId) {
    const doctor = await Doctor.findOne({ where: { userId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    const slot = await AvailabilitySlot.findOne({ where: { id: slotId, doctorId: doctor.id } });
    if (!slot) throw new AppError('Slot not found', 404);

    if (slot.isBooked) {
      throw new AppError('Cannot delete a slot that has an active booking. Please cancel the appointment first.', 400);
    }

    await slot.destroy();
  }
}

module.exports = AvailabilityService;
