const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const WorkingHour = sequelize.define('WorkingHour', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  doctorId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'doctors',
      key: 'id'
    }
  },
  dayOfWeek: {
    type: DataTypes.INTEGER, // 0 (Sunday) to 6 (Saturday)
    allowNull: false,
    validate: {
      min: 0,
      max: 6
    }
  },
  startTime: {
    type: DataTypes.STRING, // Format: "HH:mm"
    allowNull: true
  },
  endTime: {
    type: DataTypes.STRING, // Format: "HH:mm"
    allowNull: true
  },
  isClosed: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
}, {
  tableName: 'working_hours',
  timestamps: true,
  underscored: true
});

module.exports = WorkingHour;
