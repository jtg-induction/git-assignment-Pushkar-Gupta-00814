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
