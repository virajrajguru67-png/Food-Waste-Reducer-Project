const express = require('express');
const router = express.Router();
const Restaurant = require('../models/Restaurant');
const { authenticateToken } = require('../middleware/auth');
const { requireAdmin, requireAdminOrOwner } = require('../middleware/admin');

// Get all restaurants (public)
router.get('/', async (req, res) => {
  try {
    const filters = {
      status: req.query.status || 'active',
      verified: req.query.verified !== undefined ? req.query.verified === 'true' : undefined,
      category: req.query.category,
      search: req.query.search,
      limit: req.query.limit ? parseInt(req.query.limit) : undefined,
      offset: req.query.offset ? parseInt(req.query.offset) : undefined,
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

// Get restaurant by ID (public)
router.get('/:id', async (req, res) => {
  try {
    const restaurant = await Restaurant.findById(req.params.id);
    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
    }

    res.json({
      success: true,
      data: restaurant,
    });
  } catch (error) {
    console.error('Error fetching restaurant:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch restaurant',
      error: error.message,
    });
  }
});

// Create restaurant (admin or restaurant owner)
router.post('/', requireAdminOrOwner, async (req, res) => {
  try {
    const {
      name,
      description,
      category,
      address,
      latitude,
      longitude,
      phone,
      email,
      images,
      operatingHours,
      commissionRate,
    } = req.body;

    if (!name) {
      return res.status(400).json({
        success: false,
        message: 'Restaurant name is required',
      });
    }

    const ownerId = req.user.role === 'admin' ? (req.body.ownerId || req.user.userId) : req.user.userId;

    const restaurantId = await Restaurant.create({
      ownerId,
      name,
      description,
      category,
      address,
      latitude,
      longitude,
      phone,
      email,
      images,
      operatingHours,
      commissionRate,
    });

    const restaurant = await Restaurant.findById(restaurantId);

    res.status(201).json({
      success: true,
      message: 'Restaurant created successfully',
      data: restaurant,
    });
  } catch (error) {
    console.error('Error creating restaurant:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create restaurant',
      error: error.message,
    });
  }
});

// Update restaurant
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const restaurant = await Restaurant.findById(req.params.id);
    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
    }

    // Check if user is admin or owner
    if (req.user.role !== 'admin' && restaurant.ownerId !== req.user.userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this restaurant',
      });
    }

    await Restaurant.update(req.params.id, req.body);
    const updatedRestaurant = await Restaurant.findById(req.params.id);

    res.json({
      success: true,
      message: 'Restaurant updated successfully',
      data: updatedRestaurant,
    });
  } catch (error) {
    console.error('Error updating restaurant:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update restaurant',
      error: error.message,
    });
  }
});

// Delete restaurant (admin only)
router.delete('/:id', requireAdmin, async (req, res) => {
  try {
    const restaurant = await Restaurant.findById(req.params.id);
    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
    }

    await Restaurant.delete(req.params.id);

    res.json({
      success: true,
      message: 'Restaurant deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting restaurant:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete restaurant',
      error: error.message,
    });
  }
});

// Get restaurants by owner
router.get('/owner/:ownerId', authenticateToken, async (req, res) => {
  try {
    // Users can only see their own restaurants unless they're admin
    if (req.user.role !== 'admin' && req.user.userId !== parseInt(req.params.ownerId)) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized',
      });
    }

    const restaurants = await Restaurant.findByOwnerId(req.params.ownerId);
    res.json({
      success: true,
      data: restaurants,
    });
  } catch (error) {
    console.error('Error fetching restaurants by owner:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch restaurants',
      error: error.message,
    });
  }
});

module.exports = router;

