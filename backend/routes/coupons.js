const express = require('express');
const router = express.Router();
const Coupon = require('../models/Coupon');
const { authenticateToken } = require('../middleware/auth');
const { requireAdmin } = require('../middleware/admin');

// Get all coupons (public, but filtered)
router.get('/', async (req, res) => {
  try {
    const filters = {
      status: req.query.status || 'active',
      restaurantId: req.query.restaurantId ? parseInt(req.query.restaurantId) : undefined,
      limit: req.query.limit ? parseInt(req.query.limit) : undefined,
    };

    const coupons = await Coupon.findAll(filters);
    res.json({
      success: true,
      data: coupons,
    });
  } catch (error) {
    console.error('Error fetching coupons:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch coupons',
      error: error.message,
    });
  }
});

// Validate coupon code
router.get('/:code/validate', async (req, res) => {
  try {
    const { code } = req.params;
    const orderAmount = parseFloat(req.query.orderAmount) || 0;
    const restaurantId = req.query.restaurantId ? parseInt(req.query.restaurantId) : null;

    const validation = await Coupon.validate(code, orderAmount, restaurantId);

    if (!validation.valid) {
      return res.status(400).json({
        success: false,
        message: validation.message,
      });
    }

    res.json({
      success: true,
      data: {
        coupon: validation.coupon,
        discount: validation.discount,
      },
    });
  } catch (error) {
    console.error('Error validating coupon:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to validate coupon',
      error: error.message,
    });
  }
});

// Get coupon by ID
router.get('/:id', async (req, res) => {
  try {
    const coupon = await Coupon.findById(req.params.id);
    if (!coupon) {
      return res.status(404).json({
        success: false,
        message: 'Coupon not found',
      });
    }

    res.json({
      success: true,
      data: coupon,
    });
  } catch (error) {
    console.error('Error fetching coupon:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch coupon',
      error: error.message,
    });
  }
});

// Create coupon (admin only)
router.post('/', requireAdmin, async (req, res) => {
  try {
    const {
      code,
      type,
      value,
      minOrderAmount,
      maxDiscount,
      validFrom,
      validUntil,
      usageLimit,
      restaurantId,
    } = req.body;

    if (!code || !type || !value) {
      return res.status(400).json({
        success: false,
        message: 'Code, type, and value are required',
      });
    }

    // Check if code already exists
    const existing = await Coupon.findByCode(code);
    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'Coupon code already exists',
      });
    }

    const couponId = await Coupon.create({
      code,
      type,
      value,
      minOrderAmount,
      maxDiscount,
      validFrom,
      validUntil,
      usageLimit,
      restaurantId,
    });

    const coupon = await Coupon.findById(couponId);

    res.status(201).json({
      success: true,
      message: 'Coupon created successfully',
      data: coupon,
    });
  } catch (error) {
    console.error('Error creating coupon:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create coupon',
      error: error.message,
    });
  }
});

// Update coupon (admin only)
router.put('/:id', requireAdmin, async (req, res) => {
  try {
    const coupon = await Coupon.findById(req.params.id);
    if (!coupon) {
      return res.status(404).json({
        success: false,
        message: 'Coupon not found',
      });
    }

    await Coupon.update(req.params.id, req.body);
    const updatedCoupon = await Coupon.findById(req.params.id);

    res.json({
      success: true,
      message: 'Coupon updated successfully',
      data: updatedCoupon,
    });
  } catch (error) {
    console.error('Error updating coupon:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update coupon',
      error: error.message,
    });
  }
});

// Delete coupon (admin only)
router.delete('/:id', requireAdmin, async (req, res) => {
  try {
    const coupon = await Coupon.findById(req.params.id);
    if (!coupon) {
      return res.status(404).json({
        success: false,
        message: 'Coupon not found',
      });
    }

    await Coupon.delete(req.params.id);

    res.json({
      success: true,
      message: 'Coupon deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting coupon:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete coupon',
      error: error.message,
    });
  }
});

module.exports = router;

