USE retail_management;

CREATE INDEX idx_product_name
ON Product(name);

CREATE INDEX idx_productvariant_price
ON ProductVariant(price);

CREATE INDEX idx_inventory_stock_level
ON Inventory(quantity_on_hand);

CREATE INDEX idx_stockmovement_inventory_date
ON StockMovement(inventory_id, created_at);

CREATE INDEX idx_purchaseorder_supplier_date
ON PurchaseOrder(supplier_id, order_date);

CREATE INDEX idx_cart_customer_status
ON Cart(customer_id, status);

CREATE INDEX idx_salesorder_customer_date
ON SalesOrder(customer_id, order_date);

CREATE INDEX idx_salesorder_status_date
ON SalesOrder(status, order_date);

CREATE INDEX idx_payment_status_date
ON Payment(status, payment_date);

CREATE INDEX idx_shipment_status_date
ON Shipment(status, shipped_at);

CREATE INDEX idx_promotion_active_dates
ON Promotion(is_active, start_date, end_date);

CREATE INDEX idx_coupon_active_dates
ON Coupon(is_active, start_date, expiry_date);

CREATE INDEX idx_productreturn_status
ON ProductReturn(status);

CREATE INDEX idx_productreview_product_status
ON ProductReview(product_id, status);

CREATE INDEX idx_auditlog_entity
ON AuditLog(entity_name, entity_id);

CREATE INDEX idx_auditlog_employee_date
ON AuditLog(employee_id, created_at);