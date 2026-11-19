const { Location, Doctor, DrLocation } = require('../models');
const AppError = require('../utils/util-app-error');

exports.addOffice = async (req, res, next) => {
  try {
    const { address, city, latitude, longitude } = req.body;
    const doctor = await Doctor.findOne({ where: { userId: req.user.id } });

    if (!doctor) throw new AppError('Doctor profile not found', 404);

    // 1. Create or Find Location
    const [location] = await Location.findOrCreate({
      where: { address, city },
      defaults: { latitude, longitude }
    });

    // 2. Link to Doctor if not already linked
    const existingLink = await DrLocation.findOne({
      where: { doctor_id: doctor.id, location_id: location.id }
    });

    if (!existingLink) {
      await DrLocation.create({
        doctor_id: doctor.id,
        location_id: location.id
      });
    }

    res.status(201).json({
      status: 'success',
      data: { location }
    });
  } catch (err) {
    next(err);
  }
};

exports.removeOffice = async (req, res, next) => {
  try {
    const doctor = await Doctor.findOne({ where: { userId: req.user.id } });
    const locationId = req.params.locationId;

    await DrLocation.destroy({
      where: { doctor_id: doctor.id, location_id: locationId }
    });

    res.status(204).json({ status: 'success', data: null });
  } catch (err) {
    next(err);
  }
};

exports.getMyOffices = async (req, res, next) => {
  try {
    const doctor = await Doctor.findOne({ 
      where: { userId: req.user.id },
      include: [{ model: Location, as: 'offices' }]
    });

    res.status(200).json({ 
      status: 'success', 
      data: { offices: doctor.offices } 
    });
  } catch (err) {
    next(err);
  }
};
