const express = require('express');
const router = express.Router();
const DeliveryTracking = require('../models/DeliveryTracking');
const Order = require('../models/Order');
const { authenticateToken } = require('../middleware/auth');
const { requireAdmin } = require('../middleware/admin');

// Get delivery status by order ID
router.get('/:orderId', authenticateToken, async (req, res) => {
  try {
    const order = await Order.findById(req.params.orderId);
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
        message: 'Not authorized to view this delivery',
      });
    }

    const tracking = await DeliveryTracking.findByOrderId(req.params.orderId);
    if (!tracking) {
      return res.status(404).json({
        success: false,
        message: 'Delivery tracking not found',
      });
    }

    res.json({
      success: true,
      data: tracking,
    });
  } catch (error) {
    console.error('Error fetching delivery tracking:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch delivery tracking',
      error: error.message,
    });
  }
});

// Get delivery by tracking number (public)
router.get('/track/:trackingNumber', async (req, res) => {
  try {
    const tracking = await DeliveryTracking.findByTrackingNumber(req.params.trackingNumber);
    if (!tracking) {
      return res.status(404).json({
        success: false,
        message: 'Tracking number not found',
      });
    }

    res.json({
      success: true,
      data: tracking,
    });
  } catch (error) {
    console.error('Error fetching delivery tracking:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch delivery tracking',
      error: error.message,
    });
  }
});

// Update delivery status (admin/system)
router.post('/:orderId/update', requireAdmin, async (req, res) => {
  try {
    const { status, currentLocation, estimatedDeliveryTime } = req.body;

    if (!status) {
      return res.status(400).json({
        success: false,
        message: 'Status is required',
      });
    }

    await DeliveryTracking.updateStatus(
      req.params.orderId,
      status,
      currentLocation,
      estimatedDeliveryTime
    );

    // Update order status if delivery is completed
    if (status === 'delivered') {
      await Order.updateStatus(req.params.orderId, 'delivered');
    }

    const tracking = await DeliveryTracking.findByOrderId(req.params.orderId);

    res.json({
      success: true,
      message: 'Delivery status updated successfully',
      data: tracking,
    });
  } catch (error) {
    console.error('Error updating delivery status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update delivery status',
      error: error.message,
    });
  }
});

// Webhook for external delivery API
router.post('/:orderId/webhook', async (req, res) => {
  try {
    // This endpoint will be called by external delivery API
    // In production, you should verify the webhook signature
    
    const externalData = req.body;
    
    await DeliveryTracking.updateFromExternal(req.params.orderId, {
      status: externalData.status,
      location: externalData.location,
      estimatedDeliveryTime: externalData.estimatedDeliveryTime,
    });

    // Update order status if delivery is completed
    if (externalData.status === 'delivered') {
      await Order.updateStatus(req.params.orderId, 'delivered');
      await Order.updatePaymentStatus(req.params.orderId, 'paid');
    }

    res.json({
      success: true,
      message: 'Webhook processed successfully',
    });
  } catch (error) {
    console.error('Error processing webhook:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process webhook',
      error: error.message,
    });
  }
});

// Get all active deliveries (admin)
router.get('/', requireAdmin, async (req, res) => {
  try {
    const filters = {
      status: req.query.status,
      limit: req.query.limit ? parseInt(req.query.limit) : 50,
    };

    const deliveries = await DeliveryTracking.findAll(filters);
    res.json({
      success: true,
      data: deliveries,
    });
  } catch (error) {
    console.error('Error fetching deliveries:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch deliveries',
      error: error.message,
    });
  }
});

module.exports = router;

