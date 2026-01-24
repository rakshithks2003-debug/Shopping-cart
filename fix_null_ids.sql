-- Fix NULL IDs in product table
-- This script will fix the product table structure and update NULL IDs

-- First, create a backup of the product table
CREATE TABLE product_backup AS SELECT * FROM product;

-- Drop the original table
DROP TABLE product;

-- Recreate product table with proper structure
CREATE TABLE product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) DEFAULT 0.00,
    category_id VARCHAR(50),
    image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert data from backup, letting MySQL assign proper IDs
INSERT INTO product (name, description, price, category_id, image, created_at)
SELECT name, description, price, category_id, image, created_at FROM product_backup ORDER BY sid;

-- Drop the backup table
DROP TABLE product_backup;

-- Reset auto-increment if needed
ALTER TABLE product AUTO_INCREMENT = 1;
