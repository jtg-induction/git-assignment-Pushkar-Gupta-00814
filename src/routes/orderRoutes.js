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
