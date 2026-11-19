'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('equipment', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      name: { type: Sequelize.STRING, allowNull: false, unique: true },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
    
    await queryInterface.createTable('doctor_equipment', {
      doctor_id: { type: Sequelize.INTEGER, references: { model: 'doctors', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      equipment_id: { type: Sequelize.INTEGER, references: { model: 'equipment', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('doctor_equipment');
    await queryInterface.dropTable('equipment');
  }
};
