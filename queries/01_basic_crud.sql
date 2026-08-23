USE retail_management;

-- =========================================================
-- 01. BASIC SELECT QUERIES
-- =========================================================

-- View all customers
SELECT *
FROM Customer;

-- View selected customer columns
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    status
FROM Customer;

-- View all products
SELECT *
FROM Product;

-- View important product information
SELECT
    product_id,
    name,
    base_price,
    status
FROM Product;

-- View product variants
SELECT
    variant_id,
    product_id,
    sku,
    color,
    size,
    price,
    is_active
FROM ProductVariant;


-- =========================================================
-- 02. COLUMN ALIASES
-- =========================================================

SELECT
    customer_id AS customer_number,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    email AS customer_email,
    status AS account_status
FROM Customer;

SELECT
    product_id,
    name AS product_name,
    base_price AS starting_price
FROM Product;


-- =========================================================
-- 03. WHERE FILTERING
-- =========================================================

START TRANSACTION;

-- Active customers
SELECT *
FROM Customer
WHERE status = 'ACTIVE';

-- Active products
SELECT *
FROM Product
WHERE status = 'ACTIVE';

-- Products costing more than PKR 100,000
SELECT
    product_id,
    name,
    base_price
FROM Product
WHERE base_price > 100000;

-- Products costing less than PKR 50,000
SELECT
    product_id,
    name,
    base_price
FROM Product
WHERE base_price < 50000;

-- Variants that are currently active
SELECT *
FROM ProductVariant
WHERE is_active = TRUE;


-- =========================================================
-- 04. MULTIPLE CONDITIONS
-- =========================================================

-- Active products above PKR 100,000
SELECT
    product_id,
    name,
    base_price,
    status
FROM Product
WHERE status = 'ACTIVE'
  AND base_price > 100000;

-- Inventory with low stock
SELECT
    inventory_id,
    variant_id,
    warehouse_id,
    quantity_on_hand,
    reorder_level
FROM Inventory
WHERE quantity_on_hand <= reorder_level;

-- Orders that are either shipped or delivered
SELECT
    order_id,
    order_number,
    status,
    total_amount
FROM SalesOrder
WHERE status = 'SHIPPED'
   OR status = 'DELIVERED';

ROLLBACK;

-- =========================================================
-- 05. ORDER BY
-- =========================================================

-- Most expensive products first
SELECT
    product_id,
    name,
    base_price
FROM Product
ORDER BY base_price DESC;

-- Cheapest products first
SELECT
    product_id,
    name,
    base_price
FROM Product
ORDER BY base_price ASC;

-- Newest customer accounts first
SELECT
    customer_id,
    first_name,
    last_name,
    created_at
FROM Customer
ORDER BY created_at DESC;

-- Orders sorted newest first
SELECT
    order_number,
    order_date,
    total_amount
FROM SalesOrder
ORDER BY order_date DESC;


-- =========================================================
-- 06. DISTINCT
-- =========================================================

-- Unique customer statuses
SELECT DISTINCT status
FROM Customer;

-- Unique product colors
SELECT DISTINCT color
FROM ProductVariant
WHERE color IS NOT NULL;

-- Unique cities used by customers
SELECT DISTINCT city
FROM Address;

-- Unique shipment carriers
SELECT DISTINCT carrier
FROM Shipment
WHERE carrier IS NOT NULL;


-- =========================================================
-- 07. LIKE SEARCHING
-- =========================================================

-- Product names containing 'Watch'
SELECT
    product_id,
    name
FROM Product
WHERE name LIKE '%Watch%';

-- Customers whose first name starts with A
SELECT
    customer_id,
    first_name,
    last_name
FROM Customer
WHERE first_name LIKE 'A%';

-- Customers whose email belongs to example.com
SELECT
    customer_id,
    email
FROM Customer
WHERE email LIKE '%@example.com';

-- SKU search
SELECT
    variant_id,
    sku,
    price
FROM ProductVariant
WHERE sku LIKE 'APL%';


-- =========================================================
-- 08. BETWEEN
-- =========================================================

-- Products priced between PKR 25,000 and PKR 150,000
SELECT
    product_id,
    name,
    base_price
FROM Product
WHERE base_price BETWEEN 25000 AND 150000
ORDER BY base_price;

-- Orders within a date period
SELECT
    order_id,
    order_number,
    order_date,
    total_amount
FROM SalesOrder
WHERE order_date BETWEEN
      '2026-08-01 00:00:00'
      AND
      '2026-08-10 23:59:59'
ORDER BY order_date;

-- Reviews with ratings between 4 and 5
SELECT
    review_id,
    product_id,
    rating,
    title
FROM ProductReview
WHERE rating BETWEEN 4 AND 5;


-- =========================================================
-- 09. IN / NOT IN
-- =========================================================

-- Orders in selected statuses
SELECT
    order_number,
    status,
    total_amount
FROM SalesOrder
WHERE status IN (
    'CONFIRMED',
    'PROCESSING',
    'SHIPPED'
);

-- Products that are not discontinued
SELECT
    product_id,
    name,
    status
FROM Product
WHERE status NOT IN (
    'DISCONTINUED'
);

-- Stock movements representing stock increases
SELECT *
FROM StockMovement
WHERE movement_type IN (
    'PURCHASE',
    'RETURN',
    'TRANSFER_IN'
);


-- =========================================================
-- 10. NULL / IS NOT NULL
-- =========================================================

-- Payments without a completed payment date
SELECT
    payment_id,
    order_id,
    status,
    payment_date
FROM Payment
WHERE payment_date IS NULL;

-- Shipments not yet delivered
SELECT
    shipment_id,
    tracking_number,
    status
FROM Shipment
WHERE delivered_at IS NULL;

-- Variants without a defined size
SELECT
    variant_id,
    sku,
    color
FROM ProductVariant
WHERE size IS NULL;


-- =========================================================
-- 11. LIMIT
-- =========================================================

-- Top 5 most expensive products
SELECT
    product_id,
    name,
    base_price
FROM Product
ORDER BY base_price DESC
LIMIT 5;

-- Latest 5 orders
SELECT
    order_id,
    order_number,
    order_date
FROM SalesOrder
ORDER BY order_date DESC
LIMIT 5;

-- Latest 3 reviews
SELECT
    review_id,
    product_id,
    rating,
    created_at
FROM ProductReview
ORDER BY created_at DESC
LIMIT 3;


-- =========================================================
-- 12. PAGINATION
-- =========================================================

-- First page: 5 products
SELECT
    product_id,
    name,
    base_price
FROM Product
ORDER BY product_id
LIMIT 5 OFFSET 0;

-- Second page: next 5 products
SELECT
    product_id,
    name,
    base_price
FROM Product
ORDER BY product_id
LIMIT 5 OFFSET 5;


-- =========================================================
-- 13. INSERT EXAMPLES
-- =========================================================

START TRANSACTION;

-- Add a new customer
INSERT INTO Customer (
    first_name,
    last_name,
    email,
    phone,
    password_hash,
    date_of_birth,
    status
)
VALUES (
    'Test',
    'Customer',
    'test.customer@example.com',
    '+92-300-9999999',
    '$2y$10$demopasswordhash',
    '2002-01-10',
    'ACTIVE'
);

-- Add a temporary category
INSERT INTO Category (
    name,
    slug,
    description,
    is_active
)
VALUES (
    'Demo Category',
    'demo-category',
    'Temporary category used for CRUD demonstration.',
    TRUE
);


-- =========================================================
-- 14. UPDATE EXAMPLES
-- =========================================================

-- Update the test customer's phone number
UPDATE Customer
SET phone = '+92-311-8888888'
WHERE email = 'test.customer@example.com';

-- Disable the demo category
UPDATE Category
SET is_active = FALSE
WHERE slug = 'demo-category';

-- Change the status of one order
UPDATE SalesOrder
SET status = 'PROCESSING'
WHERE order_number = 'ORD-2026-0006';


-- =========================================================
-- 15. DELETE EXAMPLES
-- =========================================================

-- Delete the temporary category
DELETE FROM Category
WHERE slug = 'demo-category';

-- Delete the temporary customer
DELETE FROM Customer
WHERE email = 'test.customer@example.com';

ROLLBACK;

-- =========================================================
-- 16. USEFUL RETAIL CRUD QUERIES
-- =========================================================

-- View active promotions
SELECT
    promotion_id,
    name,
    discount_type,
    discount_value,
    start_date,
    end_date
FROM Promotion
WHERE is_active = TRUE
  AND NOW() BETWEEN start_date AND end_date;

-- View active coupons
SELECT
    coupon_id,
    code,
    discount_type,
    discount_value,
    usage_limit,
    usage_count
FROM Coupon
WHERE is_active = TRUE
  AND NOW() BETWEEN start_date AND expiry_date;

-- Find products requiring restocking
SELECT
    inventory_id,
    variant_id,
    warehouse_id,
    quantity_on_hand,
    reorder_level
FROM Inventory
WHERE quantity_on_hand <= reorder_level
ORDER BY quantity_on_hand ASC;

-- View pending payments
SELECT
    payment_id,
    order_id,
    amount,
    status
FROM Payment
WHERE status = 'PENDING';

-- View orders awaiting completion
SELECT
    order_id,
    order_number,
    customer_id,
    status,
    total_amount
FROM SalesOrder
WHERE status IN (
    'PENDING',
    'CONFIRMED',
    'PROCESSING'
)
ORDER BY order_date ASC;

-- View pending return requests
SELECT
    return_id,
    return_number,
    order_id,
    reason,
    status,
    requested_at
FROM ProductReturn
WHERE status IN (
    'REQUESTED',
    'APPROVED'
);

-- View active employees
SELECT
    employee_id,
    first_name,
    last_name,
    email,
    role_id
FROM Employee
WHERE status = 'ACTIVE';