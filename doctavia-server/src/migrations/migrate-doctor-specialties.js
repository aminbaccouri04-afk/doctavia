'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('doctor_specialties', {
      doctor_id: { type: Sequelize.INTEGER, references: { model: 'doctors', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      specialty_id: { type: Sequelize.INTEGER, references: { model: 'specialties', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('doctor_specialties');
  }
};
