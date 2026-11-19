'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('availability_slots', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      doctor_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'doctors', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      start_time: { type: Sequelize.DATE, allowNull: false },
      end_time: { type: Sequelize.DATE, allowNull: false },
      is_booked: { type: Sequelize.BOOLEAN, defaultValue: false },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('availability_slots');
  }
};
