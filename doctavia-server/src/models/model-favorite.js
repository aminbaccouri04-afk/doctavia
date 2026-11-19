const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

/**
 * Junction table for Patient Favorites (User <-> Doctor).
 * PRD §7.3: POST/DELETE /doctors/favorites
 */
const Favorite = sequelize.define('Favorite', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'users', key: 'id' }
  },
  doctorId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'doctors', key: 'id' }
  }
}, {
  tableName: 'favorites',
  timestamps: true,
  underscored: true,
  indexes: [
    { unique: true, fields: ['user_id', 'doctor_id'] }
  ]
});

module.exports = Favorite;
