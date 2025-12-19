const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const Restaurant = require('../models/Restaurant');
const DeliveryTracking = require('../models/DeliveryTracking');
const { authenticateToken } = require('../middleware/auth');

// Get all orders (filtered by user role)
router.get('/', authenticateToken, async (req, res) => {
  try {
    const filters = {};

    // Users can only see their own orders
    if (req.user.role === 'user') {
      filters.userId = req.user.userId;
    } else if (req.user.role === 'restaurant_owner') {
      // Restaurant owners see their restaurant's orders
      filters.restaurantId = req.query.restaurantId ? parseInt(req.query.restaurantId) : undefined;
    }
    // Admins can see all orders

    if (req.query.status) {
      filters.status = req.query.status;
    }

    if (req.query.paymentStatus) {
      filters.paymentStatus = req.query.paymentStatus;
    }

    filters.limit = req.query.limit ? parseInt(req.query.limit) : 50;
    filters.offset = req.query.offset ? parseInt(req.query.offset) : 0;

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

// Get order by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    // Check authorization
    if (req.user.role === 'user' && order.userId !== req.user.userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this order',
      });
    }

    res.json({
      success: true,
      data: order,
    });
  } catch (error) {
    console.error('Error fetching order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch order',
      error: error.message,
    });
  }
});

// Create order
router.post('/', authenticateToken, async (req, res) => {
  try {
    const {
      restaurantId,
      items,
      totalAmount,
      discountAmount,
      couponId,
      finalAmount,
      paymentMethod,
      address,
      notes,
    } = req.body;

    if (!restaurantId || !items || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Restaurant ID and items are required',
      });
    }

    const orderId = await Order.create({
      userId: req.user.userId,
      restaurantId,
      items,
      totalAmount,
      discountAmount,
      couponId,
      finalAmount,
      paymentMethod,
      address,
      notes,
    });

    // Create delivery tracking
    await DeliveryTracking.create({
      orderId,
      status: 'pending',
    });

    const order = await Order.findById(orderId);

    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: order,
    });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create order',
      error: error.message,
    });
  }
});

// Update order status
router.put('/:id/status', authenticateToken, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    // Check authorization - restaurant owners and admins can update status
    if (req.user.role === 'user') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update order status',
      });
    }

    if (req.user.role === 'restaurant_owner') {
      const restaurant = await Restaurant.findById(order.restaurantId);
      if (!restaurant || restaurant.ownerId !== req.user.userId) {
        return res.status(403).json({
          success: false,
          message: 'Not authorized to update this order',
        });
      }
    }

    const { status } = req.body;
    if (!status) {
      return res.status(400).json({
        success: false,
        message: 'Status is required',
      });
    }

    await Order.updateStatus(req.params.id, status);

    // Update delivery tracking if order is being delivered
    if (['ready', 'picked_up', 'delivered'].includes(status)) {
      await DeliveryTracking.updateStatus(req.params.id, status);
    }

    const updatedOrder = await Order.findById(req.params.id);

    res.json({
      success: true,
      message: 'Order status updated successfully',
      data: updatedOrder,
    });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update order status',
      error: error.message,
    });
  }
});

// Cancel order
router.post('/:id/cancel', authenticateToken, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    // Only users can cancel their own orders
    if (req.user.role === 'user' && order.userId !== req.user.userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to cancel this order',
      });
    }

    await Order.cancel(req.params.id, req.user.userId);
    const cancelledOrder = await Order.findById(req.params.id);

    res.json({
      success: true,
      message: 'Order cancelled successfully',
      data: cancelledOrder,
    });
  } catch (error) {
    console.error('Error cancelling order:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to cancel order',
      error: error.message,
    });
  }
});

// Update payment status
router.put('/:id/payment', authenticateToken, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    const { paymentStatus } = req.body;
    if (!paymentStatus) {
      return res.status(400).json({
        success: false,
        message: 'Payment status is required',
      });
    }

    await Order.updatePaymentStatus(req.params.id, paymentStatus);
    const updatedOrder = await Order.findById(req.params.id);

    res.json({
      success: true,
      message: 'Payment status updated successfully',
      data: updatedOrder,
    });
  } catch (error) {
    console.error('Error updating payment status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update payment status',
      error: error.message,
    });
  }
});

module.exports = router;

