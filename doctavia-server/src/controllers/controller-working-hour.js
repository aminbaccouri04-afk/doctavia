const workingHourService = require('../services/service-working-hour');

exports.getWorkingHours = async (req, res, next) => {
  try {
    const workingHours = await workingHourService.getWorkingHours(req.user.id);
    res.status(200).json({
      status: 'success',
      data: workingHours
    });
  } catch (err) {
    next(err);
  }
};

exports.updateWorkingHours = async (req, res, next) => {
  try {
    const workingHours = await workingHourService.updateWorkingHours(req.user.id, req.body.workingHours);
    res.status(200).json({
      status: 'success',
      data: workingHours
    });
  } catch (err) {
    next(err);
  }
};

exports.generateSlots = async (req, res, next) => {
  try {
    const { startDate, endDate, slotDurationMinutes } = req.body;
    const slots = await workingHourService.generateSlotsFromWorkingHours(
      req.user.id, 
      startDate, 
      endDate, 
      slotDurationMinutes
    );
    
    res.status(201).json({
      status: 'success',
      results: slots.length,
      data: slots
    });
  } catch (err) {
    next(err);
  }
};
