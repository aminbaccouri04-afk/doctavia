'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('medical_records', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      profile_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'profiles', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      file_url: { type: Sequelize.STRING, allowNull: false },
      file_name: { type: Sequelize.STRING, allowNull: false },
      file_type: { type: Sequelize.STRING, allowNull: false },
      file_size: { type: Sequelize.INTEGER, allowNull: false },
      description: { type: Sequelize.STRING },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('medical_records');
  }
};
