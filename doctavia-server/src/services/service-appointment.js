const { Appointment, AvailabilitySlot, sequelize, Doctor, User, Profile, ConsultationNote, PracticeStaff, Offering } = require('../models');
const AppError = require('../utils/util-app-error');
const NotificationService = require('./service-notification');

class AppointmentService {
  /**
   * Atomic Booking Logic: Ensures prevention of double-booking
   */
  static async bookAppointment(patientProfileId, bookedById, slotId, offeringId) {
    // 1. Transaction to guarantee atomicity
    const transaction = await sequelize.transaction();

    try {
      // 2. Fetch slot to check existence and copy times (Snapshotting)
      const slot = await AvailabilitySlot.findByPk(slotId, { transaction, include: [Doctor] });
      
      if (!slot) {
        throw new AppError('Slot not found', 404);
      }
      
      if (slot.isBooked) {
        throw new AppError('This slot is already booked', 400);
      }

      // 3. Atomically update the slot
      // This is the race-condition protection. If two requests hit this exact line simultaneously,
      // the `isBooked = false` clause ensures only the first one updates the row.
      const [updatedRows] = await AvailabilitySlot.update(
        { isBooked: true },
        { 
          where: { id: slotId, isBooked: false },
          transaction
        }
      );

      if (updatedRows === 0) {
        // Someone else beat us to the punch
        throw new AppError('We are sorry, but this slot was just booked by someone else.', 409);
      }

      // 4. Create the Appointment with snapshots
      const appointment = await Appointment.create({
        slotId,
        patientProfileId,
        bookedById,
        offeringId,
        startTimeSnapshot: slot.startTime,
        endTimeSnapshot: slot.endTime,
        status: 'confirmed'
      }, { transaction });

      await transaction.commit();

      // PRD §2: Notify Doctor of new booking
      await NotificationService.notify(
        slot.Doctor.userId,
        'New Appointment',
        `You have a new appointment on ${slot.startTime.toLocaleString()}.`
      );

      return appointment;

    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }

  static async getPatientAppointments(userId) {
    const appointments = await Appointment.findAll({
      where: { bookedById: userId },
      include: [
        { 
          model: AvailabilitySlot, 
          include: [{ 
            model: Doctor, 
            include: [{ 
              model: User, 
              as: 'user',
              attributes: ['email'],
              include: [{ 
                model: Profile, 
                as: 'profiles', 
                attributes: ['fullName', 'avatarUrl'],
                where: { relationship: 'Self' }, 
                required: false 
              }]
            }] 
          }] 
        },
        { model: Profile, as: 'patient' },
        { model: Offering, as: 'offering' }
      ],
      order: [['startTimeSnapshot', 'ASC']]
    });
    return appointments;
  }

  /**
   * Fetches the queue for a doctor.
   */
  static async getDoctorAppointments(doctorUserId) {
    const doctor = await Doctor.findOne({ where: { userId: doctorUserId } });
    if (!doctor) throw new AppError('Doctor profile not found', 404);

    const appointments = await Appointment.findAll({
      include: [
        { 
          model: AvailabilitySlot, 
          where: { doctorId: doctor.id },
          required: true 
        },
        { model: Profile, as: 'patient' },
        { model: Offering, as: 'offering' }
      ],
      order: [['startTimeSnapshot', 'ASC']]
    });
    return appointments;
  }

  /**
   * Cancels an appointment and opens back the slot.
   * Logs action in AuditLog.
   */
  static async cancelAppointment(appointmentId, actorId, reason) {
    const transaction = await sequelize.transaction();

    try {
      const appointment = await Appointment.findByPk(appointmentId, { transaction });
      if (!appointment) throw new AppError('Appointment not found', 404);
      if (appointment.status === 'cancelled') throw new AppError('Appointment is already cancelled', 400);

      // Re-open the slot
      if (appointment.slotId) {
        await AvailabilitySlot.update(
          { isBooked: false },
          { where: { id: appointment.slotId }, transaction }
        );
      }

      await appointment.update({
        status: 'cancelled',
        cancelledById: actorId,
        cancellationReason: reason
      }, { transaction });

      await transaction.commit();

      // PRD §2: Trigger Notifications
      const fullAppointment = await Appointment.findByPk(appointmentId, { 
        include: [{ model: AvailabilitySlot, include: [Doctor] }] 
      });
      await NotificationService.notifyAppointment(
        fullAppointment.bookedById,
        fullAppointment.AvailabilitySlot.Doctor.userId,
        'Appointment Cancelled',
        `The appointment at ${fullAppointment.startTimeSnapshot.toLocaleString()} has been cancelled.`
      );

      return appointment;
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }

  /**
   * Add consultation notes for an appointment (Doctor only)
   */
  static async addConsultationNotes(appointmentId, doctorUserId, noteData) {
    const { patientSummary, internalNotes } = noteData;

    const appointment = await Appointment.findByPk(appointmentId);
    if (!appointment) throw new AppError('Appointment not found', 404);

    // Verify doctor owns this appointment via slot
    const doctor = await Doctor.findOne({ where: { userId: doctorUserId } });
    if (!doctor) throw new AppError('Doctor not found', 404);

    const slot = await AvailabilitySlot.findByPk(appointment.slotId);
    if (!slot || slot.doctorId !== doctor.id) {
      throw new AppError('Not authorized to add notes to this appointment', 403);
    }

    // Save or Update SOAP Note
    let [note, created] = await ConsultationNote.findOrCreate({
      where: { appointmentId },
      defaults: {
        patientSummary, internalNotes
      }
    });

    if (!created) {
      await note.update({ patientSummary, internalNotes });
    }

    return note;
  }

  /**
   * Finalizes an appointment (Doctor only)
   */
  static async completeAppointment(appointmentId, doctorId) {
    const appointment = await Appointment.findByPk(appointmentId);
    if (!appointment) throw new AppError('Appointment not found', 404);

    // Verify doctor owns this appointment
    const doctor = await Doctor.findOne({ where: { userId: doctorId } });
    if (!doctor) throw new AppError('Doctor not found', 404);

    const slot = await AvailabilitySlot.findByPk(appointment.slotId);
    if (!slot || slot.doctorId !== doctor.id) {
      throw new AppError('Not authorized to complete this appointment', 403);
    }

    await appointment.update({ status: 'completed' });
    
    // PRD §9: Generate Invoice automatically
    const BillingService = require('./service-billing');
    await BillingService.generateInvoice(appointmentId);

    // PRD §2: Notify Patient
    await NotificationService.notify(
      appointment.bookedById,
      'Consultation Completed',
      'The summary of your visit is now available in your medical records.'
    );

    return appointment;
  }

  /**
   * Marks a patient as checked-in (Doctor or Secretary)
   */
  static async checkInAppointment(appointmentId, actorUserId) {
    const appointment = await Appointment.findByPk(appointmentId, {
      include: [{ model: AvailabilitySlot, include: [Doctor] }]
    });
    if (!appointment) throw new AppError('Appointment not found', 404);

    // Verify actor is either the doctor or a linked secretary
    const actor = await User.findByPk(actorUserId);
    const doctor = appointment.AvailabilitySlot.Doctor;
    
    if (actor.role === 'secretary') {
      const isLinked = await PracticeStaff.findOne({ where: { userId: actorUserId, doctorId: doctor.id }});
      if (!isLinked) throw new AppError('Not authorized to manage this doctor\'s patients', 403);
    } else if (actor.id !== doctor.userId) {
      throw new AppError('Not authorized to manage this appointment', 403);
    }

    await appointment.update({ status: 'checked_in' });
    return appointment;
  }

  /**
   * Starts the formal consultation (Doctor only)
   */
  static async startConsultation(appointmentId, doctorUserId) {
    const appointment = await Appointment.findByPk(appointmentId, {
      include: [{ model: AvailabilitySlot, include: [Doctor] }]
    });
    if (!appointment) throw new AppError('Appointment not found', 404);

    if (appointment.AvailabilitySlot.Doctor.userId !== doctorUserId) {
      throw new AppError('Not authorized to start this consultation', 403);
    }

    await appointment.update({ status: 'in_progress' });
    
    // Notify Patient to join
    await NotificationService.notify(
      appointment.bookedById,
      'Consultation Started',
      'Your doctor is ready! Please join the waiting room or consultation link.'
    );

    return appointment;
  }
}

module.exports = AppointmentService;
