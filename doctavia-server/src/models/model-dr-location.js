const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DrLocation = sequelize.define('DrLocation', {
  doctor_id: {
    type: DataTypes.INTEGER,
    references: { model: 'doctors', key: 'id' }
  },
  location_id: {
    type: DataTypes.INTEGER,
    references: { model: 'locations', key: 'id' }
  }
}, {
  tableName: 'dr_locations',
  timestamps: false,
  underscored: true
});

module.exports = DrLocation;
