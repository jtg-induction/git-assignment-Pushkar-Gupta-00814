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
