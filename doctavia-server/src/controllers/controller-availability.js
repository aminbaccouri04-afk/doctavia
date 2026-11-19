const AvailabilityService = require('../services/service-availability');

exports.createSlots = async (req, res, next) => {
  try {
    const { slots } = req.body; // Array of { startTime, endTime }
    const createdSlots = await AvailabilityService.createSlots(req.user.id, slots);
    
    res.status(201).json({ status: 'success', data: { slots: createdSlots } });
  } catch (err) {
    next(err);
  }
};

exports.deleteSlot = async (req, res, next) => {
  try {
    await AvailabilityService.deleteSlot(req.user.id, req.params.id);
    res.status(204).json({ status: 'success', data: null });
  } catch (err) {
    next(err);
  }
};
