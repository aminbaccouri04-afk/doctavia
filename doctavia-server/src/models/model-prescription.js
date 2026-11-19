const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

/**
 * Prescription Model (PHASE 8: Advanced Clinical Management)
 * Tracks medications issued during a consultation.
 */
const Prescription = sequelize.define('Prescription', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  appointmentId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  doctorId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  patientProfileId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  medicationName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  dosage: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'e.g., 500mg'
  },
  frequency: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'e.g., Twice daily'
  },
  duration: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'e.g., 7 days'
  },
  instructions: {
    type: DataTypes.TEXT,
    comment: 'e.g., Take after meals'
  },
  status: {
    type: DataTypes.ENUM('active', 'completed', 'cancelled'),
    defaultValue: 'active'
  }
}, {
  tableName: 'prescriptions',
  timestamps: true,
  underscored: true
});

module.exports = Prescription;
