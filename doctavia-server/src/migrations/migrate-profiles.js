'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    console.log('>>> DEBUG: Creating profiles table with avatar_url column');
    await queryInterface.createTable('profiles', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      account_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'users', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
      full_name: { type: Sequelize.STRING, allowNull: false },
      date_of_birth: { type: Sequelize.DATEONLY, allowNull: false },
      relationship: { type: Sequelize.STRING, defaultValue: 'Self', allowNull: false },
      avatar_url: { type: Sequelize.STRING, allowNull: true },
      created_at: { allowNull: false, type: Sequelize.DATE },
      updated_at: { allowNull: false, type: Sequelize.DATE }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('profiles');
  }
};
