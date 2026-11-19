const { Reminder, Prescription } = require('../models');

/**
 * Reminder Controller
 * Handles CRUD for medication reminders.
 */
exports.getMyReminders = async (req, res) => {
  try {
    const reminders = await Reminder.findAll({
      where: { userId: req.user.id },
      order: [['createdAt', 'DESC']]
    });

    res.status(200).json({
      status: 'success',
      data: { reminders }
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

exports.createReminder = async (req, res) => {
  try {
    const { medicationName, dosage, frequency, times, prescriptionId } = req.body;

    const reminder = await Reminder.create({
      userId: req.user.id,
      medicationName,
      dosage,
      frequency,
      times,
      prescriptionId,
      isActive: true
    });

    res.status(201).json({
      status: 'success',
      data: { reminder }
    });
  } catch (error) {
    res.status(400).json({ status: 'error', message: error.message });
  }
};

exports.updateReminder = async (req, res) => {
  try {
    const reminder = await Reminder.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });

    if (!reminder) {
      return res.status(404).json({ status: 'fail', message: 'Reminder not found' });
    }

    const { medicationName, dosage, frequency, times, isActive } = req.body;
    
    await reminder.update({
      medicationName: medicationName || reminder.medicationName,
      dosage: dosage || reminder.dosage,
      frequency: frequency || reminder.frequency,
      times: times || reminder.times,
      isActive: isActive !== undefined ? isActive : reminder.isActive
    });

    res.status(200).json({
      status: 'success',
      data: { reminder }
    });
  } catch (error) {
    res.status(400).json({ status: 'error', message: error.message });
  }
};

exports.deleteReminder = async (req, res) => {
  try {
    const deleted = await Reminder.destroy({
      where: { id: req.params.id, userId: req.user.id }
    });

    if (!deleted) {
      return res.status(404).json({ status: 'fail', message: 'Reminder not found' });
    }

    res.status(204).json({
      status: 'success',
      data: null
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};
