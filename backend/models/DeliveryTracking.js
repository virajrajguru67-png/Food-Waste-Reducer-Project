const { pool } = require('../config/database');
const { v4: uuidv4 } = require('uuid');

class DeliveryTracking {
  static async create(trackingData) {
    const {
      orderId,
      status,
      estimatedDeliveryTime,
      deliveryPartnerId,
      externalApiTrackingId,
    } = trackingData;

    if (!orderId) {
      throw new Error('Order ID is required');
    }

    // Generate tracking number
    const trackingNumber = `TRK-${Date.now()}-${uuidv4().substring(0, 8).toUpperCase()}`;

    try {
      const [result] = await pool.execute(
        `INSERT INTO delivery_tracking (
          order_id, tracking_number, status, estimated_delivery_time,
          delivery_partner_id, external_api_tracking_id, status_history
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          orderId,
          trackingNumber,
          status || 'pending',
          estimatedDeliveryTime || null,
          deliveryPartnerId || null,
          externalApiTrackingId || null,
          JSON.stringify([{
            status: status || 'pending',
            timestamp: new Date().toISOString(),
          }]),
        ]
      );

      // Update order with delivery tracking ID
      await pool.execute(
        'UPDATE orders SET delivery_tracking_id = ? WHERE id = ?',
        [result.insertId, orderId]
      );

      return result.insertId;
    } catch (error) {
      console.error('Error creating delivery tracking:', error);
      throw error;
    }
  }

  static async findByOrderId(orderId) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM delivery_tracking WHERE order_id = ?',
        [orderId]
      );
      if (rows.length === 0) return null;
      return this._formatTracking(rows[0]);
    } catch (error) {
      console.error('Error finding delivery tracking:', error);
      throw error;
    }
  }

  static async findByTrackingNumber(trackingNumber) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM delivery_tracking WHERE tracking_number = ?',
        [trackingNumber]
      );
      if (rows.length === 0) return null;
      return this._formatTracking(rows[0]);
    } catch (error) {
      console.error('Error finding delivery tracking:', error);
      throw error;
    }
  }

  static async updateStatus(orderId, status, currentLocation = null, estimatedDeliveryTime = null) {
    try {
      const tracking = await this.findByOrderId(orderId);
      if (!tracking) {
        throw new Error('Delivery tracking not found');
      }

      const statusHistory = tracking.statusHistory || [];
      statusHistory.push({
        status: status,
        timestamp: new Date().toISOString(),
        location: currentLocation,
      });

      await pool.execute(
        `UPDATE delivery_tracking 
         SET status = ?, current_location = ?, estimated_delivery_time = ?, status_history = ?
         WHERE order_id = ?`,
        [
          status,
          currentLocation ? JSON.stringify(currentLocation) : null,
          estimatedDeliveryTime || null,
          JSON.stringify(statusHistory),
          orderId,
        ]
      );
    } catch (error) {
      console.error('Error updating delivery status:', error);
      throw error;
    }
  }

  static async updateFromExternal(orderId, externalData) {
    try {
      const tracking = await this.findByOrderId(orderId);
      if (!tracking) {
        throw new Error('Delivery tracking not found');
      }

      const statusHistory = tracking.statusHistory || [];
      statusHistory.push({
        status: externalData.status || tracking.status,
        timestamp: new Date().toISOString(),
        location: externalData.location,
        source: 'external_api',
      });

      await pool.execute(
        `UPDATE delivery_tracking 
         SET status = ?, current_location = ?, estimated_delivery_time = ?, status_history = ?
         WHERE order_id = ?`,
        [
          externalData.status || tracking.status,
          externalData.location ? JSON.stringify(externalData.location) : null,
          externalData.estimatedDeliveryTime || null,
          JSON.stringify(statusHistory),
          orderId,
        ]
      );
    } catch (error) {
      console.error('Error updating from external API:', error);
      throw error;
    }
  }

  static async findAll(filters = {}) {
    try {
      let query = 'SELECT * FROM delivery_tracking WHERE 1=1';
      const params = [];

      if (filters.status) {
        query += ' AND status = ?';
        params.push(filters.status);
      }

      query += ' ORDER BY created_at DESC';

      if (filters.limit) {
        query += ' LIMIT ?';
        params.push(filters.limit);
      }

      const [rows] = await pool.execute(query, params);
      return rows.map(row => this._formatTracking(row));
    } catch (error) {
      console.error('Error finding delivery tracking:', error);
      throw error;
    }
  }

  static _formatTracking(row) {
    return {
      id: row.id,
      orderId: row.order_id,
      trackingNumber: row.tracking_number,
      status: row.status,
      currentLocation: row.current_location ? JSON.parse(row.current_location) : null,
      estimatedDeliveryTime: row.estimated_delivery_time,
      deliveryPartnerId: row.delivery_partner_id,
      externalApiTrackingId: row.external_api_tracking_id,
      statusHistory: row.status_history ? JSON.parse(row.status_history) : [],
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}

module.exports = DeliveryTracking;

