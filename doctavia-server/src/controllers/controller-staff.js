const StaffService = require('../services/service-staff');

exports.generateCode = async (req, res, next) => {
  try {
    const code = await StaffService.generateCode(req.user.id);
    res.status(200).json({ status: 'success', data: { authCode: code } });
  } catch (err) {
    next(err);
  }
};

exports.linkSecretary = async (req, res, next) => {
  try {
    const { authCode } = req.body;
    const link = await StaffService.linkSecretary(req.user.id, authCode);
    res.status(200).json({ status: 'success', data: { link } });
  } catch (err) {
    next(err);
  }
};

exports.getRegistry = async (req, res, next) => {
  try {
    const appointments = await StaffService.getRegistry(req.user.id);
    res.status(200).json({ status: 'success', data: { appointments } });
  } catch (err) {
    next(err);
  }
};

exports.getMembers = async (req, res, next) => {
  try {
    const members = await StaffService.getMembers(req.user.id);
    res.status(200).json({ status: 'success', data: { members } });
  } catch (err) {
    next(err);
  }
};

exports.removeMember = async (req, res, next) => {
  try {
    const { id } = req.params;
    await StaffService.removeMember(req.user.id, id);
    res.status(204).json({ status: 'success', data: null });
  } catch (err) {
    next(err);
  }
};
