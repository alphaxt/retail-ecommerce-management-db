USE retail_management;

-- =========================================================
-- 02. JOIN QUERIES
-- Retail & E-Commerce Management Database
-- =========================================================


-- =========================================================
-- 01. INNER JOIN - CUSTOMER + ADDRESS
-- =========================================================

-- Show customers with their saved addresses
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ca.address_type,
    a.address_line1,
    a.address_line2,
    a.city,
    a.state,
    a.country,
    ca.is_default
FROM Customer c
INNER JOIN CustomerAddress ca
    ON c.customer_id = ca.customer_id
INNER JOIN Address a
    ON ca.address_id = a.address_id
ORDER BY c.customer_id;


-- =========================================================
-- 02. INNER JOIN - PRODUCT + BRAND
-- =========================================================

-- Show every product with its brand
SELECT
    p.product_id,
    p.name AS product_name,
    b.name AS brand_name,
    p.base_price,
    p.status
FROM Product p
INNER JOIN Brand b
    ON p.brand_id = b.brand_id
ORDER BY b.name, p.name;


-- =========================================================
-- 03. PRODUCT + CATEGORY
-- =========================================================

-- Show products and their categories
SELECT
    p.product_id,
    p.name AS product_name,
    c.category_id,
    c.name AS category_name
FROM Product p
INNER JOIN ProductCategory pc
    ON p.product_id = pc.product_id
INNER JOIN Category c
    ON pc.category_id = c.category_id
ORDER BY p.product_id, c.name;


-- =========================================================
-- 04. PRODUCT + VARIANTS
-- =========================================================

-- Display all variants with parent product information
SELECT
    p.product_id,
    p.name AS product_name,
    pv.variant_id,
    pv.sku,
    pv.color,
    pv.size,
    pv.price,
    pv.is_active
FROM Product p
INNER JOIN ProductVariant pv
    ON p.product_id = pv.product_id
ORDER BY p.product_id, pv.variant_id;


-- =========================================================
-- 05. PRODUCT + BRAND + VARIANT
-- =========================================================

-- Show complete sellable SKU information
SELECT
    pv.variant_id,
    pv.sku,
    b.name AS brand_name,
    p.name AS product_name,
    pv.color,
    pv.size,
    pv.price
FROM ProductVariant pv
INNER JOIN Product p
    ON pv.product_id = p.product_id
INNER JOIN Brand b
    ON p.brand_id = b.brand_id
ORDER BY b.name, p.name;


-- =========================================================
-- 06. INVENTORY + PRODUCT + VARIANT + WAREHOUSE
-- =========================================================

-- Show where each product variant is stored
SELECT
    i.inventory_id,
    p.name AS product_name,
    pv.sku,
    w.name AS warehouse_name,
    w.city,
    i.quantity_on_hand,
    i.quantity_reserved,
    i.reorder_level
FROM Inventory i
INNER JOIN ProductVariant pv
    ON i.variant_id = pv.variant_id
INNER JOIN Product p
    ON pv.product_id = p.product_id
INNER JOIN Warehouse w
    ON i.warehouse_id = w.warehouse_id
ORDER BY p.name, w.name;


-- =========================================================
-- 07. AVAILABLE INVENTORY
-- =========================================================

-- Calculate stock currently available for sale
SELECT
    p.name AS product_name,
    pv.sku,
    w.name AS warehouse_name,
    i.quantity_on_hand,
    i.quantity_reserved,
    (i.quantity_on_hand - i.quantity_reserved) AS available_quantity
FROM Inventory i
INNER JOIN ProductVariant pv
    ON i.variant_id = pv.variant_id
INNER JOIN Product p
    ON pv.product_id = p.product_id
INNER JOIN Warehouse w
    ON i.warehouse_id = w.warehouse_id
ORDER BY available_quantity ASC;


-- =========================================================
-- 08. STOCK MOVEMENT HISTORY
-- =========================================================

-- Display stock movements with product and warehouse details
SELECT
    sm.movement_id,
    sm.movement_type,
    sm.quantity,
    sm.reference_type,
    sm.reference_id,
    sm.created_at,
    p.name AS product_name,
    pv.sku,
    w.name AS warehouse_name
FROM StockMovement sm
INNER JOIN Inventory i
    ON sm.inventory_id = i.inventory_id
INNER JOIN ProductVariant pv
    ON i.variant_id = pv.variant_id
INNER JOIN Product p
    ON pv.product_id = p.product_id
INNER JOIN Warehouse w
    ON i.warehouse_id = w.warehouse_id
ORDER BY sm.created_at DESC;


-- =========================================================
-- 09. SUPPLIER + PURCHASE ORDER
-- =========================================================

-- Show purchase orders with supplier information
SELECT
    po.purchase_order_id,
    s.name AS supplier_name,
    po.order_date,
    po.expected_date,
    po.status,
    po.total_amount
FROM PurchaseOrder po
INNER JOIN Supplier s
    ON po.supplier_id = s.supplier_id
ORDER BY po.order_date DESC;


-- =========================================================
-- 10. PURCHASE ORDER DETAILS
-- =========================================================

-- Show items purchased from suppliers
SELECT
    po.purchase_order_id,
    s.name AS supplier_name,
    p.name AS product_name,
    pv.sku,
    poi.quantity,
    poi.unit_cost,
    poi.line_total
FROM PurchaseOrderItem poi
INNER JOIN PurchaseOrder po
    ON poi.purchase_order_id = po.purchase_order_id
INNER JOIN Supplier s
    ON po.supplier_id = s.supplier_id
INNER JOIN ProductVariant pv
    ON poi.variant_id = pv.variant_id
INNER JOIN Product p
    ON pv.product_id = p.product_id
ORDER BY po.purchase_order_id;


-- =========================================================
-- 11. CUSTOMER + CART
-- =========================================================

-- Show customer carts
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ca.cart_id,
    ca.status AS cart_status,
    ca.created_at,
    ca.expires_at
FROM Customer c
INNER JOIN Cart ca
    ON c.customer_id = ca.customer_id
ORDER BY ca.created_at DESC;


-- =========================================================
-- 12. CART CONTENTS
-- =========================================================

-- Show products currently contained in carts
SELECT
    c.cart_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
    p.name AS product_name,
    pv.sku,
    ci.quantity,
    ci.unit_price,
    (ci.quantity * ci.unit_price) AS cart_line_total
FROM CartItem ci
INNER JOIN Cart c
    ON ci.cart_id = c.cart_id
INNER JOIN Customer cu
    ON c.customer_id = cu.customer_id
INNER JOIN ProductVariant pv
    ON ci.variant_id = pv.variant_id
INNER JOIN Product p
    ON pv.product_id = p.product_id
ORDER BY c.cart_id;


-- =========================================================
-- 13. WISHLIST CONTENTS
-- =========================================================

SELECT
    w.wishlist_id,
    w.name AS wishlist_name,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    p.name AS product_name,
    pv.sku,
    pv.price
FROM WishlistItem wi
INNER JOIN Wishlist w
    ON wi.wishlist_id = w.wishlist_id
INNER JOIN Customer c
    ON w.customer_id = c.customer_id
INNER JOIN ProductVariant pv
    ON wi.variant_id = pv.variant_id
INNER JOIN Product p
    ON pv.product_id = p.product_id
ORDER BY w.wishlist_id;


-- =========================================================
-- 14. CUSTOMER ORDER HISTORY
-- =========================================================

-- Show orders together with their customers
SELECT
    so.order_id,
    so.order_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    so.order_date,
    so.status,
    so.total_amount,
    so.currency
FROM SalesOrder so
INNER JOIN Customer c
    ON so.customer_id = c.customer_id
ORDER BY so.order_date DESC;


-- =========================================================
-- 15. FULL ORDER DETAILS
-- =========================================================

-- Show every order item with customer and product information
SELECT
    so.order_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    p.name AS product_name,
    pv.sku,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    oi.line_total
FROM OrderItem oi
INNER JOIN SalesOrder so
    ON oi.order_id = so.order_id
INNER JOIN Customer c
    ON so.customer_id = c.customer_id
INNER JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id
INNER JOIN Product p
    ON pv.product_id = p.product_id
ORDER BY so.order_id, oi.order_item_id;


-- =========================================================
-- 16. ORDERS + PAYMENTS
-- =========================================================

SELECT
    so.order_number,
    so.total_amount AS order_total,
    pm.name AS payment_method,
    p.amount AS payment_amount,
    p.status AS payment_status,
    p.transaction_reference,
    p.payment_date
FROM SalesOrder so
INNER JOIN Payment p
    ON so.order_id = p.order_id
INNER JOIN PaymentMethod pm
    ON p.payment_method_id = pm.payment_method_id
ORDER BY so.order_id;


-- =========================================================
-- 17. CUSTOMER PAYMENT HISTORY
-- =========================================================

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    so.order_number,
    pm.name AS payment_method,
    py.amount,
    py.status AS payment_status,
    py.payment_date
FROM Payment py
INNER JOIN SalesOrder so
    ON py.order_id = so.order_id
INNER JOIN Customer c
    ON so.customer_id = c.customer_id
INNER JOIN PaymentMethod pm
    ON py.payment_method_id = pm.payment_method_id
ORDER BY py.payment_date DESC;


-- =========================================================
-- 18. ORDERS + SHIPMENTS
-- =========================================================

SELECT
    so.order_number,
    s.shipment_id,
    s.tracking_number,
    s.carrier,
    s.status AS shipment_status,
    s.shipped_at,
    s.estimated_delivery,
    s.delivered_at
FROM SalesOrder so
INNER JOIN Shipment s
    ON so.order_id = s.order_id
ORDER BY so.order_id;


-- =========================================================
-- 19. SHIPMENT ITEM DETAILS
-- =========================================================

SELECT
    s.tracking_number,
    so.order_number,
    p.name AS product_name,
    pv.sku,
    si.quantity,
    s.status AS shipment_status
FROM ShipmentItem si
INNER JOIN Shipment s
    ON si.shipment_id = s.shipment_id
INNER JOIN SalesOrder so
    ON s.order_id = so.order_id
INNER JOIN OrderItem oi
    ON si.order_item_id = oi.order_item_id
INNER JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id
INNER JOIN Product p
    ON pv.product_id = p.product_id
ORDER BY s.shipment_id;


-- =========================================================
-- 20. PROMOTIONS + PRODUCTS
-- =========================================================

SELECT
    pr.name AS promotion_name,
    pr.discount_type,
    pr.discount_value,
    p.name AS product_name,
    pr.start_date,
    pr.end_date
FROM PromotionProduct pp
INNER JOIN Promotion pr
    ON pp.promotion_id = pr.promotion_id
INNER JOIN Product p
    ON pp.product_id = p.product_id
ORDER BY pr.promotion_id, p.name;


-- =========================================================
-- 21. PROMOTIONS + COUPONS
-- =========================================================

SELECT
    p.name AS promotion_name,
    c.code AS coupon_code,
    c.discount_type,
    c.discount_value,
    c.usage_limit,
    c.usage_count,
    c.expiry_date
FROM Coupon c
INNER JOIN Promotion p
    ON c.promotion_id = p.promotion_id
ORDER BY p.promotion_id;


-- =========================================================
-- 22. RETURNS + ORIGINAL ORDERS
-- =========================================================

SELECT
    pr.return_number,
    so.order_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    pr.reason,
    pr.status,
    pr.requested_at,
    pr.approved_at,
    pr.received_at
FROM ProductReturn pr
INNER JOIN SalesOrder so
    ON pr.order_id = so.order_id
INNER JOIN Customer c
    ON so.customer_id = c.customer_id
ORDER BY pr.requested_at DESC;


-- =========================================================
-- 23. RETURN ITEM DETAILS
-- =========================================================

SELECT
    pr.return_number,
    so.order_number,
    p.name AS product_name,
    pv.sku,
    ri.quantity,
    ri.reason,
    ri.item_condition,
    ri.resolution
FROM ReturnItem ri
INNER JOIN ProductReturn pr
    ON ri.return_id = pr.return_id
INNER JOIN SalesOrder so
    ON pr.order_id = so.order_id
INNER JOIN OrderItem oi
    ON ri.order_item_id = oi.order_item_id
INNER JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id
INNER JOIN Product p
    ON pv.product_id = p.product_id
ORDER BY pr.return_id;


-- =========================================================
-- 24. RETURNS + REFUNDS
-- =========================================================

SELECT
    pr.return_number,
    so.order_number,
    r.amount AS refund_amount,
    r.status AS refund_status,
    r.refund_method,
    r.transaction_reference,
    r.processed_at
FROM Refund r
INNER JOIN ProductReturn pr
    ON r.return_id = pr.return_id
INNER JOIN SalesOrder so
    ON pr.order_id = so.order_id
ORDER BY r.refund_id;


-- =========================================================
-- 25. PRODUCT REVIEWS
-- =========================================================

SELECT
    p.name AS product_name,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    pr.rating,
    pr.title,
    pr.comment,
    pr.verified_purchase,
    pr.created_at
FROM ProductReview pr
INNER JOIN Product p
    ON pr.product_id = p.product_id
INNER JOIN Customer c
    ON pr.customer_id = c.customer_id
WHERE pr.status = 'PUBLISHED'
ORDER BY pr.created_at DESC;


-- =========================================================
-- 26. EMPLOYEE + ROLE
-- =========================================================

SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.email,
    r.name AS role_name,
    e.status,
    e.hire_date
FROM Employee e
INNER JOIN Role r
    ON e.role_id = r.role_id
ORDER BY e.employee_id;


-- =========================================================
-- 27. EMPLOYEE + AUDIT LOG
-- =========================================================

SELECT
    al.audit_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    al.action,
    al.entity_name,
    al.entity_id,
    al.old_values,
    al.new_values,
    al.created_at
FROM AuditLog al
LEFT JOIN Employee e
    ON al.employee_id = e.employee_id
ORDER BY al.created_at DESC;


-- =========================================================
-- 28. LEFT JOIN - ALL CUSTOMERS AND THEIR ORDERS
-- =========================================================

-- Customers are returned even if they have placed no orders
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    so.order_number,
    so.order_date,
    so.status,
    so.total_amount
FROM Customer c
LEFT JOIN SalesOrder so
    ON c.customer_id = so.customer_id
ORDER BY c.customer_id, so.order_date;


-- =========================================================
-- 29. CUSTOMERS WITH NO ORDERS
-- =========================================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email
FROM Customer c
LEFT JOIN SalesOrder so
    ON c.customer_id = so.customer_id
WHERE so.order_id IS NULL;


-- =========================================================
-- 30. LEFT JOIN - ALL PRODUCTS AND REVIEWS
-- =========================================================

-- Products without reviews are also displayed
SELECT
    p.product_id,
    p.name AS product_name,
    pr.review_id,
    pr.rating,
    pr.title
FROM Product p
LEFT JOIN ProductReview pr
    ON p.product_id = pr.product_id
ORDER BY p.product_id;


-- =========================================================
-- 31. PRODUCTS WITH NO REVIEWS
-- =========================================================

SELECT
    p.product_id,
    p.name AS product_name
FROM Product p
LEFT JOIN ProductReview pr
    ON p.product_id = pr.product_id
WHERE pr.review_id IS NULL;


-- =========================================================
-- 32. LEFT JOIN - PRODUCTS AND PROMOTIONS
-- =========================================================

-- Show every product whether or not it has a promotion
SELECT
    p.product_id,
    p.name AS product_name,
    pr.name AS promotion_name,
    pr.discount_type,
    pr.discount_value
FROM Product p
LEFT JOIN PromotionProduct pp
    ON p.product_id = pp.product_id
LEFT JOIN Promotion pr
    ON pp.promotion_id = pr.promotion_id
ORDER BY p.product_id;


-- =========================================================
-- 33. LEFT JOIN - ORDERS AND RETURNS
-- =========================================================

-- Show all orders, including those that were never returned
SELECT
    so.order_number,
    so.status AS order_status,
    pr.return_number,
    pr.status AS return_status,
    pr.reason
FROM SalesOrder so
LEFT JOIN ProductReturn pr
    ON so.order_id = pr.order_id
ORDER BY so.order_id;


-- =========================================================
-- 34. LEFT JOIN - ORDERS AND SHIPMENTS
-- =========================================================

-- Useful for finding orders that have not yet been shipped
SELECT
    so.order_id,
    so.order_number,
    so.status AS order_status,
    s.tracking_number,
    s.status AS shipment_status
FROM SalesOrder so
LEFT JOIN Shipment s
    ON so.order_id = s.order_id
ORDER BY so.order_id;


-- =========================================================
-- 35. ORDERS WITHOUT SHIPMENTS
-- =========================================================

SELECT
    so.order_id,
    so.order_number,
    so.status,
    so.order_date
FROM SalesOrder so
LEFT JOIN Shipment s
    ON so.order_id = s.order_id
WHERE s.shipment_id IS NULL;


-- =========================================================
-- 36. MULTI-TABLE BUSINESS VIEW
-- CUSTOMER -> ORDER -> ITEM -> PRODUCT -> PAYMENT
-- =========================================================

SELECT
    so.order_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    p.name AS product_name,
    pv.sku,
    oi.quantity,
    oi.line_total,
    py.status AS payment_status,
    pm.name AS payment_method
FROM SalesOrder so
INNER JOIN Customer c
    ON so.customer_id = c.customer_id
INNER JOIN OrderItem oi
    ON so.order_id = oi.order_id
INNER JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id
INNER JOIN Product p
    ON pv.product_id = p.product_id
LEFT JOIN Payment py
    ON so.order_id = py.order_id
LEFT JOIN PaymentMethod pm
    ON py.payment_method_id = pm.payment_method_id
ORDER BY so.order_id, oi.order_item_id;


-- =========================================================
-- 37. COMPLETE ORDER FULFILLMENT VIEW
-- =========================================================

SELECT
    so.order_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    so.status AS order_status,
    py.status AS payment_status,
    sh.status AS shipment_status,
    sh.tracking_number,
    sh.carrier
FROM SalesOrder so
INNER JOIN Customer c
    ON so.customer_id = c.customer_id
LEFT JOIN Payment py
    ON so.order_id = py.order_id
LEFT JOIN Shipment sh
    ON so.order_id = sh.order_id
ORDER BY so.order_id;