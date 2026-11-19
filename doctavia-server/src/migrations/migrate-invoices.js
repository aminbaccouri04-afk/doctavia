'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('invoices', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      appointment_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'appointments', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      patient_profile_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'profiles', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      doctor_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'doctors', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      amount: { type: Sequelize.DECIMAL(10, 2), allowNull: false },
      status: { type: Sequelize.ENUM('pending', 'paid', 'cancelled'), defaultValue: 'pending' },
      issued_at: { type: Sequelize.DATE, defaultValue: Sequelize.NOW },
      paid_at: { type: Sequelize.DATE },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('invoices');
  }
};
