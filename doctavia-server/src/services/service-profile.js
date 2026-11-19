const { Profile, Appointment, ConsultationNote } = require('../models');
const AppError = require('../utils/util-app-error');

class ProfileService {
  static async getProfileTrends(profileId) {
    const appointments = await Appointment.findAll({
      where: { patientProfileId: profileId },
      include: [{
        model: ConsultationNote,
        as: 'notes',
        required: true
      }],
      order: [['created_at', 'ASC']]
    });

    const trends = [];
    appointments.forEach(app => {
      const vitals = app.notes.vitals;
      if (vitals) {
        const date = app.createdAt || app.created_at;
        
        if (vitals.bp) {
          const parts = vitals.bp.split('/');
          if (parts.length === 2) {
            trends.push({ type: 'BP (Systolic)', value: parseFloat(parts[0]), unit: 'mmHg', date });
            trends.push({ type: 'BP (Diastolic)', value: parseFloat(parts[1]), unit: 'mmHg', date });
          }
        }
        if (vitals.hr) trends.push({ type: 'Heart Rate', value: parseFloat(vitals.hr), unit: 'bpm', date });
        if (vitals.temp) trends.push({ type: 'Temperature', value: parseFloat(vitals.temp), unit: '°C', date });
        if (vitals.weight) trends.push({ type: 'Weight', value: parseFloat(vitals.weight), unit: 'kg', date });
      }
    });

    return trends;
  }

  static async getProfilesByAccount(accountId) {
    return await Profile.findAll({ where: { accountId } });
  }

  static async createSubProfile(accountId, profileData) {
    const { fullName, dateOfBirth, relationship } = profileData;
    if (relationship === 'Self') {
      throw new AppError('A Self profile already exists for this account', 400);
    }
    return await Profile.create({ accountId, fullName, dateOfBirth, relationship });
  }

  static async updateProfile(accountId, profileId, updates) {
    const profile = await Profile.findOne({ where: { id: profileId, accountId } });
    if (!profile) throw new AppError('Profile not found or access denied', 404);
    // Prevent changing a Self profile's relationship type
    if (profile.relationship === 'Self' && updates.relationship && updates.relationship !== 'Self') {
      throw new AppError('Cannot change the relationship of the primary Self profile', 400);
    }
    await profile.update(updates);
    return profile;
  }

  static async deleteProfile(accountId, profileId) {
    const profile = await Profile.findOne({ where: { id: profileId, accountId } });
    if (!profile) throw new AppError('Profile not found or access denied', 404);
    if (profile.relationship === 'Self') {
      throw new AppError('Cannot delete the primary account profile', 400);
    }
    await profile.destroy();
  }
}

module.exports = ProfileService;
