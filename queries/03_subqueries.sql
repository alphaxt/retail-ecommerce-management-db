USE retail_management;

-- =========================================================
-- 03. SUBQUERIES
-- Retail & E-Commerce Management Database
-- =========================================================


-- =========================================================
-- 01. PRODUCTS ABOVE AVERAGE PRICE
-- Scalar subquery
-- =========================================================

SELECT
    product_id,
    name,
    base_price
FROM Product
WHERE base_price > (
    SELECT AVG(base_price)
    FROM Product
)
ORDER BY base_price DESC;


-- =========================================================
-- 02. MOST EXPENSIVE PRODUCT
-- Scalar subquery
-- =========================================================

SELECT
    product_id,
    name,
    base_price
FROM Product
WHERE base_price = (
    SELECT MAX(base_price)
    FROM Product
);


-- =========================================================
-- 03. CHEAPEST PRODUCT
-- Scalar subquery
-- =========================================================

SELECT
    product_id,
    name,
    base_price
FROM Product
WHERE base_price = (
    SELECT MIN(base_price)
    FROM Product
);


-- =========================================================
-- 04. PRODUCTS ABOVE THEIR BRAND'S AVERAGE PRICE
-- Correlated subquery
-- =========================================================

SELECT
    p.product_id,
    p.name,
    p.brand_id,
    p.base_price
FROM Product p
WHERE p.base_price > (
    SELECT AVG(p2.base_price)
    FROM Product p2
    WHERE p2.brand_id = p.brand_id
)
ORDER BY p.brand_id, p.base_price DESC;


-- =========================================================
-- 05. CUSTOMERS WHO HAVE PLACED ORDERS
-- IN subquery
-- =========================================================

SELECT
    customer_id,
    first_name,
    last_name,
    email
FROM Customer
WHERE customer_id IN (
    SELECT customer_id
    FROM SalesOrder
)
ORDER BY customer_id;


-- =========================================================
-- 06. CUSTOMERS WHO HAVE NEVER PLACED AN ORDER
-- NOT EXISTS subquery
-- =========================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM Customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM SalesOrder so
    WHERE so.customer_id = c.customer_id
);


-- =========================================================
-- 07. PRODUCTS THAT HAVE BEEN ORDERED
-- EXISTS subquery
-- =========================================================

SELECT
    p.product_id,
    p.name
FROM Product p
WHERE EXISTS (
    SELECT 1
    FROM ProductVariant pv
    JOIN OrderItem oi
        ON pv.variant_id = oi.variant_id
    WHERE pv.product_id = p.product_id
)
ORDER BY p.product_id;


-- =========================================================
-- 08. PRODUCTS NEVER ORDERED
-- NOT EXISTS
-- =========================================================

SELECT
    p.product_id,
    p.name
FROM Product p
WHERE NOT EXISTS (
    SELECT 1
    FROM ProductVariant pv
    JOIN OrderItem oi
        ON pv.variant_id = oi.variant_id
    WHERE pv.product_id = p.product_id
)
ORDER BY p.product_id;


-- =========================================================
-- 09. CUSTOMERS WHO SPENT ABOVE AVERAGE ORDER VALUE
-- IN + aggregation subquery
-- =========================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM Customer c
WHERE c.customer_id IN (
    SELECT so.customer_id
    FROM SalesOrder so
    GROUP BY so.customer_id
    HAVING AVG(so.total_amount) > (
        SELECT AVG(total_amount)
        FROM SalesOrder
    )
);


-- =========================================================
-- 10. ORDERS ABOVE AVERAGE ORDER VALUE
-- Scalar subquery
-- =========================================================

SELECT
    order_id,
    order_number,
    customer_id,
    total_amount
FROM SalesOrder
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM SalesOrder
)
ORDER BY total_amount DESC;


-- =========================================================
-- 11. HIGHEST VALUE ORDER
-- =========================================================

SELECT
    order_id,
    order_number,
    customer_id,
    total_amount
FROM SalesOrder
WHERE total_amount = (
    SELECT MAX(total_amount)
    FROM SalesOrder
);


-- =========================================================
-- 12. CUSTOMERS WITH THE HIGHEST TOTAL SPENDING
-- Nested subquery
-- =========================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM Customer c
WHERE c.customer_id IN (
    SELECT so.customer_id
    FROM SalesOrder so
    GROUP BY so.customer_id
    HAVING SUM(so.total_amount) = (
        SELECT MAX(customer_total)
        FROM (
            SELECT
                customer_id,
                SUM(total_amount) AS customer_total
            FROM SalesOrder
            GROUP BY customer_id
        ) totals
    )
);


-- =========================================================
-- 13. PRODUCT VARIANTS ABOVE AVERAGE VARIANT PRICE
-- =========================================================

SELECT
    variant_id,
    sku,
    price
FROM ProductVariant
WHERE price > (
    SELECT AVG(price)
    FROM ProductVariant
)
ORDER BY price DESC;


-- =========================================================
-- 14. MOST EXPENSIVE VARIANT OF EACH PRODUCT
-- Correlated subquery
-- =========================================================

SELECT
    pv.variant_id,
    pv.product_id,
    pv.sku,
    pv.price
FROM ProductVariant pv
WHERE pv.price = (
    SELECT MAX(pv2.price)
    FROM ProductVariant pv2
    WHERE pv2.product_id = pv.product_id
)
ORDER BY pv.product_id;


-- =========================================================
-- 15. PRODUCTS WITH MORE THAN ONE VARIANT
-- =========================================================

SELECT
    product_id,
    name
FROM Product
WHERE product_id IN (
    SELECT product_id
    FROM ProductVariant
    GROUP BY product_id
    HAVING COUNT(*) > 1
);


-- =========================================================
-- 16. PRODUCTS IN MORE THAN ONE CATEGORY
-- =========================================================

SELECT
    product_id,
    name
FROM Product
WHERE product_id IN (
    SELECT product_id
    FROM ProductCategory
    GROUP BY product_id
    HAVING COUNT(*) > 1
);


-- =========================================================
-- 17. INVENTORY BELOW AVERAGE STOCK LEVEL
-- =========================================================

SELECT
    inventory_id,
    variant_id,
    warehouse_id,
    quantity_on_hand
FROM Inventory
WHERE quantity_on_hand < (
    SELECT AVG(quantity_on_hand)
    FROM Inventory
)
ORDER BY quantity_on_hand;


-- =========================================================
-- 18. WAREHOUSES HOLDING ABOVE-AVERAGE TOTAL STOCK
-- =========================================================

SELECT
    w.warehouse_id,
    w.name
FROM Warehouse w
WHERE w.warehouse_id IN (
    SELECT i.warehouse_id
    FROM Inventory i
    GROUP BY i.warehouse_id
    HAVING SUM(i.quantity_on_hand) > (
        SELECT AVG(warehouse_stock)
        FROM (
            SELECT
                warehouse_id,
                SUM(quantity_on_hand) AS warehouse_stock
            FROM Inventory
            GROUP BY warehouse_id
        ) stock_totals
    )
);


-- =========================================================
-- 19. SUPPLIERS WITH PURCHASE ORDERS
-- EXISTS
-- =========================================================

SELECT
    s.supplier_id,
    s.name
FROM Supplier s
WHERE EXISTS (
    SELECT 1
    FROM PurchaseOrder po
    WHERE po.supplier_id = s.supplier_id
);


-- =========================================================
-- 20. SUPPLIERS WITH NO PURCHASE ORDERS
-- NOT EXISTS
-- =========================================================

SELECT
    s.supplier_id,
    s.name
FROM Supplier s
WHERE NOT EXISTS (
    SELECT 1
    FROM PurchaseOrder po
    WHERE po.supplier_id = s.supplier_id
);


-- =========================================================
-- 21. PURCHASE ORDERS ABOVE AVERAGE PURCHASE VALUE
-- =========================================================

SELECT
    purchase_order_id,
    supplier_id,
    order_date,
    total_amount
FROM PurchaseOrder
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM PurchaseOrder
)
ORDER BY total_amount DESC;


-- =========================================================
-- 22. ORDERS THAT HAVE SUCCESSFUL PAYMENTS
-- EXISTS
-- =========================================================

SELECT
    so.order_id,
    so.order_number,
    so.total_amount
FROM SalesOrder so
WHERE EXISTS (
    SELECT 1
    FROM Payment p
    WHERE p.order_id = so.order_id
      AND p.status = 'PAID'
);


-- =========================================================
-- 23. ORDERS WITHOUT SUCCESSFUL PAYMENT
-- NOT EXISTS
-- =========================================================

SELECT
    so.order_id,
    so.order_number,
    so.status
FROM SalesOrder so
WHERE NOT EXISTS (
    SELECT 1
    FROM Payment p
    WHERE p.order_id = so.order_id
      AND p.status = 'PAID'
);


-- =========================================================
-- 24. ORDERS WITH SHIPMENTS
-- =========================================================

SELECT
    order_id,
    order_number,
    status
FROM SalesOrder
WHERE order_id IN (
    SELECT order_id
    FROM Shipment
);


-- =========================================================
-- 25. ORDERS WITHOUT SHIPMENTS
-- =========================================================

SELECT
    so.order_id,
    so.order_number,
    so.status
FROM SalesOrder so
WHERE NOT EXISTS (
    SELECT 1
    FROM Shipment s
    WHERE s.order_id = so.order_id
);


-- =========================================================
-- 26. PRODUCTS WITH PUBLISHED REVIEWS
-- =========================================================

SELECT
    p.product_id,
    p.name
FROM Product p
WHERE EXISTS (
    SELECT 1
    FROM ProductReview pr
    WHERE pr.product_id = p.product_id
      AND pr.status = 'PUBLISHED'
);


-- =========================================================
-- 27. PRODUCTS WITHOUT REVIEWS
-- =========================================================

SELECT
    p.product_id,
    p.name
FROM Product p
WHERE NOT EXISTS (
    SELECT 1
    FROM ProductReview pr
    WHERE pr.product_id = p.product_id
);


-- =========================================================
-- 28. PRODUCTS WITH ABOVE-AVERAGE REVIEW RATING
-- =========================================================

SELECT
    p.product_id,
    p.name
FROM Product p
WHERE p.product_id IN (
    SELECT pr.product_id
    FROM ProductReview pr
    WHERE pr.status = 'PUBLISHED'
    GROUP BY pr.product_id
    HAVING AVG(pr.rating) > (
        SELECT AVG(rating)
        FROM ProductReview
        WHERE status = 'PUBLISHED'
    )
);


-- =========================================================
-- 29. PROMOTIONS THAT HAVE PRODUCTS ASSIGNED
-- =========================================================

SELECT
    promotion_id,
    name
FROM Promotion
WHERE promotion_id IN (
    SELECT promotion_id
    FROM PromotionProduct
);


-- =========================================================
-- 30. PROMOTIONS WITH NO PRODUCTS ASSIGNED
-- =========================================================

SELECT
    p.promotion_id,
    p.name
FROM Promotion p
WHERE NOT EXISTS (
    SELECT 1
    FROM PromotionProduct pp
    WHERE pp.promotion_id = p.promotion_id
);


-- =========================================================
-- 31. RETURNS WITH REFUNDS
-- =========================================================

SELECT
    pr.return_id,
    pr.return_number,
    pr.status
FROM ProductReturn pr
WHERE EXISTS (
    SELECT 1
    FROM Refund r
    WHERE r.return_id = pr.return_id
);


-- =========================================================
-- 32. RETURNS WITHOUT COMPLETED REFUNDS
-- =========================================================

SELECT
    pr.return_id,
    pr.return_number,
    pr.status
FROM ProductReturn pr
WHERE NOT EXISTS (
    SELECT 1
    FROM Refund r
    WHERE r.return_id = pr.return_id
      AND r.status = 'COMPLETED'
);


-- =========================================================
-- 33. EMPLOYEES WHO HAVE AUDIT LOG ACTIVITY
-- =========================================================

SELECT
    employee_id,
    first_name,
    last_name
FROM Employee
WHERE employee_id IN (
    SELECT DISTINCT employee_id
    FROM AuditLog
    WHERE employee_id IS NOT NULL
);


-- =========================================================
-- 34. EMPLOYEES WITH NO AUDIT ACTIVITY
-- =========================================================

SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM Employee e
WHERE NOT EXISTS (
    SELECT 1
    FROM AuditLog al
    WHERE al.employee_id = e.employee_id
);