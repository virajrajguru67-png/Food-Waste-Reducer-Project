const { pool } = require('../config/database');

class UserAddress {
  static async create(addressData) {
    const {
      userId,
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
    } = addressData;

    if (!userId || !label || !addressLine1 || !city) {
      throw new Error('User ID, label, address line 1, and city are required');
    }

    try {
      // If this is set as default, unset other defaults
      if (isDefault) {
        await pool.execute(
          'UPDATE user_addresses SET is_default = FALSE WHERE user_id = ?',
          [userId]
        );
      }

      const [result] = await pool.execute(
        `INSERT INTO user_addresses (
          user_id, label, address_line1, address_line2, city, state,
          postal_code, country, latitude, longitude, is_default
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          userId,
          label.trim(),
          addressLine1.trim(),
          addressLine2 ? addressLine2.trim() : null,
          city.trim(),
          state ? state.trim() : null,
          postalCode ? postalCode.trim() : null,
          country || 'India',
          latitude || null,
          longitude || null,
          isDefault || false,
        ]
      );

      return result.insertId;
    } catch (error) {
      console.error('Error creating user address:', error);
      throw error;
    }
  }

  static async findById(id) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM user_addresses WHERE id = ?',
        [id]
      );
      if (rows.length === 0) return null;
      return this._formatAddress(rows[0]);
    } catch (error) {
      console.error('Error finding address:', error);
      throw error;
    }
  }

  static async findByUserId(userId) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM user_addresses WHERE user_id = ? ORDER BY is_default DESC, created_at DESC',
        [userId]
      );
      return rows.map(row => this._formatAddress(row));
    } catch (error) {
      console.error('Error finding addresses by user:', error);
      throw error;
    }
  }

  static async findDefaultByUserId(userId) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM user_addresses WHERE user_id = ? AND is_default = TRUE LIMIT 1',
        [userId]
      );
      return rows.length > 0 ? this._formatAddress(rows[0]) : null;
    } catch (error) {
      console.error('Error finding default address:', error);
      throw error;
    }
  }

  static async update(id, updateData) {
    try {
      const updates = [];
      const values = [];

      const allowedFields = [
        'label', 'address_line1', 'address_line2', 'city', 'state',
        'postal_code', 'country', 'latitude', 'longitude', 'is_default'
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

      // If setting as default, unset other defaults for the same user
      if (updateData.is_default === true) {
        const address = await this.findById(id);
        if (address) {
          await pool.execute(
            'UPDATE user_addresses SET is_default = FALSE WHERE user_id = ? AND id != ?',
            [address.userId, id]
          );
        }
      }

      values.push(id);
      await pool.execute(
        `UPDATE user_addresses SET ${updates.join(', ')} WHERE id = ?`,
        values
      );
    } catch (error) {
      console.error('Error updating address:', error);
      throw error;
    }
  }

  static async delete(id) {
    try {
      await pool.execute('DELETE FROM user_addresses WHERE id = ?', [id]);
    } catch (error) {
      console.error('Error deleting address:', error);
      throw error;
    }
  }

  static _formatAddress(row) {
    return {
      id: row.id,
      userId: row.user_id,
      label: row.label,
      addressLine1: row.address_line1,
      addressLine2: row.address_line2,
      city: row.city,
      state: row.state,
      postalCode: row.postal_code,
      country: row.country,
      latitude: row.latitude ? parseFloat(row.latitude) : null,
      longitude: row.longitude ? parseFloat(row.longitude) : null,
      isDefault: row.is_default === 1,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}

module.exports = UserAddress;

