const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Appointment = sequelize.define('Appointment', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  slotId: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  patientProfileId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  offeringId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    field: 'offering_id'
  },
  bookedById: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  startTimeSnapshot: {
    type: DataTypes.DATE,
    allowNull: false
  },
  endTimeSnapshot: {
    type: DataTypes.DATE,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('confirmed', 'cancelled', 'completed', 'checked_in', 'in_progress'),
    defaultValue: 'confirmed'
  },
  cancelledById: {
    type: DataTypes.UUID
  },
  cancellationReason: {
    type: DataTypes.TEXT
  }
}, {
  tableName: 'appointments',
  timestamps: true,
  underscored: true
});

module.exports = Appointment;
