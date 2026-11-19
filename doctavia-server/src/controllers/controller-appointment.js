const AppointmentService = require('../services/service-appointment');

exports.bookAppointment = async (req, res, next) => {
  try {
    const { slotId, patientProfileId, offeringId } = req.body;
    const bookedById = req.user.id;
    const appointment = await AppointmentService.bookAppointment(patientProfileId, bookedById, slotId, offeringId);

    res.status(201).json({
      status: 'success',
      data: { appointment }
    });
  } catch (err) {
    next(err);
  }
};

exports.getMyBookings = async (req, res, next) => {
  try {
    let appointments;
    if (req.user.role === 'doctor' || req.user.role === 'secretary') {
      // For simplicity, we assume secretary uses doctorUserId from query or logic
      // In this PRD, for dashboard view, we fetch for the logged-in doctor
      appointments = await AppointmentService.getDoctorAppointments(req.user.id);
    } else {
      appointments = await AppointmentService.getPatientAppointments(req.user.id);
    }

    const formattedAppointments = appointments.map(a => {
      const appt = a.toJSON();
      
      // Extract Doctor Name from deeply nested User -> Profiles
      const user = a.AvailabilitySlot?.Doctor?.user;
      const doctorProfile = user?.profiles?.[0];
      
      return {
        ...appt,
        doctor: {
          fullName: doctorProfile?.fullName || 'Unknown Doctor',
          avatarUrl: doctorProfile?.avatarUrl
        },
        // Patient Profile is joined directly as 'patient'
        patient: appt.patient ? {
          fullName: appt.patient.fullName,
          avatarUrl: appt.patient.avatarUrl
        } : null

      };
    });

    res.status(200).json({
      status: 'success',
      results: formattedAppointments.length,
      data: { appointments: formattedAppointments }
    });
  } catch (err) {
    next(err);
  }
};

exports.cancelAppointment = async (req, res, next) => {
  try {
    const { reason } = req.body;
    const appointment = await AppointmentService.cancelAppointment(req.params.id, req.user.id, reason);
    
    res.status(200).json({ status: 'success', data: { appointment } });
  } catch (err) {
    next(err);
  }
};

exports.completeAppointment = async (req, res, next) => {
  try {
    const appointment = await AppointmentService.completeAppointment(req.params.id, req.user.id);
    res.status(200).json({ status: 'success', data: { appointment } });
  } catch (err) {
    next(err);
  }
};

exports.checkInPatient = async (req, res, next) => {
  try {
    const appointment = await AppointmentService.checkInAppointment(req.params.id, req.user.id);
    res.status(200).json({ status: 'success', data: { appointment } });
  } catch (err) {
    next(err);
  }
};

exports.startConsultation = async (req, res, next) => {
  try {
    const appointment = await AppointmentService.startConsultation(req.params.id, req.user.id);
    res.status(200).json({ status: 'success', data: { appointment } });
  } catch (err) {
    next(err);
  }
};
