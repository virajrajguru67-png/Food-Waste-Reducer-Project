const { pool } = require('../config/database');

class Restaurant {
  static async create(restaurantData) {
    const {
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
    } = restaurantData;

    if (!name || !name.trim()) {
      throw new Error('Restaurant name is required');
    }
    if (!ownerId) {
      throw new Error('Owner ID is required');
    }

    try {
      const [result] = await pool.execute(
        `INSERT INTO restaurants (
          owner_id, name, description, category, address, 
          latitude, longitude, phone, email, images, 
          operating_hours, commission_rate
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          ownerId,
          name.trim(),
          description ? description.trim() : null,
          category || null,
          address ? JSON.stringify(address) : null,
          latitude || null,
          longitude || null,
          phone ? phone.trim() : null,
          email ? email.trim() : null,
          images ? JSON.stringify(images) : null,
          operatingHours ? JSON.stringify(operatingHours) : null,
          commissionRate || 0.00,
        ]
      );

      return result.insertId;
    } catch (error) {
      console.error('Error creating restaurant:', error);
      throw error;
    }
  }

  static async findById(id) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM restaurants WHERE id = ?',
        [id]
      );
      if (rows.length === 0) return null;
      return this._formatRestaurant(rows[0]);
    } catch (error) {
      console.error('Error finding restaurant:', error);
      throw error;
    }
  }

  static async findByOwnerId(ownerId) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM restaurants WHERE owner_id = ? ORDER BY created_at DESC',
        [ownerId]
      );
      return rows.map(row => this._formatRestaurant(row));
    } catch (error) {
      console.error('Error finding restaurants by owner:', error);
      throw error;
    }
  }

  static async findAll(filters = {}) {
    try {
      let query = 'SELECT * FROM restaurants WHERE 1=1';
      const params = [];

      if (filters.status) {
        query += ' AND status = ?';
        params.push(filters.status);
      }

      if (filters.verified !== undefined) {
        query += ' AND verified = ?';
        params.push(filters.verified);
      }

      if (filters.category) {
        query += ' AND category = ?';
        params.push(filters.category);
      }

      if (filters.search) {
        query += ' AND (name LIKE ? OR description LIKE ?)';
        const searchTerm = `%${filters.search}%`;
        params.push(searchTerm, searchTerm);
      }

      query += ' ORDER BY created_at DESC';

      if (filters.limit) {
        query += ' LIMIT ?';
        params.push(filters.limit);
        if (filters.offset) {
          query += ' OFFSET ?';
          params.push(filters.offset);
        }
      }

      const [rows] = await pool.execute(query, params);
      return rows.map(row => this._formatRestaurant(row));
    } catch (error) {
      console.error('Error finding restaurants:', error);
      throw error;
    }
  }

  static async update(id, updateData) {
    try {
      const updates = [];
      const values = [];

      const allowedFields = [
        'name', 'description', 'category', 'address', 'latitude', 'longitude',
        'phone', 'email', 'images', 'operating_hours', 'verified', 'status', 'commission_rate'
      ];

      for (const [key, value] of Object.entries(updateData)) {
        if (allowedFields.includes(key)) {
          if (key === 'address' || key === 'images' || key === 'operating_hours') {
            updates.push(`${key} = ?`);
            values.push(value ? JSON.stringify(value) : null);
          } else {
            updates.push(`${key} = ?`);
            values.push(value);
          }
        }
      }

      if (updates.length === 0) {
        return;
      }

      values.push(id);
      await pool.execute(
        `UPDATE restaurants SET ${updates.join(', ')} WHERE id = ?`,
        values
      );
    } catch (error) {
      console.error('Error updating restaurant:', error);
      throw error;
    }
  }

  static async updateRating(restaurantId) {
    try {
      const [rows] = await pool.execute(
        `SELECT AVG(rating) as avg_rating, COUNT(*) as review_count 
         FROM reviews WHERE restaurant_id = ?`,
        [restaurantId]
      );

      const avgRating = rows[0].avg_rating || 0;
      const reviewCount = rows[0].review_count || 0;

      await pool.execute(
        'UPDATE restaurants SET rating = ?, review_count = ? WHERE id = ?',
        [avgRating, reviewCount, restaurantId]
      );
    } catch (error) {
      console.error('Error updating restaurant rating:', error);
      throw error;
    }
  }

  static async delete(id) {
    try {
      await pool.execute('DELETE FROM restaurants WHERE id = ?', [id]);
    } catch (error) {
      console.error('Error deleting restaurant:', error);
      throw error;
    }
  }

  static _formatRestaurant(row) {
    return {
      id: row.id,
      ownerId: row.owner_id,
      name: row.name,
      description: row.description,
      category: row.category,
      address: row.address ? JSON.parse(row.address) : null,
      latitude: row.latitude,
      longitude: row.longitude,
      phone: row.phone,
      email: row.email,
      images: row.images ? JSON.parse(row.images) : [],
      operatingHours: row.operating_hours ? JSON.parse(row.operating_hours) : null,
      verified: row.verified === 1,
      rating: parseFloat(row.rating) || 0,
      reviewCount: row.review_count || 0,
      status: row.status,
      commissionRate: parseFloat(row.commission_rate) || 0,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}

module.exports = Restaurant;

