const { pool } = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  static async create(userData) {
    const { name, email, password, phone, googleId, googleEmail } = userData;
    
    // Validate required fields
    if (!name || !name.trim()) {
      throw new Error('Name is required');
    }
    if (!email || !email.trim()) {
      throw new Error('Email is required');
    }
    
    // Hash password if provided
    let hashedPassword = null;
    if (password) {
      hashedPassword = await bcrypt.hash(password, 10);
    }

    try {
      const [result] = await pool.execute(
        `INSERT INTO users (name, email, password, phone, google_id, google_email) 
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          name.trim(), 
          email.trim(), 
          hashedPassword, 
          phone ? phone.trim() : null, 
          googleId || null, 
          googleEmail ? googleEmail.trim() : null
        ]
      );

      return result.insertId;
    } catch (error) {
      console.error('Error creating user:', error);
      throw error;
    }
  }

  static async findByEmail(email) {
    const [rows] = await pool.execute(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );
    return rows[0] || null;
  }

  static async findById(id) {
    try {
      const [rows] = await pool.execute(
        'SELECT id, name, email, role, phone, google_id, google_email, created_at FROM users WHERE id = ?',
        [id]
      );
      const user = rows[0] || null;
      if (user) {
        console.log('User found by ID:', { id: user.id, email: user.email, hasGoogleId: !!user.google_id });
      }
      return user;
    } catch (error) {
      console.error('Error in findById:', error);
      throw error;
    }
  }

  static async findAll(filters = {}) {
    try {
      let query = 'SELECT id, name, email, role, phone, google_id, google_email, created_at FROM users WHERE 1=1';
      const params = [];

      if (filters.role) {
        query += ' AND role = ?';
        params.push(filters.role);
      }

      if (filters.search) {
        query += ' AND (name LIKE ? OR email LIKE ?)';
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
      return rows;
    } catch (error) {
      console.error('Error finding users:', error);
      throw error;
    }
  }

  static async updateRole(userId, role) {
    try {
      await pool.execute(
        'UPDATE users SET role = ? WHERE id = ?',
        [role, userId]
      );
    } catch (error) {
      console.error('Error updating user role:', error);
      throw error;
    }
  }

  static async findByGoogleId(googleId) {
    const [rows] = await pool.execute(
      'SELECT * FROM users WHERE google_id = ?',
      [googleId]
    );
    return rows[0] || null;
  }

  static async verifyPassword(plainPassword, hashedPassword) {
    if (!hashedPassword) return false;
    return await bcrypt.compare(plainPassword, hashedPassword);
  }

  static async updateGoogleInfo(userId, googleId, googleEmail) {
    await pool.execute(
      'UPDATE users SET google_id = ?, google_email = ? WHERE id = ?',
      [googleId, googleEmail, userId]
    );
  }

  static async updateProfile(userId, profileData) {
    const { phone } = profileData;
    const updates = [];
    const values = [];

    if (phone !== undefined) {
      updates.push('phone = ?');
      values.push(phone ? phone.trim() : null);
    }

    if (updates.length === 0) {
      return; // No updates to make
    }

    values.push(userId);

    await pool.execute(
      `UPDATE users SET ${updates.join(', ')} WHERE id = ?`,
      values
    );
  }
}

module.exports = User;

