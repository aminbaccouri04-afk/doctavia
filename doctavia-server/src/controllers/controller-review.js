const { Review, Appointment } = require('../models');
const AppError = require('../utils/util-app-error');

exports.submitReview = async (req, res, next) => {
  try {
    const { appointmentId, rating, comment } = req.body;

    const appointment = await Appointment.findByPk(appointmentId);
    if (!appointment || appointment.status !== 'completed') {
      return next(new AppError('Reviews can only be submitted for completed appointments.', 400));
    }

    const review = await Review.create({ appointmentId, rating, comment });
    res.status(201).json({ status: 'success', data: { review } });
  } catch (err) {
    next(err);
  }
};
