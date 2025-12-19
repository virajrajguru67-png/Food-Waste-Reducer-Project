const express = require('express');
const router = express.Router();
const FoodItem = require('../models/FoodItem');
const Restaurant = require('../models/Restaurant');
const { authenticateToken } = require('../middleware/auth');
const { requireAdminOrOwner } = require('../middleware/admin');

// Get all food items (public)
router.get('/', async (req, res) => {
  try {
    const filters = {
      restaurantId: req.query.restaurantId ? parseInt(req.query.restaurantId) : undefined,
      status: req.query.status,
      category: req.query.category,
      search: req.query.search,
      limit: req.query.limit ? parseInt(req.query.limit) : undefined,
      offset: req.query.offset ? parseInt(req.query.offset) : undefined,
    };

    const foodItems = await FoodItem.findAll(filters);
    res.json({
      success: true,
      data: foodItems,
    });
  } catch (error) {
    console.error('Error fetching food items:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch food items',
      error: error.message,
    });
  }
});

// Get food item by ID (public)
router.get('/:id', async (req, res) => {
  try {
    const foodItem = await FoodItem.findById(req.params.id);
    if (!foodItem) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found',
      });
    }

    res.json({
      success: true,
      data: foodItem,
    });
  } catch (error) {
    console.error('Error fetching food item:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch food item',
      error: error.message,
    });
  }
});

// Get food items by restaurant (public)
router.get('/restaurant/:restaurantId', async (req, res) => {
  try {
    const filters = {
      status: req.query.status,
      category: req.query.category,
      search: req.query.search,
    };

    const foodItems = await FoodItem.findByRestaurantId(req.params.restaurantId, filters);
    res.json({
      success: true,
      data: foodItems,
    });
  } catch (error) {
    console.error('Error fetching food items:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch food items',
      error: error.message,
    });
  }
});

// Create food item (restaurant owner or admin)
router.post('/', requireAdminOrOwner, async (req, res) => {
  try {
    const {
      restaurantId,
      name,
      description,
      category,
      images,
      originalPrice,
      discountedPrice,
      quantityAvailable,
      expiryTime,
      pickupTimeWindow,
      ingredients,
      allergens,
      dietaryInfo,
    } = req.body;

    if (!name || !restaurantId) {
      return res.status(400).json({
        success: false,
        message: 'Name and restaurant ID are required',
      });
    }

    // Check if user owns the restaurant or is admin
    if (req.user.role !== 'admin') {
      const restaurant = await Restaurant.findById(restaurantId);
      if (!restaurant || restaurant.ownerId !== req.user.userId) {
        return res.status(403).json({
          success: false,
          message: 'Not authorized to add items to this restaurant',
        });
      }
    }

    const foodItemId = await FoodItem.create({
      restaurantId,
      name,
      description,
      category,
      images,
      originalPrice,
      discountedPrice,
      quantityAvailable,
      expiryTime,
      pickupTimeWindow,
      ingredients,
      allergens,
      dietaryInfo,
    });

    const foodItem = await FoodItem.findById(foodItemId);

    res.status(201).json({
      success: true,
      message: 'Food item created successfully',
      data: foodItem,
    });
  } catch (error) {
    console.error('Error creating food item:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create food item',
      error: error.message,
    });
  }
});

// Update food item
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const foodItem = await FoodItem.findById(req.params.id);
    if (!foodItem) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found',
      });
    }

    // Check if user owns the restaurant or is admin
    if (req.user.role !== 'admin') {
      const restaurant = await Restaurant.findById(foodItem.restaurantId);
      if (!restaurant || restaurant.ownerId !== req.user.userId) {
        return res.status(403).json({
          success: false,
          message: 'Not authorized to update this food item',
        });
      }
    }

    await FoodItem.update(req.params.id, req.body);
    const updatedFoodItem = await FoodItem.findById(req.params.id);

    res.json({
      success: true,
      message: 'Food item updated successfully',
      data: updatedFoodItem,
    });
  } catch (error) {
    console.error('Error updating food item:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update food item',
      error: error.message,
    });
  }
});

// Delete food item
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const foodItem = await FoodItem.findById(req.params.id);
    if (!foodItem) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found',
      });
    }

    // Check if user owns the restaurant or is admin
    if (req.user.role !== 'admin') {
      const restaurant = await Restaurant.findById(foodItem.restaurantId);
      if (!restaurant || restaurant.ownerId !== req.user.userId) {
        return res.status(403).json({
          success: false,
          message: 'Not authorized to delete this food item',
        });
      }
    }

    await FoodItem.delete(req.params.id);

    res.json({
      success: true,
      message: 'Food item deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting food item:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete food item',
      error: error.message,
    });
  }
});

module.exports = router;

