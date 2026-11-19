'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const specialtiesData = ['Cardiology', 'Dermatology', 'Pediatrics', 'Neurology', 'General Practice', 'Orthopedics', 'Psychiatry', 'Ophthalmology'].map(name => ({
      name
    }));
    await queryInterface.bulkInsert('specialties', specialtiesData);
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('specialties', null, {});
  }
};
