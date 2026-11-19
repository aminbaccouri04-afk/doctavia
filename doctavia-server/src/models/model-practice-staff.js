const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const PracticeStaff = sequelize.define('PracticeStaff', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'users', key: 'id' }
  },
  doctorId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'doctors', key: 'id' }
  }
}, {
  tableName: 'practice_staff',
  timestamps: true,
  underscored: true
});

module.exports = PracticeStaff;
