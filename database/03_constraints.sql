USE retail_management;

-- ============================================
-- PURCHASE ORDER BUSINESS RULES
-- ============================================

ALTER TABLE PurchaseOrder
ADD CONSTRAINT chk_purchaseorder_expected_date
CHECK (
    expected_date IS NULL
    OR expected_date >= DATE(order_date)
);

ALTER TABLE PurchaseOrder
ADD CONSTRAINT chk_purchaseorder_status
CHECK (
    status IN (
        'PENDING',
        'APPROVED',
        'ORDERED',
        'PARTIALLY_RECEIVED',
        'RECEIVED',
        'CANCELLED'
    )
);


-- ============================================
-- CATALOG
-- ============================================

ALTER TABLE Product
ADD CONSTRAINT chk_product_status
CHECK (
    status IN ('ACTIVE', 'INACTIVE', 'DISCONTINUED')
);


-- ============================================
-- CUSTOMER
-- ============================================

ALTER TABLE Customer
ADD CONSTRAINT chk_customer_status
CHECK (
    status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')
);


-- ============================================
-- INVENTORY
-- ============================================

ALTER TABLE Warehouse
ADD CONSTRAINT chk_warehouse_status
CHECK (
    status IN ('ACTIVE', 'INACTIVE', 'MAINTENANCE')
);

ALTER TABLE StockMovement
ADD CONSTRAINT chk_stockmovement_type
CHECK (
    movement_type IN (
        'PURCHASE',
        'SALE',
        'RETURN',
        'TRANSFER_IN',
        'TRANSFER_OUT',
        'ADJUSTMENT'
    )
);


-- ============================================
-- SUPPLIERS
-- ============================================

ALTER TABLE Supplier
ADD CONSTRAINT chk_supplier_status
CHECK (
    status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')
);


-- ============================================
-- CART
-- ============================================

ALTER TABLE Cart
ADD CONSTRAINT chk_cart_status
CHECK (
    status IN (
        'ACTIVE',
        'ABANDONED',
        'CONVERTED',
        'EXPIRED'
    )
);


-- ============================================
-- SALES ORDER
-- ============================================

ALTER TABLE SalesOrder
ADD CONSTRAINT chk_salesorder_status
CHECK (
    status IN (
        'PENDING',
        'CONFIRMED',
        'PROCESSING',
        'SHIPPED',
        'DELIVERED',
        'CANCELLED',
        'RETURNED'
    )
);


-- ============================================
-- PAYMENT
-- ============================================

ALTER TABLE Payment
ADD CONSTRAINT chk_payment_status
CHECK (
    status IN (
        'PENDING',
        'AUTHORIZED',
        'PAID',
        'FAILED',
        'CANCELLED',
        'REFUNDED'
    )
);


-- ============================================
-- SHIPPING
-- ============================================

ALTER TABLE Shipment
ADD CONSTRAINT chk_shipment_status
CHECK (
    status IN (
        'PENDING',
        'PACKED',
        'SHIPPED',
        'IN_TRANSIT',
        'DELIVERED',
        'FAILED',
        'RETURNED'
    )
);

ALTER TABLE Shipment
ADD CONSTRAINT chk_shipment_delivery_date
CHECK (
    estimated_delivery IS NULL
    OR shipped_at IS NULL
    OR estimated_delivery >= DATE(shipped_at)
);

ALTER TABLE Shipment
ADD CONSTRAINT chk_shipment_delivered_at
CHECK (
    delivered_at IS NULL
    OR shipped_at IS NULL
    OR delivered_at >= shipped_at
);


-- ============================================
-- PROMOTIONS
-- ============================================

ALTER TABLE Promotion
ADD CONSTRAINT chk_promotion_dates
CHECK (
    end_date >= start_date
);

ALTER TABLE Promotion
ADD CONSTRAINT chk_promotion_discount_type
CHECK (
    discount_type IN ('PERCENTAGE', 'FIXED_AMOUNT')
);

ALTER TABLE Promotion
ADD CONSTRAINT chk_promotion_percentage
CHECK (
    discount_type <> 'PERCENTAGE'
    OR discount_value <= 100
);


-- ============================================
-- COUPONS
-- ============================================

ALTER TABLE Coupon
ADD CONSTRAINT chk_coupon_dates
CHECK (
    expiry_date >= start_date
);

ALTER TABLE Coupon
ADD CONSTRAINT chk_coupon_discount_type
CHECK (
    discount_type IN ('PERCENTAGE', 'FIXED_AMOUNT')
);

ALTER TABLE Coupon
ADD CONSTRAINT chk_coupon_percentage
CHECK (
    discount_type <> 'PERCENTAGE'
    OR discount_value <= 100
);

ALTER TABLE Coupon
ADD CONSTRAINT chk_coupon_usage
CHECK (
    usage_limit IS NULL
    OR usage_count <= usage_limit
);


-- ============================================
-- RETURNS
-- ============================================

ALTER TABLE ProductReturn
ADD CONSTRAINT chk_productreturn_status
CHECK (
    status IN (
        'REQUESTED',
        'APPROVED',
        'REJECTED',
        'RECEIVED',
        'COMPLETED',
        'CANCELLED'
    )
);

ALTER TABLE ProductReturn
ADD CONSTRAINT chk_productreturn_dates
CHECK (
    (approved_at IS NULL OR approved_at >= requested_at)
    AND
    (received_at IS NULL OR received_at >= requested_at)
);

ALTER TABLE ReturnItem
ADD CONSTRAINT chk_returnitem_condition
CHECK (
    item_condition IS NULL
    OR item_condition IN (
        'UNOPENED',
        'OPENED',
        'USED',
        'DAMAGED',
        'DEFECTIVE'
    )
);

ALTER TABLE ReturnItem
ADD CONSTRAINT chk_returnitem_resolution
CHECK (
    resolution IS NULL
    OR resolution IN (
        'REFUND',
        'REPLACEMENT',
        'STORE_CREDIT',
        'REJECTED'
    )
);


-- ============================================
-- REFUNDS
-- ============================================

ALTER TABLE Refund
ADD CONSTRAINT chk_refund_status
CHECK (
    status IN (
        'PENDING',
        'PROCESSING',
        'COMPLETED',
        'FAILED',
        'CANCELLED'
    )
);


-- ============================================
-- REVIEWS
-- ============================================

ALTER TABLE ProductReview
ADD CONSTRAINT chk_productreview_status
CHECK (
    status IN (
        'PENDING',
        'PUBLISHED',
        'REJECTED',
        'HIDDEN'
    )
);


-- ============================================
-- EMPLOYEES
-- ============================================

ALTER TABLE Employee
ADD CONSTRAINT chk_employee_status
CHECK (
    status IN (
        'ACTIVE',
        'INACTIVE',
        'SUSPENDED',
        'TERMINATED'
    )
);


-- ============================================
-- AUDITING
-- ============================================

ALTER TABLE AuditLog
ADD CONSTRAINT chk_auditlog_action
CHECK (
    action IN (
        'INSERT',
        'UPDATE',
        'DELETE',
        'LOGIN',
        'LOGOUT',
        'STATUS_CHANGE'
    )
);


SHOW CREATE TABLE Promotion;
SHOW CREATE TABLE Coupon;