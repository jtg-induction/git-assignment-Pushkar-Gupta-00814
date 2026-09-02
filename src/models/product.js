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
