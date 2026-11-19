const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

/**
 * Reminder Model (Phase 11: Patient Engagement)
 * Tracks user-defined medication or visit reminders.
 */
const Reminder = sequelize.define('Reminder', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  medicationName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  dosage: {
    type: DataTypes.STRING,
    allowNull: true
  },
  frequency: {
    type: DataTypes.STRING,
    allowNull: true
  },
  times: {
    type: DataTypes.JSON,
    allowNull: false,
    comment: 'Array of time strings, e.g. ["08:00", "20:00"]'
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  prescriptionId: {
    type: DataTypes.INTEGER,
    allowNull: true
  }
}, {
  tableName: 'reminders',
  timestamps: true,
  underscored: true
});

module.exports = Reminder;
