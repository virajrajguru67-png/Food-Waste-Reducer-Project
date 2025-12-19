const { pool } = require('../config/database');
const { v4: uuidv4 } = require('uuid');

class Order {
  static async create(orderData) {
    const {
      userId,
      restaurantId,
      items,
      totalAmount,
      discountAmount,
      couponId,
      finalAmount,
      paymentMethod,
      address,
      notes,
    } = orderData;

    if (!userId || !restaurantId || !items || items.length === 0) {
      throw new Error('User ID, restaurant ID, and items are required');
    }

    // Generate unique order number
    const orderNumber = `ORD-${Date.now()}-${uuidv4().substring(0, 8).toUpperCase()}`;

    try {
      const connection = await pool.getConnection();
      await connection.beginTransaction();

      try {
        // Create order
        const [result] = await connection.execute(
          `INSERT INTO orders (
            user_id, restaurant_id, order_number, items,
            total_amount, discount_amount, coupon_id, final_amount,
            payment_method, address, notes
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            userId,
            restaurantId,
            orderNumber,
            JSON.stringify(items),
            totalAmount,
            discountAmount || 0,
            couponId || null,
            finalAmount,
            paymentMethod || null,
            address ? JSON.stringify(address) : null,
            notes || null,
          ]
        );

        const orderId = result.insertId;

        // Create order items
        for (const item of items) {
          await connection.execute(
            `INSERT INTO order_items (
              order_id, food_item_id, food_item_name, quantity, unit_price, total_price
            ) VALUES (?, ?, ?, ?, ?, ?)`,
            [
              orderId,
              item.foodItemId,
              item.foodItemName,
              item.quantity,
              item.unitPrice,
              item.totalPrice,
            ]
          );

          // Update food item quantity
          await connection.execute(
            'UPDATE food_items SET quantity_available = quantity_available - ? WHERE id = ?',
            [item.quantity, item.foodItemId]
          );
        }

        // Update coupon usage if applicable
        if (couponId) {
          await connection.execute(
            'UPDATE coupons SET used_count = used_count + 1 WHERE id = ?',
            [couponId]
          );
        }

        await connection.commit();
        return orderId;
      } catch (error) {
        await connection.rollback();
        throw error;
      } finally {
        connection.release();
      }
    } catch (error) {
      console.error('Error creating order:', error);
      throw error;
    }
  }

  static async findById(id) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM orders WHERE id = ?',
        [id]
      );
      if (rows.length === 0) return null;
      return await this._formatOrder(rows[0]);
    } catch (error) {
      console.error('Error finding order:', error);
      throw error;
    }
  }

  static async findByUserId(userId, filters = {}) {
    try {
      let query = 'SELECT * FROM orders WHERE user_id = ?';
      const params = [userId];

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
      return await Promise.all(rows.map(row => this._formatOrder(row)));
    } catch (error) {
      console.error('Error finding orders by user:', error);
      throw error;
    }
  }

  static async findByRestaurantId(restaurantId, filters = {}) {
    try {
      let query = 'SELECT * FROM orders WHERE restaurant_id = ?';
      const params = [restaurantId];

      if (filters.status) {
        query += ' AND status = ?';
        params.push(filters.status);
      }

      query += ' ORDER BY created_at DESC';

      const [rows] = await pool.execute(query, params);
      return await Promise.all(rows.map(row => this._formatOrder(row)));
    } catch (error) {
      console.error('Error finding orders by restaurant:', error);
      throw error;
    }
  }

  static async findAll(filters = {}) {
    try {
      let query = 'SELECT * FROM orders WHERE 1=1';
      const params = [];

      if (filters.userId) {
        query += ' AND user_id = ?';
        params.push(filters.userId);
      }

      if (filters.restaurantId) {
        query += ' AND restaurant_id = ?';
        params.push(filters.restaurantId);
      }

      if (filters.status) {
        query += ' AND status = ?';
        params.push(filters.status);
      }

      if (filters.paymentStatus) {
        query += ' AND payment_status = ?';
        params.push(filters.paymentStatus);
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
      return await Promise.all(rows.map(row => this._formatOrder(row)));
    } catch (error) {
      console.error('Error finding orders:', error);
      throw error;
    }
  }

  static async updateStatus(id, status) {
    try {
      await pool.execute(
        'UPDATE orders SET status = ? WHERE id = ?',
        [status, id]
      );
    } catch (error) {
      console.error('Error updating order status:', error);
      throw error;
    }
  }

  static async updatePaymentStatus(id, paymentStatus) {
    try {
      await pool.execute(
        'UPDATE orders SET payment_status = ? WHERE id = ?',
        [paymentStatus, id]
      );
    } catch (error) {
      console.error('Error updating payment status:', error);
      throw error;
    }
  }

  static async cancel(id, userId) {
    try {
      const connection = await pool.getConnection();
      await connection.beginTransaction();

      try {
        // Get order details
        const [orders] = await connection.execute(
          'SELECT * FROM orders WHERE id = ? AND user_id = ?',
          [id, userId]
        );

        if (orders.length === 0) {
          throw new Error('Order not found or unauthorized');
        }

        const order = orders[0];

        // Only allow cancellation if order is pending or confirmed
        if (!['pending', 'confirmed'].includes(order.status)) {
          throw new Error('Order cannot be cancelled at this stage');
        }

        // Restore food item quantities
        const [orderItems] = await connection.execute(
          'SELECT * FROM order_items WHERE order_id = ?',
          [id]
        );

        for (const item of orderItems) {
          await connection.execute(
            'UPDATE food_items SET quantity_available = quantity_available + ? WHERE id = ?',
            [item.quantity, item.food_item_id]
          );
        }

        // Update order status
        await connection.execute(
          'UPDATE orders SET status = ? WHERE id = ?',
          ['cancelled', id]
        );

        await connection.commit();
      } catch (error) {
        await connection.rollback();
        throw error;
      } finally {
        connection.release();
      }
    } catch (error) {
      console.error('Error cancelling order:', error);
      throw error;
    }
  }

  static async _formatOrder(row) {
    // Get order items
    const [orderItems] = await pool.execute(
      'SELECT * FROM order_items WHERE order_id = ?',
      [row.id]
    );

    // Get restaurant name
    const [restaurants] = await pool.execute(
      'SELECT name FROM restaurants WHERE id = ?',
      [row.restaurant_id]
    );

    return {
      id: row.id,
      userId: row.user_id,
      restaurantId: row.restaurant_id,
      restaurantName: restaurants.length > 0 ? restaurants[0].name : null,
      orderNumber: row.order_number,
      items: row.items ? JSON.parse(row.items) : orderItems.map(item => ({
        foodItemId: item.food_item_id,
        foodItemName: item.food_item_name,
        quantity: item.quantity,
        unitPrice: parseFloat(item.unit_price),
        totalPrice: parseFloat(item.total_price),
      })),
      totalAmount: parseFloat(row.total_amount),
      discountAmount: parseFloat(row.discount_amount),
      couponId: row.coupon_id,
      finalAmount: parseFloat(row.final_amount),
      status: row.status,
      paymentStatus: row.payment_status,
      paymentMethod: row.payment_method,
      pickupTime: row.pickup_time,
      address: row.address ? JSON.parse(row.address) : null,
      deliveryTrackingId: row.delivery_tracking_id,
      notes: row.notes,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}

module.exports = Order;

