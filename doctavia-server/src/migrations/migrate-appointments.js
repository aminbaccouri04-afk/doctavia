'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('appointments', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      slot_id: { type: Sequelize.INTEGER, references: { model: 'availability_slots', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'SET NULL' },
      patient_profile_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'profiles', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      offering_id: { type: Sequelize.INTEGER, references: { model: 'offerings', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'SET NULL' },
      booked_by_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'users', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      start_time_snapshot: { type: Sequelize.DATE, allowNull: false },
      end_time_snapshot: { type: Sequelize.DATE, allowNull: false },
      status: { type: Sequelize.ENUM('confirmed', 'cancelled', 'completed', 'checked_in', 'in_progress'), defaultValue: 'confirmed' },
      cancelled_by_id: { type: Sequelize.INTEGER },
      cancellation_reason: { type: Sequelize.TEXT },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('appointments');
  }
};
