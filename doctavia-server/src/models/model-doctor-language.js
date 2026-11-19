const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DoctorLanguage = sequelize.define('DoctorLanguage', {
  doctorId: {
    type: DataTypes.INTEGER,
    references: { model: 'doctors', key: 'id' }
  },
  languageId: {
    type: DataTypes.INTEGER,
    references: { model: 'languages', key: 'id' }
  }
}, {
  tableName: 'doctor_languages',
  timestamps: false,
  underscored: true
});

module.exports = DoctorLanguage;
