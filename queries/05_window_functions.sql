USE retail_management;

-- =========================================================
-- 05. WINDOW FUNCTIONS
-- Retail & E-Commerce Management Database
-- =========================================================


-- =========================================================
-- 01. ROW_NUMBER - NUMBER ALL ORDERS
-- =========================================================

SELECT
    order_id,
    order_number,
    order_date,
    total_amount,

    ROW_NUMBER() OVER (
        ORDER BY order_date
    ) AS order_sequence

FROM SalesOrder
ORDER BY order_date;


-- =========================================================
-- 02. ROW_NUMBER - CUSTOMER ORDER SEQUENCE
-- =========================================================

SELECT
    customer_id,
    order_number,
    order_date,
    total_amount,

    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS customer_order_number

FROM SalesOrder
ORDER BY customer_id, order_date;


-- =========================================================
-- 03. RANK - ORDERS BY VALUE
-- =========================================================

SELECT
    order_number,
    total_amount,

    RANK() OVER (
        ORDER BY total_amount DESC
    ) AS order_value_rank

FROM SalesOrder
ORDER BY order_value_rank;


-- =========================================================
-- 04. DENSE_RANK - ORDERS BY VALUE
-- =========================================================

SELECT
    order_number,
    total_amount,

    DENSE_RANK() OVER (
        ORDER BY total_amount DESC
    ) AS order_value_dense_rank

FROM SalesOrder
ORDER BY order_value_dense_rank;


-- =========================================================
-- 05. ROW_NUMBER vs RANK vs DENSE_RANK
-- =========================================================

SELECT
    order_number,
    total_amount,

    ROW_NUMBER() OVER (
        ORDER BY total_amount DESC
    ) AS row_num,

    RANK() OVER (
        ORDER BY total_amount DESC
    ) AS normal_rank,

    DENSE_RANK() OVER (
        ORDER BY total_amount DESC
    ) AS dense_ranks

FROM SalesOrder
ORDER BY total_amount DESC;


-- =========================================================
-- 06. RANK PRODUCT VARIANTS BY PRICE
-- =========================================================

SELECT
    product_id,
    sku,
    price,

    RANK() OVER (
        PARTITION BY product_id
        ORDER BY price DESC
    ) AS price_rank_within_product

FROM ProductVariant
ORDER BY product_id, price_rank_within_product;


-- =========================================================
-- 07. MOST EXPENSIVE VARIANT OF EACH PRODUCT
-- ROW_NUMBER + CTE
-- =========================================================

WITH RankedVariants AS (
    SELECT
        pv.variant_id,
        pv.product_id,
        pv.sku,
        pv.color,
        pv.size,
        pv.price,

        ROW_NUMBER() OVER (
            PARTITION BY pv.product_id
            ORDER BY pv.price DESC
        ) AS rn

    FROM ProductVariant pv
)

SELECT
    p.name AS product_name,
    rv.sku,
    rv.color,
    rv.size,
    rv.price

FROM RankedVariants rv

JOIN Product p
    ON rv.product_id = p.product_id

WHERE rv.rn = 1

ORDER BY rv.price DESC;


-- =========================================================
-- 08. CUSTOMER SPENDING + RUNNING TOTAL
-- =========================================================

SELECT
    customer_id,
    order_number,
    order_date,
    total_amount,

    SUM(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_customer_spending

FROM SalesOrder
ORDER BY customer_id, order_date;


-- =========================================================
-- 09. COMPANY-WIDE RUNNING REVENUE
-- =========================================================

SELECT
    order_number,
    order_date,
    total_amount,

    SUM(total_amount) OVER (
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_revenue

FROM SalesOrder
ORDER BY order_date, order_id;


-- =========================================================
-- 10. TOTAL CUSTOMER SPENDING WITHOUT GROUP BY
-- =========================================================

SELECT
    order_id,
    customer_id,
    order_number,
    total_amount,

    SUM(total_amount) OVER (
        PARTITION BY customer_id
    ) AS customer_total_spending

FROM SalesOrder
ORDER BY customer_id, order_date;


-- =========================================================
-- 11. AVERAGE ORDER VALUE PER CUSTOMER
-- =========================================================

SELECT
    customer_id,
    order_number,
    total_amount,

    AVG(total_amount) OVER (
        PARTITION BY customer_id
    ) AS customer_average_order_value

FROM SalesOrder
ORDER BY customer_id, order_date;


-- =========================================================
-- 12. COMPARE ORDER TO CUSTOMER AVERAGE
-- =========================================================

SELECT
    customer_id,
    order_number,
    total_amount,

    AVG(total_amount) OVER (
        PARTITION BY customer_id
    ) AS customer_average,

    total_amount -
    AVG(total_amount) OVER (
        PARTITION BY customer_id
    ) AS difference_from_customer_average

FROM SalesOrder
ORDER BY customer_id, order_date;


-- =========================================================
-- 13. COUNT ORDERS PER CUSTOMER WITHOUT GROUP BY
-- =========================================================

SELECT
    order_id,
    customer_id,
    order_number,
    order_date,

    COUNT(*) OVER (
        PARTITION BY customer_id
    ) AS customer_order_count

FROM SalesOrder
ORDER BY customer_id, order_date;


-- =========================================================
-- 14. LAG - PREVIOUS CUSTOMER ORDER
-- =========================================================

SELECT
    customer_id,
    order_number,
    order_date,
    total_amount,

    LAG(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS previous_order_amount

FROM SalesOrder
ORDER BY customer_id, order_date;


-- =========================================================
-- 15. ORDER VALUE CHANGE FROM PREVIOUS ORDER
-- =========================================================

WITH OrderHistory AS (
    SELECT
        customer_id,
        order_number,
        order_date,
        total_amount,

        LAG(total_amount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS previous_order_amount

    FROM SalesOrder
)

SELECT
    customer_id,
    order_number,
    order_date,
    total_amount,
    previous_order_amount,

    total_amount - previous_order_amount
        AS amount_change

FROM OrderHistory
ORDER BY customer_id, order_date;


-- =========================================================
-- 16. LEAD - NEXT CUSTOMER ORDER
-- =========================================================

SELECT
    customer_id,
    order_number,
    order_date,

    LEAD(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS next_order_date

FROM SalesOrder
ORDER BY customer_id, order_date;


-- =========================================================
-- 17. DAYS UNTIL NEXT ORDER
-- =========================================================

WITH CustomerOrders AS (
    SELECT
        customer_id,
        order_number,
        order_date,

        LEAD(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS next_order_date

    FROM SalesOrder
)

SELECT
    customer_id,
    order_number,
    order_date,
    next_order_date,

    TIMESTAMPDIFF(
        DAY,
        order_date,
        next_order_date
    ) AS days_until_next_order

FROM CustomerOrders
ORDER BY customer_id, order_date;


-- =========================================================
-- 18. FIRST ORDER PER CUSTOMER
-- =========================================================

WITH RankedOrders AS (
    SELECT
        so.*,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS rn

    FROM SalesOrder so
)

SELECT
    order_id,
    customer_id,
    order_number,
    order_date,
    total_amount

FROM RankedOrders
WHERE rn = 1
ORDER BY customer_id;


-- =========================================================
-- 19. LATEST ORDER PER CUSTOMER
-- =========================================================

WITH RankedOrders AS (
    SELECT
        so.*,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC
        ) AS rn

    FROM SalesOrder so
)

SELECT
    order_id,
    customer_id,
    order_number,
    order_date,
    status,
    total_amount

FROM RankedOrders
WHERE rn = 1
ORDER BY customer_id;


-- =========================================================
-- 20. TOP PRODUCTS BY REVENUE
-- =========================================================

WITH ProductRevenue AS (
    SELECT
        pv.product_id,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.line_total) AS revenue

    FROM OrderItem oi

    JOIN ProductVariant pv
        ON oi.variant_id = pv.variant_id

    GROUP BY pv.product_id
),

RankedProducts AS (
    SELECT
        product_id,
        units_sold,
        revenue,

        RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank

    FROM ProductRevenue
)

SELECT
    rp.revenue_rank,
    p.product_id,
    p.name AS product_name,
    rp.units_sold,
    rp.revenue

FROM RankedProducts rp

JOIN Product p
    ON rp.product_id = p.product_id

ORDER BY rp.revenue_rank;


-- =========================================================
-- 21. PRODUCT REVENUE SHARE
-- =========================================================

WITH ProductRevenue AS (
    SELECT
        pv.product_id,
        SUM(oi.line_total) AS revenue

    FROM OrderItem oi

    JOIN ProductVariant pv
        ON oi.variant_id = pv.variant_id

    GROUP BY pv.product_id
)

SELECT
    p.name AS product_name,
    pr.revenue,

    SUM(pr.revenue) OVER () AS overall_revenue,

    ROUND(
        100 * pr.revenue /
        SUM(pr.revenue) OVER (),
        2
    ) AS revenue_percentage

FROM ProductRevenue pr

JOIN Product p
    ON pr.product_id = p.product_id

ORDER BY revenue_percentage DESC;


-- =========================================================
-- 22. RANK PRODUCTS WITHIN BRAND BY PRICE
-- =========================================================

SELECT
    b.name AS brand_name,
    p.name AS product_name,
    p.base_price,

    DENSE_RANK() OVER (
        PARTITION BY p.brand_id
        ORDER BY p.base_price DESC
    ) AS brand_price_rank

FROM Product p

JOIN Brand b
    ON p.brand_id = b.brand_id

ORDER BY b.name, brand_price_rank;


-- =========================================================
-- 23. INVENTORY RANKING BY WAREHOUSE
-- =========================================================

SELECT
    w.name AS warehouse_name,
    pv.sku,
    i.quantity_on_hand,

    RANK() OVER (
        PARTITION BY i.warehouse_id
        ORDER BY i.quantity_on_hand DESC
    ) AS stock_rank

FROM Inventory i

JOIN Warehouse w
    ON i.warehouse_id = w.warehouse_id

JOIN ProductVariant pv
    ON i.variant_id = pv.variant_id

ORDER BY w.name, stock_rank;


-- =========================================================
-- 24. INVENTORY TOTAL BY WAREHOUSE WITHOUT GROUP BY
-- =========================================================

SELECT
    inventory_id,
    warehouse_id,
    variant_id,
    quantity_on_hand,

    SUM(quantity_on_hand) OVER (
        PARTITION BY warehouse_id
    ) AS warehouse_total_inventory

FROM Inventory
ORDER BY warehouse_id;


-- =========================================================
-- 25. PRODUCT STOCK SHARE WITHIN WAREHOUSE
-- =========================================================

SELECT
    i.inventory_id,
    w.name AS warehouse_name,
    pv.sku,
    i.quantity_on_hand,

    SUM(i.quantity_on_hand) OVER (
        PARTITION BY i.warehouse_id
    ) AS warehouse_stock,

    ROUND(
        100 * i.quantity_on_hand /
        SUM(i.quantity_on_hand) OVER (
            PARTITION BY i.warehouse_id
        ),
        2
    ) AS warehouse_stock_percentage

FROM Inventory i

JOIN Warehouse w
    ON i.warehouse_id = w.warehouse_id

JOIN ProductVariant pv
    ON i.variant_id = pv.variant_id

ORDER BY i.warehouse_id,
         warehouse_stock_percentage DESC;


-- =========================================================
-- 26. STOCK MOVEMENT SEQUENCE
-- =========================================================

SELECT
    inventory_id,
    movement_id,
    movement_type,
    quantity,
    created_at,

    ROW_NUMBER() OVER (
        PARTITION BY inventory_id
        ORDER BY created_at
    ) AS movement_sequence

FROM StockMovement
ORDER BY inventory_id, created_at;


-- =========================================================
-- 27. PREVIOUS STOCK MOVEMENT
-- =========================================================

SELECT
    inventory_id,
    movement_type,
    quantity,
    created_at,

    LAG(movement_type) OVER (
        PARTITION BY inventory_id
        ORDER BY created_at
    ) AS previous_movement_type,

    LAG(quantity) OVER (
        PARTITION BY inventory_id
        ORDER BY created_at
    ) AS previous_quantity

FROM StockMovement
ORDER BY inventory_id, created_at;


-- =========================================================
-- 28. PURCHASE ORDER RANKING BY SUPPLIER
-- =========================================================

SELECT
    supplier_id,
    purchase_order_id,
    order_date,
    total_amount,

    RANK() OVER (
        PARTITION BY supplier_id
        ORDER BY total_amount DESC
    ) AS supplier_purchase_rank

FROM PurchaseOrder
ORDER BY supplier_id, supplier_purchase_rank;


-- =========================================================
-- 29. PAYMENT TOTAL BY METHOD
-- =========================================================

SELECT
    p.payment_id,
    pm.name AS payment_method,
    p.amount,
    p.status,

    SUM(p.amount) OVER (
        PARTITION BY p.payment_method_id
    ) AS method_total_amount

FROM Payment p

JOIN PaymentMethod pm
    ON p.payment_method_id = pm.payment_method_id

ORDER BY pm.name;


-- =========================================================
-- 30. REVIEW RANKING WITHIN PRODUCT
-- =========================================================

SELECT
    product_id,
    review_id,
    rating,
    title,

    DENSE_RANK() OVER (
        PARTITION BY product_id
        ORDER BY rating DESC
    ) AS rating_rank

FROM ProductReview
WHERE status = 'PUBLISHED'
ORDER BY product_id, rating_rank;


-- =========================================================
-- 31. AVERAGE RATING BY PRODUCT WITHOUT GROUP BY
-- =========================================================

SELECT
    review_id,
    product_id,
    rating,

    AVG(rating) OVER (
        PARTITION BY product_id
    ) AS product_average_rating

FROM ProductReview
WHERE status = 'PUBLISHED'
ORDER BY product_id;


-- =========================================================
-- 32. MONTHLY SALES
-- Prepare data before using month-to-month windows
-- =========================================================

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(total_amount) AS revenue

    FROM SalesOrder

    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)

SELECT
    sales_month,
    revenue

FROM MonthlySales
ORDER BY sales_month;


-- =========================================================
-- 33. MONTH-OVER-MONTH REVENUE CHANGE
-- =========================================================

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(total_amount) AS revenue

    FROM SalesOrder

    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),

SalesComparison AS (
    SELECT
        sales_month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue

    FROM MonthlySales
)

SELECT
    sales_month,
    revenue,
    previous_month_revenue,

    revenue - previous_month_revenue
        AS revenue_change

FROM SalesComparison
ORDER BY sales_month;


-- =========================================================
-- 34. MONTH-OVER-MONTH GROWTH PERCENTAGE
-- =========================================================

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(total_amount) AS revenue

    FROM SalesOrder

    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),

SalesComparison AS (
    SELECT
        sales_month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue

    FROM MonthlySales
)

SELECT
    sales_month,
    revenue,
    previous_month_revenue,

    ROUND(
        (
            revenue - previous_month_revenue
        ) / NULLIF(previous_month_revenue, 0)
        * 100,
        2
    ) AS growth_percentage

FROM SalesComparison
ORDER BY sales_month;


-- =========================================================
-- 35. RUNNING MONTHLY REVENUE
-- =========================================================

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(total_amount) AS revenue

    FROM SalesOrder

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

FROM MonthlySales
ORDER BY sales_month;