'use strict';

const users = require('./migrate-users');
const profiles = require('./migrate-profiles');
const specialties = require('./migrate-specialties');
const locations = require('./migrate-locations');
const doctors = require('./migrate-doctors');
const practiceStaff = require('./migrate-practice-staff');
const drLocations = require('./migrate-dr-locations');
const slots = require('./migrate-availability-slots');
const offerings = require('./migrate-offerings');
const appointments = require('./migrate-appointments');
const notes = require('./migrate-consultation-notes');
const reviews = require('./migrate-reviews');
const notifications = require('./migrate-notifications');
const records = require('./migrate-medical-records');
const invoices = require('./migrate-invoices');
const favorites = require('./migrate-favorites');
const prescriptions = require('./migrate-prescriptions');
const reminders = require('./migrate-reminders');
const workingHours = require('./migrate-working-hours');
const categories = require('./migrate-categories');
const equipment = require('./migrate-equipment');
const languages = require('./migrate-languages');
const doctorSpecialties = require('./migrate-doctor-specialties');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Force silence all SQL logs for a cleaner output
    queryInterface.sequelize.options.logging = console.log;

    console.log('--- Starting Migration Pipeline ---');
    
    await users.up(queryInterface, Sequelize);
    console.log('✅ Users table created');
    
    await profiles.up(queryInterface, Sequelize);
    console.log('✅ Profiles table created');
    
    await specialties.up(queryInterface, Sequelize);
    console.log('✅ Specialties table created');
    
    await locations.up(queryInterface, Sequelize);
    console.log('✅ Locations table created');
    
    await doctors.up(queryInterface, Sequelize);
    console.log('✅ Doctors table created');
    
    await practiceStaff.up(queryInterface, Sequelize);
    console.log('✅ Practice Staff table created');
    
    await drLocations.up(queryInterface, Sequelize);
    console.log('✅ Dr Locations table created');
    
    await slots.up(queryInterface, Sequelize);
    console.log('✅ Availability Slots table created');
    
    await offerings.up(queryInterface, Sequelize);
    console.log('✅ Offerings table created');
    
    await appointments.up(queryInterface, Sequelize);
    console.log('✅ Appointments table created');
    
    await notes.up(queryInterface, Sequelize);
    console.log('✅ Consultation Notes table created');
    
    await reviews.up(queryInterface, Sequelize);
    console.log('✅ Reviews table created');
    
    await notifications.up(queryInterface, Sequelize);
    console.log('✅ Notifications table created');
    
    await records.up(queryInterface, Sequelize);
    console.log('✅ Medical Records table created');
    
    await invoices.up(queryInterface, Sequelize);
    console.log('✅ Invoices table created');
    
    await favorites.up(queryInterface, Sequelize);
    console.log('✅ Favorites table created');
    
    await prescriptions.up(queryInterface, Sequelize);
    console.log('✅ Prescriptions table created');

    await reminders.up(queryInterface, Sequelize);
    console.log('✅ Reminders table created');

    await workingHours.up(queryInterface, Sequelize);
    console.log('✅ Working Hours table created');

    await categories.up(queryInterface, Sequelize);
    console.log('✅ Categories and Doctor-Categories junction tables created');

    await equipment.up(queryInterface, Sequelize);
    console.log('✅ Equipment and Doctor-Equipment junction tables created');

    await languages.up(queryInterface, Sequelize);
    console.log('✅ Languages and Doctor-Languages junction tables created');

    await doctorSpecialties.up(queryInterface, Sequelize);
    console.log('✅ Doctor-Specialties junction table created');

    console.log('--- Migration Pipeline Finished Successfully ---');
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.sequelize.query('SET FOREIGN_KEY_CHECKS = 0');
    
    await workingHours.down(queryInterface, Sequelize);
    await languages.down(queryInterface, Sequelize);
    await equipment.down(queryInterface, Sequelize);
    await categories.down(queryInterface, Sequelize);
    await reminders.down(queryInterface, Sequelize);
    await prescriptions.down(queryInterface, Sequelize);
    await favorites.down(queryInterface, Sequelize);
    await invoices.down(queryInterface, Sequelize);
    await records.down(queryInterface, Sequelize);
    await notifications.down(queryInterface, Sequelize);
    await reviews.down(queryInterface, Sequelize);
    await notes.down(queryInterface, Sequelize);
    await appointments.down(queryInterface, Sequelize);
    await offerings.down(queryInterface, Sequelize);
    await slots.down(queryInterface, Sequelize);
    await drLocations.down(queryInterface, Sequelize);
    await practiceStaff.down(queryInterface, Sequelize);
    await doctors.down(queryInterface, Sequelize);
    await locations.down(queryInterface, Sequelize);
    await specialties.down(queryInterface, Sequelize);
    await profiles.down(queryInterface, Sequelize);
    await users.down(queryInterface, Sequelize);

    await queryInterface.sequelize.query('SET FOREIGN_KEY_CHECKS = 1');
  }
};
