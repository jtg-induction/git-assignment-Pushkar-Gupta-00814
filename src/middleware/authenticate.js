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
