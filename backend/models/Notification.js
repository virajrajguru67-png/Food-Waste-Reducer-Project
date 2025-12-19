const { pool } = require('../config/database');

class Notification {
  static async create(notificationData) {
    const {
      userId,
      type,
      title,
      message,
      data,
    } = notificationData;

    if (!userId || !type || !title || !message) {
      throw new Error('User ID, type, title, and message are required');
    }

    try {
      const [result] = await pool.execute(
        `INSERT INTO notifications (
          user_id, type, title, message, data
        ) VALUES (?, ?, ?, ?, ?)`,
        [
          userId,
          type,
          title.trim(),
          message.trim(),
          data ? JSON.stringify(data) : null,
        ]
      );

      return result.insertId;
    } catch (error) {
      console.error('Error creating notification:', error);
      throw error;
    }
  }

  static async findById(id) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM notifications WHERE id = ?',
        [id]
      );
      if (rows.length === 0) return null;
      return this._formatNotification(rows[0]);
    } catch (error) {
      console.error('Error finding notification:', error);
      throw error;
    }
  }

  static async findByUserId(userId, filters = {}) {
    try {
      let query = 'SELECT * FROM notifications WHERE user_id = ?';
      const params = [userId];

      if (filters.read !== undefined) {
        query += ' AND `read` = ?';
        params.push(filters.read ? 1 : 0);
      }

      if (filters.type) {
        query += ' AND type = ?';
        params.push(filters.type);
      }

      query += ' ORDER BY created_at DESC';

      if (filters.limit) {
        query += ' LIMIT ?';
        params.push(filters.limit);
      }

      const [rows] = await pool.execute(query, params);
      return rows.map(row => this._formatNotification(row));
    } catch (error) {
      console.error('Error finding notifications:', error);
      throw error;
    }
  }

  static async markAsRead(id) {
    try {
      await pool.execute(
        'UPDATE notifications SET `read` = TRUE WHERE id = ?',
        [id]
      );
    } catch (error) {
      console.error('Error marking notification as read:', error);
      throw error;
    }
  }

  static async markAllAsRead(userId) {
    try {
      await pool.execute(
        'UPDATE notifications SET `read` = TRUE WHERE user_id = ? AND `read` = FALSE',
        [userId]
      );
    } catch (error) {
      console.error('Error marking all notifications as read:', error);
      throw error;
    }
  }

  static async getUnreadCount(userId) {
    try {
      const [rows] = await pool.execute(
        'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND `read` = FALSE',
        [userId]
      );
      return rows[0].count || 0;
    } catch (error) {
      console.error('Error getting unread count:', error);
      throw error;
    }
  }

  static async delete(id) {
    try {
      await pool.execute('DELETE FROM notifications WHERE id = ?', [id]);
    } catch (error) {
      console.error('Error deleting notification:', error);
      throw error;
    }
  }

  static async deleteAll(userId) {
    try {
      await pool.execute('DELETE FROM notifications WHERE user_id = ?', [userId]);
    } catch (error) {
      console.error('Error deleting all notifications:', error);
      throw error;
    }
  }

  static _formatNotification(row) {
    return {
      id: row.id,
      userId: row.user_id,
      type: row.type,
      title: row.title,
      message: row.message,
      data: row.data ? JSON.parse(row.data) : null,
      read: row.read === 1,
      createdAt: row.created_at,
    };
  }
}

module.exports = Notification;

