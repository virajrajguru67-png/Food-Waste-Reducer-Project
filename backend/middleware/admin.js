const { authenticateToken } = require('./auth');

const requireAdmin = (req, res, next) => {
  authenticateToken(req, res, () => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Admin access required'
      });
    }
    next();
  });
};

const requireAdminOrOwner = (req, res, next) => {
  authenticateToken(req, res, () => {
    if (req.user.role !== 'admin' && req.user.role !== 'restaurant_owner') {
      return res.status(403).json({
        success: false,
        message: 'Admin or restaurant owner access required'
      });
    }
    next();
  });
};

module.exports = { requireAdmin, requireAdminOrOwner };

