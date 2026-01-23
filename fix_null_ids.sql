-- Fix NULL IDs in product table
-- This script will fix the product table structure and update NULL IDs

-- First, create a backup of the product table
CREATE TABLE product_backup AS SELECT * FROM product;

-- Recreate product table with proper structure
CREATE TABLE product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) DEFAULT 0.00,
    category_id VARCHAR(50),
    image VARCHAR(255)
);

-- Insert data from backup, letting MySQL assign proper IDs
INSERT INTO product (name, description, price, category_id, image)
SELECT name, description, price, category_id, image FROM product_backup ORDER BY sid;

-- Drop the backup table
DROP TABLE product_backup;

-- Reset auto-increment if needed
ALTER TABLE product AUTO_INCREMENT = 1;
