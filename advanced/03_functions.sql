USE retail_management;

-- =========================================================
-- 03. STORED FUNCTIONS
-- Retail & E-Commerce Management Database
-- =========================================================


-- =========================================================
-- 01. AVAILABLE INVENTORY
-- Purpose:
-- Return available stock after reservations
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_available_stock (
    p_inventory_id BIGINT UNSIGNED
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_available INT;

    SELECT
        quantity_on_hand - quantity_reserved
    INTO v_available
    FROM Inventory
    WHERE inventory_id = p_inventory_id;

    RETURN COALESCE(v_available, 0);
END $$

DELIMITER ;


-- =========================================================
-- 02. ORDER ITEM LINE TOTAL
-- Purpose:
-- Calculate quantity × price - discount + tax
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_calculate_line_total (
    p_quantity INT,
    p_unit_price DECIMAL(12,2),
    p_discount_amount DECIMAL(12,2),
    p_tax_amount DECIMAL(12,2)
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
BEGIN
    RETURN
        (p_quantity * p_unit_price)
        - p_discount_amount
        + p_tax_amount;
END $$

DELIMITER ;


-- =========================================================
-- 03. PERCENTAGE DISCOUNT AMOUNT
-- Purpose:
-- Calculate discount amount from a percentage
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_percentage_discount (
    p_amount DECIMAL(12,2),
    p_percentage DECIMAL(5,2)
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN ROUND(
        p_amount * p_percentage / 100,
        2
    );
END $$

DELIMITER ;


-- =========================================================
-- 04. FIXED / PERCENTAGE DISCOUNT CALCULATOR
-- Purpose:
-- Handle both discount types
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_calculate_discount (
    p_amount DECIMAL(12,2),
    p_discount_type VARCHAR(30),
    p_discount_value DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_discount DECIMAL(12,2);

    IF p_discount_type = 'PERCENTAGE' THEN

        SET v_discount =
            p_amount * p_discount_value / 100;

    ELSEIF p_discount_type = 'FIXED_AMOUNT' THEN

        SET v_discount = p_discount_value;

    ELSE

        SET v_discount = 0;

    END IF;

    IF v_discount > p_amount THEN
        SET v_discount = p_amount;
    END IF;

    RETURN ROUND(v_discount, 2);
END $$

DELIMITER ;


-- =========================================================
-- 05. GROSS PROFIT
-- Purpose:
-- Revenue minus product cost
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_gross_profit (
    p_quantity INT,
    p_selling_price DECIMAL(12,2),
    p_cost_price DECIMAL(12,2)
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
BEGIN
    RETURN
        p_quantity *
        (p_selling_price - p_cost_price);
END $$

DELIMITER ;


-- =========================================================
-- 06. GROSS MARGIN PERCENTAGE
-- Purpose:
-- Return gross margin percentage
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_gross_margin_percentage (
    p_revenue DECIMAL(14,2),
    p_cost DECIMAL(14,2)
)
RETURNS DECIMAL(7,2)
DETERMINISTIC
BEGIN
    IF p_revenue = 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND(
        ((p_revenue - p_cost) / p_revenue) * 100,
        2
    );
END $$

DELIMITER ;


-- =========================================================
-- 07. CUSTOMER TOTAL SPENDING
-- Purpose:
-- Return lifetime spending for one customer
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_customer_total_spending (
    p_customer_id BIGINT UNSIGNED
)
RETURNS DECIMAL(14,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(14,2);

    SELECT
        COALESCE(SUM(total_amount), 0)
    INTO v_total
    FROM SalesOrder
    WHERE customer_id = p_customer_id
      AND status <> 'CANCELLED';

    RETURN v_total;
END $$

DELIMITER ;


-- =========================================================
-- 08. CUSTOMER ORDER COUNT
-- Purpose:
-- Return number of orders for a customer
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_customer_order_count (
    p_customer_id BIGINT UNSIGNED
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;

    SELECT
        COUNT(*)
    INTO v_count
    FROM SalesOrder
    WHERE customer_id = p_customer_id;

    RETURN v_count;
END $$

DELIMITER ;


-- =========================================================
-- 09. ORDER ITEM COUNT
-- Purpose:
-- Return number of order lines in an order
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_order_item_count (
    p_order_id BIGINT UNSIGNED
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;

    SELECT
        COUNT(*)
    INTO v_count
    FROM OrderItem
    WHERE order_id = p_order_id;

    RETURN v_count;
END $$

DELIMITER ;


-- =========================================================
-- 10. ORDER TOTAL QUANTITY
-- Purpose:
-- Return total units contained in an order
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_order_total_quantity (
    p_order_id BIGINT UNSIGNED
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_quantity INT;

    SELECT
        COALESCE(SUM(quantity), 0)
    INTO v_quantity
    FROM OrderItem
    WHERE order_id = p_order_id;

    RETURN v_quantity;
END $$

DELIMITER ;


-- =========================================================
-- 11. PRODUCT AVERAGE RATING
-- Purpose:
-- Return published average rating for one product
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_product_average_rating (
    p_product_id BIGINT UNSIGNED
)
RETURNS DECIMAL(3,2)
READS SQL DATA
BEGIN
    DECLARE v_rating DECIMAL(3,2);

    SELECT
        ROUND(AVG(rating), 2)
    INTO v_rating
    FROM ProductReview
    WHERE product_id = p_product_id
      AND status = 'PUBLISHED';

    RETURN COALESCE(v_rating, 0);
END $$

DELIMITER ;


-- =========================================================
-- 12. PRODUCT REVIEW COUNT
-- Purpose:
-- Return number of published reviews
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_product_review_count (
    p_product_id BIGINT UNSIGNED
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;

    SELECT
        COUNT(*)
    INTO v_count
    FROM ProductReview
    WHERE product_id = p_product_id
      AND status = 'PUBLISHED';

    RETURN v_count;
END $$

DELIMITER ;


-- =========================================================
-- 13. DAYS BETWEEN ORDER AND DELIVERY
-- Purpose:
-- Calculate delivery time in days
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_delivery_days (
    p_shipped_at DATETIME,
    p_delivered_at DATETIME
)
RETURNS INT
DETERMINISTIC
BEGIN
    IF p_shipped_at IS NULL
       OR p_delivered_at IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN TIMESTAMPDIFF(
        DAY,
        p_shipped_at,
        p_delivered_at
    );
END $$

DELIMITER ;


-- =========================================================
-- 14. CUSTOMER VALUE SEGMENT
-- Purpose:
-- Classify customer by total spending
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_customer_segment (
    p_total_spent DECIMAL(14,2)
)
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    IF p_total_spent >= 400000 THEN

        RETURN 'HIGH VALUE';

    ELSEIF p_total_spent >= 100000 THEN

        RETURN 'MEDIUM VALUE';

    ELSE

        RETURN 'LOW VALUE';

    END IF;
END $$

DELIMITER ;


-- =========================================================
-- 15. COUPON REMAINING USES
-- Purpose:
-- Calculate remaining coupon usage
-- NULL means unlimited
-- =========================================================

DELIMITER $$

CREATE FUNCTION fn_coupon_remaining_uses (
    p_usage_limit INT UNSIGNED,
    p_usage_count INT UNSIGNED
)
RETURNS INT
DETERMINISTIC
BEGIN
    IF p_usage_limit IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN GREATEST(
        p_usage_limit - p_usage_count,
        0
    );
END $$

DELIMITER ;


SELECT fn_percentage_discount(
    100000,
    10
) AS discount_amount;


SELECT fn_calculate_line_total(
    2,
    25000,
    3000,
    500
) AS line_total;



SELECT
    inventory_id,
    quantity_on_hand,
    quantity_reserved,
    fn_available_stock(inventory_id)
        AS available_stock
FROM Inventory;




SELECT
    customer_id,

    CONCAT(
        first_name,
        ' ',
        last_name
    ) AS customer_name,

    fn_customer_total_spending(customer_id)
        AS total_spent,

    fn_customer_order_count(customer_id)
        AS order_count,

    fn_customer_segment(
        fn_customer_total_spending(customer_id)
    ) AS customer_segment

FROM Customer;




SHOW FUNCTION STATUS
WHERE Db = 'retail_management';