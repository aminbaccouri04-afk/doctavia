const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AvailabilitySlot = sequelize.define('AvailabilitySlot', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  doctorId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  startTime: {
    type: DataTypes.DATE,
    allowNull: false
  },
  endTime: {
    type: DataTypes.DATE,
    allowNull: false
  },
  isBooked: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
}, {
  tableName: 'availability_slots',
  timestamps: true,
  underscored: true
});

module.exports = AvailabilitySlot;
