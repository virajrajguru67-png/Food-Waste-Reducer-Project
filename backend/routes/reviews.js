const express = require('express');
const router = express.Router();
const Review = require('../models/Review');
const { authenticateToken } = require('../middleware/auth');

// Get all reviews
router.get('/', async (req, res) => {
  try {
    const filters = {
      restaurantId: req.query.restaurantId ? parseInt(req.query.restaurantId) : undefined,
      rating: req.query.rating ? parseInt(req.query.rating) : undefined,
      limit: req.query.limit ? parseInt(req.query.limit) : undefined,
    };

    const reviews = await Review.findAll(filters);
    res.json({
      success: true,
      data: reviews,
    });
  } catch (error) {
    console.error('Error fetching reviews:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch reviews',
      error: error.message,
    });
  }
});

// Get reviews by restaurant
router.get('/restaurant/:restaurantId', async (req, res) => {
  try {
    const filters = {
      rating: req.query.rating ? parseInt(req.query.rating) : undefined,
      limit: req.query.limit ? parseInt(req.query.limit) : undefined,
    };

    const reviews = await Review.findByRestaurantId(req.params.restaurantId, filters);
    res.json({
      success: true,
      data: reviews,
    });
  } catch (error) {
    console.error('Error fetching reviews:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch reviews',
      error: error.message,
    });
  }
});

// Get review by ID
router.get('/:id', async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found',
      });
    }

    res.json({
      success: true,
      data: review,
    });
  } catch (error) {
    console.error('Error fetching review:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch review',
      error: error.message,
    });
  }
});

// Create review
router.post('/', authenticateToken, async (req, res) => {
  try {
    const {
      restaurantId,
      orderId,
      rating,
      comment,
      images,
    } = req.body;

    if (!restaurantId || !rating) {
      return res.status(400).json({
        success: false,
        message: 'Restaurant ID and rating are required',
      });
    }

    if (rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5',
      });
    }

    const reviewId = await Review.create({
      userId: req.user.userId,
      restaurantId,
      orderId,
      rating,
      comment,
      images,
    });

    const review = await Review.findById(reviewId);

    res.status(201).json({
      success: true,
      message: 'Review created successfully',
      data: review,
    });
  } catch (error) {
    console.error('Error creating review:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create review',
      error: error.message,
    });
  }
});

// Update review
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found',
      });
    }

    // Only the review author can update
    if (review.userId !== req.user.userId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this review',
      });
    }

    await Review.update(req.params.id, req.body);
    const updatedReview = await Review.findById(req.params.id);

    res.json({
      success: true,
      message: 'Review updated successfully',
      data: updatedReview,
    });
  } catch (error) {
    console.error('Error updating review:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update review',
      error: error.message,
    });
  }
});

// Mark review as helpful
router.post('/:id/helpful', authenticateToken, async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found',
      });
    }

    await Review.incrementHelpful(req.params.id);
    const updatedReview = await Review.findById(req.params.id);

    res.json({
      success: true,
      message: 'Review marked as helpful',
      data: updatedReview,
    });
  } catch (error) {
    console.error('Error marking review as helpful:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to mark review as helpful',
      error: error.message,
    });
  }
});

// Delete review
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found',
      });
    }

    // Only the review author or admin can delete
    if (review.userId !== req.user.userId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this review',
      });
    }

    await Review.delete(req.params.id);

    res.json({
      success: true,
      message: 'Review deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting review:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete review',
      error: error.message,
    });
  }
});

module.exports = router;

