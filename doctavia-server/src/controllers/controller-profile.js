const ProfileService = require('../services/service-profile');
const AppError = require('../utils/util-app-error');

exports.getMyProfiles = async (req, res, next) => {
  try {
    const profiles = await ProfileService.getProfilesByAccount(req.user.id);
    res.status(200).json({ status: 'success', data: { profiles } });
  } catch (err) {
    next(err);
  }
};

exports.createProfile = async (req, res, next) => {
  try {
    const profile = await ProfileService.createSubProfile(req.user.id, req.body);
    res.status(201).json({ status: 'success', data: { profile } });
  } catch (err) {
    next(err);
  }
};

exports.updateProfile = async (req, res, next) => {
  try {
    const profile = await ProfileService.updateProfile(req.user.id, req.params.id, req.body);
    res.status(200).json({ status: 'success', data: { profile } });
  } catch (err) {
    next(err);
  }
};

exports.deleteProfile = async (req, res, next) => {
  try {
    await ProfileService.deleteProfile(req.user.id, req.params.id);
    res.status(204).json({ status: 'success', data: null });
  } catch (err) {
    next(err);
  }
};

exports.getTrends = async (req, res, next) => {
  try {
    const trends = await ProfileService.getProfileTrends(req.params.id);
    res.status(200).json({ status: 'success', data: { trends } });
  } catch (err) {
    next(err);
  }
};

exports.uploadAvatar = async (req, res, next) => {
  try {
    if (!req.file) {
      return next(new AppError('No avatar file uploaded', 400));
    }
    const avatarUrl = `/uploads/avatars/${req.file.filename}`;
    const profile = await ProfileService.updateProfile(req.user.id, req.params.id, { avatarUrl });
    res.status(200).json({ status: 'success', data: { avatarUrl, profile } });
  } catch (err) {
    next(err);
  }
};
