USE retail_management;

-- =========================================================
-- 02. STORED PROCEDURES
-- Retail & E-Commerce Management Database
-- =========================================================


-- =========================================================
-- 01. ADD CUSTOMER
-- Purpose:
-- Create a new customer record
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_add_customer (
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_email VARCHAR(255),
    IN p_phone VARCHAR(30),
    IN p_password_hash VARCHAR(255),
    IN p_date_of_birth DATE
)
BEGIN
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
        p_first_name,
        p_last_name,
        p_email,
        p_phone,
        p_password_hash,
        p_date_of_birth,
        'ACTIVE'
    );
END $$

DELIMITER ;


-- =========================================================
-- 02. UPDATE CUSTOMER STATUS
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_update_customer_status (
    IN p_customer_id BIGINT UNSIGNED,
    IN p_status VARCHAR(30)
)
BEGIN
    UPDATE Customer
    SET status = p_status
    WHERE customer_id = p_customer_id;
END $$

DELIMITER ;


-- =========================================================
-- 03. UPDATE PRODUCT STATUS
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_update_product_status (
    IN p_product_id BIGINT UNSIGNED,
    IN p_status VARCHAR(30)
)
BEGIN
    UPDATE Product
    SET status = p_status
    WHERE product_id = p_product_id;
END $$

DELIMITER ;


-- =========================================================
-- 04. UPDATE SALES ORDER STATUS
-- Purpose:
-- Centralize order status changes
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_update_order_status (
    IN p_order_id BIGINT UNSIGNED,
    IN p_status VARCHAR(30)
)
BEGIN
    UPDATE SalesOrder
    SET status = p_status
    WHERE order_id = p_order_id;
END $$

DELIMITER ;


-- =========================================================
-- 05. GET CUSTOMER ORDER HISTORY
-- Purpose:
-- Return all orders for one customer
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_get_customer_orders (
    IN p_customer_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        so.order_id,
        so.order_number,
        so.order_date,
        so.status,
        so.subtotal,
        so.discount_amount,
        so.shipping_amount,
        so.total_amount,
        so.currency
    FROM SalesOrder so
    WHERE so.customer_id = p_customer_id
    ORDER BY so.order_date DESC;
END $$

DELIMITER ;


-- =========================================================
-- 06. GET ORDER DETAILS
-- Purpose:
-- Return detailed products for an order
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_get_order_details (
    IN p_order_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        so.order_number,
        so.order_date,
        so.status AS order_status,
        p.name AS product_name,
        pv.sku,
        oi.quantity,
        oi.unit_price,
        oi.discount_amount,
        oi.tax_amount,
        oi.line_total
    FROM SalesOrder so

    JOIN OrderItem oi
        ON so.order_id = oi.order_id

    JOIN ProductVariant pv
        ON oi.variant_id = pv.variant_id

    JOIN Product p
        ON pv.product_id = p.product_id

    WHERE so.order_id = p_order_id

    ORDER BY oi.order_item_id;
END $$

DELIMITER ;


-- =========================================================
-- 07. ADJUST INVENTORY
-- Purpose:
-- Increase or decrease stock safely
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_adjust_inventory (
    IN p_inventory_id BIGINT UNSIGNED,
    IN p_quantity_change INT
)
BEGIN
    DECLARE v_current_quantity INT;

    SELECT quantity_on_hand
    INTO v_current_quantity
    FROM Inventory
    WHERE inventory_id = p_inventory_id;

    IF v_current_quantity IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Inventory record not found';

    ELSEIF v_current_quantity + p_quantity_change < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Inventory cannot become negative';

    ELSE
        UPDATE Inventory
        SET quantity_on_hand =
            quantity_on_hand + p_quantity_change
        WHERE inventory_id = p_inventory_id;
    END IF;
END $$

DELIMITER ;


-- =========================================================
-- 08. RESERVE INVENTORY
-- Purpose:
-- Reserve stock for an order/cart
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_reserve_inventory (
    IN p_inventory_id BIGINT UNSIGNED,
    IN p_quantity INT UNSIGNED
)
BEGIN
    DECLARE v_on_hand INT UNSIGNED;
    DECLARE v_reserved INT UNSIGNED;
    DECLARE v_available INT;

    SELECT
        quantity_on_hand,
        quantity_reserved
    INTO
        v_on_hand,
        v_reserved
    FROM Inventory
    WHERE inventory_id = p_inventory_id;

    IF v_on_hand IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Inventory record not found';

    ELSE

        SET v_available = v_on_hand - v_reserved;

        IF p_quantity = 0 THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Reservation quantity must be greater than zero';

        ELSEIF p_quantity > v_available THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Insufficient available inventory';

        ELSE

            UPDATE Inventory
            SET quantity_reserved =
                quantity_reserved + p_quantity
            WHERE inventory_id = p_inventory_id;

        END IF;

    END IF;
END $$

DELIMITER ;


-- =========================================================
-- 09. RELEASE RESERVED INVENTORY
-- Purpose:
-- Release stock when cart/order reservation is cancelled
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_release_inventory (
    IN p_inventory_id BIGINT UNSIGNED,
    IN p_quantity INT UNSIGNED
)
BEGIN
    DECLARE v_reserved INT UNSIGNED;

    SELECT quantity_reserved
    INTO v_reserved
    FROM Inventory
    WHERE inventory_id = p_inventory_id;

    IF v_reserved IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Inventory record not found';

    ELSEIF p_quantity = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Release quantity must be greater than zero';

    ELSEIF p_quantity > v_reserved THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Cannot release more than reserved quantity';

    ELSE

        UPDATE Inventory
        SET quantity_reserved =
            quantity_reserved - p_quantity
        WHERE inventory_id = p_inventory_id;

    END IF;
END $$

DELIMITER ;


-- =========================================================
-- 10. RECORD PAYMENT
-- Purpose:
-- Insert payment for an order
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_record_payment (
    IN p_order_id BIGINT UNSIGNED,
    IN p_payment_method_id BIGINT UNSIGNED,
    IN p_transaction_reference VARCHAR(150),
    IN p_amount DECIMAL(12,2),
    IN p_status VARCHAR(30)
)
BEGIN
    INSERT INTO Payment (
        order_id,
        payment_method_id,
        transaction_reference,
        amount,
        status,
        payment_date
    )
    VALUES (
        p_order_id,
        p_payment_method_id,
        p_transaction_reference,
        p_amount,
        p_status,
        CASE
            WHEN p_status IN ('PAID', 'AUTHORIZED')
                THEN CURRENT_TIMESTAMP
            ELSE NULL
        END
    );
END $$

DELIMITER ;


-- =========================================================
-- 11. GET LOW STOCK INVENTORY
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_get_low_stock ()
BEGIN
    SELECT
        i.inventory_id,
        p.name AS product_name,
        pv.sku,
        w.name AS warehouse_name,
        i.quantity_on_hand,
        i.quantity_reserved,
        i.reorder_level,
        (
            i.quantity_on_hand -
            i.quantity_reserved
        ) AS available_quantity

    FROM Inventory i

    JOIN ProductVariant pv
        ON i.variant_id = pv.variant_id

    JOIN Product p
        ON pv.product_id = p.product_id

    JOIN Warehouse w
        ON i.warehouse_id = w.warehouse_id

    WHERE
        (
            i.quantity_on_hand -
            i.quantity_reserved
        ) <= i.reorder_level

    ORDER BY available_quantity ASC;
END $$

DELIMITER ;


-- =========================================================
-- 12. GET PRODUCT SALES SUMMARY
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_get_product_sales (
    IN p_product_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        p.product_id,
        p.name AS product_name,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.line_total) AS total_revenue
    FROM Product p

    JOIN ProductVariant pv
        ON p.product_id = pv.product_id

    JOIN OrderItem oi
        ON pv.variant_id = oi.variant_id

    WHERE p.product_id = p_product_id

    GROUP BY
        p.product_id,
        p.name;
END $$

DELIMITER ;


-- =========================================================
-- 13. PROCESS REFUND
-- Purpose:
-- Create a refund record
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_create_refund (
    IN p_return_id BIGINT UNSIGNED,
    IN p_amount DECIMAL(12,2),
    IN p_refund_method VARCHAR(50),
    IN p_transaction_reference VARCHAR(150)
)
BEGIN
    IF p_amount <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Refund amount must be greater than zero';

    ELSE

        INSERT INTO Refund (
            return_id,
            amount,
            status,
            refund_method,
            transaction_reference,
            processed_at
        )
        VALUES (
            p_return_id,
            p_amount,
            'PENDING',
            p_refund_method,
            p_transaction_reference,
            NULL
        );

    END IF;
END $$

DELIMITER ;


-- =========================================================
-- 14. COMPLETE REFUND
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_complete_refund (
    IN p_refund_id BIGINT UNSIGNED
)
BEGIN
    UPDATE Refund
    SET
        status = 'COMPLETED',
        processed_at = CURRENT_TIMESTAMP
    WHERE refund_id = p_refund_id;
END $$

DELIMITER ;


-- =========================================================
-- 15. ADD PRODUCT REVIEW
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_add_product_review (
    IN p_customer_id BIGINT UNSIGNED,
    IN p_product_id BIGINT UNSIGNED,
    IN p_rating TINYINT UNSIGNED,
    IN p_title VARCHAR(200),
    IN p_comment TEXT,
    IN p_verified_purchase BOOLEAN
)
BEGIN
    IF p_rating < 1 OR p_rating > 5 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rating must be between 1 and 5';

    ELSE

        INSERT INTO ProductReview (
            customer_id,
            product_id,
            rating,
            title,
            comment,
            status,
            verified_purchase
        )
        VALUES (
            p_customer_id,
            p_product_id,
            p_rating,
            p_title,
            p_comment,
            'PENDING',
            p_verified_purchase
        );

    END IF;
END $$

DELIMITER ;


-- =========================================================
-- 16. CUSTOMER SPENDING REPORT WITH OUT PARAMETER
-- Purpose:
-- Demonstrate OUT parameters
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_customer_total_spending (
    IN p_customer_id BIGINT UNSIGNED,
    OUT p_total_spending DECIMAL(14,2)
)
BEGIN
    SELECT
        COALESCE(SUM(total_amount), 0)
    INTO p_total_spending
    FROM SalesOrder
    WHERE customer_id = p_customer_id
      AND status <> 'CANCELLED';
END $$

DELIMITER ;


CALL sp_get_customer_orders(1);

CALL sp_get_order_details(1);

CALL sp_get_low_stock();

CALL sp_get_product_sales(1);


START TRANSACTION;

CALL sp_update_order_status(
    6,
    'PROCESSING'
);

SELECT *
FROM SalesOrder
WHERE order_id = 6;

ROLLBACK;


START TRANSACTION;

CALL sp_reserve_inventory(
    1,
    2
);

SELECT
    inventory_id,
    quantity_on_hand,
    quantity_reserved
FROM Inventory
WHERE inventory_id = 1;

ROLLBACK;


CALL sp_reserve_inventory(
    1,
    999999
);


CALL sp_customer_total_spending(
    1,
    @customer_spending
);

SELECT @customer_spending
    AS total_customer_spending;
    
    
SHOW PROCEDURE STATUS
WHERE Db = 'retail_management';


SHOW PROCEDURE STATUS
WHERE Db = DATABASE();


DROP PROCEDURE IF EXISTS sp_add_customer;

DELIMITER $$

CREATE PROCEDURE sp_add_customer (...)
BEGIN
    ...
END $$

DELIMITER ;


