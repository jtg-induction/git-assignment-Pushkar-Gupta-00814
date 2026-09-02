$ErrorActionPreference = 'Stop'
$RepoPath = "C:\Users\Windows\Documents\antigravity\amazing-galileo"
Set-Location $RepoPath

# ============================================================
# CLEAN SLATE
# ============================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " ShopNow API - Git Assignment Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[1/8] Cleaning up old repository..." -ForegroundColor Yellow
if (Test-Path ".git") { Remove-Item -Recurse -Force ".git" }

# Remove old flat files from previous assignment version
$oldFiles = @('config.sh','utils.sh','process_data.sh','script.sh','database_connector.sh',
              'user_service.sh','helper.sh','Assignment.md','README.md','.env','.env.example')
foreach ($f in $oldFiles) { if (Test-Path $f) { Remove-Item $f -Force } }

# Remove old directories
foreach ($d in @('src','tests')) { if (Test-Path $d) { Remove-Item -Recurse -Force $d } }

# ============================================================
# CREATE PROJECT STRUCTURE
# ============================================================
Write-Host "[2/8] Creating project directory structure..." -ForegroundColor Yellow
$dirs = @('src','src/config','src/controllers','src/middleware','src/models','src/routes','src/services','tests')
foreach ($dir in $dirs) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

# ============================================================
# GIT INIT
# ============================================================
git init
git config user.name "Abhimanyu Tiwari"
git config user.email "abhimanyu.tiwari@joshtechnologygroup.com"

# ============================================================
# MAIN BRANCH - Full Project Skeleton (21 files)
# ============================================================
Write-Host "[3/8] Creating main branch with full project skeleton..." -ForegroundColor Yellow

# --- README.md ---
Set-Content -Path "README.md" -Value @'
# ShopNow Order Management API

A production-grade RESTful API for managing users, products, and orders for the ShopNow e-commerce platform.

## Tech Stack
- **Runtime**: Node.js 18+
- **Framework**: Express.js 4.x
- **Database**: MongoDB (via Mongoose ODM)
- **Auth**: JWT (JSON Web Tokens) + bcryptjs
- **Testing**: Jest + Supertest

## Project Structure
```
src/
  app.js                 # Express application entry point
  config/
    constants.js         # Application-wide constants & limits
    database.js          # MongoDB connection with retry logic
  controllers/           # Route handler functions (thin layer)
  middleware/
    errorHandler.js      # Centralized error handling middleware
  models/                # Mongoose schemas and models
  routes/                # Express route definitions
  services/              # Business logic layer (fat services)
tests/                   # Jest test suites (unit + integration)
```

## Git Assignment Branches
| Branch | Skill | Description |
|---|---|---|
| `feature/amend-me` | `git commit --amend` | Fix a bad commit: leaked secrets, missing file, debug logs |
| `feature/dependent-feature` | `git merge/rebase` | Sync with base branch security patch (route conflict) |
| `feature/merge-conflict` | `git merge` | Resolve 5-file conflict between pagination and caching refactors |
| `feature/rebase-me` | `git rebase` | Rebase discount feature onto main (3-file conflict) |
| `feature/squash-me` | `git rebase -i` | Squash 12 messy payment sprint commits into 1 clean commit |
| `feature/cherry-pick` | `git cherry-pick` | Pick a critical bug fix from another branch without bringing experimental code |

## Getting Started
```bash
npm install
cp .env.example .env
# Fill in MONGO_URI and JWT_SECRET in .env
npm run dev
```
'@

# --- package.json ---
Set-Content -Path "package.json" -Value @'
{
  "name": "shopnow-order-api",
  "version": "1.0.0",
  "description": "E-Commerce Order Management REST API for ShopNow platform",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "dev": "nodemon src/app.js",
    "test": "jest --coverage --detectOpenHandles",
    "test:watch": "jest --watch"
  },
  "dependencies": {
    "bcryptjs": "^2.4.3",
    "dotenv": "^16.3.1",
    "express": "^4.18.2",
    "express-rate-limit": "^7.1.1",
    "jsonwebtoken": "^9.0.2",
    "mongoose": "^7.5.0",
    "node-cache": "^5.1.2"
  },
  "devDependencies": {
    "jest": "^29.6.4",
    "nodemon": "^3.0.1",
    "supertest": "^6.3.3"
  },
  "jest": {
    "testEnvironment": "node",
    "coveragePathIgnorePatterns": ["/node_modules/"]
  }
}
'@

# --- .gitignore ---
Set-Content -Path ".gitignore" -Value @'
# Dependencies
node_modules/

# Environment variables - NEVER commit this!
.env

# Build output
dist/
build/

# Logs
*.log
logs/
npm-debug.log*

# Test coverage
coverage/
.nyc_output/

# IDE / OS files
.DS_Store
.vscode/settings.json
Thumbs.db
'@

# --- .env.example ---
Set-Content -Path ".env.example" -Value @'
# Copy this file to .env and fill in your values
# NEVER commit the actual .env file

PORT=3000
NODE_ENV=development

# MongoDB Connection String
MONGO_URI=mongodb://localhost:27017/shopnow_db

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d

# App Configuration
MAX_REQUEST_RATE=100
RATE_LIMIT_WINDOW_MS=900000
'@

# --- src/config/constants.js ---
Set-Content -Path "src/config/constants.js" -Value @'
// =========================================================
// Application-wide constants for ShopNow Order API
// =========================================================

module.exports = {
  // --- Database ---
  DB_RETRY_LIMIT: 5,
  DB_RETRY_DELAY_MS: 5000,

  // --- Authentication ---
  JWT_EXPIRES_IN: '7d',
  BCRYPT_SALT_ROUNDS: 12,

  // --- Pagination ---
  DEFAULT_PAGE_SIZE: 20,
  MAX_PAGE_SIZE: 100,

  // --- Order Configuration ---
  ORDER_LIMITS: {
    MAX_ITEMS_PER_ORDER: 50,
    MIN_ORDER_AMOUNT: 1.00,
    MAX_ORDER_AMOUNT: 50000.00,
    CANCELLATION_WINDOW_HOURS: 24,
  },

  // --- Order Statuses ---
  ORDER_STATUS: {
    PENDING: 'pending',
    CONFIRMED: 'confirmed',
    PROCESSING: 'processing',
    SHIPPED: 'shipped',
    DELIVERED: 'delivered',
    CANCELLED: 'cancelled',
    REFUNDED: 'refunded',
  },

  // --- Product Configuration ---
  PRODUCT_CATEGORIES: [
    'electronics', 'clothing', 'books', 'home-garden',
    'sports', 'food-beverage', 'beauty', 'toys',
  ],

  // --- Rate Limiting ---
  RATE_LIMIT: {
    WINDOW_MS: 15 * 60 * 1000,  // 15 minutes
    MAX_REQUESTS: 100,
    MESSAGE: 'Too many requests from this IP. Please try again later.',
  },

  // --- Cache ---
  CACHE_TTL_SECONDS: 60,
};
'@

# --- src/config/database.js ---
Set-Content -Path "src/config/database.js" -Value @'
const mongoose = require('mongoose');
const { DB_RETRY_LIMIT, DB_RETRY_DELAY_MS } = require('./constants');

let retryCount = 0;

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000,
    });
    console.log(`[DB] MongoDB connected: ${conn.connection.host}`);
    retryCount = 0;
  } catch (err) {
    console.error(`[DB] Connection failed: ${err.message}`);

    if (retryCount < DB_RETRY_LIMIT) {
      retryCount++;
      console.log(`[DB] Retrying connection in ${DB_RETRY_DELAY_MS / 1000}s (attempt ${retryCount}/${DB_RETRY_LIMIT})...`);
      setTimeout(connectDB, DB_RETRY_DELAY_MS);
    } else {
      console.error('[DB] Max retry limit reached. Exiting process.');
      process.exit(1);
    }
  }
};

mongoose.connection.on('disconnected', () => {
  console.warn('[DB] MongoDB disconnected. Attempting to reconnect...');
  connectDB();
});

module.exports = connectDB;
'@

# --- src/app.js ---
Set-Content -Path "src/app.js" -Value @'
const express = require('express');
const dotenv = require('dotenv');
dotenv.config();

const connectDB = require('./config/database');
const userRoutes = require('./routes/userRoutes');
const productRoutes = require('./routes/productRoutes');
const orderRoutes = require('./routes/orderRoutes');
const errorHandler = require('./middleware/errorHandler');

const app = express();

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Database connection
connectDB();

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), version: '1.0.0' });
});

// API Routes
app.use('/api/users', userRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found` });
});

// Centralized error handler (must be last middleware)
app.use(errorHandler);

const PORT = process.env.PORT || 3000;
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => console.log(`[APP] ShopNow API running on port ${PORT} in ${process.env.NODE_ENV} mode`));
}

module.exports = app;
'@

# --- src/middleware/errorHandler.js ---
Set-Content -Path "src/middleware/errorHandler.js" -Value @'
// Centralized error handling middleware for ShopNow API
// All errors thrown in route handlers bubble up here via next(err)

const errorHandler = (err, req, res, next) => {
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    statusCode = 400;
    const fields = Object.values(err.errors).map((e) => e.message);
    message = `Validation failed: ${fields.join(', ')}`;
  }

  // Mongoose duplicate key error
  if (err.code === 11000) {
    statusCode = 409;
    const field = Object.keys(err.keyValue)[0];
    message = `A record with this ${field} already exists.`;
  }

  // Mongoose cast error (invalid ObjectId)
  if (err.name === 'CastError') {
    statusCode = 400;
    message = `Invalid value for field: ${err.path}`;
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid authentication token.';
  }

  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Authentication token has expired. Please log in again.';
  }

  // Log server errors in non-test environments
  if (statusCode >= 500 && process.env.NODE_ENV !== 'test') {
    console.error(`[ERROR] ${err.stack}`);
  }

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = errorHandler;
'@

# --- src/models/user.js ---
Set-Content -Path "src/models/user.js" -Value @'
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
'@

# --- src/models/product.js ---
Set-Content -Path "src/models/product.js" -Value @'
const mongoose = require('mongoose');
const { PRODUCT_CATEGORIES } = require('../config/constants');

const reviewSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  rating: { type: Number, required: true, min: 1, max: 5 },
  comment: { type: String, maxlength: 1000 },
  createdAt: { type: Date, default: Date.now },
}, { _id: false });

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Product name is required'],
    trim: true,
    maxlength: [200, 'Product name cannot exceed 200 characters'],
  },
  description: {
    type: String,
    required: [true, 'Product description is required'],
    maxlength: [5000, 'Description cannot exceed 5000 characters'],
  },
  price: {
    type: Number,
    required: [true, 'Price is required'],
    min: [0, 'Price cannot be negative'],
  },
  compareAtPrice: {
    type: Number,
    min: [0, 'Compare-at price cannot be negative'],
  },
  category: {
    type: String,
    required: [true, 'Category is required'],
    enum: { values: PRODUCT_CATEGORIES, message: 'Invalid product category' },
  },
  tags: [{ type: String, lowercase: true, trim: true }],
  stock: {
    type: Number,
    required: true,
    default: 0,
    min: [0, 'Stock cannot be negative'],
    validate: { validator: Number.isInteger, message: 'Stock must be a whole number' },
  },
  sku: {
    type: String,
    required: [true, 'SKU is required'],
    unique: true,
    uppercase: true,
    trim: true,
  },
  images: [{ url: String, altText: String }],
  isAvailable: { type: Boolean, default: true },
  weight: { type: Number, min: 0 },  // in kg
  reviews: [reviewSchema],
  averageRating: { type: Number, default: 0, min: 0, max: 5 },
}, { timestamps: true });

// Text search index
productSchema.index({ name: 'text', description: 'text', tags: 'text' });
// Compound index for category browsing with price sorting
productSchema.index({ category: 1, price: 1, isAvailable: 1 });

// Recalculate average rating after review changes
productSchema.methods.updateAverageRating = function () {
  if (this.reviews.length === 0) {
    this.averageRating = 0;
    return;
  }
  const sum = this.reviews.reduce((acc, r) => acc + r.rating, 0);
  this.averageRating = Math.round((sum / this.reviews.length) * 10) / 10;
};

module.exports = mongoose.model('Product', productSchema);
'@

# --- src/models/order.js ---
Set-Content -Path "src/models/order.js" -Value @'
const mongoose = require('mongoose');
const { ORDER_STATUS } = require('../config/constants');

const orderItemSchema = new mongoose.Schema({
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: [true, 'Product reference is required'],
  },
  quantity: {
    type: Number,
    required: [true, 'Quantity is required'],
    min: [1, 'Quantity must be at least 1'],
    validate: { validator: Number.isInteger, message: 'Quantity must be a whole number' },
  },
  unitPrice: {
    type: Number,
    required: [true, 'Unit price is required'],
    min: [0, 'Unit price cannot be negative'],
  },
  productName: { type: String, required: true },  // Snapshot at time of order
  productSku: { type: String, required: true },   // Snapshot at time of order
}, { _id: false });

const shippingAddressSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  street: { type: String, required: true },
  city: { type: String, required: true },
  state: { type: String, required: true },
  zipCode: { type: String, required: true },
  country: { type: String, required: true, default: 'US' },
  phone: { type: String },
}, { _id: false });

const orderSchema = new mongoose.Schema({
  orderNumber: {
    type: String,
    unique: true,
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User reference is required'],
  },
  items: {
    type: [orderItemSchema],
    validate: [(arr) => arr.length > 0, 'Order must have at least one item'],
  },
  status: {
    type: String,
    enum: Object.values(ORDER_STATUS),
    default: ORDER_STATUS.PENDING,
  },
  shippingAddress: {
    type: shippingAddressSchema,
    required: [true, 'Shipping address is required'],
  },
  subtotal: {
    type: Number,
    required: true,
    min: 0,
  },
  shippingCost: {
    type: Number,
    default: 0,
    min: 0,
  },
  totalAmount: {
    type: Number,
    required: true,
    min: 0,
  },
  paymentStatus: {
    type: String,
    enum: ['unpaid', 'paid', 'refunded'],
    default: 'unpaid',
  },
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters'],
  },
  statusHistory: [{
    status: { type: String, enum: Object.values(ORDER_STATUS) },
    changedAt: { type: Date, default: Date.now },
    changedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    reason: String,
  }],
}, { timestamps: true });

// Auto-generate order number before saving
orderSchema.pre('save', function (next) {
  if (!this.orderNumber) {
    const timestamp = Date.now().toString(36).toUpperCase();
    const random = Math.random().toString(36).substring(2, 6).toUpperCase();
    this.orderNumber = `ORD-${timestamp}-${random}`;
  }
  next();
});

orderSchema.index({ user: 1, status: 1, createdAt: -1 });
orderSchema.index({ orderNumber: 1 });
orderSchema.index({ createdAt: -1 });

module.exports = mongoose.model('Order', orderSchema);
'@

# --- src/services/userService.js ---
Set-Content -Path "src/services/userService.js" -Value @'
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
'@

# --- src/services/productService.js ---
Set-Content -Path "src/services/productService.js" -Value @'
const Product = require('../models/product');
const { DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE } = require('../config/constants');

/**
 * List products with optional filtering and pagination.
 */
const getProducts = async (query = {}) => {
  const { category, minPrice, maxPrice, search, page = 1, limit = DEFAULT_PAGE_SIZE, sort = '-createdAt' } = query;

  const filter = { isAvailable: true };
  if (category) filter.category = category;
  if (minPrice !== undefined || maxPrice !== undefined) {
    filter.price = {};
    if (minPrice !== undefined) filter.price.$gte = parseFloat(minPrice);
    if (maxPrice !== undefined) filter.price.$lte = parseFloat(maxPrice);
  }
  if (search) {
    filter.$text = { $search: search };
  }

  const effectiveLimit = Math.min(parseInt(limit), MAX_PAGE_SIZE);
  const skip = (parseInt(page) - 1) * effectiveLimit;

  const [products, total] = await Promise.all([
    Product.find(filter).sort(sort).skip(skip).limit(effectiveLimit),
    Product.countDocuments(filter),
  ]);

  return { products, total, page: parseInt(page), limit: effectiveLimit };
};

/**
 * Retrieve a single product by ID.
 */
const getProductById = async (productId) => {
  const product = await Product.findById(productId);
  if (!product) {
    const err = new Error('Product not found.');
    err.statusCode = 404;
    throw err;
  }
  return product;
};

/**
 * Create a new product listing.
 */
const createProduct = async (productData) => {
  const product = new Product(productData);
  await product.save();
  return product;
};

/**
 * Update an existing product.
 */
const updateProduct = async (productId, updates) => {
  const product = await Product.findByIdAndUpdate(productId, updates, { new: true, runValidators: true });
  if (!product) {
    const err = new Error('Product not found.');
    err.statusCode = 404;
    throw err;
  }
  return product;
};

/**
 * Delete a product (hard delete; use with caution in production).
 */
const deleteProduct = async (productId) => {
  const product = await Product.findByIdAndDelete(productId);
  if (!product) {
    const err = new Error('Product not found.');
    err.statusCode = 404;
    throw err;
  }
  return product;
};

module.exports = { getProducts, getProductById, createProduct, updateProduct, deleteProduct };
'@

# --- src/services/orderService.js ---
# THIS IS THE KEY FILE for rebase-me and merge-conflict branches!
Set-Content -Path "src/services/orderService.js" -Value @'
const Order = require('../models/order');
const Product = require('../models/product');
const User = require('../models/user');
const { ORDER_STATUS, ORDER_LIMITS } = require('../config/constants');

/**
 * Calculate the subtotal for a list of order items.
 * @param {Array} items - Array of { unitPrice, quantity }
 * @returns {number} subtotal
 */
const calculateSubtotal = (items) => {
  return items.reduce((total, item) => {
    return total + (item.unitPrice * item.quantity);
  }, 0);
};

/**
 * Calculate the grand total for an order.
 * @param {number} subtotal
 * @returns {number} total amount due
 */
const calculateTotal = (subtotal) => {
  return parseFloat(subtotal.toFixed(2));
};

/**
 * Validate order items against inventory and return enriched item list.
 */
const validateAndEnrichItems = async (items) => {
  if (!items || items.length === 0) {
    const err = new Error('Order must contain at least one item.');
    err.statusCode = 400;
    throw err;
  }
  if (items.length > ORDER_LIMITS.MAX_ITEMS_PER_ORDER) {
    const err = new Error(`Cannot exceed ${ORDER_LIMITS.MAX_ITEMS_PER_ORDER} items per order.`);
    err.statusCode = 400;
    throw err;
  }

  const enrichedItems = [];
  for (const item of items) {
    const product = await Product.findById(item.productId);
    if (!product) {
      const err = new Error(`Product with ID '${item.productId}' was not found.`);
      err.statusCode = 404;
      throw err;
    }
    if (!product.isAvailable) {
      const err = new Error(`'${product.name}' is currently unavailable.`);
      err.statusCode = 422;
      throw err;
    }
    if (product.stock < item.quantity) {
      const err = new Error(`Insufficient stock for '${product.name}'. Available: ${product.stock}, Requested: ${item.quantity}.`);
      err.statusCode = 422;
      throw err;
    }

    enrichedItems.push({
      product: product._id,
      quantity: item.quantity,
      unitPrice: product.price,
      productName: product.name,
      productSku: product.sku,
    });
  }

  return enrichedItems;
};

/**
 * Create a new order for a user.
 */
const createOrder = async (userId, orderData) => {
  const { items, shippingAddress, notes } = orderData;

  const enrichedItems = await validateAndEnrichItems(items);
  const subtotal = calculateSubtotal(enrichedItems);

  if (subtotal < ORDER_LIMITS.MIN_ORDER_AMOUNT) {
    const err = new Error(`Order minimum is $${ORDER_LIMITS.MIN_ORDER_AMOUNT.toFixed(2)}.`);
    err.statusCode = 400;
    throw err;
  }
  if (subtotal > ORDER_LIMITS.MAX_ORDER_AMOUNT) {
    const err = new Error(`Order maximum is $${ORDER_LIMITS.MAX_ORDER_AMOUNT.toFixed(2)}.`);
    err.statusCode = 400;
    throw err;
  }

  const totalAmount = calculateTotal(subtotal);

  const order = new Order({
    user: userId,
    items: enrichedItems,
    shippingAddress,
    subtotal,
    totalAmount,
    notes,
    statusHistory: [{ status: ORDER_STATUS.PENDING }],
  });

  await order.save();

  // Decrement stock for each purchased product
  const stockUpdates = enrichedItems.map((item) =>
    Product.findByIdAndUpdate(item.product, { $inc: { stock: -item.quantity } })
  );
  await Promise.all(stockUpdates);

  // Update user's order stats
  await User.findByIdAndUpdate(userId, {
    $inc: { totalOrders: 1, totalSpend: totalAmount },
  });

  return order.populate('items.product');
};

/**
 * Get all orders for a specific user.
 */
const getOrdersByUser = async (userId) => {
  return Order.find({ user: userId })
    .populate('items.product', 'name sku images')
    .sort({ createdAt: -1 });
};

/**
 * Get a single order by ID (with ownership check).
 */
const getOrderById = async (orderId, userId, userRole) => {
  const order = await Order.findById(orderId).populate('items.product');
  if (!order) {
    const err = new Error('Order not found.');
    err.statusCode = 404;
    throw err;
  }
  if (userRole !== 'admin' && order.user.toString() !== userId.toString()) {
    const err = new Error('You are not authorized to view this order.');
    err.statusCode = 403;
    throw err;
  }
  return order;
};

/**
 * Update the status of an order (admin only).
 */
const updateOrderStatus = async (orderId, newStatus, adminId, reason) => {
  const validTransitions = {
    pending: ['confirmed', 'cancelled'],
    confirmed: ['processing', 'cancelled'],
    processing: ['shipped', 'cancelled'],
    shipped: ['delivered'],
    delivered: ['refunded'],
    cancelled: [],
    refunded: [],
  };

  const order = await Order.findById(orderId);
  if (!order) {
    const err = new Error('Order not found.');
    err.statusCode = 404;
    throw err;
  }

  if (!validTransitions[order.status].includes(newStatus)) {
    const err = new Error(`Cannot transition order from '${order.status}' to '${newStatus}'.`);
    err.statusCode = 422;
    throw err;
  }

  order.status = newStatus;
  order.statusHistory.push({ status: newStatus, changedBy: adminId, reason });
  await order.save();

  return order;
};

/**
 * Cancel a pending order (user-initiated).
 */
const cancelOrder = async (orderId, userId) => {
  const order = await Order.findById(orderId);
  if (!order) {
    const err = new Error('Order not found.');
    err.statusCode = 404;
    throw err;
  }
  if (order.user.toString() !== userId.toString()) {
    const err = new Error('You are not authorized to cancel this order.');
    err.statusCode = 403;
    throw err;
  }
  if (order.status !== ORDER_STATUS.PENDING) {
    const err = new Error(`Only pending orders can be cancelled. Current status: '${order.status}'.`);
    err.statusCode = 422;
    throw err;
  }

  order.status = ORDER_STATUS.CANCELLED;
  order.statusHistory.push({ status: ORDER_STATUS.CANCELLED, changedBy: userId, reason: 'Cancelled by customer' });
  await order.save();

  // Restore inventory stock
  const stockRestores = order.items.map((item) =>
    Product.findByIdAndUpdate(item.product, { $inc: { stock: item.quantity } })
  );
  await Promise.all(stockRestores);

  // Adjust user stats
  await User.findByIdAndUpdate(userId, {
    $inc: { totalOrders: -1, totalSpend: -order.totalAmount },
  });

  return order;
};

module.exports = {
  calculateSubtotal,
  calculateTotal,
  validateAndEnrichItems,
  createOrder,
  getOrdersByUser,
  getOrderById,
  updateOrderStatus,
  cancelOrder,
};
'@

# --- src/controllers/userController.js ---
Set-Content -Path "src/controllers/userController.js" -Value @'
const userService = require('../services/userService');

/**
 * POST /api/users/register
 * Create a new user account.
 */
const register = async (req, res, next) => {
  try {
    const user = await userService.registerUser(req.body);
    res.status(201).json({ success: true, message: 'Account created successfully.', data: user });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/users/login
 * Authenticate and receive a JWT token.
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required.' });
    }
    const result = await userService.loginUser(email, password);
    res.json({ success: true, message: 'Login successful.', data: result });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/users/me
 * Get the currently authenticated user's profile.
 */
const getMe = async (req, res, next) => {
  try {
    const user = await userService.getUserById(req.user.id);
    res.json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/users
 * List all users (admin only).
 */
const getAllUsers = async (req, res, next) => {
  try {
    const users = await userService.getAllUsers();
    res.json({ success: true, count: users.length, data: users });
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /api/users/:id
 * Deactivate a user account (admin only).
 */
const deactivateUser = async (req, res, next) => {
  try {
    const user = await userService.deactivateUser(req.params.id);
    res.json({ success: true, message: 'User account deactivated.', data: user });
  } catch (err) {
    next(err);
  }
};

module.exports = { register, login, getMe, getAllUsers, deactivateUser };
'@

# --- src/controllers/productController.js ---
Set-Content -Path "src/controllers/productController.js" -Value @'
const productService = require('../services/productService');

/**
 * GET /api/products
 * List products with filtering, sorting, and pagination.
 */
const getProducts = async (req, res, next) => {
  try {
    const result = await productService.getProducts(req.query);
    res.json({
      success: true,
      data: result.products,
      pagination: {
        total: result.total,
        page: result.page,
        limit: result.limit,
        pages: Math.ceil(result.total / result.limit),
      },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/products/:id
 * Get a single product by its ID.
 */
const getProductById = async (req, res, next) => {
  try {
    const product = await productService.getProductById(req.params.id);
    res.json({ success: true, data: product });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/products
 * Create a new product (admin only).
 */
const createProduct = async (req, res, next) => {
  try {
    const product = await productService.createProduct(req.body);
    res.status(201).json({ success: true, message: 'Product created.', data: product });
  } catch (err) {
    next(err);
  }
};

/**
 * PUT /api/products/:id
 * Update an existing product (admin only).
 */
const updateProduct = async (req, res, next) => {
  try {
    const product = await productService.updateProduct(req.params.id, req.body);
    res.json({ success: true, message: 'Product updated.', data: product });
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /api/products/:id
 * Delete a product (admin only).
 */
const deleteProduct = async (req, res, next) => {
  try {
    await productService.deleteProduct(req.params.id);
    res.json({ success: true, message: 'Product deleted successfully.' });
  } catch (err) {
    next(err);
  }
};

module.exports = { getProducts, getProductById, createProduct, updateProduct, deleteProduct };
'@

# --- src/controllers/orderController.js ---
# THIS IS A KEY CONFLICT FILE for feature/merge-conflict
Set-Content -Path "src/controllers/orderController.js" -Value @'
const orderService = require('../services/orderService');

/**
 * POST /api/orders
 * Create a new order for the authenticated user.
 */
const createOrder = async (req, res, next) => {
  try {
    const order = await orderService.createOrder(req.user.id, req.body);
    res.status(201).json({ success: true, message: 'Order placed successfully.', data: order });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/orders
 * Get all orders for the authenticated user.
 */
const getOrders = async (req, res, next) => {
  try {
    const orders = await orderService.getOrdersByUser(req.user.id);
    res.json({ success: true, count: orders.length, data: orders });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/orders/:id
 * Get a specific order by ID.
 */
const getOrderById = async (req, res, next) => {
  try {
    const order = await orderService.getOrderById(req.params.id, req.user.id, req.user.role);
    res.json({ success: true, data: order });
  } catch (err) {
    next(err);
  }
};

/**
 * PUT /api/orders/:id/status
 * Update order status (admin only).
 */
const updateOrderStatus = async (req, res, next) => {
  try {
    const { status, reason } = req.body;
    if (!status) return res.status(400).json({ success: false, message: 'Status is required.' });
    const order = await orderService.updateOrderStatus(req.params.id, status, req.user.id, reason);
    res.json({ success: true, message: 'Order status updated.', data: order });
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /api/orders/:id
 * Cancel a pending order (user-initiated).
 */
const cancelOrder = async (req, res, next) => {
  try {
    const order = await orderService.cancelOrder(req.params.id, req.user.id);
    res.json({ success: true, message: 'Order cancelled successfully.', data: order });
  } catch (err) {
    next(err);
  }
};

module.exports = { createOrder, getOrders, getOrderById, updateOrderStatus, cancelOrder };
'@

# --- src/routes/userRoutes.js ---
# THIS IS A KEY CONFLICT FILE for feature/dependent-feature
Set-Content -Path "src/routes/userRoutes.js" -Value @'
const express = require('express');
const router = express.Router();
const { register, login, getMe, getAllUsers, deactivateUser } = require('../controllers/userController');

// Public routes
router.post('/register', register);
router.post('/login', login);

// Protected routes (require authentication - middleware to be added)
router.get('/me', getMe);

// Admin-only routes
router.get('/', getAllUsers);
router.delete('/:id', deactivateUser);

module.exports = router;
'@

# --- src/routes/productRoutes.js ---
Set-Content -Path "src/routes/productRoutes.js" -Value @'
const express = require('express');
const router = express.Router();
const {
  getProducts, getProductById, createProduct, updateProduct, deleteProduct,
} = require('../controllers/productController');

// Public routes
router.get('/', getProducts);
router.get('/:id', getProductById);

// Admin-only routes (auth middleware to be wired up)
router.post('/', createProduct);
router.put('/:id', updateProduct);
router.delete('/:id', deleteProduct);

module.exports = router;
'@

# --- src/routes/orderRoutes.js ---
# THIS IS A KEY CONFLICT FILE for feature/merge-conflict
Set-Content -Path "src/routes/orderRoutes.js" -Value @'
const express = require('express');
const router = express.Router();
const {
  createOrder, getOrders, getOrderById, updateOrderStatus, cancelOrder,
} = require('../controllers/orderController');

// All order routes require authentication (middleware to be added)
router.post('/', createOrder);
router.get('/', getOrders);
router.get('/:id', getOrderById);
router.put('/:id/status', updateOrderStatus);
router.delete('/:id', cancelOrder);

module.exports = router;
'@

# --- tests/user.test.js ---
Set-Content -Path "tests/user.test.js" -Value @'
const userService = require('../src/services/userService');
const User = require('../src/models/user');

// Mock the User model to avoid real DB calls
jest.mock('../src/models/user');

describe('userService', () => {
  afterEach(() => jest.clearAllMocks());

  describe('registerUser()', () => {
    it('should throw 409 if email already exists', async () => {
      User.findOne.mockResolvedValue({ email: 'exists@test.com' });
      await expect(userService.registerUser({
        name: 'Test', email: 'exists@test.com', password: 'password123',
      })).rejects.toMatchObject({ statusCode: 409 });
    });

    it('should create a new user if email is unique', async () => {
      User.findOne.mockResolvedValue(null);
      const mockSave = jest.fn().mockResolvedValue(true);
      const mockUser = {
        name: 'New User',
        email: 'new@test.com',
        save: mockSave,
        toPublic: () => ({ name: 'New User', email: 'new@test.com', role: 'customer' }),
      };
      User.mockImplementation(() => mockUser);
      const result = await userService.registerUser({ name: 'New User', email: 'new@test.com', password: 'password123' });
      expect(mockSave).toHaveBeenCalledTimes(1);
      expect(result.email).toBe('new@test.com');
    });
  });

  describe('loginUser()', () => {
    it('should throw 401 for non-existent user', async () => {
      User.findOne.mockReturnValue({ select: jest.fn().mockResolvedValue(null) });
      await expect(userService.loginUser('ghost@test.com', 'password')).rejects.toMatchObject({ statusCode: 401 });
    });

    it('should throw 401 for wrong password', async () => {
      const mockUser = {
        _id: 'user123',
        role: 'customer',
        comparePassword: jest.fn().mockResolvedValue(false),
        lastLogin: null,
        save: jest.fn(),
      };
      User.findOne.mockReturnValue({ select: jest.fn().mockResolvedValue(mockUser) });
      await expect(userService.loginUser('test@test.com', 'wrongpassword')).rejects.toMatchObject({ statusCode: 401 });
    });
  });
});
'@

# --- tests/order.test.js ---
# THIS IS A KEY CONFLICT FILE for feature/merge-conflict
Set-Content -Path "tests/order.test.js" -Value @'
const orderService = require('../src/services/orderService');
const Order = require('../src/models/order');
const Product = require('../src/models/product');
const User = require('../src/models/user');

jest.mock('../src/models/order');
jest.mock('../src/models/product');
jest.mock('../src/models/user');

const mockProduct = {
  _id: 'prod123',
  name: 'Test Widget',
  sku: 'WDG-001',
  price: 29.99,
  stock: 100,
  isAvailable: true,
};

describe('orderService', () => {
  afterEach(() => jest.clearAllMocks());

  describe('calculateSubtotal()', () => {
    it('should correctly sum item prices', () => {
      const items = [
        { unitPrice: 10.00, quantity: 2 },
        { unitPrice: 5.50, quantity: 3 },
      ];
      expect(orderService.calculateSubtotal(items)).toBe(36.50);
    });

    it('should return 0 for an empty item list', () => {
      expect(orderService.calculateSubtotal([])).toBe(0);
    });
  });

  describe('cancelOrder()', () => {
    it('should throw 422 if order is not in pending state', async () => {
      const mockOrder = {
        user: { toString: () => 'user123' },
        status: 'shipped',
        items: [],
      };
      Order.findById.mockResolvedValue(mockOrder);

      await expect(orderService.cancelOrder('order123', 'user123')).rejects.toMatchObject({ statusCode: 422 });
    });

    it('should throw 403 if user does not own the order', async () => {
      const mockOrder = {
        user: { toString: () => 'otherUser' },
        status: 'pending',
      };
      Order.findById.mockResolvedValue(mockOrder);

      await expect(orderService.cancelOrder('order123', 'user123')).rejects.toMatchObject({ statusCode: 403 });
    });
  });
});
'@

# --- Commit everything to main ---
git add .
git commit -m "chore: initial project setup - ShopNow Order Management API

Sets up the complete Node.js/Express e-commerce backend with:
- User authentication (register/login)
- Product catalog with categories, stock management, reviews
- Order management with status transitions and inventory sync
- Centralized error handling and validation
- Jest test scaffolding"

git branch -M main

Write-Host "  -> main branch created (21 files)" -ForegroundColor Green

# ============================================================
# BRANCH 1: feature/amend-me
# ============================================================
Write-Host "[4/8] Creating feature/amend-me branch (amend scenario)..." -ForegroundColor Yellow

git checkout -b feature/amend-me

# --- Assignment.md for this branch ---
Set-Content -Path "Assignment.md" -Value @'
# Assignment: Fix a Bad Commit with `git commit --amend`

## Scenario
A developer was rushing to finish the "JWT Authentication" feature before end of sprint.
They made one commit — but it was a DISASTER. The commit:

1. **Leaked production secrets**: accidentally committed a real `.env` file containing
   the database password and JWT secret to the repository.
2. **Left debug code in**: `src/controllers/userController.js` has a dozen `console.log`
   statements that were used during development and must be removed before production.
3. **Typo in commit message**: `"feat: add auth setup and login endpoit"` (missing 'n').

## Your Tasks

### Step 1: Inspect the damage
```bash
git log --oneline -5
git show HEAD --stat
git diff HEAD~1 HEAD
```

### Step 2: Remove the `.env` file from the commit
The `.env` file must NEVER be committed. Remove it from git's tracking:
```bash
git rm --cached .env
```
Then open `.gitignore` and make sure `.env` is listed (it should already be — just verify).

### Step 3: Remove debug console.logs
Open `src/controllers/userController.js` and remove ALL the `console.log` debug
statements (lines marked with `// DEBUG`). Keep the real logic intact.

### Step 4: Amend the commit
Stage all your changes and amend the last commit:
```bash
git add src/controllers/userController.js .gitignore
git commit --amend -m "feat: add JWT authentication middleware and login endpoint"
```

### Step 5: Verify
```bash
git log --oneline -3       # Should show the corrected commit message
git show HEAD --stat       # Should NOT show .env
git diff HEAD~1 HEAD -- .env  # Should show nothing (file was removed from commit)
```

## Expected Final State
- `.env` is NOT tracked by git (but exists locally for development)
- `.gitignore` includes `.env`
- `src/controllers/userController.js` has NO debug console.log lines
- The amend commit message is exactly: `feat: add JWT authentication middleware and login endpoint`
'@

# Simulate the bad commit:
# 1. .env with real secrets (should NOT be committed!)
Set-Content -Path ".env" -Value @'
PORT=3000
NODE_ENV=production

# Database - PRODUCTION CREDENTIALS
MONGO_URI=mongodb+srv://shopnow_admin:Pr0d_P@ssw0rd_2024!@cluster0.mongodb.net/shopnow_production

# JWT - PRODUCTION SECRET
JWT_SECRET=6f8a3c2e1d7b9e4f2a5c8d1e3b6f9a2c4d7e0f1a3b5c8d9e2f4a6b8c0d1e3f
JWT_EXPIRES_IN=7d

# Stripe API Keys - LIVE KEYS
STRIPE_SECRET_KEY=sk_live_51KjH7aGqIv8mNpQr3xYz9wUv2fT6mLkO8nRsB4cEpA1dHiJlMoNqPrSt0uVw
STRIPE_WEBHOOK_SECRET=whsec_aB3cD4eF5gH6iJ7kL8mN9oP0qR1sT2uV3wX4yZ5
'@

# 2. userController.js with debug console.log spam
Set-Content -Path "src/controllers/userController.js" -Value @'
const userService = require('../services/userService');

/**
 * POST /api/users/register
 * Create a new user account.
 */
const register = async (req, res, next) => {
  try {
    console.log('[DEBUG] register() called with body:', JSON.stringify(req.body)); // DEBUG
    console.log('[DEBUG] Headers received:', JSON.stringify(req.headers));         // DEBUG
    const user = await userService.registerUser(req.body);
    console.log('[DEBUG] registerUser() returned:', JSON.stringify(user));         // DEBUG
    res.status(201).json({ success: true, message: 'Account created successfully.', data: user });
  } catch (err) {
    console.log('[DEBUG] register() threw error:', err.message, err.stack);       // DEBUG
    next(err);
  }
};

/**
 * POST /api/users/login
 * Authenticate and receive a JWT token.
 */
const login = async (req, res, next) => {
  try {
    console.log('[DEBUG] login() called. Email:', req.body.email);                // DEBUG
    console.log('[DEBUG] Raw password received (length):', req.body.password?.length); // DEBUG - SECURITY RISK!
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required.' });
    }
    const result = await userService.loginUser(email, password);
    console.log('[DEBUG] loginUser() result token:', result.token);               // DEBUG - LEAKS TOKEN IN LOGS!
    console.log('[DEBUG] loginUser() user object:', JSON.stringify(result.user)); // DEBUG
    res.json({ success: true, message: 'Login successful.', data: result });
  } catch (err) {
    console.log('[DEBUG] login() error:', err);                                   // DEBUG
    next(err);
  }
};

/**
 * GET /api/users/me
 * Get the currently authenticated user's profile.
 */
const getMe = async (req, res, next) => {
  try {
    console.log('[DEBUG] getMe() - req.user from auth middleware:', JSON.stringify(req.user)); // DEBUG
    const user = await userService.getUserById(req.user.id);
    res.json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/users
 * List all users (admin only).
 */
const getAllUsers = async (req, res, next) => {
  try {
    console.log('[DEBUG] getAllUsers() called by user:', req.user?.id);            // DEBUG
    const users = await userService.getAllUsers();
    console.log('[DEBUG] getAllUsers() found', users.length, 'users');             // DEBUG
    res.json({ success: true, count: users.length, data: users });
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /api/users/:id
 * Deactivate a user account (admin only).
 */
const deactivateUser = async (req, res, next) => {
  try {
    const user = await userService.deactivateUser(req.params.id);
    res.json({ success: true, message: 'User account deactivated.', data: user });
  } catch (err) {
    next(err);
  }
};

module.exports = { register, login, getMe, getAllUsers, deactivateUser };
'@

# 3. userRoutes.js - with login route wired up, but no authenticate middleware yet
Set-Content -Path "src/routes/userRoutes.js" -Value @'
const express = require('express');
const router = express.Router();
const { register, login, getMe, getAllUsers, deactivateUser } = require('../controllers/userController');
// TODO: import authenticate middleware once it exists
// const authenticate = require('../middleware/authenticate');

// Public routes
router.post('/register', register);
router.post('/login', login);

// Protected routes - authenticate middleware not yet applied (forgot to create the file!)
router.get('/me', getMe);

// Admin-only routes
router.get('/', getAllUsers);
router.delete('/:id', deactivateUser);

module.exports = router;
'@

git add Assignment.md .env src/controllers/userController.js src/routes/userRoutes.js
git commit -m "feat: add auth setup and login endpoit"

git checkout main
Write-Host "  -> feature/amend-me created" -ForegroundColor Green

# ============================================================
# BRANCH 2: feature/squash-me
# ============================================================
Write-Host "[5/8] Creating feature/squash-me branch (squash scenario, 12 commits)..." -ForegroundColor Yellow

git checkout -b feature/squash-me

# --- Assignment.md ---
Set-Content -Path "Assignment.md" -Value @'
# Assignment: Clean Up a Messy Sprint History with Interactive Rebase

## Scenario
The payments feature was developed during a frantic sprint. The developer committed
frequently and messily — 12 commits across 5 files, including a commit that added
massive debug logging to half the codebase.

Your job is to use `git rebase -i` to produce a single, clean, professional commit.

## Your Tasks

### Step 1: Inspect the commit history
```bash
git log --oneline
```
You will see 12 commits on this branch (on top of the initial project commit).

### Step 2: Identify the "bad" commit
Find the commit with message `"debug: add verbose logging everywhere"`. This commit
added console.log spam to `paymentService.js`, `paymentController.js`, and
`database.js`. It must be **completely dropped**.

### Step 3: Launch interactive rebase
```bash
git rebase -i HEAD~12
```

In the editor:
- Change the FIRST commit's action from `pick` to `pick` (keep it as the base)
- Change all OTHER commits (except the debug one) to `squash` or `s`
- Change the `"debug: add verbose logging everywhere"` commit to `drop` or `d`

### Step 4: Write the final commit message
After dropping and squashing, git will prompt you for a final commit message.
Use exactly:
```
feat: implement payment processing module

Adds complete payment processing support including:
- Payment model with card validation
- Payment service with amount and card number validation
- Payment controller for REST endpoints
- Payment routes (POST /api/payments, GET /api/payments/:id)
- Unit tests for payment service
- Payment limits added to app constants
```

### Step 5: Verify the result
```bash
git log --oneline          # Should show exactly 2 commits (initial + your squashed one)
git show HEAD --stat       # Should show all payment files, NO debug logs anywhere
git diff HEAD -- src/config/constants.js  # Should contain PAYMENT_LIMITS
```

## Expected Final State
- Exactly ONE new commit on top of the base commit
- The commit contains all 5 payment files with clean, production-ready code
- NO debug console.log statements anywhere in the codebase
- Commit message matches exactly what is specified above
'@

git add Assignment.md
git commit -m "chore: add squash assignment instructions"

# Commit 1: Payment service skeleton
Set-Content -Path "src/services/paymentService.js" -Value @'
const { ORDER_LIMITS } = require('../config/constants');

// TODO: integrate with real payment gateway (Stripe)
// TODO: add card tokenization

/**
 * Process a payment for an order.
 * @param {Object} paymentData - { orderId, amount, cardNumber, expiryMonth, expiryYear, cvv }
 */
const processPayment = async (paymentData) => {
  // TODO: implement
  throw new Error('Not implemented yet');
};

module.exports = { processPayment };
'@
git add src/services/paymentService.js
git commit -m "wip: start payments module - add paymentService skeleton"

# Commit 2: Payment model
Set-Content -Path "src/models/payment.js" -Value @'
const mongoose = require('mongoose');

const PAYMENT_STATUS = {
  PENDING: 'pending',
  PROCESSING: 'processing',
  COMPLETED: 'completed',
  FAILED: 'failed',
  REFUNDED: 'refunded',
};

const paymentSchema = new mongoose.Schema({
  order: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: [true, 'Order reference is required'],
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User reference is required'],
  },
  amount: {
    type: Number,
    required: [true, 'Payment amount is required'],
    min: [0.01, 'Amount must be greater than zero'],
  },
  currency: {
    type: String,
    default: 'USD',
    uppercase: true,
    enum: ['USD', 'EUR', 'GBP', 'CAD'],
  },
  status: {
    type: String,
    enum: Object.values(PAYMENT_STATUS),
    default: PAYMENT_STATUS.PENDING,
  },
  // Store only last 4 digits — NEVER store full card numbers!
  cardLastFour: {
    type: String,
    required: true,
    match: [/^\d{4}$/, 'cardLastFour must be exactly 4 digits'],
  },
  cardBrand: {
    type: String,
    enum: ['visa', 'mastercard', 'amex', 'discover'],
  },
  transactionId: {  // External gateway transaction reference
    type: String,
    unique: true,
    sparse: true,
  },
  failureReason: { type: String },
  processedAt: { type: Date },
}, { timestamps: true });

paymentSchema.index({ order: 1 });
paymentSchema.index({ user: 1, status: 1 });
paymentSchema.index({ transactionId: 1 });

module.exports = mongoose.model('Payment', paymentSchema);
module.exports.PAYMENT_STATUS = PAYMENT_STATUS;
'@
git add src/models/payment.js
git commit -m "feat: add Payment mongoose model with status tracking"

# Commit 3: Payment routes stub
Set-Content -Path "src/routes/paymentRoutes.js" -Value @'
const express = require('express');
const router = express.Router();
// TODO: wire up controller once it exists
// const paymentController = require('../controllers/paymentController');

// POST /api/payments - initiate payment
router.put('/', (req, res) => res.status(501).json({ message: 'Not implemented' }));

// GET /api/payments/:id - get payment status
router.get('/:id', (req, res) => res.status(501).json({ message: 'Not implemented' }));

module.exports = router;
'@
git add src/routes/paymentRoutes.js
git commit -m "wip: stub out payment routes (need to wire controller)"

# Commit 4: THE BAD COMMIT - debug logging everywhere (must be DROPPED)
$dbJs = Get-Content "src/config/database.js" -Raw
$dbJsDebug = $dbJs -replace "console.log\(`\[DB\] MongoDB connected:", "console.log('[DEBUG-PAYMENTS] DB module loaded at:', new Date().toISOString());`n    console.log('[DEBUG-PAYMENTS] MONGO_URI is:', process.env.MONGO_URI);`n    console.log('[DEBUG-PAYMENTS] Full connection options:', JSON.stringify(arguments));`n    console.log('[DB] MongoDB connected:"
Set-Content -Path "src/config/database.js" -Value $dbJsDebug

Set-Content -Path "src/services/paymentService.js" -Value @'
const { ORDER_LIMITS } = require('../config/constants');

const processPayment = async (paymentData) => {
  console.log('[DEBUG] processPayment() CALLED - full paymentData:', JSON.stringify(paymentData));
  console.log('[DEBUG] cardNumber (FULL!):', paymentData.cardNumber);   // SECURITY RISK - logs card number!
  console.log('[DEBUG] cvv:', paymentData.cvv);                         // SECURITY RISK - logs CVV!
  console.log('[DEBUG] amount:', paymentData.amount);
  console.log('[DEBUG] ORDER_LIMITS from config:', JSON.stringify(ORDER_LIMITS));
  throw new Error('Not implemented yet');
};

module.exports = { processPayment };
'@

git add src/config/database.js src/services/paymentService.js
git commit -m "debug: add verbose logging everywhere to trace payment flow"

# Commit 5: Fix amount validation
Set-Content -Path "src/services/paymentService.js" -Value @'
const Payment = require('../models/payment');
const { PAYMENT_LIMITS } = require('../config/constants');

/**
 * Validate that a payment amount is within acceptable bounds.
 */
const validateAmount = (amount) => {
  if (!amount || typeof amount !== 'number') {
    const err = new Error('Payment amount must be a valid number.');
    err.statusCode = 400;
    throw err;
  }
  if (amount <= 0) {
    const err = new Error('Payment amount must be greater than zero.');
    err.statusCode = 400;
    throw err;
  }
  if (amount > PAYMENT_LIMITS.MAX_TRANSACTION_AMOUNT) {
    const err = new Error(`Payment amount cannot exceed $${PAYMENT_LIMITS.MAX_TRANSACTION_AMOUNT}.`);
    err.statusCode = 400;
    throw err;
  }
};

/**
 * Process a payment for an order.
 */
const processPayment = async (paymentData) => {
  const { orderId, userId, amount, cardNumber, expiryMonth, expiryYear, cvv } = paymentData;

  validateAmount(amount);

  // TODO: validate card number format
  // TODO: call payment gateway

  const cardLastFour = String(cardNumber).slice(-4);

  const payment = new Payment({
    order: orderId,
    user: userId,
    amount,
    cardLastFour,
    status: 'pending',
  });

  await payment.save();
  return payment;
};

module.exports = { processPayment, validateAmount };
'@
git add src/services/paymentService.js
git commit -m "fix: add payment amount validation with min/max limits"

# Commit 6: Payment controller
Set-Content -Path "src/controllers/paymentController.js" -Value @'
const paymentService = require('../services/paymentService');

/**
 * POST /api/payments
 * Initiate a payment for an order.
 */
const initiatePayment = async (req, res, next) => {
  try {
    // TODO: add input validation middleware
    // TODO: verify order belongs to req.user
    const paymentData = { ...req.body, userId: req.user.id };
    const payment = await paymentService.processPayment(paymentData);
    res.status(201).json({ success: true, message: 'Payment initiated.', data: payment });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/payments/:id
 * Get payment status by payment ID.
 */
const getPaymentStatus = async (req, res, next) => {
  try {
    // TODO: implement getPaymentById in service
    res.status(501).json({ success: false, message: 'Not yet implemented.' });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/payments/:id/refund
 * Initiate a refund for a completed payment.
 */
const refundPayment = async (req, res, next) => {
  try {
    // TODO: implement refund logic
    res.status(501).json({ success: false, message: 'Refunds not yet implemented.' });
  } catch (err) {
    next(err);
  }
};

module.exports = { initiatePayment, getPaymentStatus, refundPayment };
'@
git add src/controllers/paymentController.js
git commit -m "wip payment controller - initiatePayment stub with TODOs"

# Commit 7: Fix HTTP method in routes
Set-Content -Path "src/routes/paymentRoutes.js" -Value @'
const express = require('express');
const router = express.Router();
const { initiatePayment, getPaymentStatus, refundPayment } = require('../controllers/paymentController');

// POST /api/payments - initiate a payment
router.post('/', initiatePayment);

// GET /api/payments/:id - get payment status
router.get('/:id', getPaymentStatus);

// POST /api/payments/:id/refund - refund a payment
router.post('/:id/refund', refundPayment);

module.exports = router;
'@
git add src/routes/paymentRoutes.js
git commit -m "fix: correct HTTP method for payment creation (POST not PUT)"

# Commit 8: Add test stubs
Set-Content -Path "tests/payment.test.js" -Value @'
const paymentService = require('../src/services/paymentService');
const Payment = require('../src/models/payment');

jest.mock('../src/models/payment');

describe('paymentService', () => {
  afterEach(() => jest.clearAllMocks());

  describe('validateAmount()', () => {
    it('should throw 400 for zero amount', () => {
      expect(() => paymentService.validateAmount(0)).toThrow();
    });

    it('should throw 400 for negative amount', () => {
      expect(() => paymentService.validateAmount(-50)).toThrow();
    });

    it('should not throw for valid amount', () => {
      expect(() => paymentService.validateAmount(99.99)).not.toThrow();
    });

    // TODO: test max amount validation
    // TODO: test non-number input
  });

  describe('processPayment()', () => {
    // TODO: mock payment gateway
    // TODO: test successful payment creation
    // TODO: test failed payment handling
    // TODO: test card validation
  });
});
'@
git add tests/payment.test.js
git commit -m "test: add payment service test stubs (validateAmount coverage)"

# Commit 9: Fix card number validation
Set-Content -Path "src/services/paymentService.js" -Value @'
const Payment = require('../models/payment');
const { PAYMENT_LIMITS } = require('../config/constants');

/**
 * Validate that a payment amount is within acceptable bounds.
 */
const validateAmount = (amount) => {
  if (!amount || typeof amount !== 'number') {
    const err = new Error('Payment amount must be a valid number.');
    err.statusCode = 400;
    throw err;
  }
  if (amount <= 0) {
    const err = new Error('Payment amount must be greater than zero.');
    err.statusCode = 400;
    throw err;
  }
  if (amount > PAYMENT_LIMITS.MAX_TRANSACTION_AMOUNT) {
    const err = new Error(`Payment amount cannot exceed $${PAYMENT_LIMITS.MAX_TRANSACTION_AMOUNT}.`);
    err.statusCode = 400;
    throw err;
  }
};

/**
 * Validate basic card number format (16 digits for Visa/MC, 15 for Amex).
 * NOTE: This is basic format validation only — real validation happens at the gateway.
 */
const validateCardNumber = (cardNumber) => {
  const cleaned = String(cardNumber).replace(/\s|-/g, '');
  if (!/^\d{15,16}$/.test(cleaned)) {
    const err = new Error('Card number must be 15 or 16 digits.');
    err.statusCode = 400;
    throw err;
  }
  return cleaned;
};

/**
 * Detect card brand from card number prefix.
 */
const detectCardBrand = (cardNumber) => {
  if (/^4/.test(cardNumber)) return 'visa';
  if (/^5[1-5]/.test(cardNumber)) return 'mastercard';
  if (/^3[47]/.test(cardNumber)) return 'amex';
  if (/^6(?:011|5)/.test(cardNumber)) return 'discover';
  return null;
};

/**
 * Process a payment for an order.
 */
const processPayment = async (paymentData) => {
  const { orderId, userId, amount, cardNumber, expiryMonth, expiryYear, cvv } = paymentData;

  validateAmount(amount);
  const cleanedCard = validateCardNumber(cardNumber);
  const cardLastFour = cleanedCard.slice(-4);
  const cardBrand = detectCardBrand(cleanedCard);

  // TODO: call actual payment gateway (Stripe/Braintree)
  // const gatewayResponse = await stripeClient.charges.create({...});

  const payment = new Payment({
    order: orderId,
    user: userId,
    amount,
    cardLastFour,
    cardBrand,
    status: 'pending',
  });

  await payment.save();
  return payment;
};

module.exports = { processPayment, validateAmount, validateCardNumber, detectCardBrand };
'@
git add src/services/paymentService.js
git commit -m "fix: validate card number must be 15-16 digits, detect card brand"

# Commit 10: Update constants with payment limits
$constantsContent = Get-Content "src/config/constants.js" -Raw
$constantsContent = $constantsContent -replace "(// --- Cache ---)", @"
  // --- Payment Configuration ---
  PAYMENT_LIMITS: {
    MIN_TRANSACTION_AMOUNT: 0.50,
    MAX_TRANSACTION_AMOUNT: 25000.00,
    MAX_REFUND_DAYS: 30,
    SUPPORTED_CURRENCIES: ['USD', 'EUR', 'GBP', 'CAD'],
  },

  `$1
"@
Set-Content -Path "src/config/constants.js" -Value $constantsContent
git add src/config/constants.js
git commit -m "chore: add PAYMENT_LIMITS constants to config"

# Commit 11: Remove TODO comments from service and controller
$svcContent = Get-Content "src/services/paymentService.js" -Raw
$svcContent = $svcContent -replace "\s*// TODO: call actual payment gateway.*\n\s*// const gatewayResponse.*\n", "`n  "
Set-Content -Path "src/services/paymentService.js" -Value $svcContent

$ctrlContent = Get-Content "src/controllers/paymentController.js" -Raw
$ctrlContent = $ctrlContent -replace "\s*// TODO: add input validation middleware\n", ""
$ctrlContent = $ctrlContent -replace "\s*// TODO: verify order belongs to req.user\n", ""
Set-Content -Path "src/controllers/paymentController.js" -Value $ctrlContent

git add src/services/paymentService.js src/controllers/paymentController.js
git commit -m "refactor: remove TODO comments from payment service and controller"

# Commit 12: Rename field in payment model (transactionId -> paymentId for clarity)
$paymentModel = Get-Content "src/models/payment.js" -Raw
$paymentModel = $paymentModel -replace "transactionId:", "paymentId:"
$paymentModel = $paymentModel -replace "transactionId: 1", "paymentId: 1"
Set-Content -Path "src/models/payment.js" -Value $paymentModel
git add src/models/payment.js
git commit -m "fix: rename transactionId to paymentId in Payment model for clarity"

git checkout main
Write-Host "  -> feature/squash-me created (12 commits)" -ForegroundColor Green

# ============================================================
# BRANCH 3: feature/rebase-me
# Branches off main BEFORE main gets the tax update.
# Adds DISCOUNT system. Main will later add TAX system.
# Both change orderService.js, order.js, constants.js -> CONFLICT
# ============================================================
Write-Host "[6/8] Creating feature/rebase-me branch (rebase conflict scenario)..." -ForegroundColor Yellow

git checkout -b feature/rebase-me

# --- Assignment.md ---
Set-Content -Path "Assignment.md" -Value @'
# Assignment: Rebase with Multi-File Conflicts

## Scenario
You are working on the `feature/rebase-me` branch, which adds a **Discount Code System**
to the order management API.

While you were working on this, the team merged a **Tax Calculation System** into `main`.

Both changes heavily modified the same three files:
- `src/services/orderService.js` — both changed `calculateTotal()` and `createOrder()`
- `src/models/order.js` — both added new fields to the order schema
- `src/config/constants.js` — both added new config constants

## Your Tasks

### Step 1: Inspect the situation
```bash
git log --oneline                         # See your commits on this branch
git log --oneline main                    # See what main has that you don't
git diff HEAD main -- src/services/orderService.js   # Preview the differences
```

### Step 2: Start the rebase
```bash
git rebase main
```
Git will pause with conflict markers in **3 files**. Do NOT panic.

### Step 3: Resolve conflicts in `src/config/constants.js`
- Keep BOTH the `DISCOUNT_CONFIG` block (your change) AND the `TAX_CONFIG` block (from main)
- Keep BOTH the updated `ORDER_LIMITS` sections — merge them together

### Step 4: Resolve conflicts in `src/models/order.js`
- Keep BOTH the `discountCode` + `discountAmount` fields (your change)
  AND the `taxRate` + `taxAmount` fields (from main)
- The final schema should support both discounts AND taxes

### Step 5: Resolve conflicts in `src/services/orderService.js`
- `calculateTotal()` was changed by both branches:
  - Your version: accepts a `discountAmount` parameter
  - Main's version: accepts a `taxRate` parameter
  - **Resolution**: accept BOTH parameters: `calculateTotal(subtotal, discountAmount = 0, taxRate = 0)`
- Keep BOTH `applyDiscount()` (your function) AND `calculateTax()` (main's function)
- In `createOrder()`: include BOTH discount code handling AND tax calculation

### Step 6: Mark as resolved and continue
```bash
git add src/config/constants.js src/models/order.js src/services/orderService.js
git rebase --continue
```
Write a commit message if prompted, then complete the rebase.

### Step 7: Verify
```bash
git log --oneline                         # Your commits should now be on top of main
git diff main -- src/services/orderService.js   # Should show discount + tax features
```

## Expected Final State
- This branch is cleanly rebased on top of the latest `main`
- `orderService.js` has: `applyDiscount()`, `calculateTax()`, and `calculateTotal(subtotal, discountAmount, taxRate)`
- `order.js` schema has: `discountCode`, `discountAmount`, `taxRate`, `taxAmount` fields
- `constants.js` has: both `DISCOUNT_CONFIG` and `TAX_CONFIG` sections
'@
git add Assignment.md
git commit -m "docs: add rebase assignment instructions"

# Feature branch: Discount System changes
# 1. Update constants.js with DISCOUNT config
$constantsForDiscount = Get-Content "src/config/constants.js" -Raw
$discountAddition = @'

  // --- Discount Codes ---
  DISCOUNT_CONFIG: {
    MAX_DISCOUNT_PERCENTAGE: 75,
    MIN_ORDER_FOR_DISCOUNT: 25.00,
    CODES: {
      WELCOME10: { type: 'percentage', value: 10, description: 'Welcome offer - 10% off' },
      SAVE20: { type: 'percentage', value: 20, description: 'Loyalty reward - 20% off' },
      FREESHIP: { type: 'fixed', value: 9.99, description: 'Free shipping coupon' },
      VIP50: { type: 'percentage', value: 50, description: 'VIP member discount - 50% off' },
    },
  },

'@
$constantsForDiscount = $constantsForDiscount -replace "(  // --- Rate Limiting ---)", "$discountAddition  // --- Rate Limiting ---"
# Also update ORDER_LIMITS to note discount interaction
$constantsForDiscount = $constantsForDiscount -replace "(    MAX_ORDER_AMOUNT: 50000\.00,)", "    MAX_ORDER_AMOUNT: 50000.00,`n    MIN_DISCOUNT_ELIGIBLE_AMOUNT: 25.00,"
Set-Content -Path "src/config/constants.js" -Value $constantsForDiscount
git add src/config/constants.js
git commit -m "feat(discount): add DISCOUNT_CONFIG constants and discount eligibility limit"

# 2. Update order.js model with discount fields
Set-Content -Path "src/models/order.js" -Value @'
const mongoose = require('mongoose');
const { ORDER_STATUS } = require('../config/constants');

const orderItemSchema = new mongoose.Schema({
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: [true, 'Product reference is required'],
  },
  quantity: {
    type: Number,
    required: [true, 'Quantity is required'],
    min: [1, 'Quantity must be at least 1'],
    validate: { validator: Number.isInteger, message: 'Quantity must be a whole number' },
  },
  unitPrice: {
    type: Number,
    required: [true, 'Unit price is required'],
    min: [0, 'Unit price cannot be negative'],
  },
  productName: { type: String, required: true },
  productSku: { type: String, required: true },
}, { _id: false });

const shippingAddressSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  street: { type: String, required: true },
  city: { type: String, required: true },
  state: { type: String, required: true },
  zipCode: { type: String, required: true },
  country: { type: String, required: true, default: 'US' },
  phone: { type: String },
}, { _id: false });

const orderSchema = new mongoose.Schema({
  orderNumber: { type: String, unique: true },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User reference is required'],
  },
  items: {
    type: [orderItemSchema],
    validate: [(arr) => arr.length > 0, 'Order must have at least one item'],
  },
  status: {
    type: String,
    enum: Object.values(ORDER_STATUS),
    default: ORDER_STATUS.PENDING,
  },
  shippingAddress: {
    type: shippingAddressSchema,
    required: [true, 'Shipping address is required'],
  },
  subtotal: { type: Number, required: true, min: 0 },

  // --- Discount fields (added by feature/rebase-me) ---
  discountCode: {
    type: String,
    uppercase: true,
    trim: true,
  },
  discountAmount: {
    type: Number,
    default: 0,
    min: [0, 'Discount amount cannot be negative'],
  },
  discountDescription: { type: String },

  shippingCost: { type: Number, default: 0, min: 0 },
  totalAmount: { type: Number, required: true, min: 0 },
  paymentStatus: {
    type: String,
    enum: ['unpaid', 'paid', 'refunded'],
    default: 'unpaid',
  },
  notes: { type: String, maxlength: [500, 'Notes cannot exceed 500 characters'] },
  statusHistory: [{
    status: { type: String, enum: Object.values(ORDER_STATUS) },
    changedAt: { type: Date, default: Date.now },
    changedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    reason: String,
  }],
}, { timestamps: true });

orderSchema.pre('save', function (next) {
  if (!this.orderNumber) {
    const timestamp = Date.now().toString(36).toUpperCase();
    const random = Math.random().toString(36).substring(2, 6).toUpperCase();
    this.orderNumber = `ORD-${timestamp}-${random}`;
  }
  next();
});

orderSchema.index({ user: 1, status: 1, createdAt: -1 });
orderSchema.index({ orderNumber: 1 });
orderSchema.index({ discountCode: 1 });

module.exports = mongoose.model('Order', orderSchema);
'@
git add src/models/order.js
git commit -m "feat(discount): add discountCode, discountAmount, discountDescription fields to Order schema"

# 3. Update orderService.js with discount functions
Set-Content -Path "src/services/orderService.js" -Value @'
const Order = require('../models/order');
const Product = require('../models/product');
const User = require('../models/user');
const { ORDER_STATUS, ORDER_LIMITS, DISCOUNT_CONFIG } = require('../config/constants');

/**
 * Calculate the subtotal for a list of order items.
 */
const calculateSubtotal = (items) => {
  return items.reduce((total, item) => {
    return total + (item.unitPrice * item.quantity);
  }, 0);
};

/**
 * Calculate the grand total, applying a discount to the subtotal.
 * @param {number} subtotal
 * @param {number} discountAmount - flat amount to subtract (default: 0)
 * @returns {number} total amount due (never goes below 0)
 */
const calculateTotal = (subtotal, discountAmount = 0) => {
  const discounted = subtotal - discountAmount;
  return parseFloat(Math.max(0, discounted).toFixed(2));
};

/**
 * Look up and apply a discount code to a subtotal.
 * Returns the discount amount and a description.
 * @param {number} subtotal
 * @param {string} discountCode
 * @returns {{ discountAmount: number, discountDescription: string, valid: boolean }}
 */
const applyDiscount = (subtotal, discountCode) => {
  if (!discountCode) {
    return { discountAmount: 0, discountDescription: null, valid: false };
  }

  const code = DISCOUNT_CONFIG.CODES[discountCode.toUpperCase()];
  if (!code) {
    return { discountAmount: 0, discountDescription: null, valid: false };
  }

  if (subtotal < DISCOUNT_CONFIG.MIN_ORDER_FOR_DISCOUNT) {
    const err = new Error(`Discount codes require a minimum order of $${DISCOUNT_CONFIG.MIN_ORDER_FOR_DISCOUNT}.`);
    err.statusCode = 400;
    throw err;
  }

  let discountAmount = 0;
  if (code.type === 'percentage') {
    discountAmount = parseFloat((subtotal * (code.value / 100)).toFixed(2));
    const maxDiscount = subtotal * (DISCOUNT_CONFIG.MAX_DISCOUNT_PERCENTAGE / 100);
    discountAmount = Math.min(discountAmount, maxDiscount);
  } else if (code.type === 'fixed') {
    discountAmount = Math.min(code.value, subtotal);
  }

  return { discountAmount, discountDescription: code.description, valid: true };
};

/**
 * Validate order items against inventory and return enriched item list.
 */
const validateAndEnrichItems = async (items) => {
  if (!items || items.length === 0) {
    const err = new Error('Order must contain at least one item.');
    err.statusCode = 400;
    throw err;
  }
  if (items.length > ORDER_LIMITS.MAX_ITEMS_PER_ORDER) {
    const err = new Error(`Cannot exceed ${ORDER_LIMITS.MAX_ITEMS_PER_ORDER} items per order.`);
    err.statusCode = 400;
    throw err;
  }

  const enrichedItems = [];
  for (const item of items) {
    const product = await Product.findById(item.productId);
    if (!product) { const err = new Error(`Product '${item.productId}' not found.`); err.statusCode = 404; throw err; }
    if (!product.isAvailable) { const err = new Error(`'${product.name}' is unavailable.`); err.statusCode = 422; throw err; }
    if (product.stock < item.quantity) { const err = new Error(`Insufficient stock for '${product.name}'.`); err.statusCode = 422; throw err; }

    enrichedItems.push({
      product: product._id,
      quantity: item.quantity,
      unitPrice: product.price,
      productName: product.name,
      productSku: product.sku,
    });
  }
  return enrichedItems;
};

/**
 * Create a new order, applying an optional discount code.
 */
const createOrder = async (userId, orderData) => {
  const { items, shippingAddress, notes, discountCode } = orderData;

  const enrichedItems = await validateAndEnrichItems(items);
  const subtotal = calculateSubtotal(enrichedItems);

  if (subtotal < ORDER_LIMITS.MIN_ORDER_AMOUNT) { const err = new Error(`Minimum order is $${ORDER_LIMITS.MIN_ORDER_AMOUNT}.`); err.statusCode = 400; throw err; }
  if (subtotal > ORDER_LIMITS.MAX_ORDER_AMOUNT) { const err = new Error(`Maximum order is $${ORDER_LIMITS.MAX_ORDER_AMOUNT}.`); err.statusCode = 400; throw err; }

  // Apply discount code if provided
  const { discountAmount, discountDescription, valid } = applyDiscount(subtotal, discountCode);
  const totalAmount = calculateTotal(subtotal, discountAmount);

  const order = new Order({
    user: userId,
    items: enrichedItems,
    shippingAddress,
    subtotal,
    discountCode: valid ? discountCode.toUpperCase() : undefined,
    discountAmount,
    discountDescription,
    totalAmount,
    notes,
    statusHistory: [{ status: ORDER_STATUS.PENDING }],
  });

  await order.save();

  await Promise.all(enrichedItems.map((item) =>
    Product.findByIdAndUpdate(item.product, { $inc: { stock: -item.quantity } })
  ));

  await User.findByIdAndUpdate(userId, { $inc: { totalOrders: 1, totalSpend: totalAmount } });

  return order.populate('items.product');
};

const getOrdersByUser = async (userId) => {
  return Order.find({ user: userId }).populate('items.product', 'name sku images').sort({ createdAt: -1 });
};

const getOrderById = async (orderId, userId, userRole) => {
  const order = await Order.findById(orderId).populate('items.product');
  if (!order) { const err = new Error('Order not found.'); err.statusCode = 404; throw err; }
  if (userRole !== 'admin' && order.user.toString() !== userId.toString()) { const err = new Error('Not authorized.'); err.statusCode = 403; throw err; }
  return order;
};

const updateOrderStatus = async (orderId, newStatus, adminId, reason) => {
  const validTransitions = {
    pending: ['confirmed', 'cancelled'], confirmed: ['processing', 'cancelled'],
    processing: ['shipped', 'cancelled'], shipped: ['delivered'],
    delivered: ['refunded'], cancelled: [], refunded: [],
  };
  const order = await Order.findById(orderId);
  if (!order) { const err = new Error('Order not found.'); err.statusCode = 404; throw err; }
  if (!validTransitions[order.status].includes(newStatus)) { const err = new Error(`Cannot transition from '${order.status}' to '${newStatus}'.`); err.statusCode = 422; throw err; }
  order.status = newStatus;
  order.statusHistory.push({ status: newStatus, changedBy: adminId, reason });
  await order.save();
  return order;
};

const cancelOrder = async (orderId, userId) => {
  const order = await Order.findById(orderId);
  if (!order) { const err = new Error('Order not found.'); err.statusCode = 404; throw err; }
  if (order.user.toString() !== userId.toString()) { const err = new Error('Not authorized.'); err.statusCode = 403; throw err; }
  if (order.status !== ORDER_STATUS.PENDING) { const err = new Error('Only pending orders can be cancelled.'); err.statusCode = 422; throw err; }
  order.status = ORDER_STATUS.CANCELLED;
  order.statusHistory.push({ status: ORDER_STATUS.CANCELLED, changedBy: userId, reason: 'Cancelled by customer' });
  await order.save();
  await Promise.all(order.items.map((item) => Product.findByIdAndUpdate(item.product, { $inc: { stock: item.quantity } })));
  await User.findByIdAndUpdate(userId, { $inc: { totalOrders: -1, totalSpend: -order.totalAmount } });
  return order;
};

module.exports = {
  calculateSubtotal, calculateTotal, applyDiscount,
  validateAndEnrichItems, createOrder, getOrdersByUser,
  getOrderById, updateOrderStatus, cancelOrder,
};
'@
git add src/services/orderService.js
git commit -m "feat(discount): add applyDiscount() and update calculateTotal() + createOrder() to support discount codes"

git checkout main

# NOW update MAIN with TAX system (creates the rebase conflict for feature/rebase-me)
$constantsForTax = Get-Content "src/config/constants.js" -Raw
$taxAddition = @'

  // --- Tax Configuration ---
  TAX_CONFIG: {
    DEFAULT_RATE_PERCENTAGE: 8.5,
    RATES_BY_STATE: {
      CA: 10.25,
      NY: 8.875,
      TX: 8.25,
      FL: 7.00,
      WA: 10.50,
      OR: 0.00,
      MT: 0.00,
    },
    TAX_EXEMPT_CATEGORIES: ['food-beverage'],
  },

'@
$constantsForTax = $constantsForTax -replace "(  // --- Rate Limiting ---)", "$taxAddition  // --- Rate Limiting ---"
$constantsForTax = $constantsForTax -replace "(    MIN_ORDER_AMOUNT: 1\.00,)", "    MIN_ORDER_AMOUNT: 1.00,`n    INCLUDE_TAX_IN_MINIMUM: false,"
Set-Content -Path "src/config/constants.js" -Value $constantsForTax
git add src/config/constants.js

Set-Content -Path "src/models/order.js" -Value @'
const mongoose = require('mongoose');
const { ORDER_STATUS } = require('../config/constants');

const orderItemSchema = new mongoose.Schema({
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: [true, 'Product reference is required'],
  },
  quantity: {
    type: Number,
    required: [true, 'Quantity is required'],
    min: [1, 'Quantity must be at least 1'],
    validate: { validator: Number.isInteger, message: 'Quantity must be a whole number' },
  },
  unitPrice: {
    type: Number,
    required: [true, 'Unit price is required'],
    min: [0, 'Unit price cannot be negative'],
  },
  productName: { type: String, required: true },
  productSku: { type: String, required: true },
}, { _id: false });

const shippingAddressSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  street: { type: String, required: true },
  city: { type: String, required: true },
  state: { type: String, required: true },
  zipCode: { type: String, required: true },
  country: { type: String, required: true, default: 'US' },
  phone: { type: String },
}, { _id: false });

const orderSchema = new mongoose.Schema({
  orderNumber: { type: String, unique: true },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User reference is required'],
  },
  items: {
    type: [orderItemSchema],
    validate: [(arr) => arr.length > 0, 'Order must have at least one item'],
  },
  status: {
    type: String,
    enum: Object.values(ORDER_STATUS),
    default: ORDER_STATUS.PENDING,
  },
  shippingAddress: {
    type: shippingAddressSchema,
    required: [true, 'Shipping address is required'],
  },
  subtotal: { type: Number, required: true, min: 0 },

  // --- Tax fields (added by main - tax calculation feature) ---
  taxRate: {
    type: Number,
    default: 0,
    min: [0, 'Tax rate cannot be negative'],
    max: [50, 'Tax rate seems unreasonably high'],
  },
  taxAmount: {
    type: Number,
    default: 0,
    min: [0, 'Tax amount cannot be negative'],
  },
  taxExempt: { type: Boolean, default: false },

  shippingCost: { type: Number, default: 0, min: 0 },
  totalAmount: { type: Number, required: true, min: 0 },
  paymentStatus: {
    type: String,
    enum: ['unpaid', 'paid', 'refunded'],
    default: 'unpaid',
  },
  notes: { type: String, maxlength: [500, 'Notes cannot exceed 500 characters'] },
  statusHistory: [{
    status: { type: String, enum: Object.values(ORDER_STATUS) },
    changedAt: { type: Date, default: Date.now },
    changedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    reason: String,
  }],
}, { timestamps: true });

orderSchema.pre('save', function (next) {
  if (!this.orderNumber) {
    const timestamp = Date.now().toString(36).toUpperCase();
    const random = Math.random().toString(36).substring(2, 6).toUpperCase();
    this.orderNumber = `ORD-${timestamp}-${random}`;
  }
  next();
});

orderSchema.index({ user: 1, status: 1, createdAt: -1 });
orderSchema.index({ orderNumber: 1 });

module.exports = mongoose.model('Order', orderSchema);
'@
git add src/models/order.js

Set-Content -Path "src/services/orderService.js" -Value @'
const Order = require('../models/order');
const Product = require('../models/product');
const User = require('../models/user');
const { ORDER_STATUS, ORDER_LIMITS, TAX_CONFIG } = require('../config/constants');

/**
 * Calculate the subtotal for a list of order items.
 */
const calculateSubtotal = (items) => {
  return items.reduce((total, item) => {
    return total + (item.unitPrice * item.quantity);
  }, 0);
};

/**
 * Calculate the tax amount for a given subtotal and tax rate.
 * @param {number} subtotal
 * @param {number} taxRate - tax percentage (e.g., 8.5 for 8.5%)
 * @returns {number} tax amount
 */
const calculateTax = (subtotal, taxRate) => {
  if (!taxRate || taxRate <= 0) return 0;
  return parseFloat((subtotal * (taxRate / 100)).toFixed(2));
};

/**
 * Get the applicable tax rate for a shipping address state.
 */
const getTaxRateForState = (state) => {
  return TAX_CONFIG.RATES_BY_STATE[state?.toUpperCase()] ?? TAX_CONFIG.DEFAULT_RATE_PERCENTAGE;
};

/**
 * Calculate the grand total including tax.
 * @param {number} subtotal
 * @param {number} taxRate - tax percentage (default: 0)
 * @returns {number} total amount due
 */
const calculateTotal = (subtotal, taxRate = 0) => {
  const taxAmount = calculateTax(subtotal, taxRate);
  return parseFloat((subtotal + taxAmount).toFixed(2));
};

/**
 * Validate order items against inventory and return enriched item list.
 */
const validateAndEnrichItems = async (items) => {
  if (!items || items.length === 0) {
    const err = new Error('Order must contain at least one item.');
    err.statusCode = 400;
    throw err;
  }
  if (items.length > ORDER_LIMITS.MAX_ITEMS_PER_ORDER) {
    const err = new Error(`Cannot exceed ${ORDER_LIMITS.MAX_ITEMS_PER_ORDER} items per order.`);
    err.statusCode = 400;
    throw err;
  }

  const enrichedItems = [];
  for (const item of items) {
    const product = await Product.findById(item.productId);
    if (!product) { const err = new Error(`Product '${item.productId}' not found.`); err.statusCode = 404; throw err; }
    if (!product.isAvailable) { const err = new Error(`'${product.name}' is unavailable.`); err.statusCode = 422; throw err; }
    if (product.stock < item.quantity) { const err = new Error(`Insufficient stock for '${product.name}'.`); err.statusCode = 422; throw err; }

    enrichedItems.push({
      product: product._id,
      quantity: item.quantity,
      unitPrice: product.price,
      productName: product.name,
      productSku: product.sku,
    });
  }
  return enrichedItems;
};

/**
 * Create a new order, calculating applicable tax based on shipping state.
 */
const createOrder = async (userId, orderData) => {
  const { items, shippingAddress, notes } = orderData;

  const enrichedItems = await validateAndEnrichItems(items);
  const subtotal = calculateSubtotal(enrichedItems);

  if (subtotal < ORDER_LIMITS.MIN_ORDER_AMOUNT) { const err = new Error(`Minimum order is $${ORDER_LIMITS.MIN_ORDER_AMOUNT}.`); err.statusCode = 400; throw err; }
  if (subtotal > ORDER_LIMITS.MAX_ORDER_AMOUNT) { const err = new Error(`Maximum order is $${ORDER_LIMITS.MAX_ORDER_AMOUNT}.`); err.statusCode = 400; throw err; }

  // Calculate tax based on shipping state
  const taxRate = getTaxRateForState(shippingAddress?.state);
  const taxAmount = calculateTax(subtotal, taxRate);
  const totalAmount = calculateTotal(subtotal, taxRate);

  const order = new Order({
    user: userId,
    items: enrichedItems,
    shippingAddress,
    subtotal,
    taxRate,
    taxAmount,
    totalAmount,
    notes,
    statusHistory: [{ status: ORDER_STATUS.PENDING }],
  });

  await order.save();

  await Promise.all(enrichedItems.map((item) =>
    Product.findByIdAndUpdate(item.product, { $inc: { stock: -item.quantity } })
  ));

  await User.findByIdAndUpdate(userId, { $inc: { totalOrders: 1, totalSpend: totalAmount } });

  return order.populate('items.product');
};

const getOrdersByUser = async (userId) => {
  return Order.find({ user: userId }).populate('items.product', 'name sku images').sort({ createdAt: -1 });
};

const getOrderById = async (orderId, userId, userRole) => {
  const order = await Order.findById(orderId).populate('items.product');
  if (!order) { const err = new Error('Order not found.'); err.statusCode = 404; throw err; }
  if (userRole !== 'admin' && order.user.toString() !== userId.toString()) { const err = new Error('Not authorized.'); err.statusCode = 403; throw err; }
  return order;
};

const updateOrderStatus = async (orderId, newStatus, adminId, reason) => {
  const validTransitions = {
    pending: ['confirmed', 'cancelled'], confirmed: ['processing', 'cancelled'],
    processing: ['shipped', 'cancelled'], shipped: ['delivered'],
    delivered: ['refunded'], cancelled: [], refunded: [],
  };
  const order = await Order.findById(orderId);
  if (!order) { const err = new Error('Order not found.'); err.statusCode = 404; throw err; }
  if (!validTransitions[order.status].includes(newStatus)) { const err = new Error(`Cannot transition from '${order.status}' to '${newStatus}'.`); err.statusCode = 422; throw err; }
  order.status = newStatus;
  order.statusHistory.push({ status: newStatus, changedBy: adminId, reason });
  await order.save();
  return order;
};

const cancelOrder = async (orderId, userId) => {
  const order = await Order.findById(orderId);
  if (!order) { const err = new Error('Order not found.'); err.statusCode = 404; throw err; }
  if (order.user.toString() !== userId.toString()) { const err = new Error('Not authorized.'); err.statusCode = 403; throw err; }
  if (order.status !== ORDER_STATUS.PENDING) { const err = new Error('Only pending orders can be cancelled.'); err.statusCode = 422; throw err; }
  order.status = ORDER_STATUS.CANCELLED;
  order.statusHistory.push({ status: ORDER_STATUS.CANCELLED, changedBy: userId, reason: 'Cancelled by customer' });
  await order.save();
  await Promise.all(order.items.map((item) => Product.findByIdAndUpdate(item.product, { $inc: { stock: item.quantity } })));
  await User.findByIdAndUpdate(userId, { $inc: { totalOrders: -1, totalSpend: -order.totalAmount } });
  return order;
};

module.exports = {
  calculateSubtotal, calculateTotal, calculateTax, getTaxRateForState,
  validateAndEnrichItems, createOrder, getOrdersByUser,
  getOrderById, updateOrderStatus, cancelOrder,
};
'@
git add src/services/orderService.js

git commit -m "feat(tax): add tax calculation system with state-based rates

- Add TAX_CONFIG with per-state tax rates to constants.js
- Add taxRate, taxAmount, taxExempt fields to Order schema
- Add calculateTax() and getTaxRateForState() to orderService
- calculateTotal() now includes tax in grand total
- createOrder() automatically applies tax based on shipping state"

Write-Host "  -> feature/rebase-me created + main updated with tax system" -ForegroundColor Green

# ============================================================
# BRANCH 4: feature/merge-conflict
# Branches off main AFTER the tax update.
# Adds PAGINATION + SEARCH to orders.
# Main will add CACHING + RATE LIMITING -> 5-file conflict
# ============================================================
Write-Host "[7/8] Creating feature/merge-conflict branch (merge conflict scenario)..." -ForegroundColor Yellow

git checkout -b feature/merge-conflict

# --- Assignment.md ---
Set-Content -Path "Assignment.md" -Value @'
# Assignment: Resolve a Multi-File Merge Conflict

## Scenario
Two developers worked on the same files simultaneously during a sprint:

**You (feature/merge-conflict branch)** added:
- Pagination and filtering support to `GET /api/orders`
- A new `GET /api/orders/search` endpoint for full-text order search
- Enhanced test coverage in `tests/order.test.js`
- Updated `src/routes/orderRoutes.js` to include the search route
- Updated `src/middleware/errorHandler.js` to handle search-specific errors

**Your colleague (on main)** added:
- In-memory caching layer for the `GET /api/orders` endpoint
- Rate limiting middleware on all order routes to prevent abuse
- Also enhanced error handling in `src/middleware/errorHandler.js`

Both of you modified **5 of the same files**. When you try to merge main into your
branch, you will get conflicts in all 5 files.

## Your Tasks

### Step 1: Assess the situation
```bash
git log --oneline                             # See your 3 commits
git log --oneline main                        # See what main has
git diff HEAD...main --stat                   # Preview which files will conflict
```

### Step 2: Merge main into your branch
```bash
git merge main
```

### Step 3: Resolve conflict in `src/controllers/orderController.js`
- `getOrders`: Your version adds pagination (`page`, `limit`, `status`, `sort` query params).
  Main's version adds caching (cache lookup before DB call).
  **Resolution**: Combine both — check cache first, if miss then paginate, then cache the result.
- `searchOrders`: This is a new function you added. It doesn't exist in main.
  Keep it — just make sure the conflict markers around other functions are resolved.

### Step 4: Resolve conflict in `src/services/orderService.js`
- `getOrdersByUser`: Your version accepts pagination `options`. Main's version is unchanged.
  **Resolution**: Keep your paginated version. Main's callers will be updated.
- `searchOrders` (new service function): Keep this — it only exists on your branch.

### Step 5: Resolve conflict in `src/routes/orderRoutes.js`
- Your version adds a `search` route and imports `searchOrders`.
- Main's version adds rate limiting middleware to all routes.
- **Resolution**: Keep BOTH — apply rate limiting AND add the search route.

### Step 6: Resolve conflict in `src/middleware/errorHandler.js`
- Your version adds handling for MongoDB text search errors.
- Main's version adds handling for rate limit errors (429).
- **Resolution**: Keep BOTH error handlers.

### Step 7: Resolve conflict in `tests/order.test.js`
- Your version adds pagination tests for `getOrdersByUser`.
- Main's version adds cache invalidation tests.
- **Resolution**: Keep ALL test cases from both branches.

### Step 8: Complete the merge
```bash
git add src/controllers/orderController.js src/services/orderService.js \
        src/routes/orderRoutes.js src/middleware/errorHandler.js tests/order.test.js
git merge --continue
```
Write a merge commit message like: `merge: integrate main caching and rate limiting with pagination feature`

## Expected Final State
- `GET /api/orders` supports: pagination, filtering, AND caching
- `GET /api/orders/search` endpoint exists
- Rate limiting is applied to all order routes
- Error handler covers both rate-limit errors and search errors
- All test cases from both branches are present
'@
git add Assignment.md
git commit -m "docs: add merge-conflict assignment instructions"

# Feature/merge-conflict changes: Pagination + Search
Set-Content -Path "src/controllers/orderController.js" -Value @'
const orderService = require('../services/orderService');
const { DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE } = require('../config/constants');

/**
 * POST /api/orders
 * Create a new order for the authenticated user.
 */
const createOrder = async (req, res, next) => {
  try {
    const order = await orderService.createOrder(req.user.id, req.body);
    res.status(201).json({ success: true, message: 'Order placed successfully.', data: order });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/orders
 * Get paginated and filtered orders for the authenticated user.
 * Query params: ?page=1&limit=20&status=pending&sort=-createdAt
 */
const getOrders = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = DEFAULT_PAGE_SIZE,
      status,
      sort = '-createdAt',
      minAmount,
      maxAmount,
    } = req.query;

    const options = {
      page: Math.max(1, parseInt(page)),
      limit: Math.min(parseInt(limit), MAX_PAGE_SIZE),
      status,
      sort,
      minAmount: minAmount ? parseFloat(minAmount) : undefined,
      maxAmount: maxAmount ? parseFloat(maxAmount) : undefined,
    };

    const result = await orderService.getOrdersByUser(req.user.id, options);

    res.json({
      success: true,
      data: result.orders,
      pagination: {
        total: result.total,
        page: options.page,
        limit: options.limit,
        pages: Math.ceil(result.total / options.limit),
        hasNextPage: options.page < Math.ceil(result.total / options.limit),
        hasPrevPage: options.page > 1,
      },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/orders/search?q=widget&status=pending
 * Full-text search across the user's orders.
 */
const searchOrders = async (req, res, next) => {
  try {
    const { q, status, page = 1, limit = DEFAULT_PAGE_SIZE } = req.query;

    if (!q || q.trim().length < 2) {
      return res.status(400).json({ success: false, message: 'Search query must be at least 2 characters.' });
    }

    const options = {
      query: q.trim(),
      status,
      page: Math.max(1, parseInt(page)),
      limit: Math.min(parseInt(limit), MAX_PAGE_SIZE),
    };

    const result = await orderService.searchOrders(req.user.id, options);

    res.json({
      success: true,
      data: result.orders,
      meta: { query: q, total: result.total, page: options.page, limit: options.limit },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/orders/:id
 * Get a specific order by ID.
 */
const getOrderById = async (req, res, next) => {
  try {
    const order = await orderService.getOrderById(req.params.id, req.user.id, req.user.role);
    res.json({ success: true, data: order });
  } catch (err) {
    next(err);
  }
};

/**
 * PUT /api/orders/:id/status
 * Update order status (admin only).
 */
const updateOrderStatus = async (req, res, next) => {
  try {
    const { status, reason } = req.body;
    if (!status) return res.status(400).json({ success: false, message: 'Status is required.' });
    const order = await orderService.updateOrderStatus(req.params.id, status, req.user.id, reason);
    res.json({ success: true, message: 'Order status updated.', data: order });
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /api/orders/:id
 * Cancel a pending order (user-initiated).
 */
const cancelOrder = async (req, res, next) => {
  try {
    const order = await orderService.cancelOrder(req.params.id, req.user.id);
    res.json({ success: true, message: 'Order cancelled successfully.', data: order });
  } catch (err) {
    next(err);
  }
};

module.exports = { createOrder, getOrders, searchOrders, getOrderById, updateOrderStatus, cancelOrder };
'@

Set-Content -Path "src/services/orderService.js" -Value @'
const Order = require('../models/order');
const Product = require('../models/product');
const User = require('../models/user');
const { ORDER_STATUS, ORDER_LIMITS, TAX_CONFIG } = require('../config/constants');

const calculateSubtotal = (items) => {
  return items.reduce((total, item) => total + (item.unitPrice * item.quantity), 0);
};

const calculateTax = (subtotal, taxRate) => {
  if (!taxRate || taxRate <= 0) return 0;
  return parseFloat((subtotal * (taxRate / 100)).toFixed(2));
};

const getTaxRateForState = (state) => {
  return TAX_CONFIG.RATES_BY_STATE[state?.toUpperCase()] ?? TAX_CONFIG.DEFAULT_RATE_PERCENTAGE;
};

const calculateTotal = (subtotal, taxRate = 0) => {
  const taxAmount = calculateTax(subtotal, taxRate);
  return parseFloat((subtotal + taxAmount).toFixed(2));
};

const validateAndEnrichItems = async (items) => {
  if (!items || items.length === 0) { const err = new Error('Order must contain at least one item.'); err.statusCode = 400; throw err; }
  if (items.length > ORDER_LIMITS.MAX_ITEMS_PER_ORDER) { const err = new Error(`Cannot exceed ${ORDER_LIMITS.MAX_ITEMS_PER_ORDER} items.`); err.statusCode = 400; throw err; }
  const enrichedItems = [];
  for (const item of items) {
    const product = await Product.findById(item.productId);
    if (!product) { const err = new Error(`Product '${item.productId}' not found.`); err.statusCode = 404; throw err; }
    if (!product.isAvailable) { const err = new Error(`'${product.name}' is unavailable.`); err.statusCode = 422; throw err; }
    if (product.stock < item.quantity) { const err = new Error(`Insufficient stock for '${product.name}'.`); err.statusCode = 422; throw err; }
    enrichedItems.push({ product: product._id, quantity: item.quantity, unitPrice: product.price, productName: product.name, productSku: product.sku });
  }
  return enrichedItems;
};

const createOrder = async (userId, orderData) => {
  const { items, shippingAddress, notes } = orderData;
  const enrichedItems = await validateAndEnrichItems(items);
  const subtotal = calculateSubtotal(enrichedItems);
  if (subtotal < ORDER_LIMITS.MIN_ORDER_AMOUNT) { const err = new Error(`Minimum order is $${ORDER_LIMITS.MIN_ORDER_AMOUNT}.`); err.statusCode = 400; throw err; }
  const taxRate = getTaxRateForState(shippingAddress?.state);
  const taxAmount = calculateTax(subtotal, taxRate);
  const totalAmount = calculateTotal(subtotal, taxRate);
  const order = new Order({ user: userId, items: enrichedItems, shippingAddress, subtotal, taxRate, taxAmount, totalAmount, notes, statusHistory: [{ status: ORDER_STATUS.PENDING }] });
  await order.save();
  await Promise.all(enrichedItems.map((item) => Product.findByIdAndUpdate(item.product, { $inc: { stock: -item.quantity } })));
  await User.findByIdAndUpdate(userId, { $inc: { totalOrders: 1, totalSpend: totalAmount } });
  return order.populate('items.product');
};

/**
 * Get paginated and filtered orders for a user.
 * @param {string} userId
 * @param {Object} options - { page, limit, status, sort, minAmount, maxAmount }
 */
const getOrdersByUser = async (userId, options = {}) => {
  const { page = 1, limit = 20, status, sort = '-createdAt', minAmount, maxAmount } = options;

  const filter = { user: userId };
  if (status) filter.status = status;
  if (minAmount !== undefined || maxAmount !== undefined) {
    filter.totalAmount = {};
    if (minAmount !== undefined) filter.totalAmount.$gte = minAmount;
    if (maxAmount !== undefined) filter.totalAmount.$lte = maxAmount;
  }

  const skip = (page - 1) * limit;
  const [orders, total] = await Promise.all([
    Order.find(filter).populate('items.product', 'name sku images').sort(sort).skip(skip).limit(limit),
    Order.countDocuments(filter),
  ]);

  return { orders, total };
};

/**
 * Full-text search across a user's orders (searches product names in items).
 */
const searchOrders = async (userId, options = {}) => {
  const { query, status, page = 1, limit = 20 } = options;

  const filter = {
    user: userId,
    'items.productName': { $regex: query, $options: 'i' },
  };
  if (status) filter.status = status;

  const skip = (page - 1) * limit;
  const [orders, total] = await Promise.all([
    Order.find(filter).populate('items.product', 'name sku images').sort('-createdAt').skip(skip).limit(limit),
    Order.countDocuments(filter),
  ]);

  return { orders, total };
};

const getOrderById = async (orderId, userId, userRole) => {
  const order = await Order.findById(orderId).populate('items.product');
  if (!order) { const err = new Error('Order not found.'); err.statusCode = 404; throw err; }
  if (userRole !== 'admin' && order.user.toString() !== userId.toString()) { const err = new Error('Not authorized.'); err.statusCode = 403; throw err; }
  return order;
};

const updateOrderStatus = async (orderId, newStatus, adminId, reason) => {
  const validTransitions = { pending: ['confirmed', 'cancelled'], confirmed: ['processing', 'cancelled'], processing: ['shipped', 'cancelled'], shipped: ['delivered'], delivered: ['refunded'], cancelled: [], refunded: [] };
  const order = await Order.findById(orderId);
  if (!order) { const err = new Error('Order not found.'); err.statusCode = 404; throw err; }
  if (!validTransitions[order.status].includes(newStatus)) { const err = new Error(`Cannot transition from '${order.status}' to '${newStatus}'.`); err.statusCode = 422; throw err; }
  order.status = newStatus;
  order.statusHistory.push({ status: newStatus, changedBy: adminId, reason });
  await order.save();
  return order;
};

const cancelOrder = async (orderId, userId) => {
  const order = await Order.findById(orderId);
  if (!order) { const err = new Error('Order not found.'); err.statusCode = 404; throw err; }
  if (order.user.toString() !== userId.toString()) { const err = new Error('Not authorized.'); err.statusCode = 403; throw err; }
  if (order.status !== ORDER_STATUS.PENDING) { const err = new Error('Only pending orders can be cancelled.'); err.statusCode = 422; throw err; }
  order.status = ORDER_STATUS.CANCELLED;
  order.statusHistory.push({ status: ORDER_STATUS.CANCELLED, changedBy: userId, reason: 'Cancelled by customer' });
  await order.save();
  await Promise.all(order.items.map((item) => Product.findByIdAndUpdate(item.product, { $inc: { stock: item.quantity } })));
  await User.findByIdAndUpdate(userId, { $inc: { totalOrders: -1, totalSpend: -order.totalAmount } });
  return order;
};

module.exports = { calculateSubtotal, calculateTotal, calculateTax, getTaxRateForState, validateAndEnrichItems, createOrder, getOrdersByUser, searchOrders, getOrderById, updateOrderStatus, cancelOrder };
'@

Set-Content -Path "src/routes/orderRoutes.js" -Value @'
const express = require('express');
const router = express.Router();
const {
  createOrder, getOrders, searchOrders, getOrderById, updateOrderStatus, cancelOrder,
} = require('../controllers/orderController');

// All order routes require authentication
router.post('/', createOrder);
router.get('/search', searchOrders);   // Must be before /:id to avoid conflict
router.get('/', getOrders);
router.get('/:id', getOrderById);
router.put('/:id/status', updateOrderStatus);
router.delete('/:id', cancelOrder);

module.exports = router;
'@

Set-Content -Path "src/middleware/errorHandler.js" -Value @'
// Centralized error handling middleware for ShopNow API

const errorHandler = (err, req, res, next) => {
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    statusCode = 400;
    const fields = Object.values(err.errors).map((e) => e.message);
    message = `Validation failed: ${fields.join(', ')}`;
  }

  // Mongoose duplicate key error
  if (err.code === 11000) {
    statusCode = 409;
    const field = Object.keys(err.keyValue)[0];
    message = `A record with this ${field} already exists.`;
  }

  // Mongoose cast error
  if (err.name === 'CastError') {
    statusCode = 400;
    message = `Invalid value for field: ${err.path}`;
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') { statusCode = 401; message = 'Invalid authentication token.'; }
  if (err.name === 'TokenExpiredError') { statusCode = 401; message = 'Authentication token has expired. Please log in again.'; }

  // MongoDB text search error (e.g., text index not yet built)
  if (err.codeName === 'IndexNotFound' || (err.message && err.message.includes('text index'))) {
    statusCode = 503;
    message = 'Search is temporarily unavailable. Please try again later.';
  }

  if (statusCode >= 500 && process.env.NODE_ENV !== 'test') {
    console.error(`[ERROR] ${err.stack}`);
  }

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = errorHandler;
'@

Set-Content -Path "tests/order.test.js" -Value @'
const orderService = require('../src/services/orderService');
const Order = require('../src/models/order');
const Product = require('../src/models/product');
const User = require('../src/models/user');

jest.mock('../src/models/order');
jest.mock('../src/models/product');
jest.mock('../src/models/user');

describe('orderService', () => {
  afterEach(() => jest.clearAllMocks());

  describe('calculateSubtotal()', () => {
    it('should correctly sum item prices', () => {
      const items = [{ unitPrice: 10.00, quantity: 2 }, { unitPrice: 5.50, quantity: 3 }];
      expect(orderService.calculateSubtotal(items)).toBe(36.50);
    });

    it('should return 0 for an empty item list', () => {
      expect(orderService.calculateSubtotal([])).toBe(0);
    });
  });

  describe('getOrdersByUser() - pagination', () => {
    it('should apply skip and limit based on page options', async () => {
      const mockFind = { populate: jest.fn().mockReturnThis(), sort: jest.fn().mockReturnThis(), skip: jest.fn().mockReturnThis(), limit: jest.fn().mockResolvedValue([]) };
      Order.find.mockReturnValue(mockFind);
      Order.countDocuments.mockResolvedValue(50);

      await orderService.getOrdersByUser('user123', { page: 2, limit: 10 });

      expect(mockFind.skip).toHaveBeenCalledWith(10); // (page-1) * limit = 1 * 10
      expect(mockFind.limit).toHaveBeenCalledWith(10);
    });

    it('should filter by status when provided', async () => {
      const mockFind = { populate: jest.fn().mockReturnThis(), sort: jest.fn().mockReturnThis(), skip: jest.fn().mockReturnThis(), limit: jest.fn().mockResolvedValue([]) };
      Order.find.mockReturnValue(mockFind);
      Order.countDocuments.mockResolvedValue(0);

      await orderService.getOrdersByUser('user123', { status: 'pending' });

      expect(Order.find).toHaveBeenCalledWith(expect.objectContaining({ status: 'pending' }));
    });

    it('should return total count alongside orders', async () => {
      const mockFind = { populate: jest.fn().mockReturnThis(), sort: jest.fn().mockReturnThis(), skip: jest.fn().mockReturnThis(), limit: jest.fn().mockResolvedValue([]) };
      Order.find.mockReturnValue(mockFind);
      Order.countDocuments.mockResolvedValue(42);

      const result = await orderService.getOrdersByUser('user123', {});
      expect(result.total).toBe(42);
    });
  });

  describe('cancelOrder()', () => {
    it('should throw 422 if order is not in pending state', async () => {
      const mockOrder = { user: { toString: () => 'user123' }, status: 'shipped', items: [] };
      Order.findById.mockResolvedValue(mockOrder);
      await expect(orderService.cancelOrder('order123', 'user123')).rejects.toMatchObject({ statusCode: 422 });
    });

    it('should throw 403 if user does not own the order', async () => {
      const mockOrder = { user: { toString: () => 'otherUser' }, status: 'pending' };
      Order.findById.mockResolvedValue(mockOrder);
      await expect(orderService.cancelOrder('order123', 'user123')).rejects.toMatchObject({ statusCode: 403 });
    });
  });
});
'@

git add src/controllers/orderController.js src/services/orderService.js src/routes/orderRoutes.js src/middleware/errorHandler.js tests/order.test.js
git commit -m "feat(search): add pagination, filtering, and full-text search to order endpoints

- GET /api/orders now accepts page, limit, status, sort, minAmount, maxAmount
- GET /api/orders/search added for querying orders by product name
- orderService.getOrdersByUser() refactored to return paginated results
- orderService.searchOrders() added
- errorHandler updated for text search index errors"

git checkout main

# NOW update MAIN with caching + rate limiting (creates the merge conflict)
Set-Content -Path "src/controllers/orderController.js" -Value @'
const orderService = require('../services/orderService');
const NodeCache = require('node-cache');
const { CACHE_TTL_SECONDS } = require('../config/constants');

// In-memory cache for order list responses
const orderCache = new NodeCache({ stdTTL: CACHE_TTL_SECONDS, checkperiod: 30 });

/**
 * POST /api/orders
 * Create a new order. Invalidates the user's order list cache.
 */
const createOrder = async (req, res, next) => {
  try {
    const order = await orderService.createOrder(req.user.id, req.body);
    // Invalidate cache when a new order is placed
    orderCache.del(`orders:${req.user.id}`);
    res.status(201).json({ success: true, message: 'Order placed successfully.', data: order });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/orders
 * Get all orders for the authenticated user. Cached for CACHE_TTL_SECONDS.
 */
const getOrders = async (req, res, next) => {
  try {
    const cacheKey = `orders:${req.user.id}`;
    const cached = orderCache.get(cacheKey);

    if (cached) {
      return res.json({ success: true, fromCache: true, count: cached.length, data: cached });
    }

    const orders = await orderService.getOrdersByUser(req.user.id);
    orderCache.set(cacheKey, orders);

    res.json({ success: true, fromCache: false, count: orders.length, data: orders });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/orders/:id
 * Get a specific order by ID.
 */
const getOrderById = async (req, res, next) => {
  try {
    const order = await orderService.getOrderById(req.params.id, req.user.id, req.user.role);
    res.json({ success: true, data: order });
  } catch (err) {
    next(err);
  }
};

/**
 * PUT /api/orders/:id/status
 * Update order status (admin only). Invalidates affected user cache.
 */
const updateOrderStatus = async (req, res, next) => {
  try {
    const { status, reason } = req.body;
    if (!status) return res.status(400).json({ success: false, message: 'Status is required.' });
    const order = await orderService.updateOrderStatus(req.params.id, status, req.user.id, reason);
    // Invalidate the order owner's cache
    orderCache.del(`orders:${order.user.toString()}`);
    res.json({ success: true, message: 'Order status updated.', data: order });
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /api/orders/:id
 * Cancel a pending order. Invalidates cache.
 */
const cancelOrder = async (req, res, next) => {
  try {
    const order = await orderService.cancelOrder(req.params.id, req.user.id);
    orderCache.del(`orders:${req.user.id}`);
    res.json({ success: true, message: 'Order cancelled successfully.', data: order });
  } catch (err) {
    next(err);
  }
};

module.exports = { createOrder, getOrders, getOrderById, updateOrderStatus, cancelOrder, orderCache };
'@

Set-Content -Path "src/routes/orderRoutes.js" -Value @'
const express = require('express');
const rateLimit = require('express-rate-limit');
const router = express.Router();
const { createOrder, getOrders, getOrderById, updateOrderStatus, cancelOrder } = require('../controllers/orderController');
const { RATE_LIMIT } = require('../config/constants');

// Apply stricter rate limiting to order creation to prevent abuse
const createOrderLimiter = rateLimit({
  windowMs: RATE_LIMIT.WINDOW_MS,
  max: 10,  // Max 10 order creations per 15 minutes
  message: { success: false, message: 'Too many orders created. Please wait before trying again.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// General API rate limiting for read operations
const readLimiter = rateLimit({
  windowMs: RATE_LIMIT.WINDOW_MS,
  max: RATE_LIMIT.MAX_REQUESTS,
  message: { success: false, message: RATE_LIMIT.MESSAGE },
  standardHeaders: true,
  legacyHeaders: false,
});

router.post('/', createOrderLimiter, createOrder);
router.get('/', readLimiter, getOrders);
router.get('/:id', readLimiter, getOrderById);
router.put('/:id/status', readLimiter, updateOrderStatus);
router.delete('/:id', readLimiter, cancelOrder);

module.exports = router;
'@

Set-Content -Path "src/middleware/errorHandler.js" -Value @'
// Centralized error handling middleware for ShopNow API

const errorHandler = (err, req, res, next) => {
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    statusCode = 400;
    const fields = Object.values(err.errors).map((e) => e.message);
    message = `Validation failed: ${fields.join(', ')}`;
  }

  // Mongoose duplicate key error
  if (err.code === 11000) {
    statusCode = 409;
    const field = Object.keys(err.keyValue)[0];
    message = `A record with this ${field} already exists.`;
  }

  // Mongoose cast error
  if (err.name === 'CastError') {
    statusCode = 400;
    message = `Invalid value for field: ${err.path}`;
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') { statusCode = 401; message = 'Invalid authentication token.'; }
  if (err.name === 'TokenExpiredError') { statusCode = 401; message = 'Authentication token has expired. Please log in again.'; }

  // Rate limit exceeded (from express-rate-limit)
  if (statusCode === 429) {
    message = err.message || 'Too many requests. Please slow down and try again later.';
  }

  // Cache errors (node-cache)
  if (err.message && err.message.includes('node-cache')) {
    statusCode = 503;
    message = 'Cache service temporarily unavailable. Request served from database.';
  }

  if (statusCode >= 500 && process.env.NODE_ENV !== 'test') {
    console.error(`[ERROR] ${err.stack}`);
  }

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = errorHandler;
'@

Set-Content -Path "tests/order.test.js" -Value @'
const orderService = require('../src/services/orderService');
const { orderCache } = require('../src/controllers/orderController');
const Order = require('../src/models/order');
const Product = require('../src/models/product');
const User = require('../src/models/user');

jest.mock('../src/models/order');
jest.mock('../src/models/product');
jest.mock('../src/models/user');

describe('orderService', () => {
  afterEach(() => jest.clearAllMocks());

  describe('calculateSubtotal()', () => {
    it('should correctly sum item prices', () => {
      const items = [{ unitPrice: 10.00, quantity: 2 }, { unitPrice: 5.50, quantity: 3 }];
      expect(orderService.calculateSubtotal(items)).toBe(36.50);
    });

    it('should return 0 for an empty item list', () => {
      expect(orderService.calculateSubtotal([])).toBe(0);
    });
  });

  describe('cancelOrder()', () => {
    it('should throw 422 if order is not in pending state', async () => {
      const mockOrder = { user: { toString: () => 'user123' }, status: 'shipped', items: [] };
      Order.findById.mockResolvedValue(mockOrder);
      await expect(orderService.cancelOrder('order123', 'user123')).rejects.toMatchObject({ statusCode: 422 });
    });

    it('should throw 403 if user does not own the order', async () => {
      const mockOrder = { user: { toString: () => 'otherUser' }, status: 'pending' };
      Order.findById.mockResolvedValue(mockOrder);
      await expect(orderService.cancelOrder('order123', 'user123')).rejects.toMatchObject({ statusCode: 403 });
    });
  });
});

describe('orderController - cache behavior', () => {
  beforeEach(() => {
    orderCache.flushAll();
  });

  it('should store orders in cache after first fetch', async () => {
    // After calling getOrders, cache key should be set
    // (Integration-level: use supertest with mocked service)
    expect(orderCache.keys()).toHaveLength(0);
    orderCache.set('orders:user123', [{ id: 'order1' }]);
    expect(orderCache.get('orders:user123')).toBeDefined();
  });

  it('should invalidate cache when a new order is created', () => {
    orderCache.set('orders:user123', [{ id: 'order1' }]);
    expect(orderCache.get('orders:user123')).toBeDefined();
    orderCache.del('orders:user123');
    expect(orderCache.get('orders:user123')).toBeUndefined();
  });
});
'@

git add src/controllers/orderController.js src/routes/orderRoutes.js src/middleware/errorHandler.js tests/order.test.js
git commit -m "feat(cache): add in-memory caching and rate limiting to order endpoints

- NodeCache added to orderController for GET /api/orders responses
- Cache is invalidated on createOrder, updateOrderStatus, cancelOrder
- express-rate-limit applied: 10 creations/15min, 100 reads/15min
- errorHandler updated to handle 429 rate limit and cache errors"

Write-Host "  -> feature/merge-conflict created + main updated with caching" -ForegroundColor Green

# ============================================================
# BRANCH 5: feature/base-feature + feature/dependent-feature
# ============================================================
Write-Host "[8/8] Creating feature/base-feature and feature/dependent-feature..." -ForegroundColor Yellow

git checkout -b feature/base-feature

# Base feature: JWT authentication infrastructure
Set-Content -Path "src/middleware/authenticate.js" -Value @'
const jwt = require('jsonwebtoken');
const User = require('../models/user');

/**
 * Authentication middleware.
 * Verifies JWT token from Authorization header and attaches user to req.user.
 * Usage: router.get('/protected', authenticate, handler)
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Authentication required. Please provide a Bearer token.' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Fetch fresh user data to check if account is still active
    const user = await User.findById(decoded.id).select('_id name email role isActive');
    if (!user || !user.isActive) {
      return res.status(401).json({ success: false, message: 'Account not found or deactivated.' });
    }

    req.user = { id: user._id.toString(), name: user.name, email: user.email, role: user.role };
    next();
  } catch (err) {
    next(err);  // JWT errors handled by errorHandler (JsonWebTokenError, TokenExpiredError)
  }
};

/**
 * Authorization middleware factory.
 * Usage: router.delete('/user/:id', authenticate, authorize('admin'), handler)
 * @param {...string} roles - Allowed roles
 */
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Authentication required.' });
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Access denied. Required role: ${roles.join(' or ')}. Your role: ${req.user.role}.`,
      });
    }
    next();
  };
};

module.exports = { authenticate, authorize };
'@

# Update userRoutes to wire up authenticate middleware (without security patch yet)
Set-Content -Path "src/routes/userRoutes.js" -Value @'
const express = require('express');
const router = express.Router();
const { register, login, getMe, getAllUsers, deactivateUser } = require('../controllers/userController');
const { authenticate, authorize } = require('../middleware/authenticate');

// Public routes (no auth required)
router.post('/register', register);
router.post('/login', login);

// Protected routes (requires valid JWT)
router.get('/me', authenticate, getMe);

// Admin-only routes
router.get('/', authenticate, authorize('admin'), getAllUsers);
router.delete('/:id', authenticate, authorize('admin'), deactivateUser);

module.exports = router;
'@

# Update productRoutes too
Set-Content -Path "src/routes/productRoutes.js" -Value @'
const express = require('express');
const router = express.Router();
const { getProducts, getProductById, createProduct, updateProduct, deleteProduct } = require('../controllers/productController');
const { authenticate, authorize } = require('../middleware/authenticate');

// Public routes
router.get('/', getProducts);
router.get('/:id', getProductById);

// Admin-only routes
router.post('/', authenticate, authorize('admin'), createProduct);
router.put('/:id', authenticate, authorize('admin'), updateProduct);
router.delete('/:id', authenticate, authorize('admin'), deleteProduct);

module.exports = router;
'@

git add src/middleware/authenticate.js src/routes/userRoutes.js src/routes/productRoutes.js
git commit -m "feat(auth): add JWT authentication and role-based authorization middleware

- authenticate.js: verifies Bearer JWT, checks user still active, attaches req.user
- authorize(): middleware factory for role-based access control
- userRoutes: protect /me with authenticate, /admin routes with authorize('admin')
- productRoutes: protect create/update/delete with authorize('admin')"

# Create dependent branch from base feature
git checkout -b feature/dependent-feature

# Dependent feature Assignment.md
Set-Content -Path "Assignment.md" -Value @'
# Assignment: Sync a Dependent Branch with Its Base Branch

## Scenario
You are on `feature/dependent-feature`, which was created from `feature/base-feature`.
Your branch adds a **User Profile API** that allows users to view and update their profiles.
This depends on the JWT authentication infrastructure from `feature/base-feature`.

While you were building the profile API, the security team discovered a **critical vulnerability**
in the JWT validation code on `feature/base-feature` and pushed an emergency security patch.

The patch on `feature/base-feature`:
1. Fixes a vulnerability where tokens without an `iss` (issuer) claim were being accepted
2. Adds `src/middleware/rateLimit.js` — a configurable rate limiting middleware
3. Updates `src/config/constants.js` with new security-related constants
4. **Also modified `src/routes/userRoutes.js`** to add the rate limiter to auth endpoints

**The problem**: You also modified `src/routes/userRoutes.js` to add your 3 new profile routes.
So when you sync with `feature/base-feature`, you will get a **conflict in userRoutes.js**.

## Your Tasks

### Step 1: Understand what changed on the base branch
```bash
git log --oneline feature/base-feature    # See the security patch commit
git diff HEAD feature/base-feature        # See all differences
git diff HEAD feature/base-feature -- src/routes/userRoutes.js   # See the route conflict
```

### Step 2: Bring in the security patch
Choose either merge or rebase:
```bash
git merge feature/base-feature
# OR
git rebase feature/base-feature
```
You will get a conflict in `src/routes/userRoutes.js`.

### Step 3: Resolve the conflict in `src/routes/userRoutes.js`
- **Your changes**: Added 3 profile routes (`GET /me/profile`, `PUT /me/profile`, `DELETE /me`)
- **Base branch changes**: Added `authRateLimiter` to `POST /register` and `POST /login`
- **Resolution**: Keep BOTH — apply rate limiting to auth routes AND include your profile routes

### Step 4: Verify the security patch is applied
```bash
git show feature/base-feature:src/middleware/authenticate.js | grep "iss"
# Should show the issuer claim check
cat src/middleware/authenticate.js  # Your branch should also have it now
cat src/middleware/rateLimit.js     # Should now exist on your branch
```

### Step 5: Complete the operation
```bash
# If merging:
git add src/routes/userRoutes.js
git merge --continue

# If rebasing:
git add src/routes/userRoutes.js
git rebase --continue
```

## Expected Final State
- `src/middleware/authenticate.js` has the `iss` claim security fix
- `src/middleware/rateLimit.js` exists (from base branch security patch)
- `src/routes/userRoutes.js` has: rate limiting on auth routes AND your 3 profile routes
- `src/controllers/userController.js` has the `getProfile`, `updateProfile`, `deleteAccount` controllers
'@

# Add the profile API (dependent branch's own work)
Set-Content -Path "src/controllers/userController.js" -Value @'
const userService = require('../services/userService');

const register = async (req, res, next) => {
  try {
    const user = await userService.registerUser(req.body);
    res.status(201).json({ success: true, message: 'Account created successfully.', data: user });
  } catch (err) { next(err); }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ success: false, message: 'Email and password are required.' });
    const result = await userService.loginUser(email, password);
    res.json({ success: true, message: 'Login successful.', data: result });
  } catch (err) { next(err); }
};

const getMe = async (req, res, next) => {
  try {
    const user = await userService.getUserById(req.user.id);
    res.json({ success: true, data: user });
  } catch (err) { next(err); }
};

const getAllUsers = async (req, res, next) => {
  try {
    const users = await userService.getAllUsers();
    res.json({ success: true, count: users.length, data: users });
  } catch (err) { next(err); }
};

const deactivateUser = async (req, res, next) => {
  try {
    const user = await userService.deactivateUser(req.params.id);
    res.json({ success: true, message: 'User account deactivated.', data: user });
  } catch (err) { next(err); }
};

// ---- Profile endpoints (added by feature/dependent-feature) ----

/**
 * GET /api/users/me/profile
 * Get the detailed profile of the currently authenticated user.
 */
const getProfile = async (req, res, next) => {
  try {
    const user = await userService.getUserById(req.user.id);
    res.json({
      success: true,
      data: {
        ...user,
        memberSince: user.createdAt,
        accountAge: Math.floor((Date.now() - new Date(user.createdAt)) / (1000 * 60 * 60 * 24)) + ' days',
      },
    });
  } catch (err) { next(err); }
};

/**
 * PUT /api/users/me/profile
 * Update the authenticated user's profile (name, defaultAddress).
 */
const updateProfile = async (req, res, next) => {
  try {
    const allowedUpdates = ['name', 'defaultAddress'];
    const updates = {};
    for (const key of allowedUpdates) {
      if (req.body[key] !== undefined) updates[key] = req.body[key];
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ success: false, message: 'No valid fields to update. Allowed: name, defaultAddress.' });
    }

    const user = await userService.updateUserProfile(req.user.id, updates);
    res.json({ success: true, message: 'Profile updated successfully.', data: user });
  } catch (err) { next(err); }
};

/**
 * DELETE /api/users/me
 * Self-service account deletion. Requires password confirmation in body.
 */
const deleteAccount = async (req, res, next) => {
  try {
    const { password } = req.body;
    if (!password) return res.status(400).json({ success: false, message: 'Password confirmation is required.' });
    await userService.deleteUserAccount(req.user.id, password);
    res.json({ success: true, message: 'Your account has been permanently deleted.' });
  } catch (err) { next(err); }
};

module.exports = { register, login, getMe, getAllUsers, deactivateUser, getProfile, updateProfile, deleteAccount };
'@

# userRoutes with profile routes but WITHOUT the rate limiter (will conflict with base branch)
Set-Content -Path "src/routes/userRoutes.js" -Value @'
const express = require('express');
const router = express.Router();
const {
  register, login, getMe, getAllUsers, deactivateUser,
  getProfile, updateProfile, deleteAccount,
} = require('../controllers/userController');
const { authenticate, authorize } = require('../middleware/authenticate');

// Public routes
router.post('/register', register);
router.post('/login', login);

// Profile routes (added by feature/dependent-feature)
router.get('/me', authenticate, getMe);
router.get('/me/profile', authenticate, getProfile);
router.put('/me/profile', authenticate, updateProfile);
router.delete('/me', authenticate, deleteAccount);

// Admin-only routes
router.get('/', authenticate, authorize('admin'), getAllUsers);
router.delete('/:id', authenticate, authorize('admin'), deactivateUser);

module.exports = router;
'@

git add Assignment.md src/controllers/userController.js src/routes/userRoutes.js
git commit -m "feat(profile): add user profile API endpoints (GET, PUT /me/profile, DELETE /me)

- getProfile: returns enriched profile with account age calculation
- updateProfile: allows updating name and defaultAddress only
- deleteAccount: self-service deletion with password confirmation
- All profile routes require JWT authentication"

# Go back to base branch and add the SECURITY PATCH (the "gotcha" commit)
git checkout feature/base-feature

# Security patch: fix JWT issuer validation vulnerability
Set-Content -Path "src/middleware/authenticate.js" -Value @'
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const { SECURITY } = require('../config/constants');

/**
 * Authentication middleware.
 * SECURITY PATCH (2024-01-15): Added issuer (iss) claim validation to prevent
 * token confusion attacks from other services using the same JWT library.
 *
 * @see CVE-2024-SHOPNOW-001
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Authentication required. Please provide a Bearer token.' });
    }

    const token = authHeader.split(' ')[1];

    // SECURITY FIX: verify with issuer claim to prevent token confusion attacks
    const decoded = jwt.verify(token, process.env.JWT_SECRET, {
      issuer: SECURITY.JWT_ISSUER,
      algorithms: ['HS256'],  // Explicitly specify algorithm to prevent alg:none attacks
    });

    // Validate token type claim
    if (decoded.type !== 'access') {
      return res.status(401).json({ success: false, message: 'Invalid token type.' });
    }

    const user = await User.findById(decoded.id).select('_id name email role isActive');
    if (!user || !user.isActive) {
      return res.status(401).json({ success: false, message: 'Account not found or deactivated.' });
    }

    req.user = { id: user._id.toString(), name: user.name, email: user.email, role: user.role };
    next();
  } catch (err) {
    next(err);
  }
};

/**
 * Authorization middleware factory.
 */
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) return res.status(401).json({ success: false, message: 'Authentication required.' });
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ success: false, message: `Access denied. Required: ${roles.join(' or ')}. Yours: ${req.user.role}.` });
    }
    next();
  };
};

module.exports = { authenticate, authorize };
'@

# Also update userService to sign tokens with issuer claim
Set-Content -Path "src/middleware/rateLimit.js" -Value @'
const rateLimit = require('express-rate-limit');
const { SECURITY } = require('../config/constants');

/**
 * Rate limiter for authentication endpoints.
 * Prevents brute-force attacks on login and registration.
 * Stricter than the general API rate limit.
 */
const authRateLimiter = rateLimit({
  windowMs: SECURITY.AUTH_RATE_LIMIT.WINDOW_MS,
  max: SECURITY.AUTH_RATE_LIMIT.MAX_ATTEMPTS,
  message: {
    success: false,
    message: 'Too many authentication attempts from this IP. Please wait 15 minutes before trying again.',
    retryAfter: Math.ceil(SECURITY.AUTH_RATE_LIMIT.WINDOW_MS / 1000 / 60) + ' minutes',
  },
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: false,  // Count all requests, not just failures
});

/**
 * General API rate limiter for non-critical endpoints.
 */
const generalRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: { success: false, message: 'Rate limit exceeded. Please slow down.' },
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = { authRateLimiter, generalRateLimiter };
'@

# Update constants with SECURITY section
$constantsContent = Get-Content "src/config/constants.js" -Raw
$securitySection = @'

  // --- Security (PATCH: 2024-01-15 - CVE-2024-SHOPNOW-001) ---
  SECURITY: {
    JWT_ISSUER: 'shopnow-api',
    JWT_ALGORITHM: 'HS256',
    AUTH_RATE_LIMIT: {
      WINDOW_MS: 15 * 60 * 1000,   // 15 minutes
      MAX_ATTEMPTS: 10,              // 10 login/register attempts per window
    },
    PASSWORD_MIN_LENGTH: 8,
    ALLOWED_ORIGINS: ['https://shopnow.com', 'https://admin.shopnow.com'],
  },

'@
$constantsContent = $constantsContent -replace "(  // --- Rate Limiting ---)", "$securitySection  // --- Rate Limiting ---"
Set-Content -Path "src/config/constants.js" -Value $constantsContent

# Update userRoutes on BASE BRANCH to add authRateLimiter (will conflict with dependent branch)
Set-Content -Path "src/routes/userRoutes.js" -Value @'
const express = require('express');
const router = express.Router();
const { register, login, getMe, getAllUsers, deactivateUser } = require('../controllers/userController');
const { authenticate, authorize } = require('../middleware/authenticate');
const { authRateLimiter } = require('../middleware/rateLimit');

// Public routes — rate limited to prevent brute force
router.post('/register', authRateLimiter, register);
router.post('/login', authRateLimiter, login);

// Protected routes
router.get('/me', authenticate, getMe);

// Admin-only routes
router.get('/', authenticate, authorize('admin'), getAllUsers);
router.delete('/:id', authenticate, authorize('admin'), deactivateUser);

module.exports = router;
'@

git add src/middleware/authenticate.js src/middleware/rateLimit.js src/config/constants.js src/routes/userRoutes.js
git commit -m "security: patch JWT token confusion vulnerability (CVE-2024-SHOPNOW-001)

BREAKING: Tokens must now include iss=shopnow-api and type=access claims.
Old tokens will be rejected. All clients must re-authenticate.

Changes:
- authenticate.js: verify issuer claim and explicitly require HS256 algorithm
- authenticate.js: validate token type claim to prevent refresh token misuse  
- rateLimit.js: add authRateLimiter (10 attempts/15min) for /register and /login
- constants.js: add SECURITY config block with JWT_ISSUER, AUTH_RATE_LIMIT
- userRoutes.js: apply authRateLimiter to public auth endpoints"

git checkout main
Write-Host "  -> feature/base-feature + feature/dependent-feature created" -ForegroundColor Green

# ============================================================
# BRANCH 6: feature/cherry-pick
# ============================================================
Write-Host "`n[9/9] Creating feature/cherry-pick branch (cherry-pick scenario)..." -ForegroundColor Yellow

# Create source branch
git checkout -b hotfix/cache-bug main

New-Item -ItemType Directory -Force -Path "src/utils" | Out-Null
Set-Content -Path "src/utils/cartHelper.js" -Value "// WIP: experimental cart feature"
git add src/utils/cartHelper.js
git commit -m "feat: start experimental cart feature"

$constantsJs = Get-Content "src/config/constants.js" -Raw
$constantsJsBugFix = $constantsJs -replace "CACHE_TTL_SECONDS: 60", "CACHE_TTL_SECONDS: 15"
Set-Content -Path "src/config/constants.js" -Value $constantsJsBugFix
$cacheTest = @'
const { CACHE_TTL_SECONDS } = require('../src/config/constants');

describe('Cache Configuration', () => {
  it('should have a short TTL (15s) to prevent stale data', () => {
    expect(CACHE_TTL_SECONDS).toBe(15);
  });
});
'@
Set-Content -Path "tests/cache.test.js" -Value $cacheTest
git add src/config/constants.js tests/cache.test.js
git commit -m "fix: reduce cache TTL to prevent stale order data and add verification test"

Set-Content -Path "src/utils/cartHelper.js" -Value "// WIP: experimental cart feature phase 2"
git add src/utils/cartHelper.js
git commit -m "feat: continue experimental cart feature"

# Create target branch
git checkout main
git checkout -b feature/cherry-pick

$constantsJsFeature = $constantsJs -replace "CACHE_TTL_SECONDS: 60", "CACHE_TTL_SECONDS: 120"
Set-Content -Path "src/config/constants.js" -Value $constantsJsFeature
git add src/config/constants.js
git commit -m "feat: increase cache TTL for performance"

# --- Assignment.md ---
Set-Content -Path "Assignment.md" -Value @'
# Assignment: Pick a Bug Fix with `git cherry-pick` (with conflict)

## Scenario
The `hotfix/cache-bug` branch contains a critical fix that reduces the cache TTL to prevent stale order data. However, it also contains unfinished experimental features (`src/utils/cartHelper.js`). You only want the bug fix commit on your branch, without the experimental work.

The catch? Your current branch, `feature/cherry-pick`, also modified the cache TTL for performance testing. Cherry-picking the bug fix will result in a merge conflict that you must resolve.

## Your Tasks

### Step 1: Find the commit hash
View the commit history of the `hotfix/cache-bug` branch:
```bash
git log hotfix/cache-bug --oneline
```
Find the commit with the message `"fix: reduce cache TTL to prevent stale order data and add verification test"`. Note its commit hash.

### Step 2: Cherry-pick the commit
Ensure you are on the `feature/cherry-pick` branch, then run:
```bash
git cherry-pick <commit-hash>
```

Git will pause and tell you there is a conflict in `src/config/constants.js`.

### Step 3: Resolve the conflict
Open `src/config/constants.js`. You will see conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
Resolve the conflict by keeping the hotfix change (TTL of 15) and removing the markers. Save the file.

### Step 4: Complete the cherry-pick
```bash
git add src/config/constants.js
git cherry-pick --continue
```
Leave the commit message as is and save it.

### Step 5: Verify
```bash
npm run test tests/cache.test.js
```
The test should pass, confirming that the TTL was correctly set to 15!

```bash
git log -3 --oneline
```
You should see the fix commit at the top of your branch history, and `src/config/constants.js` should have `CACHE_TTL_SECONDS: 15`. `src/utils/cartHelper.js` should not exist.

## Expected Final State
- The `feature/cherry-pick` branch has exactly one new commit on top of your feature commit.
- The new commit is the one containing the cache TTL fix and the test case.
- The conflict in `src/config/constants.js` is resolved to keep the hotfix value.
- Running `npm run test tests/cache.test.js` passes successfully.
'@

git add Assignment.md
git commit -m "chore: add cherry-pick assignment instructions"

git checkout main
Write-Host "  -> feature/cherry-pick created" -ForegroundColor Green

# ============================================================
# FINAL: Push to remote if origin exists, then summary
# ============================================================
Write-Host "`n[Done] Verifying branch structure..." -ForegroundColor Cyan
git log --oneline --all --graph

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Branches created:" -ForegroundColor Cyan
Write-Host "  main                      - Full ShopNow API (21 files)"
Write-Host "  feature/amend-me          - Leaked .env + debug logs + missing auth middleware"
Write-Host "  feature/squash-me         - 12 messy payment sprint commits to squash/drop"
Write-Host "  feature/rebase-me         - 3-file conflict: discount vs tax system"
Write-Host "  feature/merge-conflict    - 5-file conflict: pagination vs caching"
Write-Host "  feature/base-feature      - JWT auth infrastructure + security patch"
Write-Host "  feature/dependent-feature - Profile API, needs security patch from base"
Write-Host "  feature/cherry-pick       - Pick a critical bug fix from another branch without bringing experimental code"
Write-Host ""
Write-Host "Each branch has an Assignment.md with detailed step-by-step instructions." -ForegroundColor Yellow
Write-Host "Checkout any branch and read its Assignment.md to get started." -ForegroundColor Yellow
Write-Host ""
