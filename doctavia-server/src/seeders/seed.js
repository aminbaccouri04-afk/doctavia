'use strict';

const specialties = require('./seed-specialties');
const locations = require('./seed-locations');
const users = require('./seed-users');
const profiles = require('./seed-profiles');
const doctors = require('./seed-doctors');
const drLocations = require('./seed-dr-locations');
const practiceStaff = require('./seed-practice-staff');
const favorites = require('./seed-favorites');
const slots = require('./seed-availability-slots');
const offerings = require('./seed-offerings');
const appointments = require('./seed-appointments');
const notes = require('./seed-consultation-notes');
const prescriptions = require('./seed-prescriptions');
const invoices = require('./seed-invoices');
const reviews = require('./seed-reviews');
const records = require('./seed-medical-records');
const notifications = require('./seed-notifications');
const doctorSpecialties = require('./seed-doctor-specialties');


module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Force silence all SQL logs for a cleaner output
    queryInterface.sequelize.options.logging = false;

    console.log('--- Starting Seeding Pipeline ---');
    
    await specialties.up(queryInterface, Sequelize);
    console.log('✅ Specialties seeded');
    
    await locations.up(queryInterface, Sequelize);
    console.log('✅ Locations seeded');
    
    await users.up(queryInterface, Sequelize);
    console.log('✅ Users seeded');
    
    await profiles.up(queryInterface, Sequelize);
    console.log('✅ Profiles seeded');
    
    await doctors.up(queryInterface, Sequelize);
    console.log('✅ Doctors seeded');
    
    await drLocations.up(queryInterface, Sequelize);
    console.log('✅ Doctor-Location mappings seeded');
    
    await practiceStaff.up(queryInterface, Sequelize);
    console.log('✅ Practice staff seeded');
    
    await favorites.up(queryInterface, Sequelize);
    console.log('✅ Favorites seeded');
    
    await slots.up(queryInterface, Sequelize);
    console.log('✅ Availability slots seeded');
    
    await offerings.up(queryInterface, Sequelize);
    console.log('✅ Offerings seeded');
    
    await appointments.up(queryInterface, Sequelize);
    console.log('✅ Appointments seeded');
    
    await notes.up(queryInterface, Sequelize);
    console.log('✅ Consultation notes seeded');
    
    await prescriptions.up(queryInterface, Sequelize);
    console.log('✅ Prescriptions seeded');
    
    await invoices.up(queryInterface, Sequelize);
    console.log('✅ Invoices seeded');
    
    await reviews.up(queryInterface, Sequelize);
    console.log('✅ Reviews seeded');
    
    await records.up(queryInterface, Sequelize);
    console.log('✅ Medical records seeded');
    
    await notifications.up(queryInterface, Sequelize);
    console.log('✅ Notifications seeded');

    await doctorSpecialties.up(queryInterface, Sequelize);
    console.log('✅ Doctor-Specialties mappings seeded');


    console.log('--- Seeding Pipeline Finished Successfully ---');
  },

  down: async (queryInterface, Sequelize) => {
    // Reverse order for down migration
    await doctorSpecialties.down(queryInterface, Sequelize);
    await notifications.down(queryInterface, Sequelize);

    await records.down(queryInterface, Sequelize);
    await reviews.down(queryInterface, Sequelize);
    await invoices.down(queryInterface, Sequelize);
    await prescriptions.down(queryInterface, Sequelize);
    await notes.down(queryInterface, Sequelize);
    await appointments.down(queryInterface, Sequelize);
    await offerings.down(queryInterface, Sequelize);
    await slots.down(queryInterface, Sequelize);
    await favorites.down(queryInterface, Sequelize);
    await practiceStaff.down(queryInterface, Sequelize);
    await drLocations.down(queryInterface, Sequelize);
    await doctors.down(queryInterface, Sequelize);
    await profiles.down(queryInterface, Sequelize);
    await users.down(queryInterface, Sequelize);
    await locations.down(queryInterface, Sequelize);
    await specialties.down(queryInterface, Sequelize);
  }
};
