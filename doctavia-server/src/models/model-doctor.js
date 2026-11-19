const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Doctor = sequelize.define('Doctor', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'user_id',
    references: {
      model: 'users',
      key: 'id'
    }
  },

  experienceYears: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    field: 'experience_years'
  },
  education: {
    type: DataTypes.TEXT
  },

  bio: {
    type: DataTypes.TEXT
  },
  authCode: {
    type: DataTypes.STRING,
    field: 'auth_code'
  },
  authCodeExpiresAt: {
    type: DataTypes.DATE,
    field: 'auth_code_expires_at'
  }
}, {
  tableName: 'doctors',
  timestamps: true,
  underscored: true
});

module.exports = Doctor;
