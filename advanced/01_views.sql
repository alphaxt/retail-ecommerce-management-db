USE retail_management;

-- =========================================================
-- 01. VIEWS
-- Retail & E-Commerce Management Database
-- =========================================================


-- =========================================================
-- 01. ACTIVE PRODUCTS VIEW
-- Purpose:
-- Reusable list of active products with brand information
-- =========================================================

CREATE OR REPLACE VIEW vw_active_products AS
SELECT
    p.product_id,
    p.name AS product_name,
    b.name AS brand_name,
    p.base_price,
    p.status,
    p.created_at
FROM Product p
JOIN Brand b
    ON p.brand_id = b.brand_id
WHERE p.status = 'ACTIVE';


-- =========================================================
-- 02. PRODUCT VARIANT DETAILS VIEW
-- Purpose:
-- Reusable product + SKU information
-- =========================================================

CREATE OR REPLACE VIEW vw_product_variant_details AS
SELECT
    pv.variant_id,
    pv.sku,
    p.product_id,
    p.name AS product_name,
    b.name AS brand_name,
    pv.color,
    pv.size,
    pv.price,
    pv.cost_price,
    pv.weight,
    pv.is_active
FROM ProductVariant pv
JOIN Product p
    ON pv.product_id = p.product_id
JOIN Brand b
    ON p.brand_id = b.brand_id;


-- =========================================================
-- 03. INVENTORY AVAILABILITY VIEW
-- Purpose:
-- Show physical, reserved, and available inventory
-- =========================================================

CREATE OR REPLACE VIEW vw_inventory_availability AS
SELECT
    i.inventory_id,
    p.product_id,
    p.name AS product_name,
    pv.variant_id,
    pv.sku,
    w.warehouse_id,
    w.name AS warehouse_name,
    w.city,
    i.quantity_on_hand,
    i.quantity_reserved,
    i.reorder_level,
    (i.quantity_on_hand - i.quantity_reserved) AS available_quantity
FROM Inventory i
JOIN ProductVariant pv
    ON i.variant_id = pv.variant_id
JOIN Product p
    ON pv.product_id = p.product_id
JOIN Warehouse w
    ON i.warehouse_id = w.warehouse_id;


-- =========================================================
-- 04. LOW STOCK VIEW
-- Purpose:
-- Identify inventory requiring attention
-- =========================================================

CREATE OR REPLACE VIEW vw_low_stock AS
SELECT
    i.inventory_id,
    p.name AS product_name,
    pv.sku,
    w.name AS warehouse_name,
    i.quantity_on_hand,
    i.quantity_reserved,
    i.reorder_level,
    (i.quantity_on_hand - i.quantity_reserved) AS available_quantity
FROM Inventory i
JOIN ProductVariant pv
    ON i.variant_id = pv.variant_id
JOIN Product p
    ON pv.product_id = p.product_id
JOIN Warehouse w
    ON i.warehouse_id = w.warehouse_id
WHERE
    (i.quantity_on_hand - i.quantity_reserved)
    <= i.reorder_level;


-- =========================================================
-- 05. CUSTOMER ORDER SUMMARY VIEW
-- Purpose:
-- Customer lifetime-value style summary
-- =========================================================

CREATE OR REPLACE VIEW vw_customer_order_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.status AS customer_status,
    COUNT(so.order_id) AS total_orders,
    COALESCE(SUM(so.total_amount), 0) AS total_spent,
    COALESCE(AVG(so.total_amount), 0) AS average_order_value,
    MAX(so.order_date) AS latest_order_date
FROM Customer c
LEFT JOIN SalesOrder so
    ON c.customer_id = so.customer_id
   AND so.status <> 'CANCELLED'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.status;


-- =========================================================
-- 06. ORDER DETAILS VIEW
-- Purpose:
-- Reusable order-line report
-- =========================================================

CREATE OR REPLACE VIEW vw_order_details AS
SELECT
    so.order_id,
    so.order_number,
    so.order_date,
    so.status AS order_status,

    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

    oi.order_item_id,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    oi.tax_amount,
    oi.line_total,

    p.product_id,
    p.name AS product_name,

    pv.variant_id,
    pv.sku,
    pv.color,
    pv.size

FROM SalesOrder so

JOIN Customer c
    ON so.customer_id = c.customer_id

JOIN OrderItem oi
    ON so.order_id = oi.order_id

JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id

JOIN Product p
    ON pv.product_id = p.product_id;


-- =========================================================
-- 07. ORDER PAYMENT STATUS VIEW
-- Purpose:
-- Show orders with payment information
-- =========================================================

CREATE OR REPLACE VIEW vw_order_payment_status AS
SELECT
    so.order_id,
    so.order_number,
    so.order_date,
    so.status AS order_status,
    so.total_amount AS order_total,

    p.payment_id,
    p.amount AS payment_amount,
    p.status AS payment_status,
    p.transaction_reference,
    p.payment_date,

    pm.name AS payment_method

FROM SalesOrder so

LEFT JOIN Payment p
    ON so.order_id = p.order_id

LEFT JOIN PaymentMethod pm
    ON p.payment_method_id = pm.payment_method_id;


-- =========================================================
-- 08. ORDER SHIPMENT STATUS VIEW
-- Purpose:
-- Show fulfillment and delivery status
-- =========================================================

CREATE OR REPLACE VIEW vw_order_shipment_status AS
SELECT
    so.order_id,
    so.order_number,
    so.status AS order_status,
    so.order_date,

    s.shipment_id,
    s.tracking_number,
    s.carrier,
    s.status AS shipment_status,
    s.shipped_at,
    s.estimated_delivery,
    s.delivered_at

FROM SalesOrder so

LEFT JOIN Shipment s
    ON so.order_id = s.order_id;


-- =========================================================
-- 09. ORDER FULFILLMENT VIEW
-- Purpose:
-- Management view combining order, payment, shipment
-- =========================================================

CREATE OR REPLACE VIEW vw_order_fulfillment AS
SELECT
    so.order_id,
    so.order_number,
    so.order_date,
    so.status AS order_status,
    so.total_amount,

    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

    p.status AS payment_status,
    pm.name AS payment_method,

    s.status AS shipment_status,
    s.tracking_number,
    s.carrier,
    s.delivered_at

FROM SalesOrder so

JOIN Customer c
    ON so.customer_id = c.customer_id

LEFT JOIN Payment p
    ON so.order_id = p.order_id

LEFT JOIN PaymentMethod pm
    ON p.payment_method_id = pm.payment_method_id

LEFT JOIN Shipment s
    ON so.order_id = s.order_id;


-- =========================================================
-- 10. PRODUCT SALES SUMMARY VIEW
-- Purpose:
-- Sales performance per product
-- =========================================================

CREATE OR REPLACE VIEW vw_product_sales_summary AS
SELECT
    p.product_id,
    p.name AS product_name,
    b.name AS brand_name,

    SUM(oi.quantity) AS units_sold,

    SUM(oi.line_total) AS total_revenue,

    SUM(
        oi.quantity * pv.cost_price
    ) AS estimated_cost,

    SUM(oi.line_total)
    -
    SUM(
        oi.quantity * pv.cost_price
    ) AS estimated_gross_profit

FROM OrderItem oi

JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id

JOIN Product p
    ON pv.product_id = p.product_id

JOIN Brand b
    ON p.brand_id = b.brand_id

WHERE pv.cost_price IS NOT NULL

GROUP BY
    p.product_id,
    p.name,
    b.name;


-- =========================================================
-- 11. SUPPLIER PURCHASE SUMMARY VIEW
-- Purpose:
-- Purchasing analysis per supplier
-- =========================================================

CREATE OR REPLACE VIEW vw_supplier_purchase_summary AS
SELECT
    s.supplier_id,
    s.name AS supplier_name,

    COUNT(po.purchase_order_id) AS purchase_order_count,

    COALESCE(
        SUM(po.total_amount),
        0
    ) AS total_purchase_value,

    COALESCE(
        AVG(po.total_amount),
        0
    ) AS average_purchase_value

FROM Supplier s

LEFT JOIN PurchaseOrder po
    ON s.supplier_id = po.supplier_id

GROUP BY
    s.supplier_id,
    s.name;


-- =========================================================
-- 12. PRODUCT REVIEW SUMMARY VIEW
-- Purpose:
-- Product rating report
-- =========================================================

CREATE OR REPLACE VIEW vw_product_review_summary AS
SELECT
    p.product_id,
    p.name AS product_name,

    COUNT(pr.review_id) AS review_count,

    ROUND(
        AVG(pr.rating),
        2
    ) AS average_rating

FROM Product p

LEFT JOIN ProductReview pr
    ON p.product_id = pr.product_id
   AND pr.status = 'PUBLISHED'

GROUP BY
    p.product_id,
    p.name;


-- =========================================================
-- 13. RETURN SUMMARY VIEW
-- Purpose:
-- Track customer returns and refunds
-- =========================================================

CREATE OR REPLACE VIEW vw_return_summary AS
SELECT
    pr.return_id,
    pr.return_number,
    pr.order_id,
    so.order_number,

    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

    pr.reason,
    pr.status AS return_status,
    pr.requested_at,
    pr.approved_at,
    pr.received_at,

    r.refund_id,
    r.amount AS refund_amount,
    r.status AS refund_status,
    r.refund_method

FROM ProductReturn pr

JOIN SalesOrder so
    ON pr.order_id = so.order_id

JOIN Customer c
    ON so.customer_id = c.customer_id

LEFT JOIN Refund r
    ON pr.return_id = r.return_id;


-- =========================================================
-- 14. ACTIVE PROMOTIONS VIEW
-- Purpose:
-- Show currently active promotion-product mappings
-- =========================================================

CREATE OR REPLACE VIEW vw_active_promotions AS
SELECT
    pr.promotion_id,
    pr.name AS promotion_name,
    pr.discount_type,
    pr.discount_value,
    pr.start_date,
    pr.end_date,

    p.product_id,
    p.name AS product_name

FROM Promotion pr

JOIN PromotionProduct pp
    ON pr.promotion_id = pp.promotion_id

JOIN Product p
    ON pp.product_id = p.product_id

WHERE pr.is_active = TRUE
  AND NOW() BETWEEN pr.start_date AND pr.end_date;


-- =========================================================
-- 15. MONTHLY SALES SUMMARY VIEW
-- Purpose:
-- Dashboard-ready monthly metrics
-- =========================================================

CREATE OR REPLACE VIEW vw_monthly_sales_summary AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,

    COUNT(*) AS total_orders,

    SUM(total_amount) AS total_revenue,

    ROUND(
        AVG(total_amount),
        2
    ) AS average_order_value

FROM SalesOrder

WHERE status <> 'CANCELLED'

GROUP BY
    DATE_FORMAT(order_date, '%Y-%m');


-- =========================================================
-- 16. EMPLOYEE AUDIT SUMMARY VIEW
-- Purpose:
-- Number of logged actions by employee
-- =========================================================

CREATE OR REPLACE VIEW vw_employee_audit_summary AS
SELECT
    e.employee_id,

    CONCAT(
        e.first_name,
        ' ',
        e.last_name
    ) AS employee_name,

    r.name AS role_name,

    COUNT(al.audit_id) AS audit_actions,

    MAX(al.created_at) AS latest_activity

FROM Employee e

JOIN Role r
    ON e.role_id = r.role_id

LEFT JOIN AuditLog al
    ON e.employee_id = al.employee_id

GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    r.name;
    
    
SELECT *
FROM vw_active_products;

SELECT *
FROM vw_inventory_availability;

SELECT *
FROM vw_low_stock;