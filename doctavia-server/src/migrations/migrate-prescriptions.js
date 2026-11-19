'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('prescriptions', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      appointment_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'appointments', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      doctor_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'doctors', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      patient_profile_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'profiles', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      medication_name: { type: Sequelize.STRING, allowNull: false },
      dosage: { type: Sequelize.STRING, allowNull: false },
      frequency: { type: Sequelize.STRING, allowNull: false },
      duration: { type: Sequelize.STRING, allowNull: false },
      instructions: { type: Sequelize.TEXT },
      status: { type: Sequelize.ENUM('active', 'completed', 'cancelled'), defaultValue: 'active' },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('prescriptions');
  }
};
