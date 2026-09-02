const jwt = require('jsonwebtoken');
const User = require('../models/user');

/**
 * Register a new user account.
 */
const registerUser = async (userData) => {
  const { name, email, password, role } = userData;

  const existingUser = await User.findOne({ email: email.toLowerCase() });
  if (existingUser) {
    const err = new Error('An account with this email address already exists.');
    err.statusCode = 409;
    throw err;
  }

  const user = new User({ name, email, password, role: role || 'customer' });
  await user.save();

  return user.toPublic();
};

/**
 * Authenticate a user and return a signed JWT.
 */
const loginUser = async (email, password) => {
  const user = await User.findOne({ email: email.toLowerCase(), isActive: true }).select('+password');
  if (!user) {
    const err = new Error('Invalid email address or password.');
    err.statusCode = 401;
    throw err;
  }

  const isPasswordCorrect = await user.comparePassword(password);
  if (!isPasswordCorrect) {
    const err = new Error('Invalid email address or password.');
    err.statusCode = 401;
    throw err;
  }

  // Update last login timestamp
  user.lastLogin = new Date();
  await user.save({ validateBeforeSave: false });

  const token = jwt.sign(
    { id: user._id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

  return { token, user: user.toPublic() };
};

/**
 * Retrieve a single user by ID (admin use or self).
 */
const getUserById = async (userId) => {
  const user = await User.findById(userId);
  if (!user) {
    const err = new Error('User not found.');
    err.statusCode = 404;
    throw err;
  }
  return user.toPublic();
};

/**
 * List all users (admin only).
 */
const getAllUsers = async () => {
  return User.find({ isActive: true }).select('-password').sort({ createdAt: -1 });
};

/**
 * Deactivate a user account (soft delete).
 */
const deactivateUser = async (userId) => {
  const user = await User.findByIdAndUpdate(
    userId,
    { isActive: false },
    { new: true }
  );
  if (!user) {
    const err = new Error('User not found.');
    err.statusCode = 404;
    throw err;
  }
  return user.toPublic();
};

module.exports = { registerUser, loginUser, getUserById, getAllUsers, deactivateUser };
