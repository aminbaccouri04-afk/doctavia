const OfferingService = require('../services/service-offering');

exports.getMyOfferings = async (req, res, next) => {
  try {
    const { Doctor } = require('../models');
    const doctor = await Doctor.findOne({ where: { userId: req.user.id } });
    if (!doctor) {
      return res.status(200).json({ status: 'success', data: { offerings: [] } });
    }

    const offerings = await OfferingService.getDoctorOfferings(doctor.id);
    res.status(200).json({
      status: 'success',
      results: offerings.length,
      data: { offerings }
    });
  } catch (err) {
    next(err);
  }
};

exports.createOffering = async (req, res, next) => {
  try {
    const offering = await OfferingService.createOffering(req.user.id, req.body);
    res.status(201).json({ status: 'success', data: { offering } });
  } catch (err) {
    next(err);
  }
};

exports.updateOffering = async (req, res, next) => {
  try {
    const offering = await OfferingService.updateOffering(req.params.id, req.user.id, req.body);
    res.status(200).json({ status: 'success', data: { offering } });
  } catch (err) {
    next(err);
  }
};

exports.deleteOffering = async (req, res, next) => {
  try {
    await OfferingService.deleteOffering(req.params.id, req.user.id);
    res.status(204).json({ status: 'success', data: null });
  } catch (err) {
    next(err);
  }
};
