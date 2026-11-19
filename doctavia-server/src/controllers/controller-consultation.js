const { ConsultationNote, Prescription, Appointment, AvailabilitySlot, Profile, User } = require('../models');
const AppError = require('../utils/util-app-error');

exports.saveConsultation = async (req, res, next) => {
  try {
    const { appointmentId } = req.params;
    const { subjective, objective, assessment, plan, vitals, prescriptions, internalNotes } = req.body;

    const appointment = await Appointment.findByPk(appointmentId, {
      include: [{ model: AvailabilitySlot }]
    });

    if (!appointment) {
      return next(new AppError('No appointment found with that ID', 404));
    }

    const AppointmentService = require('../services/service-appointment');

    // Combine SOAP fields into a formatted Patient Summary for the model
    const patientSummary = `
Subjective: ${subjective || 'N/A'}
Objective: ${objective || 'N/A'}
Assessment: ${assessment || 'N/A'}
Plan: ${plan || 'N/A'}
Vitals: ${vitals ? JSON.stringify(vitals) : 'N/A'}
`.trim();

    // 1. Save Notes via Service
    const note = await AppointmentService.addConsultationNotes(appointmentId, req.user.id, {
      patientSummary, internalNotes
    });
 
    // 2. Issue Prescriptions (if any)
    if (prescriptions && Array.isArray(prescriptions)) {
      // Clear old prescriptions for this appointment to avoid duplicates on update
      await Prescription.destroy({ where: { appointmentId } });
 
      const prescriptionRecords = prescriptions.map(p => ({
        appointmentId,
        doctorId: appointment.AvailabilitySlot.doctorId,
        patientProfileId: appointment.patientProfileId,
        medicationName: p.medicationName,
        dosage: p.dosage,
        frequency: p.frequency,
        duration: p.duration,
        instructions: p.instructions
      }));
 
      await Prescription.bulkCreate(prescriptionRecords);
    }
 
    // 3. Mark Appointment as Completed via Service
    // This triggers the Automated Invoicing and Notifications!
    await AppointmentService.completeAppointment(appointmentId, req.user.id);
 
    res.status(200).json({
      status: 'success',
      data: { note }
    });
  } catch (err) {
    next(err);
  }
};

exports.getConsultationDetails = async (req, res, next) => {
  try {
    const { appointmentId } = req.params;
    const note = await ConsultationNote.findOne({
      where: { appointmentId },
      include: [{
          model: Appointment,
          as: 'Appointment',
          include: [{ model: Prescription, as: 'prescriptions' }]
      }]
    });

    res.status(200).json({
      status: 'success',
      data: { note }
    });
  } catch (err) {
    next(err);
  }
};

exports.getPatientPrescriptions = async (req, res, next) => {
    try {
        // If patient role, use their own profiles. If doctor/secretary, use profileId in params.
        const profileId = req.params.profileId;
        
        const prescriptions = await Prescription.findAll({
            where: { patientProfileId: profileId },
            order: [['created_at', 'DESC']]
        });

        res.status(200).json({
            status: 'success',
            results: prescriptions.length,
            data: { prescriptions }
        });
    } catch (err) {
        next(err);
    }
};
