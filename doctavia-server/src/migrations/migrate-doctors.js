'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    console.log('--- Migrating Doctors Table ---');
    await queryInterface.createTable('doctors', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      user_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'users', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },

      experience_years: { type: Sequelize.INTEGER, defaultValue: 0 },
      education: { type: Sequelize.TEXT },

      bio: { type: Sequelize.TEXT },
      auth_code: { type: Sequelize.STRING },
      auth_code_expires_at: { type: Sequelize.DATE },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('doctors');
  }
};
