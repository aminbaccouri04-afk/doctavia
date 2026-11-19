const sequelize = require('../config/database');
const User = require('./model-user');
const Profile = require('./model-profile');
const Doctor = require('./model-doctor');
const Location = require('./model-location');
const Specialty = require('./model-specialty');
const AvailabilitySlot = require('./model-availability-slot');
const Appointment = require('./model-appointment');
const MedicalRecord = require('./model-medical-record');
const ConsultationNote = require('./model-consultation-note');
const Review = require('./model-review');
const Notification = require('./model-notification');
const PracticeStaff = require('./model-practice-staff');
const DrLocation = require('./model-dr-location');
const Favorite = require('./model-favorite');
const Prescription = require('./model-prescription');
const Invoice = require('./model-invoice');
const Reminder = require('./model-reminder');
const Offering = require('./model-offering');
const Category = require('./model-category');
const Equipment = require('./model-equipment');
const Language = require('./model-language');
const DoctorCategory = require('./model-doctor-category');
const DoctorEquipment = require('./model-doctor-equipment');
const DoctorLanguage = require('./model-doctor-language');
const DoctorSpecialty = require('./model-doctor-specialty');
const WorkingHour = require('./model-working-hour');

// User & Profiles
User.hasMany(Profile, { foreignKey: 'accountId', as: 'profiles' });
Profile.belongsTo(User, { foreignKey: 'accountId' });

// User & Doctor
User.hasOne(Doctor, { foreignKey: 'userId', as: 'doctorProfile' });
Doctor.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// Working Hours
Doctor.hasMany(WorkingHour, { foreignKey: 'doctorId', as: 'workingHours' });
WorkingHour.belongsTo(Doctor, { foreignKey: 'doctorId' });

// Practice Staff (Secretary delegation)
User.belongsToMany(Doctor, { through: PracticeStaff, as: 'managedDoctors', foreignKey: 'userId' });
Doctor.belongsToMany(User, { through: PracticeStaff, as: 'staff', foreignKey: 'doctorId' });

// Doctor & Locations
Doctor.belongsToMany(Location, { through: DrLocation, as: 'offices', foreignKey: 'doctor_id' });
Location.belongsToMany(Doctor, { through: DrLocation, as: 'physicians', foreignKey: 'location_id' });

// Availability & Appointments
Doctor.hasMany(AvailabilitySlot, { foreignKey: 'doctorId', as: 'schedule' });
AvailabilitySlot.belongsTo(Doctor, { foreignKey: 'doctorId' });

AvailabilitySlot.hasOne(Appointment, { foreignKey: 'slotId' });
Appointment.belongsTo(AvailabilitySlot, { foreignKey: 'slotId' });

// Offerings
Doctor.hasMany(Offering, { foreignKey: 'doctorId', as: 'offerings' });
Offering.belongsTo(Doctor, { foreignKey: 'doctorId' });

Appointment.belongsTo(Offering, { foreignKey: 'offeringId', as: 'offering' });
Offering.hasMany(Appointment, { foreignKey: 'offeringId' });

// Appointments & Profiles
Profile.hasMany(Appointment, { foreignKey: 'patientProfileId', as: 'appointments' });
Appointment.belongsTo(Profile, { foreignKey: 'patientProfileId', as: 'patient' });

User.hasMany(Appointment, { foreignKey: 'bookedById', as: 'bookings' });
Appointment.belongsTo(User, { foreignKey: 'bookedById', as: 'booker' });

// Clinical & Feedback
Appointment.hasOne(ConsultationNote, { foreignKey: 'appointmentId', as: 'notes' });
ConsultationNote.belongsTo(Appointment, { foreignKey: 'appointmentId' });

Appointment.hasOne(Review, { foreignKey: 'appointmentId', as: 'review' });
Review.belongsTo(Appointment, { foreignKey: 'appointmentId' });

// Prescriptions
Appointment.hasMany(Prescription, { foreignKey: 'appointmentId', as: 'prescriptions' });
Prescription.belongsTo(Appointment, { foreignKey: 'appointmentId' });

Doctor.hasMany(Prescription, { foreignKey: 'doctorId', as: 'prescriptionsIssued' });
Prescription.belongsTo(Doctor, { foreignKey: 'doctorId' });

Profile.hasMany(Prescription, { foreignKey: 'patientProfileId', as: 'prescriptions' });
Prescription.belongsTo(Profile, { foreignKey: 'patientProfileId' });

// Records & Notifications
Profile.hasMany(MedicalRecord, { foreignKey: 'profileId', as: 'medicalVault' });
MedicalRecord.belongsTo(Profile, { foreignKey: 'profileId' });

User.hasMany(Notification, { foreignKey: 'userId', as: 'notifications' });
Notification.belongsTo(User, { foreignKey: 'userId' });

// Favorites
User.belongsToMany(Doctor, { through: Favorite, as: 'favoriteDoctors', foreignKey: 'userId' });
Doctor.belongsToMany(User, { through: Favorite, as: 'favoritedBy', foreignKey: 'doctorId' });

// Doctor Associations (Relational instead of JSON)
Doctor.belongsToMany(Category, { through: DoctorCategory, as: 'categories', foreignKey: 'doctor_id' });
Category.belongsToMany(Doctor, { through: DoctorCategory, as: 'physicians', foreignKey: 'category_id' });

Doctor.belongsToMany(Equipment, { through: DoctorEquipment, as: 'equipment', foreignKey: 'doctor_id' });
Equipment.belongsToMany(Doctor, { through: DoctorEquipment, as: 'physicians', foreignKey: 'equipment_id' });

Doctor.belongsToMany(Language, { through: DoctorLanguage, as: 'languages', foreignKey: 'doctor_id' });
Language.belongsToMany(Doctor, { through: DoctorLanguage, as: 'speakers', foreignKey: 'language_id' });

Doctor.belongsToMany(Specialty, { through: DoctorSpecialty, as: 'specialties', foreignKey: 'doctor_id' });
Specialty.belongsToMany(Doctor, { through: DoctorSpecialty, as: 'physicians', foreignKey: 'specialty_id' });

// Invoices
Appointment.hasOne(Invoice, { foreignKey: 'appointmentId', as: 'invoice' });
Invoice.belongsTo(Appointment, { foreignKey: 'appointmentId' });

Profile.hasMany(Invoice, { foreignKey: 'patientProfileId', as: 'invoices' });
Invoice.belongsTo(Profile, { foreignKey: 'patientProfileId' });

Doctor.hasMany(Invoice, { foreignKey: 'doctorId', as: 'invoices' });
Invoice.belongsTo(Doctor, { foreignKey: 'doctorId' });

// Reminders
User.hasMany(Reminder, { foreignKey: 'userId', as: 'reminders' });
Reminder.belongsTo(User, { foreignKey: 'userId' });

Prescription.hasOne(Reminder, { foreignKey: 'prescriptionId', as: 'reminder' });
Reminder.belongsTo(Prescription, { foreignKey: 'prescriptionId' });

module.exports = {
  sequelize,
  User,
  Profile,
  Doctor,
  Location,
  Specialty,
  AvailabilitySlot,
  Appointment,
  MedicalRecord,
  ConsultationNote,
  Review,
  Notification,
  PracticeStaff,
  DrLocation,
  Favorite,
  Prescription,
  Invoice,
  Reminder,
  Offering,
  WorkingHour,
  Category,
  Equipment,
  Language,
  DoctorCategory,
  DoctorEquipment,
  DoctorLanguage,
  DoctorSpecialty
};
