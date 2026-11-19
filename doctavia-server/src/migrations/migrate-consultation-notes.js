'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('consultation_notes', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      appointment_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'appointments', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      patient_summary: { type: Sequelize.TEXT },
      internal_notes: { type: Sequelize.TEXT },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('consultation_notes');
  }
};
