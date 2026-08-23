USE retail_management;

-- =========================================================
-- 04. COMMON TABLE EXPRESSIONS (CTEs)
-- Retail & E-Commerce Management Database
-- =========================================================


-- =========================================================
-- 01. BASIC CTE - ACTIVE PRODUCTS
-- =========================================================

WITH ActiveProducts AS (
    SELECT
        product_id,
        name,
        base_price,
        status
    FROM Product
    WHERE status = 'ACTIVE'
)
SELECT
    product_id,
    name,
    base_price
FROM ActiveProducts
ORDER BY base_price DESC;


-- =========================================================
-- 02. PRODUCTS ABOVE AVERAGE PRICE
-- =========================================================

WITH AverageProductPrice AS (
    SELECT
        AVG(base_price) AS avg_price
    FROM Product
)
SELECT
    p.product_id,
    p.name,
    p.base_price,
    app.avg_price
FROM Product p
CROSS JOIN AverageProductPrice app
WHERE p.base_price > app.avg_price
ORDER BY p.base_price DESC;


-- =========================================================
-- 03. CUSTOMER ORDER TOTALS
-- =========================================================

WITH CustomerOrderTotals AS (
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_spent,
        AVG(total_amount) AS average_order_value
    FROM SalesOrder
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    cot.total_orders,
    cot.total_spent,
    cot.average_order_value
FROM CustomerOrderTotals cot
JOIN Customer c
    ON cot.customer_id = c.customer_id
ORDER BY cot.total_spent DESC;


-- =========================================================
-- 04. HIGH-VALUE CUSTOMERS
-- =========================================================

WITH CustomerSpending AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM SalesOrder
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    cs.total_spent
FROM CustomerSpending cs
JOIN Customer c
    ON cs.customer_id = c.customer_id
WHERE cs.total_spent > 200000
ORDER BY cs.total_spent DESC;


-- =========================================================
-- 05. ORDER ITEM REVENUE
-- =========================================================

WITH OrderItemRevenue AS (
    SELECT
        variant_id,
        SUM(quantity) AS total_units,
        SUM(line_total) AS total_revenue
    FROM OrderItem
    GROUP BY variant_id
)
SELECT
    p.name AS product_name,
    pv.sku,
    oir.total_units,
    oir.total_revenue
FROM OrderItemRevenue oir
JOIN ProductVariant pv
    ON oir.variant_id = pv.variant_id
JOIN Product p
    ON pv.product_id = p.product_id
ORDER BY oir.total_revenue DESC;


-- =========================================================
-- 06. PRODUCT SALES SUMMARY
-- =========================================================

WITH ProductSales AS (
    SELECT
        pv.product_id,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.line_total) AS revenue
    FROM OrderItem oi
    JOIN ProductVariant pv
        ON oi.variant_id = pv.variant_id
    GROUP BY pv.product_id
)
SELECT
    p.product_id,
    p.name AS product_name,
    ps.units_sold,
    ps.revenue
FROM ProductSales ps
JOIN Product p
    ON ps.product_id = p.product_id
ORDER BY ps.revenue DESC;


-- =========================================================
-- 07. PRODUCTS WITH NO SALES
-- =========================================================

WITH ProductSales AS (
    SELECT DISTINCT
        pv.product_id
    FROM OrderItem oi
    JOIN ProductVariant pv
        ON oi.variant_id = pv.variant_id
)
SELECT
    p.product_id,
    p.name
FROM Product p
LEFT JOIN ProductSales ps
    ON p.product_id = ps.product_id
WHERE ps.product_id IS NULL;


-- =========================================================
-- 08. WAREHOUSE STOCK TOTALS
-- =========================================================

WITH WarehouseStock AS (
    SELECT
        warehouse_id,
        SUM(quantity_on_hand) AS total_stock,
        SUM(quantity_reserved) AS total_reserved
    FROM Inventory
    GROUP BY warehouse_id
)
SELECT
    w.warehouse_id,
    w.name AS warehouse_name,
    ws.total_stock,
    ws.total_reserved,
    (ws.total_stock - ws.total_reserved) AS available_stock
FROM WarehouseStock ws
JOIN Warehouse w
    ON ws.warehouse_id = w.warehouse_id
ORDER BY available_stock DESC;


-- =========================================================
-- 09. LOW-STOCK PRODUCTS
-- =========================================================

WITH LowStock AS (
    SELECT
        inventory_id,
        variant_id,
        warehouse_id,
        quantity_on_hand,
        quantity_reserved,
        reorder_level
    FROM Inventory
    WHERE quantity_on_hand <= reorder_level
)
SELECT
    p.name AS product_name,
    pv.sku,
    w.name AS warehouse_name,
    ls.quantity_on_hand,
    ls.reorder_level
FROM LowStock ls
JOIN ProductVariant pv
    ON ls.variant_id = pv.variant_id
JOIN Product p
    ON pv.product_id = p.product_id
JOIN Warehouse w
    ON ls.warehouse_id = w.warehouse_id
ORDER BY ls.quantity_on_hand ASC;


-- =========================================================
-- 10. SUPPLIER PURCHASE SUMMARY
-- =========================================================

WITH SupplierPurchases AS (
    SELECT
        supplier_id,
        COUNT(*) AS purchase_order_count,
        SUM(total_amount) AS total_purchase_value
    FROM PurchaseOrder
    GROUP BY supplier_id
)
SELECT
    s.supplier_id,
    s.name AS supplier_name,
    sp.purchase_order_count,
    sp.total_purchase_value
FROM SupplierPurchases sp
JOIN Supplier s
    ON sp.supplier_id = s.supplier_id
ORDER BY sp.total_purchase_value DESC;


-- =========================================================
-- 11. MONTHLY SALES
-- =========================================================

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        COUNT(*) AS order_count,
        SUM(total_amount) AS total_revenue,
        AVG(total_amount) AS average_order_value
    FROM SalesOrder
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    sales_month,
    order_count,
    total_revenue,
    average_order_value
FROM MonthlySales
ORDER BY sales_month;


-- =========================================================
-- 12. DAILY SALES
-- =========================================================

WITH DailySales AS (
    SELECT
        DATE(order_date) AS sales_date,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS revenue
    FROM SalesOrder
    GROUP BY DATE(order_date)
)
SELECT
    sales_date,
    total_orders,
    revenue
FROM DailySales
ORDER BY sales_date;


-- =========================================================
-- 13. MULTIPLE CTEs - CUSTOMER ORDER ANALYSIS
-- =========================================================

WITH CustomerTotals AS (
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_spent
    FROM SalesOrder
    GROUP BY customer_id
),

OverallAverage AS (
    SELECT
        AVG(total_spent) AS average_customer_spending
    FROM CustomerTotals
)

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ct.total_orders,
    ct.total_spent,
    oa.average_customer_spending
FROM CustomerTotals ct
JOIN Customer c
    ON ct.customer_id = c.customer_id
CROSS JOIN OverallAverage oa
WHERE ct.total_spent > oa.average_customer_spending
ORDER BY ct.total_spent DESC;


-- =========================================================
-- 14. MULTIPLE CTEs - PRODUCT PROFIT ESTIMATE
-- =========================================================

WITH VariantSales AS (
    SELECT
        variant_id,
        SUM(quantity) AS units_sold,
        SUM(line_total) AS sales_revenue
    FROM OrderItem
    GROUP BY variant_id
),

VariantCosts AS (
    SELECT
        pv.variant_id,
        pv.product_id,
        pv.sku,
        pv.cost_price
    FROM ProductVariant pv
)

SELECT
    p.name AS product_name,
    vc.sku,
    vs.units_sold,
    vs.sales_revenue,
    (vs.units_sold * vc.cost_price) AS estimated_cost,
    (
        vs.sales_revenue -
        (vs.units_sold * vc.cost_price)
    ) AS estimated_profit
FROM VariantSales vs
JOIN VariantCosts vc
    ON vs.variant_id = vc.variant_id
JOIN Product p
    ON vc.product_id = p.product_id
ORDER BY estimated_profit DESC;


-- =========================================================
-- 15. PAYMENT SUMMARY BY METHOD
-- =========================================================

WITH PaymentSummary AS (
    SELECT
        payment_method_id,
        COUNT(*) AS payment_count,
        SUM(amount) AS total_payment_amount
    FROM Payment
    WHERE status = 'PAID'
    GROUP BY payment_method_id
)
SELECT
    pm.name AS payment_method,
    ps.payment_count,
    ps.total_payment_amount
FROM PaymentSummary ps
JOIN PaymentMethod pm
    ON ps.payment_method_id = pm.payment_method_id
ORDER BY ps.total_payment_amount DESC;


-- =========================================================
-- 16. SHIPMENT STATUS SUMMARY
-- =========================================================

WITH ShipmentStatusSummary AS (
    SELECT
        status,
        COUNT(*) AS shipment_count
    FROM Shipment
    GROUP BY status
)
SELECT
    status,
    shipment_count
FROM ShipmentStatusSummary
ORDER BY shipment_count DESC;


-- =========================================================
-- 17. RETURN SUMMARY
-- =========================================================

WITH ReturnSummary AS (
    SELECT
        status,
        COUNT(*) AS return_count
    FROM ProductReturn
    GROUP BY status
)
SELECT
    status,
    return_count
FROM ReturnSummary
ORDER BY return_count DESC;


-- =========================================================
-- 18. PRODUCT REVIEW SUMMARY
-- =========================================================

WITH ReviewSummary AS (
    SELECT
        product_id,
        COUNT(*) AS review_count,
        AVG(rating) AS average_rating
    FROM ProductReview
    WHERE status = 'PUBLISHED'
    GROUP BY product_id
)
SELECT
    p.name AS product_name,
    rs.review_count,
    ROUND(rs.average_rating, 2) AS average_rating
FROM ReviewSummary rs
JOIN Product p
    ON rs.product_id = p.product_id
ORDER BY average_rating DESC;


-- =========================================================
-- 19. ABOVE-AVERAGE RATED PRODUCTS
-- =========================================================

WITH ProductRatings AS (
    SELECT
        product_id,
        AVG(rating) AS avg_rating
    FROM ProductReview
    WHERE status = 'PUBLISHED'
    GROUP BY product_id
),

OverallRating AS (
    SELECT
        AVG(rating) AS overall_avg_rating
    FROM ProductReview
    WHERE status = 'PUBLISHED'
)

SELECT
    p.product_id,
    p.name,
    pr.avg_rating,
    ovr.overall_avg_rating
FROM ProductRatings pr
JOIN Product p
    ON pr.product_id = p.product_id
CROSS JOIN OverallRating ovr
WHERE pr.avg_rating > ovr.overall_avg_rating
ORDER BY pr.avg_rating DESC;


-- =========================================================
-- 20. REFUND SUMMARY
-- =========================================================

WITH RefundSummary AS (
    SELECT
        status,
        COUNT(*) AS refund_count,
        SUM(amount) AS refund_amount
    FROM Refund
    GROUP BY status
)
SELECT
    status,
    refund_count,
    refund_amount
FROM RefundSummary
ORDER BY refund_amount DESC;


-- =========================================================
-- 21. ACTIVE PROMOTIONS AND ASSIGNED PRODUCTS
-- =========================================================

WITH ActivePromotions AS (
    SELECT
        promotion_id,
        name,
        discount_type,
        discount_value
    FROM Promotion
    WHERE is_active = TRUE
      AND NOW() BETWEEN start_date AND end_date
)
SELECT
    ap.name AS promotion_name,
    ap.discount_type,
    ap.discount_value,
    p.name AS product_name
FROM ActivePromotions ap
JOIN PromotionProduct pp
    ON ap.promotion_id = pp.promotion_id
JOIN Product p
    ON pp.product_id = p.product_id
ORDER BY ap.promotion_id, p.name;


-- =========================================================
-- 22. EMPLOYEE AUDIT ACTIVITY
-- =========================================================

WITH EmployeeActivity AS (
    SELECT
        employee_id,
        COUNT(*) AS total_actions
    FROM AuditLog
    WHERE employee_id IS NOT NULL
    GROUP BY employee_id
)
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    r.name AS role_name,
    ea.total_actions
FROM EmployeeActivity ea
JOIN Employee e
    ON ea.employee_id = e.employee_id
JOIN Role r
    ON e.role_id = r.role_id
ORDER BY ea.total_actions DESC;


-- =========================================================
-- 23. ORDER FULFILLMENT SUMMARY USING MULTIPLE CTEs
-- =========================================================

WITH PaymentState AS (
    SELECT
        order_id,
        MAX(
            CASE
                WHEN status = 'PAID' THEN 1
                ELSE 0
            END
        ) AS is_paid
    FROM Payment
    GROUP BY order_id
),

ShipmentState AS (
    SELECT
        order_id,
        MAX(
            CASE
                WHEN status = 'DELIVERED' THEN 1
                ELSE 0
            END
        ) AS is_delivered
    FROM Shipment
    GROUP BY order_id
)

SELECT
    so.order_number,
    so.status AS order_status,

    CASE
        WHEN ps.is_paid = 1 THEN 'PAID'
        ELSE 'NOT PAID'
    END AS payment_state,

    CASE
        WHEN ss.is_delivered = 1 THEN 'DELIVERED'
        ELSE 'NOT DELIVERED'
    END AS shipment_state

FROM SalesOrder so

LEFT JOIN PaymentState ps
    ON so.order_id = ps.order_id

LEFT JOIN ShipmentState ss
    ON so.order_id = ss.order_id

ORDER BY so.order_id;


-- =========================================================
-- 24. RECURSIVE CTE - SIMPLE NUMBER SEQUENCE
-- Educational example
-- =========================================================

WITH RECURSIVE NumberSequence AS (
    SELECT 1 AS number

    UNION ALL

    SELECT number + 1
    FROM NumberSequence
    WHERE number < 10
)
SELECT number
FROM NumberSequence;