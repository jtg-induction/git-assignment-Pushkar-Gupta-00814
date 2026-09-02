const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const { BCRYPT_SALT_ROUNDS } = require('../config/constants');

const addressSchema = new mongoose.Schema({
  street: { type: String, required: true },
  city: { type: String, required: true },
  state: { type: String, required: true },
  zipCode: { type: String, required: true },
  country: { type: String, required: true, default: 'US' },
}, { _id: false });

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Full name is required'],
    trim: true,
    minlength: [2, 'Name must be at least 2 characters'],
    maxlength: [100, 'Name cannot exceed 100 characters'],
  },
  email: {
    type: String,
    required: [true, 'Email address is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email address'],
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [8, 'Password must be at least 8 characters'],
    select: false,  // Never return password in queries by default
  },
  role: {
    type: String,
    enum: { values: ['customer', 'admin'], message: 'Role must be customer or admin' },
    default: 'customer',
  },
  isActive: { type: Boolean, default: true },
  lastLogin: { type: Date },
  defaultAddress: addressSchema,
  totalOrders: { type: Number, default: 0 },
  totalSpend: { type: Number, default: 0 },
}, { timestamps: true });

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, BCRYPT_SALT_ROUNDS);
  next();
});

// Instance method: compare passwords
userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Instance method: safe user object (no password)
userSchema.methods.toPublic = function () {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};

// Index for common queries
userSchema.index({ email: 1 });
userSchema.index({ role: 1, isActive: 1 });

module.exports = mongoose.model('User', userSchema);
