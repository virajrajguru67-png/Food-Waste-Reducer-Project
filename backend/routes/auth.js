const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Note: JWT_SECRET should be loaded by server.js before this module is required
// This is just a runtime check
if (!process.env.JWT_SECRET || process.env.JWT_SECRET.trim() === '' || process.env.JWT_SECRET === 'your_super_secret_jwt_key_change_this_in_production') {
  console.error('⚠️  WARNING: JWT_SECRET is not set or using default value!');
  console.error('⚠️  Please ensure dotenv is loaded in server.js before requiring this route');
  console.error('⚠️  Current JWT_SECRET value:', process.env.JWT_SECRET || 'undefined');
}

// Generate JWT token
const generateToken = (userId, email) => {
  // Get JWT_SECRET from environment
  const secret = process.env.JWT_SECRET;
  
  // Explicit validation with detailed logging
  console.log('\n[generateToken] Checking JWT_SECRET...');
  console.log('[generateToken] process.env.JWT_SECRET exists:', !!secret);
  console.log('[generateToken] process.env.JWT_SECRET type:', typeof secret);
  console.log('[generateToken] process.env.JWT_SECRET length:', secret ? secret.length : 0);
  
  if (!secret) {
    console.error('[generateToken] ❌ ERROR: process.env.JWT_SECRET is undefined!');
    console.error('[generateToken] This means dotenv did not load the .env file properly.');
    throw new Error('JWT_SECRET is undefined. Ensure dotenv.config() is called in server.js before requiring this module.');
  }
  
  if (typeof secret !== 'string') {
    console.error('[generateToken] ❌ ERROR: JWT_SECRET is not a string!');
    throw new Error('JWT_SECRET must be a string value.');
  }
  
  const trimmedSecret = secret.trim();
  if (trimmedSecret === '' || trimmedSecret === 'your_super_secret_jwt_key_change_this_in_production') {
    console.error('[generateToken] ❌ ERROR: JWT_SECRET is empty or using default value!');
    throw new Error('JWT_SECRET is not properly configured in .env file.');
  }
  
  console.log('[generateToken] ✅ JWT_SECRET is valid, generating token...');
  
  try {
    const token = jwt.sign(
      { userId, email },
      trimmedSecret,
      { expiresIn: '7d' }
    );
    console.log('[generateToken] ✅ Token generated successfully');
    return token;
  } catch (error) {
    console.error('[generateToken] ❌ JWT sign error:', error.message);
    console.error('[generateToken] Error details:', error);
    throw new Error(`Failed to generate token: ${error.message}`);
  }
};

// Register endpoint
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, phone } = req.body;

    // Validation
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Name, email, and password are required'
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters'
      });
    }

    // Check if user already exists
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User with this email already exists'
      });
    }

    // Create user
    const userId = await User.create({
      name,
      email,
      password,
      phone
    });

    // Generate token
    const token = generateToken(userId, email);

    // Get user data (without password)
    const user = await User.findById(userId);
    
    if (!user) {
      throw new Error('Failed to retrieve created user');
    }

    res.status(201).json({
      success: true,
      message: 'Registration successful',
      data: {
        user,
        token
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      message: 'Registration failed',
      error: error.message
    });
  }
});

// Login endpoint
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required'
      });
    }

    // Find user
    const user = await User.findByEmail(email);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Check if user has a password (not a Google-only user)
    if (!user.password) {
      return res.status(401).json({
        success: false,
        message: 'This account was created with Google Sign-In. Please use Google Sign-In to login.'
      });
    }

    // Verify password
    const isValidPassword = await User.verifyPassword(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Generate token
    const token = generateToken(user.id, user.email);

    // Remove password from response safely
    const userResponse = {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      google_id: user.google_id,
      google_email: user.google_email,
      created_at: user.created_at
    };

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: userResponse,
        token
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Login failed',
      error: error.message
    });
  }
});

// Google Sign-In endpoint
router.post('/google', async (req, res) => {
  try {
    const { googleId, email, name, photoUrl } = req.body;

    console.log('Google Sign-In request received');
    console.log('Request body:', JSON.stringify({ googleId, email, name, photoUrl }));

    if (!googleId || !email) {
      return res.status(400).json({
        success: false,
        message: 'Google ID and email are required'
      });
    }

    // Ensure name is a valid string (required field)
    const userName = (name && name.trim()) ? name.trim() : email.split('@')[0];

    // Check if user exists with Google ID
    let user = await User.findByGoogleId(googleId);

    if (!user) {
      // Check if user exists with email
      user = await User.findByEmail(email);
      
      if (user) {
        // Update existing user with Google info
        await User.updateGoogleInfo(user.id, googleId, email);
        user = await User.findById(user.id);
      } else {
        // Create new user
        console.log('Creating new user with:', { name: userName, email, googleId });
        const userId = await User.create({
          name: userName,
          email,
          password: null, // No password for Google users
          phone: null,
          googleId,
          googleEmail: email
        });
        user = await User.findById(userId);
        console.log('User created with ID:', userId);
      }
    } else {
      console.log('User found with Google ID:', user.id);
    }

    // Verify user was created/found
    if (!user || !user.id) {
      console.error('User object:', user);
      throw new Error('Failed to create or retrieve user');
    }

    console.log('User retrieved:', { id: user.id, email: user.email, name: user.name });

    // Generate token
    const token = generateToken(user.id, user.email);

    // Remove password from response safely
    const userResponse = {
      id: user.id,
      name: user.name || email.split('@')[0],
      email: user.email,
      phone: user.phone || null,
      google_id: user.google_id || null,
      google_email: user.google_email || null,
      created_at: user.created_at || new Date().toISOString()
    };

    console.log('Sending response:', { success: true, userId: userResponse.id });

    res.json({
      success: true,
      message: 'Google Sign-In successful',
      data: {
        user: userResponse,
        token
      }
    });
  } catch (error) {
    console.error('Google Sign-In error:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Google Sign-In failed',
      error: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
});

// Update user profile endpoint
router.put('/profile', async (req, res) => {
  try {
    const { userId, phone } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    // Update user phone
    await User.updateProfile(userId, { phone });

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userResponse = {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      google_id: user.google_id,
      google_email: user.google_email,
      created_at: user.created_at
    };

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: { user: userResponse }
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update profile',
      error: error.message
    });
  }
});

// Get current user endpoint
router.get('/me', async (req, res) => {
  try {
    // This would typically use authentication middleware
    // For now, we'll get user ID from query or body
    const userId = req.query.userId || req.body.userId;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      data: { user }
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user',
      error: error.message
    });
  }
});

module.exports = router;

