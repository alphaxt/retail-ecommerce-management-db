USE retail_management;

-- =========================================================
-- 04. TRIGGERS
-- Retail & E-Commerce Management Database
-- =========================================================


-- =========================================================
-- 01. AUDIT CUSTOMER STATUS CHANGES
-- Purpose:
-- Automatically log customer status updates
-- =========================================================

DROP TRIGGER IF EXISTS trg_customer_status_audit;

DELIMITER $$

CREATE TRIGGER trg_customer_status_audit
AFTER UPDATE ON Customer
FOR EACH ROW
BEGIN

    IF OLD.status <> NEW.status THEN

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
            NULL,
            'STATUS_CHANGE',
            'Customer',
            NEW.customer_id,
            JSON_OBJECT(
                'status',
                OLD.status
            ),
            JSON_OBJECT(
                'status',
                NEW.status
            ),
            NULL,
            'Database Trigger'
        );

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 02. AUDIT PRODUCT STATUS CHANGES
-- =========================================================

DROP TRIGGER IF EXISTS trg_product_status_audit;

DELIMITER $$

CREATE TRIGGER trg_product_status_audit
AFTER UPDATE ON Product
FOR EACH ROW
BEGIN

    IF OLD.status <> NEW.status THEN

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
            NULL,
            'STATUS_CHANGE',
            'Product',
            NEW.product_id,
            JSON_OBJECT(
                'status',
                OLD.status
            ),
            JSON_OBJECT(
                'status',
                NEW.status
            ),
            NULL,
            'Database Trigger'
        );

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 03. AUDIT SALES ORDER STATUS CHANGES
-- =========================================================

DROP TRIGGER IF EXISTS trg_salesorder_status_audit;

DELIMITER $$

CREATE TRIGGER trg_salesorder_status_audit
AFTER UPDATE ON SalesOrder
FOR EACH ROW
BEGIN

    IF OLD.status <> NEW.status THEN

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
            NULL,
            'STATUS_CHANGE',
            'SalesOrder',
            NEW.order_id,
            JSON_OBJECT(
                'status',
                OLD.status
            ),
            JSON_OBJECT(
                'status',
                NEW.status
            ),
            NULL,
            'Database Trigger'
        );

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 04. AUDIT PRODUCT RETURN STATUS CHANGES
-- =========================================================

DROP TRIGGER IF EXISTS trg_productreturn_status_audit;

DELIMITER $$

CREATE TRIGGER trg_productreturn_status_audit
AFTER UPDATE ON ProductReturn
FOR EACH ROW
BEGIN

    IF OLD.status <> NEW.status THEN

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
            NULL,
            'STATUS_CHANGE',
            'ProductReturn',
            NEW.return_id,
            JSON_OBJECT(
                'status',
                OLD.status
            ),
            JSON_OBJECT(
                'status',
                NEW.status
            ),
            NULL,
            'Database Trigger'
        );

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 05. AUDIT REFUND STATUS CHANGES
-- =========================================================

DROP TRIGGER IF EXISTS trg_refund_status_audit;

DELIMITER $$

CREATE TRIGGER trg_refund_status_audit
AFTER UPDATE ON Refund
FOR EACH ROW
BEGIN

    IF OLD.status <> NEW.status THEN

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
            NULL,
            'STATUS_CHANGE',
            'Refund',
            NEW.refund_id,
            JSON_OBJECT(
                'status',
                OLD.status
            ),
            JSON_OBJECT(
                'status',
                NEW.status
            ),
            NULL,
            'Database Trigger'
        );

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 06. PREVENT INVALID INVENTORY UPDATE
-- Purpose:
-- Reserved stock cannot exceed physical stock
-- =========================================================

DROP TRIGGER IF EXISTS trg_inventory_validate_update;

DELIMITER $$

CREATE TRIGGER trg_inventory_validate_update
BEFORE UPDATE ON Inventory
FOR EACH ROW
BEGIN

    IF NEW.quantity_reserved > NEW.quantity_on_hand THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Reserved inventory cannot exceed quantity on hand';

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 07. PREVENT INVALID INVENTORY INSERT
-- =========================================================

DROP TRIGGER IF EXISTS trg_inventory_validate_insert;

DELIMITER $$

CREATE TRIGGER trg_inventory_validate_insert
BEFORE INSERT ON Inventory
FOR EACH ROW
BEGIN

    IF NEW.quantity_reserved > NEW.quantity_on_hand THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Reserved inventory cannot exceed quantity on hand';

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 10. AUDIT INVENTORY QUANTITY CHANGE
-- Purpose:
-- Record before/after inventory quantities
-- =========================================================

DROP TRIGGER IF EXISTS trg_inventory_quantity_audit;

DELIMITER $$

CREATE TRIGGER trg_inventory_quantity_audit
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN

    IF OLD.quantity_on_hand <> NEW.quantity_on_hand
       OR OLD.quantity_reserved <> NEW.quantity_reserved THEN

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
            NULL,
            'UPDATE',
            'Inventory',
            NEW.inventory_id,

            JSON_OBJECT(
                'quantity_on_hand',
                OLD.quantity_on_hand,
                'quantity_reserved',
                OLD.quantity_reserved
            ),

            JSON_OBJECT(
                'quantity_on_hand',
                NEW.quantity_on_hand,
                'quantity_reserved',
                NEW.quantity_reserved
            ),

            NULL,
            'Database Trigger'
        );

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 11. AUTO SET PAYMENT DATE
-- Purpose:
-- When payment becomes PAID, set payment_date automatically
-- =========================================================

DROP TRIGGER IF EXISTS trg_payment_set_paid_date;

DELIMITER $$

CREATE TRIGGER trg_payment_set_paid_date
BEFORE UPDATE ON Payment
FOR EACH ROW
BEGIN

    IF NEW.status = 'PAID'
       AND OLD.status <> 'PAID'
       AND NEW.payment_date IS NULL THEN

        SET NEW.payment_date = CURRENT_TIMESTAMP;

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 12. AUTO SET REFUND PROCESSED DATE
-- Purpose:
-- When refund becomes COMPLETED
-- =========================================================

DROP TRIGGER IF EXISTS trg_refund_set_processed_date;

DELIMITER $$

CREATE TRIGGER trg_refund_set_processed_date
BEFORE UPDATE ON Refund
FOR EACH ROW
BEGIN

    IF NEW.status = 'COMPLETED'
       AND OLD.status <> 'COMPLETED'
       AND NEW.processed_at IS NULL THEN

        SET NEW.processed_at = CURRENT_TIMESTAMP;

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 13. AUTO SET RETURN APPROVED DATE
-- =========================================================

DROP TRIGGER IF EXISTS trg_return_set_approved_date;

DELIMITER $$

CREATE TRIGGER trg_return_set_approved_date
BEFORE UPDATE ON ProductReturn
FOR EACH ROW
BEGIN

    IF NEW.status = 'APPROVED'
       AND OLD.status <> 'APPROVED'
       AND NEW.approved_at IS NULL THEN

        SET NEW.approved_at = CURRENT_TIMESTAMP;

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 14. AUTO SET RETURN RECEIVED DATE
-- =========================================================

DROP TRIGGER IF EXISTS trg_return_set_received_date;

DELIMITER $$

CREATE TRIGGER trg_return_set_received_date
BEFORE UPDATE ON ProductReturn
FOR EACH ROW
BEGIN

    IF NEW.status = 'RECEIVED'
       AND OLD.status <> 'RECEIVED'
       AND NEW.received_at IS NULL THEN

        SET NEW.received_at = CURRENT_TIMESTAMP;

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 15. PREVENT NEGATIVE OR ZERO PAYMENT
-- Extra database safety
-- =========================================================

DROP TRIGGER IF EXISTS trg_payment_validate_insert;

DELIMITER $$

CREATE TRIGGER trg_payment_validate_insert
BEFORE INSERT ON Payment
FOR EACH ROW
BEGIN

    IF NEW.amount <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Payment amount must be greater than zero';

    END IF;

END $$

DELIMITER ;


-- =========================================================
-- 16. PREVENT NEGATIVE OR ZERO REFUND
-- =========================================================

DROP TRIGGER IF EXISTS trg_refund_validate_insert;

DELIMITER $$

CREATE TRIGGER trg_refund_validate_insert
BEFORE INSERT ON Refund
FOR EACH ROW
BEGIN

    IF NEW.amount <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Refund amount must be greater than zero';

    END IF;

END $$

DELIMITER ;




START TRANSACTION;

UPDATE SalesOrder
SET status = 'PROCESSING'
WHERE order_id = 6;

SELECT *
FROM AuditLog
ORDER BY audit_id DESC
LIMIT 5;

ROLLBACK;