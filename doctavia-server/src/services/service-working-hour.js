const { WorkingHour, Doctor, AvailabilitySlot } = require('../models');
const AppError = require('../utils/util-app-error');
const { Op } = require('sequelize');

class WorkingHourService {
  /**
   * Retrieves all working hours for a doctor.
   */
  static async getWorkingHours(userId) {
    const doctor = await Doctor.findOne({ where: { userId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    return await WorkingHour.findAll({
      where: { doctorId: doctor.id },
      order: [['dayOfWeek', 'ASC']]
    });
  }

  /**
   * Updates or creates working hours for a doctor.
   * Expects an array of working hour objects.
   */
  static async updateWorkingHours(userId, workingHours) {
    const doctor = await Doctor.findOne({ where: { userId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    // Using a transaction to ensure atomic update
    const transaction = await WorkingHour.sequelize.transaction();

    try {
      // Delete existing working hours
      await WorkingHour.destroy({
        where: { doctorId: doctor.id },
        transaction
      });

      // Bulk create new working hours
      const mappedHours = workingHours.map(wh => ({
        ...wh,
        doctorId: doctor.id
      }));

      const createdHours = await WorkingHour.bulkCreate(mappedHours, { transaction });
      
      await transaction.commit();
      return createdHours;
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }

  /**
   * Generates availability slots for a range of dates based on working hours.
   * This is a utility that can be triggered manually or via a cron job.
   */
  static async generateSlotsFromWorkingHours(userId, startDate, endDate, slotDurationMinutes = 30) {
    const doctor = await Doctor.findOne({ 
      where: { userId },
      include: [{ model: WorkingHour, as: 'workingHours' }]
    });

    if (!doctor) throw new AppError('Doctor profile not found', 404);
    if (!doctor.workingHours || doctor.workingHours.length === 0) {
      throw new AppError('No working hours defined for this doctor.', 400);
    }

    const start = new Date(startDate);
    const end = new Date(endDate);
    const slotsToCreate = [];

    // Iterate through each day in the range
    for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
      const dayOfWeek = d.getDay();
      const configs = doctor.workingHours.filter(wh => wh.dayOfWeek === dayOfWeek);

      for (const config of configs) {
        if (!config || config.isClosed || !config.startTime || !config.endTime) continue;

        // Parse start and end times for the current day
        const [startH, startM] = config.startTime.split(':').map(Number);
        const [endH, endM] = config.endTime.split(':').map(Number);

        const dayStartTime = new Date(d);
        dayStartTime.setHours(startH, startM, 0, 0);

        const dayEndTime = new Date(d);
        dayEndTime.setHours(endH, endM, 0, 0);

        // Generate slots
        let currentSlotStart = new Date(dayStartTime);
        while (currentSlotStart < dayEndTime) {
          const currentSlotEnd = new Date(currentSlotStart);
          currentSlotEnd.setMinutes(currentSlotEnd.getMinutes() + slotDurationMinutes);

          if (currentSlotEnd > dayEndTime) break;

          slotsToCreate.push({
            doctorId: doctor.id,
            startTime: new Date(currentSlotStart),
            endTime: new Date(currentSlotEnd),
            isBooked: false
          });

          currentSlotStart = new Date(currentSlotEnd);
        }
      }
    }

    if (slotsToCreate.length === 0) return [];

    // Bulk create slots, ignoring duplicates if possible (logic depends on unique constraints)
    return await AvailabilitySlot.bulkCreate(slotsToCreate, { ignoreDuplicates: true });
  }
}

module.exports = WorkingHourService;
