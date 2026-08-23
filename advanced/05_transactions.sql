USE retail_management;

-- =========================================================
-- 05. TRANSACTIONS
-- Retail & E-Commerce Management Database
-- =========================================================


-- =========================================================
-- 01. SIMPLE TRANSACTION EXAMPLE
-- Purpose:
-- Demonstrate COMMIT and ROLLBACK
-- =========================================================

START TRANSACTION;

UPDATE Customer
SET phone = '+92-300-0000000'
WHERE customer_id = 1;

-- Use COMMIT to permanently save:
-- COMMIT;

-- Use ROLLBACK while testing:
ROLLBACK;


-- =========================================================
-- 02. ORDER STATUS UPDATE + AUDIT
-- Purpose:
-- Demonstrate multiple operations as one unit
-- =========================================================

START TRANSACTION;

UPDATE SalesOrder
SET status = 'PROCESSING'
WHERE order_id = 6;

INSERT INTO AuditLog (
    employee_id,
    action,
    entity_name,
    entity_id,
    old_values,
    new_values,
    ip_address,
    user_agent
)
VALUES (
    2,
    'STATUS_CHANGE',
    'SalesOrder',
    6,
    JSON_OBJECT('status', 'PENDING'),
    JSON_OBJECT('status', 'PROCESSING'),
    NULL,
    'Transaction Demo'
);

-- COMMIT;
ROLLBACK;


-- =========================================================
-- 03. INVENTORY RESERVATION WITH ROW LOCK
-- Purpose:
-- Safely reserve stock
-- =========================================================

START TRANSACTION;

SELECT
    inventory_id,
    quantity_on_hand,
    quantity_reserved
FROM Inventory
WHERE inventory_id = 1
FOR UPDATE;

UPDATE Inventory
SET quantity_reserved = quantity_reserved + 2
WHERE inventory_id = 1
  AND (
        quantity_on_hand - quantity_reserved
      ) >= 2;

-- COMMIT;
ROLLBACK;


-- =========================================================
-- 04. COMPLETE ORDER PLACEMENT PROCEDURE
-- Purpose:
-- Create an order, order item, reserve inventory,
-- and record stock movement atomically
-- =========================================================

DROP PROCEDURE IF EXISTS sp_place_order;

DELIMITER $$

CREATE PROCEDURE sp_place_order (
    IN p_customer_id BIGINT UNSIGNED,
    IN p_variant_id BIGINT UNSIGNED,
    IN p_warehouse_id BIGINT UNSIGNED,
    IN p_quantity INT UNSIGNED,
    IN p_order_number VARCHAR(50)
)
BEGIN
    DECLARE v_inventory_id BIGINT UNSIGNED;
    DECLARE v_available_stock INT;
    DECLARE v_unit_price DECIMAL(12,2);
    DECLARE v_order_id BIGINT UNSIGNED;
    DECLARE v_line_total DECIMAL(12,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Lock inventory row
    SELECT
        i.inventory_id,
        (i.quantity_on_hand - i.quantity_reserved),
        pv.price
    INTO
        v_inventory_id,
        v_available_stock,
        v_unit_price
    FROM Inventory i

    JOIN ProductVariant pv
        ON i.variant_id = pv.variant_id

    WHERE i.variant_id = p_variant_id
      AND i.warehouse_id = p_warehouse_id

    FOR UPDATE;

    -- Validate inventory record
    IF v_inventory_id IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Inventory record not found';

    END IF;

    -- Validate quantity
    IF p_quantity = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Order quantity must be greater than zero';

    END IF;

    -- Validate available stock
    IF v_available_stock < p_quantity THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Insufficient available inventory';

    END IF;

    SET v_line_total =
        v_unit_price * p_quantity;

    -- Create order
    INSERT INTO SalesOrder (
        customer_id,
        order_number,
        order_date,
        status,
        subtotal,
        discount_amount,
        tax_amount,
        shipping_amount,
        total_amount,
        currency
    )
    VALUES (
        p_customer_id,
        p_order_number,
        CURRENT_TIMESTAMP,
        'PENDING',
        v_line_total,
        0.00,
        0.00,
        0.00,
        v_line_total,
        'PKR'
    );

    SET v_order_id = LAST_INSERT_ID();

    -- Create order item
    INSERT INTO OrderItem (
        order_id,
        variant_id,
        quantity,
        unit_price,
        discount_amount,
        tax_amount,
        line_total
    )
    VALUES (
        v_order_id,
        p_variant_id,
        p_quantity,
        v_unit_price,
        0.00,
        0.00,
        v_line_total
    );

    -- Reserve inventory
    UPDATE Inventory
    SET quantity_reserved =
        quantity_reserved + p_quantity
    WHERE inventory_id = v_inventory_id;

    -- Record reservation movement
    INSERT INTO StockMovement (
        inventory_id,
        movement_type,
        quantity,
        reference_type,
        reference_id,
        notes
    )
    VALUES (
        v_inventory_id,
        'ADJUSTMENT',
        p_quantity,
        'SALES_ORDER_RESERVATION',
        v_order_id,
        'Inventory reserved for new order'
    );

    COMMIT;

    SELECT
        v_order_id AS new_order_id,
        p_order_number AS order_number,
        v_line_total AS order_total;

END $$

DELIMITER ;


-- =========================================================
-- 05. FULFILL ORDER
-- Purpose:
-- Convert reserved stock into actual sale
-- =========================================================

DROP PROCEDURE IF EXISTS sp_fulfill_order_item;

DELIMITER $$

CREATE PROCEDURE sp_fulfill_order_item (
    IN p_order_item_id BIGINT UNSIGNED,
    IN p_warehouse_id BIGINT UNSIGNED
)
BEGIN
    DECLARE v_order_id BIGINT UNSIGNED;
    DECLARE v_variant_id BIGINT UNSIGNED;
    DECLARE v_quantity INT UNSIGNED;
    DECLARE v_inventory_id BIGINT UNSIGNED;
    DECLARE v_on_hand INT UNSIGNED;
    DECLARE v_reserved INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Get order item
    SELECT
        order_id,
        variant_id,
        quantity
    INTO
        v_order_id,
        v_variant_id,
        v_quantity
    FROM OrderItem
    WHERE order_item_id = p_order_item_id;

    IF v_order_id IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Order item not found';

    END IF;

    -- Lock matching inventory
    SELECT
        inventory_id,
        quantity_on_hand,
        quantity_reserved
    INTO
        v_inventory_id,
        v_on_hand,
        v_reserved
    FROM Inventory
    WHERE variant_id = v_variant_id
      AND warehouse_id = p_warehouse_id
    FOR UPDATE;

    IF v_inventory_id IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Inventory record not found';

    END IF;

    IF v_on_hand < v_quantity THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Insufficient physical inventory';

    END IF;

    IF v_reserved < v_quantity THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Insufficient reserved inventory';

    END IF;

    -- Deduct physical and reserved stock
    UPDATE Inventory
    SET
        quantity_on_hand =
            quantity_on_hand - v_quantity,

        quantity_reserved =
            quantity_reserved - v_quantity

    WHERE inventory_id = v_inventory_id;

    -- Record real sale
    INSERT INTO StockMovement (
        inventory_id,
        movement_type,
        quantity,
        reference_type,
        reference_id,
        notes
    )
    VALUES (
        v_inventory_id,
        'SALE',
        v_quantity,
        'SALES_ORDER',
        v_order_id,
        'Stock deducted during order fulfillment'
    );

    COMMIT;

END $$

DELIMITER ;


-- =========================================================
-- 06. CANCEL ORDER AND RELEASE STOCK
-- =========================================================

DROP PROCEDURE IF EXISTS sp_cancel_order;

DELIMITER $$

CREATE PROCEDURE sp_cancel_order (
    IN p_order_id BIGINT UNSIGNED,
    IN p_warehouse_id BIGINT UNSIGNED
)
BEGIN
    DECLARE done INT DEFAULT FALSE;

    DECLARE v_variant_id BIGINT UNSIGNED;
    DECLARE v_quantity INT UNSIGNED;
    DECLARE v_inventory_id BIGINT UNSIGNED;

    DECLARE cur_items CURSOR FOR
        SELECT
            variant_id,
            quantity
        FROM OrderItem
        WHERE order_id = p_order_id;

    DECLARE CONTINUE HANDLER
        FOR NOT FOUND
        SET done = TRUE;

    DECLARE EXIT HANDLER
        FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Lock order
    SELECT order_id
    FROM SalesOrder
    WHERE order_id = p_order_id
    FOR UPDATE;

    -- Process each order item
    OPEN cur_items;

    item_loop: LOOP

        FETCH cur_items
        INTO
            v_variant_id,
            v_quantity;

        IF done THEN
            LEAVE item_loop;
        END IF;

        SELECT inventory_id
        INTO v_inventory_id
        FROM Inventory
        WHERE variant_id = v_variant_id
          AND warehouse_id = p_warehouse_id
        FOR UPDATE;

        IF v_inventory_id IS NULL THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Inventory record missing during cancellation';

        END IF;

        UPDATE Inventory
        SET quantity_reserved =
            quantity_reserved - v_quantity

        WHERE inventory_id = v_inventory_id
          AND quantity_reserved >= v_quantity;

        IF ROW_COUNT() = 0 THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Unable to release reserved stock';

        END IF;

        INSERT INTO StockMovement (
            inventory_id,
            movement_type,
            quantity,
            reference_type,
            reference_id,
            notes
        )
        VALUES (
            v_inventory_id,
            'ADJUSTMENT',
            v_quantity,
            'ORDER_CANCELLATION',
            p_order_id,
            'Reserved stock released after cancellation'
        );

    END LOOP;

    CLOSE cur_items;

    UPDATE SalesOrder
    SET status = 'CANCELLED'
    WHERE order_id = p_order_id;

    COMMIT;

END $$

DELIMITER ;


-- =========================================================
-- 07. PROCESS PAYMENT TRANSACTION
-- Purpose:
-- Insert payment and update order if fully paid
-- =========================================================

DROP PROCEDURE IF EXISTS sp_process_payment;

DELIMITER $$

CREATE PROCEDURE sp_process_payment (
    IN p_order_id BIGINT UNSIGNED,
    IN p_payment_method_id BIGINT UNSIGNED,
    IN p_transaction_reference VARCHAR(150),
    IN p_amount DECIMAL(12,2)
)
BEGIN
    DECLARE v_order_total DECIMAL(12,2);
    DECLARE v_paid_total DECIMAL(14,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Lock order
    SELECT total_amount
    INTO v_order_total
    FROM SalesOrder
    WHERE order_id = p_order_id
    FOR UPDATE;

    IF v_order_total IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order not found';

    END IF;

    IF p_amount <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Payment amount must be greater than zero';

    END IF;

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
        'PAID',
        CURRENT_TIMESTAMP
    );

    SELECT
        COALESCE(SUM(amount), 0)
    INTO v_paid_total
    FROM Payment
    WHERE order_id = p_order_id
      AND status = 'PAID';

    IF v_paid_total >= v_order_total THEN

        UPDATE SalesOrder
        SET status = 'CONFIRMED'
        WHERE order_id = p_order_id
          AND status = 'PENDING';

    END IF;

    COMMIT;

END $$

DELIMITER ;


-- =========================================================
-- 08. CREATE AND COMPLETE REFUND TRANSACTION
-- =========================================================

DROP PROCEDURE IF EXISTS sp_process_refund_transaction;

DELIMITER $$

CREATE PROCEDURE sp_process_refund_transaction (
    IN p_return_id BIGINT UNSIGNED,
    IN p_amount DECIMAL(12,2),
    IN p_refund_method VARCHAR(50),
    IN p_transaction_reference VARCHAR(150)
)
BEGIN
    DECLARE v_return_status VARCHAR(30);
    DECLARE v_refund_id BIGINT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Lock return
    SELECT status
    INTO v_return_status
    FROM ProductReturn
    WHERE return_id = p_return_id
    FOR UPDATE;

    IF v_return_status IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Return request not found';

    END IF;

    IF v_return_status NOT IN (
        'APPROVED',
        'RECEIVED',
        'COMPLETED'
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Return is not eligible for refund';

    END IF;

    IF p_amount <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Refund amount must be greater than zero';

    END IF;

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

    SET v_refund_id = LAST_INSERT_ID();

    UPDATE Refund
    SET
        status = 'COMPLETED',
        processed_at = CURRENT_TIMESTAMP
    WHERE refund_id = v_refund_id;

    UPDATE ProductReturn
    SET status = 'COMPLETED'
    WHERE return_id = p_return_id;

    COMMIT;

END $$

DELIMITER ;


-- =========================================================
-- 09. PURCHASE RECEIPT TRANSACTION
-- Purpose:
-- Receive purchased stock into inventory
-- =========================================================

DROP PROCEDURE IF EXISTS sp_receive_purchase_item;

DELIMITER $$

CREATE PROCEDURE sp_receive_purchase_item (
    IN p_purchase_order_item_id BIGINT UNSIGNED,
    IN p_warehouse_id BIGINT UNSIGNED
)
BEGIN
    DECLARE v_purchase_order_id BIGINT UNSIGNED;
    DECLARE v_variant_id BIGINT UNSIGNED;
    DECLARE v_quantity INT UNSIGNED;
    DECLARE v_inventory_id BIGINT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT
        purchase_order_id,
        variant_id,
        quantity
    INTO
        v_purchase_order_id,
        v_variant_id,
        v_quantity
    FROM PurchaseOrderItem
    WHERE purchase_order_item_id =
          p_purchase_order_item_id;

    IF v_purchase_order_id IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Purchase order item not found';

    END IF;

    SELECT inventory_id
    INTO v_inventory_id
    FROM Inventory
    WHERE variant_id = v_variant_id
      AND warehouse_id = p_warehouse_id
    FOR UPDATE;

    IF v_inventory_id IS NULL THEN

        INSERT INTO Inventory (
            variant_id,
            warehouse_id,
            quantity_on_hand,
            quantity_reserved,
            reorder_level
        )
        VALUES (
            v_variant_id,
            p_warehouse_id,
            v_quantity,
            0,
            0
        );

        SET v_inventory_id =
            LAST_INSERT_ID();

    ELSE

        UPDATE Inventory
        SET quantity_on_hand =
            quantity_on_hand + v_quantity
        WHERE inventory_id = v_inventory_id;

    END IF;

    INSERT INTO StockMovement (
        inventory_id,
        movement_type,
        quantity,
        reference_type,
        reference_id,
        notes
    )
    VALUES (
        v_inventory_id,
        'PURCHASE',
        v_quantity,
        'PURCHASE_ORDER',
        v_purchase_order_id,
        'Purchased stock received into warehouse'
    );

    COMMIT;

END $$

DELIMITER ;