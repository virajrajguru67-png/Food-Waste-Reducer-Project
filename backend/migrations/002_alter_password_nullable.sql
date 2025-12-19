-- Make password column nullable for Google Sign-In users
ALTER TABLE users MODIFY COLUMN password VARCHAR(255) NULL;

