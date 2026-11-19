'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('dr_locations', {
      doctor_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'doctors', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      location_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'locations', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('dr_locations');
  }
};
