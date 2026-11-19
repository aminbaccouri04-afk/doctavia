const AuthService = require('../services/service-auth');
const AppError = require('../utils/util-app-error');

exports.signup = async (req, res, next) => {
  try {
    const newUser = await AuthService.signup(req.body);
    res.status(201).json({
      status: 'success',
      data: { 
        user: { 
          id: newUser.id, 
          email: newUser.email, 
          role: newUser.role,
          profiles: newUser.profiles || []
        } 
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      throw new AppError('Email and password are required', 400);
    }

    const { user, token } = await AuthService.login(email, password);
    res.status(200).json({
      status: 'success',
      token,
      data: { 
        user: { 
          id: user.id, 
          email: user.email, 
          role: user.role,
          profiles: user.profiles || []
        } 
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.forgotPassword = async (req, res, next) => {
  try {
    const resetToken = await AuthService.forgotPassword(req.body.email);
    res.status(200).json({
      status: 'success',
      message: 'Token sent to email (mock)',
      data: { resetToken } // For test environment convenience
    });
  } catch (err) {
    next(err);
  }
};

exports.resetPassword = async (req, res, next) => {
  try {
    const { email, token, newPassword } = req.body;
    await AuthService.resetPassword(email, token, newPassword);
    res.status(200).json({ status: 'success', message: 'Password reset successful' });
  } catch (err) {
    next(err);
  }
};

exports.changePassword = async (req, res, next) => {
  try {
    const { oldPassword, newPassword } = req.body;
    await AuthService.changePassword(req.user.id, oldPassword, newPassword);
    res.status(200).json({ status: 'success', message: 'Password changed successfully' });
  } catch (err) {
    next(err);
  }
};
