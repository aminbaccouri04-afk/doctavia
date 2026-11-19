const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DoctorEquipment = sequelize.define('DoctorEquipment', {
  doctorId: {
    type: DataTypes.INTEGER,
    references: { model: 'doctors', key: 'id' }
  },
  equipmentId: {
    type: DataTypes.INTEGER,
    references: { model: 'equipment', key: 'id' }
  }
}, {
  tableName: 'doctor_equipment',
  timestamps: false,
  underscored: true
});

module.exports = DoctorEquipment;
