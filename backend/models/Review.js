const { pool } = require('../config/database');
const Restaurant = require('./Restaurant');

class Review {
  static async create(reviewData) {
    const {
      userId,
      restaurantId,
      orderId,
      rating,
      comment,
      images,
    } = reviewData;

    if (!userId || !restaurantId || !rating) {
      throw new Error('User ID, restaurant ID, and rating are required');
    }

    if (rating < 1 || rating > 5) {
      throw new Error('Rating must be between 1 and 5');
    }

    try {
      const [result] = await pool.execute(
        `INSERT INTO reviews (
          user_id, restaurant_id, order_id, rating, comment, images
        ) VALUES (?, ?, ?, ?, ?, ?)`,
        [
          userId,
          restaurantId,
          orderId || null,
          rating,
          comment ? comment.trim() : null,
          images ? JSON.stringify(images) : null,
        ]
      );

      // Update restaurant rating
      await Restaurant.updateRating(restaurantId);

      return result.insertId;
    } catch (error) {
      console.error('Error creating review:', error);
      throw error;
    }
  }

  static async findById(id) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM reviews WHERE id = ?',
        [id]
      );
      if (rows.length === 0) return null;
      return this._formatReview(rows[0]);
    } catch (error) {
      console.error('Error finding review:', error);
      throw error;
    }
  }

  static async findByRestaurantId(restaurantId, filters = {}) {
    try {
      let query = `
        SELECT r.*, u.name as user_name, u.email as user_email
        FROM reviews r
        LEFT JOIN users u ON r.user_id = u.id
        WHERE r.restaurant_id = ?
      `;
      const params = [restaurantId];

      if (filters.rating) {
        query += ' AND r.rating = ?';
        params.push(filters.rating);
      }

      query += ' ORDER BY r.created_at DESC';

      if (filters.limit) {
        query += ' LIMIT ?';
        params.push(filters.limit);
      }

      const [rows] = await pool.execute(query, params);
      return rows.map(row => this._formatReview(row));
    } catch (error) {
      console.error('Error finding reviews:', error);
      throw error;
    }
  }

  static async findByUserId(userId) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM reviews WHERE user_id = ? ORDER BY created_at DESC',
        [userId]
      );
      return rows.map(row => this._formatReview(row));
    } catch (error) {
      console.error('Error finding reviews by user:', error);
      throw error;
    }
  }

  static async findAll(filters = {}) {
    try {
      let query = `
        SELECT r.*, u.name as user_name, u.email as user_email
        FROM reviews r
        LEFT JOIN users u ON r.user_id = u.id
        WHERE 1=1
      `;
      const params = [];

      if (filters.restaurantId) {
        query += ' AND r.restaurant_id = ?';
        params.push(filters.restaurantId);
      }

      if (filters.rating) {
        query += ' AND r.rating = ?';
        params.push(filters.rating);
      }

      query += ' ORDER BY r.created_at DESC';

      if (filters.limit) {
        query += ' LIMIT ?';
        params.push(filters.limit);
      }

      const [rows] = await pool.execute(query, params);
      return rows.map(row => this._formatReview(row));
    } catch (error) {
      console.error('Error finding reviews:', error);
      throw error;
    }
  }

  static async update(id, updateData) {
    try {
      const updates = [];
      const values = [];

      if (updateData.rating !== undefined) {
        if (updateData.rating < 1 || updateData.rating > 5) {
          throw new Error('Rating must be between 1 and 5');
        }
        updates.push('rating = ?');
        values.push(updateData.rating);
      }

      if (updateData.comment !== undefined) {
        updates.push('comment = ?');
        values.push(updateData.comment ? updateData.comment.trim() : null);
      }

      if (updateData.images !== undefined) {
        updates.push('images = ?');
        values.push(updateData.images ? JSON.stringify(updateData.images) : null);
      }

      if (updates.length === 0) {
        return;
      }

      values.push(id);
      await pool.execute(
        `UPDATE reviews SET ${updates.join(', ')} WHERE id = ?`,
        values
      );

      // Update restaurant rating if rating changed
      if (updateData.rating !== undefined) {
        const review = await this.findById(id);
        if (review) {
          await Restaurant.updateRating(review.restaurantId);
        }
      }
    } catch (error) {
      console.error('Error updating review:', error);
      throw error;
    }
  }

  static async incrementHelpful(id) {
    try {
      await pool.execute(
        'UPDATE reviews SET helpful_count = helpful_count + 1 WHERE id = ?',
        [id]
      );
    } catch (error) {
      console.error('Error incrementing helpful count:', error);
      throw error;
    }
  }

  static async delete(id) {
    try {
      const review = await this.findById(id);
      await pool.execute('DELETE FROM reviews WHERE id = ?', [id]);
      
      // Update restaurant rating
      if (review) {
        await Restaurant.updateRating(review.restaurantId);
      }
    } catch (error) {
      console.error('Error deleting review:', error);
      throw error;
    }
  }

  static _formatReview(row) {
    return {
      id: row.id,
      userId: row.user_id,
      restaurantId: row.restaurant_id,
      orderId: row.order_id,
      rating: row.rating,
      comment: row.comment,
      images: row.images ? JSON.parse(row.images) : null,
      helpfulCount: row.helpful_count || 0,
      userName: row.user_name,
      userEmail: row.user_email,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}

module.exports = Review;

