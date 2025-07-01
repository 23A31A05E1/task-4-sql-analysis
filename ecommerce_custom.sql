
-- Create Database
CREATE DATABASE ecommerce_custom;
USE ecommerce_custom;

-- Create Tables
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(10, 2),
    stock INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(20),
    payment_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Insert sample data
INSERT INTO categories (category_name) VALUES 
('Electronics'), ('Clothing'), ('Books');

INSERT INTO products (product_name, category_id, price, stock) VALUES 
('Smartphone', 1, 15000.00, 100),
('Laptop', 1, 50000.00, 50),
('T-Shirt', 2, 500.00, 200),
('Novel', 3, 300.00, 150),
('Headphones', 1, 1200.00, 80);

INSERT INTO customers (customer_name, email, city, signup_date) VALUES 
('Swapna G', 'swapna@example.com', 'Vijayawada', '2024-12-10'),
('Anjali R', 'anjali@example.com', 'Hyderabad', '2025-01-15'),
('Ravi K', 'ravi@example.com', 'Guntur', '2025-02-20');

INSERT INTO orders (customer_id, order_date, status) VALUES 
(1, '2025-03-01', 'Delivered'),
(2, '2025-03-02', 'Delivered'),
(1, '2025-03-05', 'Pending'),
(3, '2025-03-10', 'Delivered');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES 
(1, 1, 1, 15000.00),
(1, 5, 2, 1200.00),
(2, 2, 1, 50000.00),
(3, 3, 3, 500.00),
(4, 4, 2, 300.00);

INSERT INTO payments (order_id, payment_method, payment_date, amount) VALUES 
(1, 'Credit Card', '2025-03-01', 17400.00),
(2, 'UPI', '2025-03-02', 50000.00),
(4, 'Cash', '2025-03-10', 600.00);
SELECT COUNT(*) AS total_customers
FROM customers;
SELECT SUM(amount) AS total_revenue
FROM payments;
SELECT 
    p.product_name, 
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 3;
SELECT 
    c.category_name, 
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY revenue DESC;
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month, 
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;
SELECT 
    cu.customer_name, 
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers cu
JOIN orders o ON cu.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY cu.customer_name
ORDER BY total_spent DESC;
SELECT *
FROM products
WHERE stock = 0;
SELECT 
    o.order_id, 
    o.order_date, 
    p.payment_date,
    DATEDIFF(p.payment_date, o.order_date) AS days_delay
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE DATEDIFF(p.payment_date, o.order_date) > 0;
CREATE OR REPLACE VIEW product_sales_summary AS
SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name;
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);
SELECT DISTINCT c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.unit_price > (
    SELECT AVG(price) FROM products
);
