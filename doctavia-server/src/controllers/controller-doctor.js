const DoctorService = require('../services/service-doctor');
const BillingService = require('../services/service-billing');
const AppError = require('../utils/util-app-error');
const { Doctor } = require('../models');

exports.searchDoctors = async (req, res, next) => {
  try {
    const { specialty, date, lat, lng, radius } = req.query;
    
    const filters = { specialty, date, lat, lng, radius };
    const doctors = await DoctorService.searchDoctors(filters);

    res.status(200).json({
      status: 'success',
      results: doctors.length,
      data: { doctors }
    });
  } catch (err) {
    next(err);
  }
};

exports.getDoctor = async (req, res, next) => {
  try {
    const doctor = await DoctorService.getDoctorById(req.params.id);
    if (!doctor) {
      return next(new AppError('No doctor found with that ID', 404));
    }

    res.status(200).json({
      status: 'success',
      data: { doctor }
    });
  } catch (err) {
    next(err);
  }
};

exports.toggleFavorite = async (req, res, next) => {
  try {
    const result = await DoctorService.toggleFavorite(req.user.id, req.params.id);
    res.status(200).json({ status: 'success', data: result });
  } catch (err) {
    next(err);
  }
};

exports.getFavorites = async (req, res, next) => {
  try {
    const { User, Doctor } = require('../models');
    const user = await User.findByPk(req.user.id, {
      include: [{ 
        model: Doctor, 
        as: 'favoriteDoctors',
        through: { attributes: [] } 
      }]
    });
    
    res.status(200).json({ 
      status: 'success', 
      results: user.favoriteDoctors.length,
      data: { favorites: user.favoriteDoctors } 
    });
  } catch (err) {
    next(err);
  }
};

exports.updateMyProfile = async (req, res, next) => {
  try {
    const doctor = await DoctorService.updateProfile(req.user.id, req.body);
    res.status(200).json({ status: 'success', data: { doctor } });
  } catch (err) {
    next(err);
  }
};

exports.getRevenueStats = async (req, res, next) => {
  try {
    const doctor = await Doctor.findOne({ where: { userId: req.user.id } });
    if (!doctor) {
      return next(new AppError('Doctor profile not found for this user', 404));
    }
    
    const stats = await BillingService.getDoctorRevenueStats(doctor.id);
    res.status(200).json({ status: 'success', data: { stats } });
  } catch (err) {
    next(err);
  }
};
