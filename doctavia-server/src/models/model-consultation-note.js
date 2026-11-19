const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ConsultationNote = sequelize.define('ConsultationNote', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  appointmentId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  patientSummary: {
    type: DataTypes.TEXT,
    comment: 'Summary of the consultation visible to the patient'
  },
  internalNotes: {
    type: DataTypes.TEXT,
    comment: 'Notes not visible to the patient'
  }
}, {
  tableName: 'consultation_notes',
  timestamps: true,
  underscored: true
});

module.exports = ConsultationNote;
