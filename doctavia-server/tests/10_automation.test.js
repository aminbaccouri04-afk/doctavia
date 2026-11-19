const sequelize = require('../src/config/database');
const { clearDatabase } = require('./utils');
const { Appointment, AvailabilitySlot, Doctor, Prescription, Notification } = require('../src/models');
const Scheduler = require('../src/utils/util-scheduler');

describe('Flow 10: Automation (Background Tasks)', () => {
  beforeAll(async () => {
    await clearDatabase();
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('7.1 Appointment Alerts - should notify users of appointments 24h away', async () => {
    const { User, Profile } = require('../src/models');
    
    // Create valid doctor setup
    const drUser = await User.create({ email: 'dr.auto@test.com', password: 'pw', role: 'doctor' });
    const dr = await Doctor.create({ userId: drUser.id }); 

    // Create valid patient setup
    const user = await User.create({ email: 'auto@test.com', password: 'pw', role: 'patient' });
    const profile = await Profile.create({ accountId: user.id, fullName: 'Auto Patient', dateOfBirth: '1990-01-01' });

    // 2. Create slot 24 hours from now
    const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000);
    const slot = await AvailabilitySlot.create({ doctorId: dr.id, startTime: tomorrow, endTime: tomorrow });

    // 3. Create confirmed appointment
    await Appointment.create({
      slotId: slot.id, patientProfileId: profile.id, bookedById: user.id,
      startTimeSnapshot: tomorrow, endTimeSnapshot: tomorrow, status: 'confirmed'
    });

    // 4. Manually trigger the reminder logic
    await Scheduler.sendAppointmentReminders(24);

    // 5. Verify notification was created
    const notification = await Notification.findOne({ where: { userId: user.id, title: 'Appointment Reminder' } });
    expect(notification).toBeDefined();
  });

  it('7.2 Medicine Reminders - should notify users with active prescriptions', async () => {
    const { User, Profile } = require('../src/models');
    
    // Create valid doctor
    const drUser = await User.create({ email: 'dr.meds@test.com', password: 'pw', role: 'doctor' });
    const dr = await Doctor.create({ userId: drUser.id });

    // Create valid patient
    const user = await User.create({ email: 'meds@test.com', password: 'pw', role: 'patient' });
    const profile = await Profile.create({ accountId: user.id, fullName: 'Med Patient', dateOfBirth: '1980-01-01' });

    // Create valid slot and appointment to satisfy FK constraints
    const now = new Date();
    const slot = await AvailabilitySlot.create({ doctorId: dr.id, startTime: now, endTime: now });
    const appt = await Appointment.create({
      slotId: slot.id, patientProfileId: profile.id, bookedById: user.id,
      startTimeSnapshot: now, endTimeSnapshot: now, status: 'completed'
    });

    // 1. Create active prescription
    await Prescription.create({
      appointmentId: appt.id,
      patientProfileId: profile.id, 
      doctorId: dr.id,
      medicationName: 'Test Med',
      status: 'active',
      dosage: '1 pill',
      frequency: 'Daily',
      duration: '10 days',
      instructions: 'Take with water'
    });

    // 2. Manually trigger medicine reminders
    await Scheduler.sendMedicineReminders();

    // 3. Verify notification
    const notification = await Notification.findOne({ where: { userId: user.id, title: 'Medicine Reminder' } });
    expect(notification).toBeDefined();
  });
});
