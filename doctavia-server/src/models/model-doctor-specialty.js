const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DoctorSpecialty = sequelize.define('DoctorSpecialty', {
  doctor_id: {
    type: DataTypes.INTEGER,
    references: { model: 'doctors', key: 'id' }
  },
  specialty_id: {
    type: DataTypes.INTEGER,
    references: { model: 'specialties', key: 'id' }
  }
}, {
  tableName: 'doctor_specialties',
  timestamps: false,
  underscored: true
});

module.exports = DoctorSpecialty;
