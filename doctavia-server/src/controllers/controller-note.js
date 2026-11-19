const { ConsultationNote, Appointment } = require('../models');
const AppError = require('../utils/util-app-error');

const AppointmentService = require('../services/service-appointment');

exports.addNote = async (req, res, next) => {
  try {
    const { appointmentId } = req.params;
    const { patientSummary, internalNotes } = req.body;
    
    const note = await AppointmentService.addConsultationNotes(
      appointmentId,
      req.user.id,
      { patientSummary, internalNotes }
    );

    res.status(201).json({ status: 'success', data: { note } });
  } catch (err) {
    next(err);
  }
};

exports.getNotes = async (req, res, next) => {
  try {
    const { appointmentId } = req.params;

    const note = await ConsultationNote.findOne({ where: { appointmentId } });
    if (!note) throw new AppError('No notes found for this appointment', 404);

    // PRD §1 & §6: Role-based access control
    // Secretaries are blocked from clinical files/notes entirely
    if (req.user.role === 'secretary') {
      throw new AppError('Secretaries do not have access to clinical notes', 403);
    }

    // PRD §1 & §4: Patients only see patient_summary, Doctors see both
    let data = { patientSummary: note.patientSummary };
    if (req.user.role === 'doctor') {
      data.internalNotes = note.internalNotes;
    }

    res.status(200).json({ status: 'success', data: { note: data } });
  } catch (err) {
    next(err);
  }
};
