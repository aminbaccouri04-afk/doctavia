const MedicalRecordService = require('../services/service-medical-record');
const AppError = require('../utils/util-app-error');
const { Profile } = require('../models');

exports.uploadRecord = async (req, res, next) => {
  try {
    const { profileId } = req.params;
    const { description } = req.body;
    
    if (!req.file) {
      next(new AppError('No file provided', 400));
      return;
    }

    const filePath = `/uploads/medical_records/${req.file.filename}`;
    const metadata = {
      fileName: req.file.originalname,
      fileType: req.file.originalname.split('.').pop(),
      fileSize: req.file.size,
      description: description
    };

    const record = await MedicalRecordService.uploadRecord(profileId, filePath, metadata);
    
    res.status(201).json({ status: 'success', data: { record } });
  } catch (err) {
    next(err);
  }
};

exports.getRecords = async (req, res, next) => {
  try {
    const { profileId } = req.params;
    const records = await MedicalRecordService.getRecordsForProfile(profileId);


    res.status(200).json({ status: 'success', data: { records } });
  } catch (err) {
    next(err);
  }
};

exports.deleteRecord = async (req, res, next) => {
  try {
    const { id } = req.params;
    await MedicalRecordService.deleteRecord(id);
    res.status(204).json({ status: 'success', data: null });
  } catch (err) {
    next(err);
  }
};
