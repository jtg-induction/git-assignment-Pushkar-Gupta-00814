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
