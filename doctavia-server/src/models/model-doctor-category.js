const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DoctorCategory = sequelize.define('DoctorCategory', {
  doctorId: {
    type: DataTypes.INTEGER,
    references: { model: 'doctors', key: 'id' }
  },
  categoryId: {
    type: DataTypes.INTEGER,
    references: { model: 'categories', key: 'id' }
  }
}, {
  tableName: 'doctor_categories',
  timestamps: false,
  underscored: true
});

module.exports = DoctorCategory;
