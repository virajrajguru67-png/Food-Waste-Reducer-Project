const { pool } = require('../config/database');

class Analytics {
  static async create(eventData) {
    const {
      eventType,
      userId,
      restaurantId,
      orderId,
      data,
    } = eventData;

    if (!eventType) {
      throw new Error('Event type is required');
    }

    try {
      const [result] = await pool.execute(
        `INSERT INTO analytics (
          event_type, user_id, restaurant_id, order_id, data
        ) VALUES (?, ?, ?, ?, ?)`,
        [
          eventType,
          userId || null,
          restaurantId || null,
          orderId || null,
          data ? JSON.stringify(data) : null,
        ]
      );

      return result.insertId;
    } catch (error) {
      console.error('Error creating analytics event:', error);
      throw error;
    }
  }

  static async getDashboardStats(dateFrom = null, dateTo = null) {
    try {
      let dateFilter = '';
      const params = [];

      if (dateFrom && dateTo) {
        dateFilter = 'WHERE created_at BETWEEN ? AND ?';
        params.push(dateFrom, dateTo);
      } else if (dateFrom) {
        dateFilter = 'WHERE created_at >= ?';
        params.push(dateFrom);
      } else if (dateTo) {
        dateFilter = 'WHERE created_at <= ?';
        params.push(dateTo);
      }

      // Total users
      const [userCount] = await pool.execute(
        `SELECT COUNT(*) as count FROM users ${dateFilter}`,
        params
      );

      // Total restaurants
      const [restaurantCount] = await pool.execute(
        `SELECT COUNT(*) as count FROM restaurants ${dateFilter}`,
        params
      );

      // Total orders
      const [orderCount] = await pool.execute(
        `SELECT COUNT(*) as count FROM orders ${dateFilter}`,
        params
      );

      // Total revenue
      const [revenue] = await pool.execute(
        `SELECT SUM(final_amount) as total FROM orders ${dateFilter} AND payment_status = 'paid'`,
        params
      );

      // Orders by status
      const [ordersByStatus] = await pool.execute(
        `SELECT status, COUNT(*) as count FROM orders ${dateFilter} GROUP BY status`,
        params
      );

      // Recent orders
      const [recentOrders] = await pool.execute(
        `SELECT * FROM orders ${dateFilter} ORDER BY created_at DESC LIMIT 10`,
        params
      );

      // Top restaurants by orders
      const [topRestaurants] = await pool.execute(
        `SELECT r.id, r.name, COUNT(o.id) as order_count, SUM(o.final_amount) as revenue
         FROM restaurants r
         LEFT JOIN orders o ON r.id = o.restaurant_id
         ${dateFilter ? 'WHERE o.created_at BETWEEN ? AND ?' : ''}
         GROUP BY r.id, r.name
         ORDER BY order_count DESC
         LIMIT 10`,
        params
      );

      return {
        totalUsers: userCount[0].count || 0,
        totalRestaurants: restaurantCount[0].count || 0,
        totalOrders: orderCount[0].count || 0,
        totalRevenue: parseFloat(revenue[0].total) || 0,
        ordersByStatus: ordersByStatus.reduce((acc, row) => {
          acc[row.status] = row.count;
          return acc;
        }, {}),
        recentOrders: recentOrders,
        topRestaurants: topRestaurants,
      };
    } catch (error) {
      console.error('Error getting dashboard stats:', error);
      throw error;
    }
  }

  static async getRevenueChart(dateFrom, dateTo, groupBy = 'day') {
    try {
      let dateFormat = '%Y-%m-%d';
      if (groupBy === 'month') {
        dateFormat = '%Y-%m';
      } else if (groupBy === 'year') {
        dateFormat = '%Y';
      }

      const [rows] = await pool.execute(
        `SELECT 
          DATE_FORMAT(created_at, ?) as date,
          SUM(final_amount) as revenue,
          COUNT(*) as order_count
         FROM orders
         WHERE created_at BETWEEN ? AND ? AND payment_status = 'paid'
         GROUP BY DATE_FORMAT(created_at, ?)
         ORDER BY date ASC`,
        [dateFormat, dateFrom, dateTo, dateFormat]
      );

      return rows.map(row => ({
        date: row.date,
        revenue: parseFloat(row.revenue) || 0,
        orderCount: row.order_count,
      }));
    } catch (error) {
      console.error('Error getting revenue chart:', error);
      throw error;
    }
  }

  static async getUserGrowthChart(dateFrom, dateTo, groupBy = 'day') {
    try {
      let dateFormat = '%Y-%m-%d';
      if (groupBy === 'month') {
        dateFormat = '%Y-%m';
      } else if (groupBy === 'year') {
        dateFormat = '%Y';
      }

      const [rows] = await pool.execute(
        `SELECT 
          DATE_FORMAT(created_at, ?) as date,
          COUNT(*) as user_count
         FROM users
         WHERE created_at BETWEEN ? AND ?
         GROUP BY DATE_FORMAT(created_at, ?)
         ORDER BY date ASC`,
        [dateFormat, dateFrom, dateTo, dateFormat]
      );

      return rows.map(row => ({
        date: row.date,
        userCount: row.user_count,
      }));
    } catch (error) {
      console.error('Error getting user growth chart:', error);
      throw error;
    }
  }

  static async getEventCounts(eventType, dateFrom = null, dateTo = null) {
    try {
      let query = 'SELECT COUNT(*) as count FROM analytics WHERE event_type = ?';
      const params = [eventType];

      if (dateFrom && dateTo) {
        query += ' AND created_at BETWEEN ? AND ?';
        params.push(dateFrom, dateTo);
      }

      const [rows] = await pool.execute(query, params);
      return rows[0].count || 0;
    } catch (error) {
      console.error('Error getting event counts:', error);
      throw error;
    }
  }
}

module.exports = Analytics;

