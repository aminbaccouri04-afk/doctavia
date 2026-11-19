const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { User, Profile, Doctor } = require('../models');
const AppError = require('../utils/util-app-error');

class AuthService {
  static async signup(userData) {
    const { email, password, role, fullName, dateOfBirth, authCode } = userData;

    // 1. Validation for Secretary
    if (role === 'secretary') {
      if (!authCode) throw new AppError('Authorization code is required for Secretary role', 400);
      
      const doctor = await Doctor.findOne({ where: { authCode } });
      if (!doctor || new Date() > new Date(doctor.authCodeExpiresAt)) {
        throw new AppError('Invalid or expired authorization code', 400);
      }
      // Note: we link the secretary to the doctor later via PracticeStaff model
    }

    // 2. Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // 3. Create User & Profile in a transaction
    const transaction = await User.sequelize.transaction();
    try {
      const newUser = await User.create({
        email,
        password: hashedPassword,
        role
      }, { transaction });

      // PRD Requirement: Every account holder automatically gets a "Self" profile
      await Profile.create({
        accountId: newUser.id,
        fullName,
        dateOfBirth,
        relationship: 'Self'
      }, { transaction });

      // If Doctor, create doctor record with a random authCode for staff delegation
      if (role === 'doctor') {
        const authCode = Math.random().toString(36).substring(2, 10).toUpperCase();
        const authCodeExpiresAt = new Date();
        authCodeExpiresAt.setDate(authCodeExpiresAt.getDate() + 7); // Valid for 7 days

        await Doctor.create({ 
          userId: newUser.id,
          authCode,
          authCodeExpiresAt
        }, { transaction });
      }

      // PRD §8: If Secretary, link to the doctor immediately
      if (role === 'secretary') {
        const doctor = await Doctor.findOne({ where: { authCode }, transaction });
        const { PracticeStaff } = require('../models');
        await PracticeStaff.create({
          userId: newUser.id,
          doctorId: doctor.id
        }, { transaction });

        // Notify Doctor of new staff member
        const NotificationService = require('./service-notification');
        await NotificationService.notify(
          doctor.userId,
          'New Staff Member',
          'A new secretary has linked to your practice during registration.'
        );
      }

      await transaction.commit();
      return newUser;
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  }

  static async login(email, password) {
    if (!email || !password) {
      throw new AppError('Email and password are required', 400);
    }

    const user = await User.findOne({ 
      where: { email },
      include: [{ model: Profile, as: 'profiles' }]
    });

    if (!user || !(await bcrypt.compare(password, user.password))) {
      throw new AppError('Incorrect email or password', 401);
    }

    if (!process.env.JWT_SECRET) {
      throw new AppError('JWT_SECRET is not configured on the server', 500);
    }

    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    return { user, token };
  }

  /**
   * Generates a 6-digit reset token for password recovery.
   * PRD §7.1
   */
  static async forgotPassword(email) {
    const user = await User.findOne({ where: { email } });
    if (!user) throw new AppError('No user found with that email address', 404);

    const resetToken = Math.floor(100000 + Math.random() * 900000).toString(); // 6 digits
    const expires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    await user.update({
      passwordResetToken: resetToken,
      passwordResetExpires: expires
    });

    // In a real app, send email here. For now, we return it.
    return resetToken;
  }

  /**
   * Resets the password using a valid token.
   * PRD §7.1
   */
  static async resetPassword(email, token, newPassword) {
    const user = await User.findOne({ 
      where: { 
        email, 
        passwordResetToken: token,
        passwordResetExpires: { [User.sequelize.Sequelize.Op.gt]: new Date() }
      } 
    });

    if (!user) throw new AppError('Token is invalid or has expired', 400);

    const hashedPassword = await bcrypt.hash(newPassword, 12);
    await user.update({
      password: hashedPassword,
      passwordResetToken: null,
      passwordResetExpires: null
    });

    return user;
  }
  /**
   * Changes the user's password if the old password is correct.
   */
  static async changePassword(userId, oldPassword, newPassword) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new AppError('User not found', 404);
    }

    if (!(await bcrypt.compare(oldPassword, user.password))) {
      throw new AppError('Incorrect old password', 401);
    }

    const hashedPassword = await bcrypt.hash(newPassword, 12);
    await user.update({ password: hashedPassword });

    return user;
  }
}

module.exports = AuthService;
