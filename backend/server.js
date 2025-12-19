// ============================================
// STEP 1: Load environment variables FIRST
// ============================================
require('dotenv').config();

// ============================================
// STEP 2: Verify JWT_SECRET is loaded
// ============================================
console.log('\n========================================');
console.log('🔍 ENVIRONMENT VARIABLES CHECK');
console.log('========================================');
console.log('JWT_SECRET LOADED:', process.env.JWT_SECRET ? 'YES' : 'NO');
if (process.env.JWT_SECRET) {
  console.log('JWT_SECRET length:', process.env.JWT_SECRET.length);
  console.log('JWT_SECRET preview:', process.env.JWT_SECRET.substring(0, 20) + '...');
} else {
  console.error('❌ JWT_SECRET is UNDEFINED!');
  console.error('❌ Check your .env file in:', __dirname);
  console.error('❌ Make sure JWT_SECRET is set in .env');
  process.exit(1);
}

if (process.env.JWT_SECRET.trim() === '' || process.env.JWT_SECRET === 'your_super_secret_jwt_key_change_this_in_production') {
  console.error('❌ ERROR: JWT_SECRET is empty or using default value!');
  console.error('❌ Please set a valid JWT_SECRET in your .env file');
  process.exit(1);
}

console.log('✅ JWT_SECRET is properly configured');
console.log('========================================\n');

// Now import other modules (they will have access to process.env)
const express = require('express');
const cors = require('cors');
const { testConnection } = require('./config/database');
const authRoutes = require('./routes/auth');
const restaurantRoutes = require('./routes/restaurants');
const foodItemRoutes = require('./routes/foodItems');
const orderRoutes = require('./routes/orders');
const couponRoutes = require('./routes/coupons');
const reviewRoutes = require('./routes/reviews');
const deliveryRoutes = require('./routes/delivery');
const adminRoutes = require('./routes/admin');
const analyticsRoutes = require('./routes/analytics');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    success: true, 
    message: 'Server is running',
    timestamp: new Date().toISOString()
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/restaurants', restaurantRoutes);
app.use('/api/food-items', foodItemRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/coupons', couponRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/delivery', deliveryRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/addresses', require('./routes/addresses'));
app.use('/api/notifications', require('./routes/notifications'));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Start server
async function startServer() {
  // Test database connection
  const dbConnected = await testConnection();
  
  if (!dbConnected) {
    console.log('⚠️  Starting server without database connection...');
    console.log('⚠️  Please ensure MySQL is running and database is configured');
  }

  app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
    console.log(`📡 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`🌐 CORS enabled for: ${process.env.CORS_ORIGIN || 'http://localhost:3000'}`);
  });
}

startServer();

