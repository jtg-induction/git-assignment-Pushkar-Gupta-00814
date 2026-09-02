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
