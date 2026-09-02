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
