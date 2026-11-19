const { Offering, Doctor } = require('../models');
const AppError = require('../utils/util-app-error');

class OfferingService {
  /**
   * Get all offerings for a specific doctor
   */
  static async getDoctorOfferings(doctorId) {
    return await Offering.findAll({ where: { doctorId } });
  }

  /**
   * Create a new offering for a doctor
   */
  static async createOffering(doctorUserId, data) {
    const doctor = await Doctor.findOne({ where: { userId: doctorUserId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    return await Offering.create({
      ...data,
      doctorId: doctor.id
    });
  }

  /**
   * Update an existing offering
   */
  static async updateOffering(offeringId, doctorUserId, data) {
    const doctor = await Doctor.findOne({ where: { userId: doctorUserId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    const offering = await Offering.findOne({ where: { id: offeringId, doctorId: doctor.id } });
    if (!offering) throw new AppError('Offering not found or you do not have permission', 404);

    return await offering.update(data);
  }

  /**
   * Delete an offering
   */
  static async deleteOffering(offeringId, doctorUserId) {
    const doctor = await Doctor.findOne({ where: { userId: doctorUserId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    const offering = await Offering.findOne({ where: { id: offeringId, doctorId: doctor.id } });
    if (!offering) throw new AppError('Offering not found or you do not have permission', 404);

    await offering.destroy();
    return true;
  }
}

module.exports = OfferingService;
