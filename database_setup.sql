-- Database setup for Mini Shopping Cart
-- This script creates the cart table for storing user cart items

-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS mscart;

-- Use the database
USE mscart;

-- Create cart table
CREATE TABLE IF NOT EXISTS cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_product (user_id, product_id)
);

-- Create indexes for better performance
CREATE INDEX idx_user_id ON cart(user_id);
CREATE INDEX idx_created_at ON cart(created_at);

-- Display table structure
DESCRIBE cart;

-- Display existing cart data
SELECT * FROM cart;
