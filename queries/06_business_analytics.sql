USE retail_management;

-- =========================================================
-- 06. BUSINESS ANALYTICS
-- Retail & E-Commerce Management Database
-- =========================================================


-- =========================================================
-- 01. TOTAL REVENUE
-- Business Question:
-- How much revenue has the store generated?
-- =========================================================

SELECT
    SUM(total_amount) AS total_revenue
FROM SalesOrder
WHERE status IN (
    'CONFIRMED',
    'PROCESSING',
    'SHIPPED',
    'DELIVERED'
);


-- =========================================================
-- 02. TOTAL ORDERS
-- Business Question:
-- How many orders have been placed?
-- =========================================================

SELECT
    COUNT(*) AS total_orders
FROM SalesOrder;


-- =========================================================
-- 03. AVERAGE ORDER VALUE (AOV)
-- Business Question:
-- What is the average amount customers spend per order?
-- =========================================================

SELECT
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM SalesOrder
WHERE status <> 'CANCELLED';


-- =========================================================
-- 04. REVENUE BY ORDER STATUS
-- Business Question:
-- How much money is associated with each order status?
-- =========================================================

SELECT
    status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_value
FROM SalesOrder
GROUP BY status
ORDER BY total_value DESC;


-- =========================================================
-- 05. CUSTOMER LIFETIME VALUE
-- Business Question:
-- Which customers have spent the most money?
-- =========================================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(so.order_id) AS total_orders,
    COALESCE(SUM(so.total_amount), 0) AS lifetime_value
FROM Customer c
LEFT JOIN SalesOrder so
    ON c.customer_id = so.customer_id
   AND so.status <> 'CANCELLED'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY lifetime_value DESC;


-- =========================================================
-- 06. TOP 5 CUSTOMERS BY SPENDING
-- =========================================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(so.total_amount) AS total_spent
FROM Customer c
JOIN SalesOrder so
    ON c.customer_id = so.customer_id
WHERE so.status <> 'CANCELLED'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_spent DESC
LIMIT 5;


-- =========================================================
-- 07. CUSTOMER ORDER FREQUENCY
-- Business Question:
-- Which customers order most frequently?
-- =========================================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(so.order_id) AS number_of_orders
FROM Customer c
LEFT JOIN SalesOrder so
    ON c.customer_id = so.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY number_of_orders DESC;


-- =========================================================
-- 08. REPEAT CUSTOMERS
-- Business Question:
-- Which customers have placed more than one order?
-- =========================================================

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(so.order_id) AS total_orders
FROM Customer c
JOIN SalesOrder so
    ON c.customer_id = so.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(so.order_id) > 1
ORDER BY total_orders DESC;


-- =========================================================
-- 09. TOP-SELLING PRODUCTS BY UNITS
-- Business Question:
-- Which products sell the most units?
-- =========================================================

SELECT
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity) AS units_sold
FROM OrderItem oi
JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id
JOIN Product p
    ON pv.product_id = p.product_id
GROUP BY
    p.product_id,
    p.name
ORDER BY units_sold DESC;


-- =========================================================
-- 10. TOP PRODUCTS BY REVENUE
-- Business Question:
-- Which products generate the most revenue?
-- =========================================================

SELECT
    p.product_id,
    p.name AS product_name,
    SUM(oi.line_total) AS product_revenue
FROM OrderItem oi
JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id
JOIN Product p
    ON pv.product_id = p.product_id
GROUP BY
    p.product_id,
    p.name
ORDER BY product_revenue DESC;


-- =========================================================
-- 11. PRODUCT REVENUE RANKING
-- Window Function
-- =========================================================

WITH ProductRevenue AS (
    SELECT
        p.product_id,
        p.name AS product_name,
        SUM(oi.line_total) AS revenue
    FROM OrderItem oi
    JOIN ProductVariant pv
        ON oi.variant_id = pv.variant_id
    JOIN Product p
        ON pv.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.name
)

SELECT
    product_id,
    product_name,
    revenue,

    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank

FROM ProductRevenue
ORDER BY revenue_rank;


-- =========================================================
-- 12. REVENUE BY BRAND
-- Business Question:
-- Which brands generate the highest sales?
-- =========================================================

SELECT
    b.brand_id,
    b.name AS brand_name,
    SUM(oi.line_total) AS brand_revenue
FROM OrderItem oi
JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id
JOIN Product p
    ON pv.product_id = p.product_id
JOIN Brand b
    ON p.brand_id = b.brand_id
GROUP BY
    b.brand_id,
    b.name
ORDER BY brand_revenue DESC;


-- =========================================================
-- 13. REVENUE BY CATEGORY
-- Note:
-- A product may belong to multiple categories.
-- =========================================================

SELECT
    c.category_id,
    c.name AS category_name,
    SUM(oi.line_total) AS category_revenue
FROM OrderItem oi
JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id
JOIN Product p
    ON pv.product_id = p.product_id
JOIN ProductCategory pc
    ON p.product_id = pc.product_id
JOIN Category c
    ON pc.category_id = c.category_id
GROUP BY
    c.category_id,
    c.name
ORDER BY category_revenue DESC;


-- =========================================================
-- 14. ESTIMATED GROSS PROFIT BY PRODUCT
-- Business Question:
-- Which products are most profitable before overhead?
-- =========================================================

SELECT
    p.product_id,
    p.name AS product_name,

    SUM(oi.quantity) AS units_sold,

    SUM(oi.line_total) AS revenue,

    SUM(
        oi.quantity * pv.cost_price
    ) AS estimated_cost,

    SUM(oi.line_total) -
    SUM(
        oi.quantity * pv.cost_price
    ) AS estimated_gross_profit

FROM OrderItem oi

JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id

JOIN Product p
    ON pv.product_id = p.product_id

WHERE pv.cost_price IS NOT NULL

GROUP BY
    p.product_id,
    p.name

ORDER BY estimated_gross_profit DESC;


-- =========================================================
-- 15. GROSS MARGIN PERCENTAGE BY PRODUCT
-- =========================================================

WITH ProductProfit AS (
    SELECT
        p.product_id,
        p.name AS product_name,
        SUM(oi.line_total) AS revenue,
        SUM(oi.quantity * pv.cost_price) AS estimated_cost
    FROM OrderItem oi
    JOIN ProductVariant pv
        ON oi.variant_id = pv.variant_id
    JOIN Product p
        ON pv.product_id = p.product_id
    WHERE pv.cost_price IS NOT NULL
    GROUP BY
        p.product_id,
        p.name
)

SELECT
    product_id,
    product_name,
    revenue,
    estimated_cost,
    revenue - estimated_cost AS gross_profit,

    ROUND(
        (
            revenue - estimated_cost
        ) / NULLIF(revenue, 0) * 100,
        2
    ) AS gross_margin_percentage

FROM ProductProfit
ORDER BY gross_margin_percentage DESC;


-- =========================================================
-- 16. INVENTORY VALUE
-- Business Question:
-- What is the estimated value of current inventory?
-- =========================================================

SELECT
    SUM(
        i.quantity_on_hand * pv.cost_price
    ) AS inventory_cost_value
FROM Inventory i
JOIN ProductVariant pv
    ON i.variant_id = pv.variant_id
WHERE pv.cost_price IS NOT NULL;


-- =========================================================
-- 17. INVENTORY VALUE BY WAREHOUSE
-- =========================================================

SELECT
    w.warehouse_id,
    w.name AS warehouse_name,

    SUM(i.quantity_on_hand) AS total_units,

    SUM(
        i.quantity_on_hand * pv.cost_price
    ) AS inventory_value

FROM Inventory i

JOIN Warehouse w
    ON i.warehouse_id = w.warehouse_id

JOIN ProductVariant pv
    ON i.variant_id = pv.variant_id

GROUP BY
    w.warehouse_id,
    w.name

ORDER BY inventory_value DESC;


-- =========================================================
-- 18. LOW STOCK / REORDER REPORT
-- Business Question:
-- Which variants need restocking?
-- =========================================================

SELECT
    p.name AS product_name,
    pv.sku,
    w.name AS warehouse_name,
    i.quantity_on_hand,
    i.quantity_reserved,
    i.reorder_level,
    i.quantity_on_hand - i.quantity_reserved AS available_stock
FROM Inventory i
JOIN ProductVariant pv
    ON i.variant_id = pv.variant_id
JOIN Product p
    ON pv.product_id = p.product_id
JOIN Warehouse w
    ON i.warehouse_id = w.warehouse_id
WHERE
    (i.quantity_on_hand - i.quantity_reserved)
    <= i.reorder_level
ORDER BY available_stock ASC;


-- =========================================================
-- 19. STOCK UTILIZATION BY WAREHOUSE
-- =========================================================

SELECT
    w.name AS warehouse_name,

    SUM(i.quantity_on_hand) AS total_stock,

    SUM(i.quantity_reserved) AS reserved_stock,

    ROUND(
        100.0 * SUM(i.quantity_reserved) /
        NULLIF(SUM(i.quantity_on_hand), 0),
        2
    ) AS reservation_percentage

FROM Inventory i
JOIN Warehouse w
    ON i.warehouse_id = w.warehouse_id

GROUP BY
    w.warehouse_id,
    w.name

ORDER BY reservation_percentage DESC;


-- =========================================================
-- 20. SUPPLIER SPENDING
-- Business Question:
-- Which suppliers receive the most purchasing spend?
-- =========================================================

SELECT
    s.supplier_id,
    s.name AS supplier_name,
    COUNT(po.purchase_order_id) AS purchase_orders,
    SUM(po.total_amount) AS total_spent
FROM Supplier s
JOIN PurchaseOrder po
    ON s.supplier_id = po.supplier_id
GROUP BY
    s.supplier_id,
    s.name
ORDER BY total_spent DESC;


-- =========================================================
-- 21. AVERAGE PURCHASE ORDER VALUE BY SUPPLIER
-- =========================================================

SELECT
    s.supplier_id,
    s.name AS supplier_name,

    COUNT(po.purchase_order_id) AS purchase_orders,

    ROUND(
        AVG(po.total_amount),
        2
    ) AS average_purchase_value

FROM Supplier s

JOIN PurchaseOrder po
    ON s.supplier_id = po.supplier_id

GROUP BY
    s.supplier_id,
    s.name

ORDER BY average_purchase_value DESC;


-- =========================================================
-- 22. PAYMENT METHOD PERFORMANCE
-- Business Question:
-- Which payment methods handle the most successful value?
-- =========================================================

SELECT
    pm.payment_method_id,
    pm.name AS payment_method,

    COUNT(p.payment_id) AS successful_payments,

    SUM(p.amount) AS successful_payment_value

FROM Payment p

JOIN PaymentMethod pm
    ON p.payment_method_id = pm.payment_method_id

WHERE p.status = 'PAID'

GROUP BY
    pm.payment_method_id,
    pm.name

ORDER BY successful_payment_value DESC;


-- =========================================================
-- 23. PAYMENT SUCCESS RATE
-- =========================================================

SELECT
    pm.name AS payment_method,

    COUNT(p.payment_id) AS total_attempts,

    SUM(
        CASE
            WHEN p.status = 'PAID' THEN 1
            ELSE 0
        END
    ) AS successful_payments,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN p.status = 'PAID' THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(COUNT(p.payment_id), 0),
        2
    ) AS success_rate_percentage

FROM PaymentMethod pm

LEFT JOIN Payment p
    ON pm.payment_method_id = p.payment_method_id

GROUP BY
    pm.payment_method_id,
    pm.name

ORDER BY success_rate_percentage DESC;


-- =========================================================
-- 24. SHIPMENT PERFORMANCE BY CARRIER
-- Business Question:
-- Which delivery company completes the most shipments?
-- =========================================================

SELECT
    carrier,
    COUNT(*) AS total_shipments,

    SUM(
        CASE
            WHEN status = 'DELIVERED' THEN 1
            ELSE 0
        END
    ) AS delivered_shipments,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN status = 'DELIVERED' THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS delivery_success_rate

FROM Shipment

WHERE carrier IS NOT NULL

GROUP BY carrier

ORDER BY delivery_success_rate DESC;


-- =========================================================
-- 25. AVERAGE DELIVERY TIME BY CARRIER
-- =========================================================

SELECT
    carrier,

    COUNT(*) AS delivered_shipments,

    ROUND(
        AVG(
            TIMESTAMPDIFF(
                HOUR,
                shipped_at,
                delivered_at
            )
        ),
        2
    ) AS average_delivery_hours

FROM Shipment

WHERE shipped_at IS NOT NULL
  AND delivered_at IS NOT NULL

GROUP BY carrier

ORDER BY average_delivery_hours ASC;


-- =========================================================
-- 26. RETURN RATE
-- Business Question:
-- What percentage of orders have a return?
-- =========================================================

SELECT
    COUNT(DISTINCT pr.order_id) AS returned_orders,

    COUNT(DISTINCT so.order_id) AS total_orders,

    ROUND(
        100.0 *
        COUNT(DISTINCT pr.order_id)
        /
        NULLIF(COUNT(DISTINCT so.order_id), 0),
        2
    ) AS return_rate_percentage

FROM SalesOrder so

LEFT JOIN ProductReturn pr
    ON so.order_id = pr.order_id;


-- =========================================================
-- 27. MOST RETURNED PRODUCTS
-- =========================================================

SELECT
    p.product_id,
    p.name AS product_name,
    SUM(ri.quantity) AS returned_quantity
FROM ReturnItem ri
JOIN OrderItem oi
    ON ri.order_item_id = oi.order_item_id
JOIN ProductVariant pv
    ON oi.variant_id = pv.variant_id
JOIN Product p
    ON pv.product_id = p.product_id
GROUP BY
    p.product_id,
    p.name
ORDER BY returned_quantity DESC;


-- =========================================================
-- 28. TOTAL REFUND VALUE
-- =========================================================

SELECT
    COUNT(*) AS completed_refunds,
    SUM(amount) AS total_refunded_amount
FROM Refund
WHERE status = 'COMPLETED';


-- =========================================================
-- 29. PRODUCT REVIEW PERFORMANCE
-- Business Question:
-- Which products are rated highest?
-- =========================================================

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
    p.name

ORDER BY
    average_rating DESC,
    review_count DESC;


-- =========================================================
-- 30. VERIFIED REVIEW RATE
-- =========================================================

SELECT
    COUNT(*) AS total_published_reviews,

    SUM(
        CASE
            WHEN verified_purchase = TRUE THEN 1
            ELSE 0
        END
    ) AS verified_reviews,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN verified_purchase = TRUE THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(COUNT(*), 0),
        2
    ) AS verified_review_percentage

FROM ProductReview

WHERE status = 'PUBLISHED';


-- =========================================================
-- 31. MONTHLY SALES PERFORMANCE
-- =========================================================

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,

    COUNT(*) AS total_orders,

    SUM(total_amount) AS revenue,

    ROUND(
        AVG(total_amount),
        2
    ) AS average_order_value

FROM SalesOrder

WHERE status <> 'CANCELLED'

GROUP BY DATE_FORMAT(order_date, '%Y-%m')

ORDER BY sales_month;


-- =========================================================
-- 32. MONTH-OVER-MONTH REVENUE GROWTH
-- =========================================================

WITH MonthlyRevenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(total_amount) AS revenue
    FROM SalesOrder
    WHERE status <> 'CANCELLED'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),

RevenueComparison AS (
    SELECT
        sales_month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue

    FROM MonthlyRevenue
)

SELECT
    sales_month,
    revenue,
    previous_month_revenue,

    revenue - previous_month_revenue AS revenue_change,

    ROUND(
        (
            revenue - previous_month_revenue
        )
        /
        NULLIF(previous_month_revenue, 0)
        * 100,
        2
    ) AS growth_percentage

FROM RevenueComparison

ORDER BY sales_month;


-- =========================================================
-- 33. CUMULATIVE REVENUE
-- =========================================================

WITH MonthlyRevenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(total_amount) AS revenue
    FROM SalesOrder
    WHERE status <> 'CANCELLED'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)

SELECT
    sales_month,
    revenue,

    SUM(revenue) OVER (
        ORDER BY sales_month
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS cumulative_revenue

FROM MonthlyRevenue

ORDER BY sales_month;


-- =========================================================
-- 34. CUSTOMER SPENDING SEGMENTATION
-- Business Question:
-- Classify customers by spending level.
-- =========================================================

WITH CustomerSpending AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COALESCE(SUM(so.total_amount), 0) AS total_spent

    FROM Customer c

    LEFT JOIN SalesOrder so
        ON c.customer_id = so.customer_id
       AND so.status <> 'CANCELLED'

    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)

SELECT
    customer_id,
    customer_name,
    total_spent,

    CASE
        WHEN total_spent >= 400000 THEN 'HIGH VALUE'
        WHEN total_spent >= 100000 THEN 'MEDIUM VALUE'
        ELSE 'LOW VALUE'
    END AS customer_segment

FROM CustomerSpending

ORDER BY total_spent DESC;


-- =========================================================
-- 35. SALES PARETO / REVENUE CONTRIBUTION
-- Business Question:
-- Which products contribute most of company revenue?
-- =========================================================

WITH ProductRevenue AS (
    SELECT
        p.product_id,
        p.name AS product_name,
        SUM(oi.line_total) AS revenue

    FROM OrderItem oi

    JOIN ProductVariant pv
        ON oi.variant_id = pv.variant_id

    JOIN Product p
        ON pv.product_id = p.product_id

    GROUP BY
        p.product_id,
        p.name
),

RevenueContribution AS (
    SELECT
        product_id,
        product_name,
        revenue,

        SUM(revenue) OVER () AS total_revenue,

        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_product_revenue

    FROM ProductRevenue
)

SELECT
    product_id,
    product_name,
    revenue,

    ROUND(
        100.0 * revenue /
        NULLIF(total_revenue, 0),
        2
    ) AS revenue_percentage,

    ROUND(
        100.0 * cumulative_product_revenue /
        NULLIF(total_revenue, 0),
        2
    ) AS cumulative_revenue_percentage

FROM RevenueContribution

ORDER BY revenue DESC;


-- =========================================================
-- 36. COMPLETE MANAGEMENT KPI SUMMARY
-- =========================================================

SELECT
    (SELECT COUNT(*)
     FROM Customer
     WHERE status = 'ACTIVE')
        AS active_customers,

    (SELECT COUNT(*)
     FROM Product
     WHERE status = 'ACTIVE')
        AS active_products,

    (SELECT COUNT(*)
     FROM SalesOrder)
        AS total_orders,

    (SELECT COALESCE(SUM(total_amount), 0)
     FROM SalesOrder
     WHERE status <> 'CANCELLED')
        AS total_revenue,

    (SELECT COALESCE(AVG(total_amount), 0)
     FROM SalesOrder
     WHERE status <> 'CANCELLED')
        AS average_order_value,

    (SELECT COUNT(*)
     FROM Payment
     WHERE status = 'PENDING')
        AS pending_payments,

    (SELECT COUNT(*)
     FROM Shipment
     WHERE status IN ('PENDING', 'PACKED', 'SHIPPED', 'IN_TRANSIT'))
        AS open_shipments,

    (SELECT COUNT(*)
     FROM ProductReturn
     WHERE status IN ('REQUESTED', 'APPROVED', 'RECEIVED'))
        AS open_returns;