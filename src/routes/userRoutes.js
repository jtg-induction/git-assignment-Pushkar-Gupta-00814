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
