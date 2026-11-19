const { Doctor, PracticeStaff, User } = require('../models');
const AppError = require('../utils/util-app-error');
const crypto = require('crypto');
const NotificationService = require('./service-notification');

class StaffService {
  static async generateCode(userId) {
    const doctor = await Doctor.findOne({ where: { userId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    const authCode = crypto.randomBytes(4).toString('hex').toUpperCase(); // E.g., 'A1B2C3D4'
    const authCodeExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

    await doctor.update({ authCode, authCodeExpiresAt });
    return authCode;
  }

  static async linkSecretary(userId, authCode) {
    const doctor = await Doctor.findOne({ where: { authCode } });
    if (!doctor || new Date() > new Date(doctor.authCodeExpiresAt)) {
      throw new AppError('Invalid or expired authorization code', 400);
    }

    const membership = await PracticeStaff.create({
      userId,
      doctorId: doctor.id
    });
    
    // PRD §2: Notify Doctor of new staff member
    await NotificationService.notify(
      doctor.userId,
      'New Staff Member',
      'A new secretary has linked to your practice and can now manage your schedule.'
    );

    return membership;
  }

  static async getRegistry(secretaryUserId) {
    const { Appointment, AvailabilitySlot, Profile } = require('../models');
    
    // 1. Find all doctors linked to this secretary
    const managedLinks = await PracticeStaff.findAll({ where: { userId: secretaryUserId } });
    const doctorIds = managedLinks.map(l => l.doctorId);

    if (doctorIds.length === 0) return [];

    // 2. Fetch appointments for these doctors with Doctor Context
    const appointments = await Appointment.findAll({
      include: [
        { 
          model: AvailabilitySlot, 
          where: { doctorId: doctorIds },
          required: true,
          include: [{
            model: Doctor,
            include: [{
              model: User,
              as: 'user',
              include: [{
                model: Profile,
                as: 'profiles',
                where: { relationship: 'Self' },
                required: false
              }]
            }]
          }]
        },
        { model: Profile, as: 'patient' }
      ],
      order: [['startTimeSnapshot', 'ASC']]
    });

    // 3. Map to consistent structure for frontend
    const results = appointments.map(a => {
      const appt = a.toJSON();
      
      // Extract Doctor Name
      const user = a.AvailabilitySlot?.Doctor?.User;
      const doctorProfile = user?.profiles?.[0];
      
      return {
        ...appt,
        doctor: {
          fullName: doctorProfile?.fullName || 'Doctor'
        },
        patientName: appt.patient?.fullName
      };
    });

    return results;
  }

  static async getMembers(doctorUserId) {
    const { Profile } = require('../models');
    const doctor = await Doctor.findOne({ where: { userId: doctorUserId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    const members = await PracticeStaff.findAll({
      where: { doctorId: doctor.id },
      include: [{
        model: User,
        include: [{
          model: Profile,
          as: 'profiles',
          where: { relationship: 'Self' },
          required: false
        }]
      }]
    });

    return members.map(m => ({
      id: m.userId,
      email: m.User?.email,
      fullName: m.User?.profiles?.[0]?.fullName || 'Secretary',
      linkedAt: m.createdAt
    }));
  }

  static async removeMember(doctorUserId, staffUserId) {
    const doctor = await Doctor.findOne({ where: { userId: doctorUserId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    await PracticeStaff.destroy({
      where: {
        doctorId: doctor.id,
        userId: staffUserId
      }
    });
  }
}

module.exports = StaffService;
