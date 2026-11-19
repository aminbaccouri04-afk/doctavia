const { Specialty } = require('../models');

exports.getSpecialties = async (req, res, next) => {
  try {
    const specialties = await Specialty.findAll({ order: [['name', 'ASC']] });
    res.status(200).json({ status: 'success', data: { specialties } });
  } catch (err) {
    next(err);
  }
};
