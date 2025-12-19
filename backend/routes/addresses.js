const express = require('express');
const router = express.Router();
const UserAddress = require('../models/UserAddress');
const { authenticateToken } = require('../middleware/auth');

// Get all addresses for current user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const addresses = await UserAddress.findByUserId(req.user.userId);
    res.json({
      success: true,
      data: addresses,
    });
  } catch (error) {
    console.error('Error fetching addresses:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch addresses',
      error: error.message,
    });
  }
});

// Get default address for current user
router.get('/default', authenticateToken, async (req, res) => {
  try {
    const address = await UserAddress.findDefaultByUserId(req.user.userId);
    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'No default address found',
      });
    }

    res.json({
      success: true,
      data: address,
    });
  } catch (error) {
    console.error('Error fetching default address:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch default address',
      error: error.message,
    });
  }
});

// Get address by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const address = await UserAddress.findById(req.params.id);
    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Address not found',
      });
    }

    // Check if user owns this address
    if (address.userId !== req.user.userId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this address',
      });
    }

    res.json({
      success: true,
      data: address,
    });
  } catch (error) {
    console.error('Error fetching address:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch address',
      error: error.message,
    });
  }
});

// Create address
router.post('/', authenticateToken, async (req, res) => {
  try {
    const {
      label,
      addressLine1,
      addressLine2,
      city,
      state,
      postalCode,
      country,
      latitude,
      longitude,
      isDefault,
    } = req.body;

    if (!label || !addressLine1 || !city) {
      return res.status(400).json({
        success: false,
        message: 'Label, address line 1, and city are required',
      });
    }

    const addressId = await UserAddress.create({
      userId: req.user.userId,
      label,
      addressLine1,
      addressLine2,
      city,
      state,
      postalCode,
      country,
      latitude,
      longitude,
      isDefault,
    });

    const address = await UserAddress.findById(addressId);

    res.status(201).json({
      success: true,
      message: 'Address created successfully',
      data: address,
    });
  } catch (error) {
    console.error('Error creating address:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create address',
      error: error.message,
    });
  }
});

// Update address
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const address = await UserAddress.findById(req.params.id);
    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Address not found',
      });
    }

    // Check if user owns this address
    if (address.userId !== req.user.userId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this address',
      });
    }

    // Map request body to database fields
    const updateData = {};
    if (req.body.label !== undefined) updateData.label = req.body.label;
    if (req.body.addressLine1 !== undefined) updateData.address_line1 = req.body.addressLine1;
    if (req.body.addressLine2 !== undefined) updateData.address_line2 = req.body.addressLine2;
    if (req.body.city !== undefined) updateData.city = req.body.city;
    if (req.body.state !== undefined) updateData.state = req.body.state;
    if (req.body.postalCode !== undefined) updateData.postal_code = req.body.postalCode;
    if (req.body.country !== undefined) updateData.country = req.body.country;
    if (req.body.latitude !== undefined) updateData.latitude = req.body.latitude;
    if (req.body.longitude !== undefined) updateData.longitude = req.body.longitude;
    if (req.body.isDefault !== undefined) updateData.is_default = req.body.isDefault;

    await UserAddress.update(req.params.id, updateData);
    const updatedAddress = await UserAddress.findById(req.params.id);

    res.json({
      success: true,
      message: 'Address updated successfully',
      data: updatedAddress,
    });
  } catch (error) {
    console.error('Error updating address:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update address',
      error: error.message,
    });
  }
});

// Delete address
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const address = await UserAddress.findById(req.params.id);
    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Address not found',
      });
    }

    // Check if user owns this address
    if (address.userId !== req.user.userId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this address',
      });
    }

    await UserAddress.delete(req.params.id);

    res.json({
      success: true,
      message: 'Address deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting address:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete address',
      error: error.message,
    });
  }
});

module.exports = router;

