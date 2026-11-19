const fs = require('fs').promises;
const path = require('path');
const { MedicalRecord, Profile } = require('../models');
const AppError = require('../utils/util-app-error');

class MedicalRecordService {
  static async uploadRecord(profileId, filePath, metadata) {
    // Verify profile exists
    const profile = await Profile.findByPk(profileId);
    if (!profile) throw new AppError('Profile not found', 404);

    return await MedicalRecord.create({ 
      profileId, 
      fileUrl: filePath, 
      fileName: metadata.fileName,
      fileType: metadata.fileType,
      fileSize: metadata.fileSize,
      description: metadata.description 
    });
  }

  static async getRecordsForProfile(profileId) {
    return await MedicalRecord.findAll({ where: { profileId } });
  }

  static async deleteRecord(recordId) {
    const record = await MedicalRecord.findByPk(recordId);
    if (!record) throw new AppError('Record not found', 404);

    // Delete physical file
    const absolutePath = path.join(__dirname, '..', record.fileUrl);
    try {
      await fs.unlink(absolutePath);
    } catch (err) {
      console.warn(`Could not delete physical file: ${absolutePath}. It might have been already removed.`);
    }

    // Delete record from DB
    await record.destroy();
  }
}

module.exports = MedicalRecordService;
