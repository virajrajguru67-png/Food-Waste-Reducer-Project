const { pool } = require('../config/database');

class Coupon {
  static async create(couponData) {
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
    } = couponData;

    if (!code || !type || !value) {
      throw new Error('Code, type, and value are required');
    }

    try {
      const [result] = await pool.execute(
        `INSERT INTO coupons (
          code, type, value, min_order_amount, max_discount,
          valid_from, valid_until, usage_limit, restaurant_id
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          code.toUpperCase().trim(),
          type,
          value,
          minOrderAmount || 0,
          maxDiscount || null,
          validFrom,
          validUntil,
          usageLimit || null,
          restaurantId || null,
        ]
      );

      return result.insertId;
    } catch (error) {
      console.error('Error creating coupon:', error);
      throw error;
    }
  }

  static async findByCode(code) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM coupons WHERE code = ?',
        [code.toUpperCase()]
      );
      if (rows.length === 0) return null;
      return this._formatCoupon(rows[0]);
    } catch (error) {
      console.error('Error finding coupon:', error);
      throw error;
    }
  }

  static async findById(id) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM coupons WHERE id = ?',
        [id]
      );
      if (rows.length === 0) return null;
      return this._formatCoupon(rows[0]);
    } catch (error) {
      console.error('Error finding coupon:', error);
      throw error;
    }
  }

  static async findAll(filters = {}) {
    try {
      let query = 'SELECT * FROM coupons WHERE 1=1';
      const params = [];

      if (filters.status) {
        query += ' AND status = ?';
        params.push(filters.status);
      }

      if (filters.restaurantId !== undefined) {
        if (filters.restaurantId === null) {
          query += ' AND restaurant_id IS NULL';
        } else {
          query += ' AND restaurant_id = ?';
          params.push(filters.restaurantId);
        }
      }

      query += ' ORDER BY created_at DESC';

      if (filters.limit) {
        query += ' LIMIT ?';
        params.push(filters.limit);
      }

      const [rows] = await pool.execute(query, params);
      return rows.map(row => this._formatCoupon(row));
    } catch (error) {
      console.error('Error finding coupons:', error);
      throw error;
    }
  }

  static async validate(code, orderAmount, restaurantId = null) {
    try {
      const coupon = await this.findByCode(code);
      
      if (!coupon) {
        return { valid: false, message: 'Coupon code not found' };
      }

      if (coupon.status !== 'active') {
        return { valid: false, message: 'Coupon is not active' };
      }

      const now = new Date();
      if (new Date(coupon.validFrom) > now) {
        return { valid: false, message: 'Coupon is not yet valid' };
      }

      if (new Date(coupon.validUntil) < now) {
        return { valid: false, message: 'Coupon has expired' };
      }

      if (orderAmount < coupon.minOrderAmount) {
        return { 
          valid: false, 
          message: `Minimum order amount is ₹${coupon.minOrderAmount}` 
        };
      }

      if (coupon.usageLimit && coupon.usedCount >= coupon.usageLimit) {
        return { valid: false, message: 'Coupon usage limit reached' };
      }

      if (coupon.restaurantId && coupon.restaurantId !== restaurantId) {
        return { valid: false, message: 'Coupon is not valid for this restaurant' };
      }

      // Calculate discount
      let discount = 0;
      if (coupon.type === 'percentage') {
        discount = (orderAmount * coupon.value) / 100;
        if (coupon.maxDiscount) {
          discount = Math.min(discount, coupon.maxDiscount);
        }
      } else {
        discount = Math.min(coupon.value, orderAmount);
      }

      return {
        valid: true,
        coupon: coupon,
        discount: discount,
      };
    } catch (error) {
      console.error('Error validating coupon:', error);
      return { valid: false, message: 'Error validating coupon' };
    }
  }

  static async update(id, updateData) {
    try {
      const updates = [];
      const values = [];

      const allowedFields = [
        'code', 'type', 'value', 'min_order_amount', 'max_discount',
        'valid_from', 'valid_until', 'usage_limit', 'restaurant_id', 'status'
      ];

      for (const [key, value] of Object.entries(updateData)) {
        if (allowedFields.includes(key)) {
          updates.push(`${key} = ?`);
          values.push(value);
        }
      }

      if (updates.length === 0) {
        return;
      }

      values.push(id);
      await pool.execute(
        `UPDATE coupons SET ${updates.join(', ')} WHERE id = ?`,
        values
      );
    } catch (error) {
      console.error('Error updating coupon:', error);
      throw error;
    }
  }

  static async delete(id) {
    try {
      await pool.execute('DELETE FROM coupons WHERE id = ?', [id]);
    } catch (error) {
      console.error('Error deleting coupon:', error);
      throw error;
    }
  }

  static _formatCoupon(row) {
    return {
      id: row.id,
      code: row.code,
      type: row.type,
      value: parseFloat(row.value),
      minOrderAmount: parseFloat(row.min_order_amount) || 0,
      maxDiscount: row.max_discount ? parseFloat(row.max_discount) : null,
      validFrom: row.valid_from,
      validUntil: row.valid_until,
      usageLimit: row.usage_limit,
      usedCount: row.used_count || 0,
      restaurantId: row.restaurant_id,
      status: row.status,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}

module.exports = Coupon;

