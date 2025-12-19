const express = require('express');
const router = express.Router();
const Analytics = require('../models/Analytics');
const { authenticateToken } = require('../middleware/auth');
const { requireAdmin } = require('../middleware/admin');

// Create analytics event
router.post('/', authenticateToken, async (req, res) => {
  try {
    const {
      eventType,
      restaurantId,
      orderId,
      data,
    } = req.body;

    if (!eventType) {
      return res.status(400).json({
        success: false,
        message: 'Event type is required',
      });
    }

    const eventId = await Analytics.create({
      eventType,
      userId: req.user.userId,
      restaurantId,
      orderId,
      data,
    });

    res.status(201).json({
      success: true,
      message: 'Analytics event created',
      data: { id: eventId },
    });
  } catch (error) {
    console.error('Error creating analytics event:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create analytics event',
      error: error.message,
    });
  }
});

// Get dashboard stats (admin only)
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

// Get revenue chart (admin only)
router.get('/revenue', requireAdmin, async (req, res) => {
  try {
    const dateFrom = req.query.dateFrom ? new Date(req.query.dateFrom) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const dateTo = req.query.dateTo ? new Date(req.query.dateTo) : new Date();
    const groupBy = req.query.groupBy || 'day';

    const chartData = await Analytics.getRevenueChart(dateFrom, dateTo, groupBy);

    res.json({
      success: true,
      data: chartData,
    });
  } catch (error) {
    console.error('Error fetching revenue chart:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch revenue chart',
      error: error.message,
    });
  }
});

// Get user growth chart (admin only)
router.get('/user-growth', requireAdmin, async (req, res) => {
  try {
    const dateFrom = req.query.dateFrom ? new Date(req.query.dateFrom) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const dateTo = req.query.dateTo ? new Date(req.query.dateTo) : new Date();
    const groupBy = req.query.groupBy || 'day';

    const chartData = await Analytics.getUserGrowthChart(dateFrom, dateTo, groupBy);

    res.json({
      success: true,
      data: chartData,
    });
  } catch (error) {
    console.error('Error fetching user growth chart:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user growth chart',
      error: error.message,
    });
  }
});

// Get event counts (admin only)
router.get('/events/:eventType', requireAdmin, async (req, res) => {
  try {
    const { eventType } = req.params;
    const dateFrom = req.query.dateFrom ? new Date(req.query.dateFrom) : null;
    const dateTo = req.query.dateTo ? new Date(req.query.dateTo) : null;

    const count = await Analytics.getEventCounts(eventType, dateFrom, dateTo);

    res.json({
      success: true,
      data: { eventType, count },
    });
  } catch (error) {
    console.error('Error fetching event counts:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch event counts',
      error: error.message,
    });
  }
});

module.exports = router;

