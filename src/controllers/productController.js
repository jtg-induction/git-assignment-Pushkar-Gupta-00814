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
