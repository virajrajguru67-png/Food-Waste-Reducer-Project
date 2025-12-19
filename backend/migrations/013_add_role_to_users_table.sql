-- Add role column to users table
ALTER TABLE users 
ADD COLUMN role ENUM('user', 'admin', 'restaurant_owner') DEFAULT 'user' AFTER email;

-- Add index for role
CREATE INDEX idx_role ON users(role);

-- Update existing users to have 'user' role (if any exist)
UPDATE users SET role = 'user' WHERE role IS NULL;

