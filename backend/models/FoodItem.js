const { pool } = require('../config/database');

class FoodItem {
  static async create(foodItemData) {
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
    } = foodItemData;

    if (!name || !name.trim()) {
      throw new Error('Food item name is required');
    }
    if (!restaurantId) {
      throw new Error('Restaurant ID is required');
    }

    try {
      const [result] = await pool.execute(
        `INSERT INTO food_items (
          restaurant_id, name, description, category, images,
          original_price, discounted_price, quantity_available,
          expiry_time, pickup_time_window, ingredients, allergens, dietary_info
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          restaurantId,
          name.trim(),
          description ? description.trim() : null,
          category || null,
          images ? JSON.stringify(images) : JSON.stringify([]),
          originalPrice,
          discountedPrice,
          quantityAvailable || 0,
          expiryTime || null,
          pickupTimeWindow ? JSON.stringify(pickupTimeWindow) : null,
          ingredients ? JSON.stringify(ingredients) : null,
          allergens ? JSON.stringify(allergens) : null,
          dietaryInfo ? JSON.stringify(dietaryInfo) : null,
        ]
      );

      return result.insertId;
    } catch (error) {
      console.error('Error creating food item:', error);
      throw error;
    }
  }

  static async findById(id) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM food_items WHERE id = ?',
        [id]
      );
      if (rows.length === 0) return null;
      return this._formatFoodItem(rows[0]);
    } catch (error) {
      console.error('Error finding food item:', error);
      throw error;
    }
  }

  static async findByRestaurantId(restaurantId, filters = {}) {
    try {
      let query = 'SELECT * FROM food_items WHERE restaurant_id = ?';
      const params = [restaurantId];

      if (filters.status) {
        query += ' AND status = ?';
        params.push(filters.status);
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

      const [rows] = await pool.execute(query, params);
      return rows.map(row => this._formatFoodItem(row));
    } catch (error) {
      console.error('Error finding food items:', error);
      throw error;
    }
  }

  static async findAll(filters = {}) {
    try {
      let query = 'SELECT * FROM food_items WHERE 1=1';
      const params = [];

      if (filters.restaurantId) {
        query += ' AND restaurant_id = ?';
        params.push(filters.restaurantId);
      }

      if (filters.status) {
        query += ' AND status = ?';
        params.push(filters.status);
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
      return rows.map(row => this._formatFoodItem(row));
    } catch (error) {
      console.error('Error finding food items:', error);
      throw error;
    }
  }

  static async update(id, updateData) {
    try {
      const updates = [];
      const values = [];

      const allowedFields = [
        'name', 'description', 'category', 'images', 'original_price', 'discounted_price',
        'quantity_available', 'expiry_time', 'pickup_time_window', 'ingredients',
        'allergens', 'dietary_info', 'status'
      ];

      for (const [key, value] of Object.entries(updateData)) {
        if (allowedFields.includes(key)) {
          if (['images', 'pickup_time_window', 'ingredients', 'allergens', 'dietary_info'].includes(key)) {
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
        `UPDATE food_items SET ${updates.join(', ')} WHERE id = ?`,
        values
      );
    } catch (error) {
      console.error('Error updating food item:', error);
      throw error;
    }
  }

  static async updateQuantity(id, quantity) {
    try {
      await pool.execute(
        'UPDATE food_items SET quantity_available = ? WHERE id = ?',
        [quantity, id]
      );
    } catch (error) {
      console.error('Error updating food item quantity:', error);
      throw error;
    }
  }

  static async delete(id) {
    try {
      await pool.execute('DELETE FROM food_items WHERE id = ?', [id]);
    } catch (error) {
      console.error('Error deleting food item:', error);
      throw error;
    }
  }

  static _formatFoodItem(row) {
    return {
      id: row.id,
      restaurantId: row.restaurant_id,
      name: row.name,
      description: row.description,
      category: row.category,
      images: row.images ? JSON.parse(row.images) : [],
      originalPrice: parseFloat(row.original_price),
      discountedPrice: parseFloat(row.discounted_price),
      quantityAvailable: row.quantity_available,
      expiryTime: row.expiry_time,
      pickupTimeWindow: row.pickup_time_window ? JSON.parse(row.pickup_time_window) : null,
      ingredients: row.ingredients ? JSON.parse(row.ingredients) : null,
      allergens: row.allergens ? JSON.parse(row.allergens) : null,
      dietaryInfo: row.dietary_info ? JSON.parse(row.dietary_info) : null,
      status: row.status,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}

module.exports = FoodItem;

