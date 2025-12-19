const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Restaurant = require('../models/Restaurant');
const Order = require('../models/Order');
const Analytics = require('../models/Analytics');
const { requireAdmin } = require('../middleware/admin');

// Admin dashboard stats
router.get('/dashboard', requireAdmin, async (req, res) => {
  try {
    const dateFrom = req.query.dateFrom ? new Date(req.query.dateFrom) : null;
    const dateTo = req.query.dateTo ? new Date(req.query.dateTo) : null;

    const stats = await Analytics.getDashboardStats(dateFrom, dateTo);

    res.json({
      success: true,
      data: stats,
    });
  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch dashboard stats',
      error: error.message,
    });
  }
});

// Get all users
router.get('/users', requireAdmin, async (req, res) => {
  try {
    const filters = {
      role: req.query.role,
      search: req.query.search,
      limit: req.query.limit ? parseInt(req.query.limit) : 50,
      offset: req.query.offset ? parseInt(req.query.offset) : 0,
    };

    const users = await User.findAll(filters);
    res.json({
      success: true,
      data: users,
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch users',
      error: error.message,
    });
  }
});

// Get all restaurants
router.get('/restaurants', requireAdmin, async (req, res) => {
  try {
    const filters = {
      status: req.query.status,
      verified: req.query.verified !== undefined ? req.query.verified === 'true' : undefined,
      search: req.query.search,
      limit: req.query.limit ? parseInt(req.query.limit) : 50,
      offset: req.query.offset ? parseInt(req.query.offset) : 0,
    };

    const restaurants = await Restaurant.findAll(filters);
    res.json({
      success: true,
      data: restaurants,
    });
  } catch (error) {
    console.error('Error fetching restaurants:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch restaurants',
      error: error.message,
    });
  }
});

// Get all orders
router.get('/orders', requireAdmin, async (req, res) => {
  try {
    const filters = {
      status: req.query.status,
      paymentStatus: req.query.paymentStatus,
      limit: req.query.limit ? parseInt(req.query.limit) : 50,
      offset: req.query.offset ? parseInt(req.query.offset) : 0,
    };

    const orders = await Order.findAll(filters);
    res.json({
      success: true,
      data: orders,
    });
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch orders',
      error: error.message,
    });
  }
});

// Update user role
router.put('/users/:id/role', requireAdmin, async (req, res) => {
  try {
    const { role } = req.body;
    
    if (!role || !['user', 'admin', 'restaurant_owner'].includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Valid role is required (user, admin, restaurant_owner)',
      });
    }

    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    await User.updateRole(req.params.id, role);
    const updatedUser = await User.findById(req.params.id);

    res.json({
      success: true,
      message: 'User role updated successfully',
      data: updatedUser,
    });
  } catch (error) {
    console.error('Error updating user role:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update user role',
      error: error.message,
    });
  }
});

// Verify/unverify restaurant
router.put('/restaurants/:id/verify', requireAdmin, async (req, res) => {
  try {
    const { verified } = req.body;
    
    const restaurant = await Restaurant.findById(req.params.id);
    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
    }

    await Restaurant.update(req.params.id, { verified: verified === true });
    const updatedRestaurant = await Restaurant.findById(req.params.id);

    res.json({
      success: true,
      message: `Restaurant ${verified ? 'verified' : 'unverified'} successfully`,
      data: updatedRestaurant,
    });
  } catch (error) {
    console.error('Error updating restaurant verification:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update restaurant verification',
      error: error.message,
    });
  }
});

module.exports = router;

