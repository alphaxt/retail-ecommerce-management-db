
CREATE TABLE Customer (
    customer_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30),
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Address (
    address_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    recipient_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE CustomerAddress (
    customer_address_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    address_id BIGINT UNSIGNED NOT NULL,
    address_type VARCHAR(30),
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_customer_address
        UNIQUE (customer_id, address_id),

    CONSTRAINT fk_customeraddress_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_customeraddress_address
        FOREIGN KEY (address_id)
        REFERENCES Address(address_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE Brand (
    brand_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(180) NOT NULL,
    description TEXT,
    logo_url VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_brand_name UNIQUE (name),
    CONSTRAINT uq_brand_slug UNIQUE (slug)
);

CREATE TABLE Category (
    category_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(180) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_category_name UNIQUE (name),
    CONSTRAINT uq_category_slug UNIQUE (slug)
);

CREATE TABLE Product (
    product_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    brand_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(220) NOT NULL,
    description TEXT,
    base_price DECIMAL(12,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_product_slug UNIQUE (slug),

    CONSTRAINT chk_product_base_price
        CHECK (base_price >= 0),

    CONSTRAINT fk_product_brand
        FOREIGN KEY (brand_id)
        REFERENCES Brand(brand_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


CREATE TABLE ProductCategory (
    product_category_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_product_category
        UNIQUE (product_id, category_id),

    CONSTRAINT fk_productcategory_product
        FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_productcategory_category
        FOREIGN KEY (category_id)
        REFERENCES Category(category_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);



CREATE TABLE ProductVariant (
    variant_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    sku VARCHAR(100) NOT NULL,
    color VARCHAR(80),
    size VARCHAR(50),
    price DECIMAL(12,2) NOT NULL,
    cost_price DECIMAL(12,2),
    weight DECIMAL(10,3),
    barcode VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_productvariant_sku UNIQUE (sku),
    CONSTRAINT uq_productvariant_barcode UNIQUE (barcode),

    CONSTRAINT chk_variant_price
        CHECK (price >= 0),

    CONSTRAINT chk_variant_cost_price
        CHECK (cost_price IS NULL OR cost_price >= 0),

    CONSTRAINT chk_variant_weight
        CHECK (weight IS NULL OR weight >= 0),

    CONSTRAINT fk_productvariant_product
        FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


CREATE TABLE ProductImage (
    image_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    display_order INT UNSIGNED NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_productimage_display_order
        CHECK (display_order >= 0),

    CONSTRAINT fk_productimage_product
        FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

SHOW TABLES;


CREATE TABLE Warehouse (
    warehouse_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    code VARCHAR(50) NOT NULL,
    phone VARCHAR(30),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_warehouse_code UNIQUE (code)
);



CREATE TABLE Inventory (
    inventory_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    variant_id BIGINT UNSIGNED NOT NULL,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    quantity_on_hand INT UNSIGNED NOT NULL DEFAULT 0,
    quantity_reserved INT UNSIGNED NOT NULL DEFAULT 0,
    reorder_level INT UNSIGNED NOT NULL DEFAULT 0,
    last_updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_inventory_variant_warehouse
        UNIQUE (variant_id, warehouse_id),

    CONSTRAINT chk_inventory_reserved
        CHECK (quantity_reserved <= quantity_on_hand),

    CONSTRAINT fk_inventory_variant
        FOREIGN KEY (variant_id)
        REFERENCES ProductVariant(variant_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_inventory_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES Warehouse(warehouse_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


CREATE TABLE StockMovement (
    movement_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    inventory_id BIGINT UNSIGNED NOT NULL,
    movement_type VARCHAR(30) NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    reference_type VARCHAR(50),
    reference_id BIGINT UNSIGNED,
    notes VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_stockmovement_quantity
        CHECK (quantity > 0),

    CONSTRAINT fk_stockmovement_inventory
        FOREIGN KEY (inventory_id)
        REFERENCES Inventory(inventory_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);



CREATE TABLE Supplier (
    supplier_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(180) NOT NULL,
    contact_name VARCHAR(150),
    email VARCHAR(255),
    phone VARCHAR(30),
    tax_number VARCHAR(100),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_supplier_tax_number UNIQUE (tax_number)
);



CREATE TABLE PurchaseOrder (
    purchase_order_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supplier_id BIGINT UNSIGNED NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expected_date DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    shipping_cost DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_purchaseorder_subtotal
        CHECK (subtotal >= 0),

    CONSTRAINT chk_purchaseorder_tax
        CHECK (tax_amount >= 0),

    CONSTRAINT chk_purchaseorder_shipping
        CHECK (shipping_cost >= 0),

    CONSTRAINT chk_purchaseorder_total
        CHECK (total_amount >= 0),

    CONSTRAINT fk_purchaseorder_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES Supplier(supplier_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);



CREATE TABLE PurchaseOrderItem (
    purchase_order_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id BIGINT UNSIGNED NOT NULL,
    variant_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_cost DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    line_total DECIMAL(12,2) NOT NULL,

    CONSTRAINT uq_purchaseorder_variant
        UNIQUE (purchase_order_id, variant_id),

    CONSTRAINT chk_purchaseitem_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_purchaseitem_unit_cost
        CHECK (unit_cost >= 0),

    CONSTRAINT chk_purchaseitem_tax
        CHECK (tax_amount >= 0),

    CONSTRAINT chk_purchaseitem_total
        CHECK (line_total >= 0),

    CONSTRAINT fk_purchaseitem_order
        FOREIGN KEY (purchase_order_id)
        REFERENCES PurchaseOrder(purchase_order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_purchaseitem_variant
        FOREIGN KEY (variant_id)
        REFERENCES ProductVariant(variant_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


show tables;


DESCRIBE Inventory;
DESCRIBE PurchaseOrderItem;


CREATE TABLE Cart (
    cart_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    expires_at DATETIME,

    CONSTRAINT fk_cart_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);



CREATE TABLE CartItem (
    cart_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    cart_id BIGINT UNSIGNED NOT NULL,
    variant_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 1,
    unit_price DECIMAL(12,2) NOT NULL,
    added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_cart_variant
        UNIQUE (cart_id, variant_id),

    CONSTRAINT chk_cartitem_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_cartitem_price
        CHECK (unit_price >= 0),

    CONSTRAINT fk_cartitem_cart
        FOREIGN KEY (cart_id)
        REFERENCES Cart(cart_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_cartitem_variant
        FOREIGN KEY (variant_id)
        REFERENCES ProductVariant(variant_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


CREATE TABLE Wishlist (
    wishlist_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL DEFAULT 'My Wishlist',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_wishlist_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);



CREATE TABLE WishlistItem (
    wishlist_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    wishlist_id BIGINT UNSIGNED NOT NULL,
    variant_id BIGINT UNSIGNED NOT NULL,
    added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_wishlist_variant
        UNIQUE (wishlist_id, variant_id),

    CONSTRAINT fk_wishlistitem_wishlist
        FOREIGN KEY (wishlist_id)
        REFERENCES Wishlist(wishlist_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_wishlistitem_variant
        FOREIGN KEY (variant_id)
        REFERENCES ProductVariant(variant_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


SHOW TABLES;


CREATE TABLE SalesOrder (
    order_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    order_number VARCHAR(50) NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    shipping_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    currency CHAR(3) NOT NULL DEFAULT 'PKR',
    notes VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_salesorder_number
        UNIQUE (order_number),

    CONSTRAINT chk_salesorder_subtotal
        CHECK (subtotal >= 0),

    CONSTRAINT chk_salesorder_discount
        CHECK (discount_amount >= 0),

    CONSTRAINT chk_salesorder_tax
        CHECK (tax_amount >= 0),

    CONSTRAINT chk_salesorder_shipping
        CHECK (shipping_amount >= 0),

    CONSTRAINT chk_salesorder_total
        CHECK (total_amount >= 0),

    CONSTRAINT fk_salesorder_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);



CREATE TABLE OrderItem (
    order_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    variant_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    line_total DECIMAL(12,2) NOT NULL,

    CONSTRAINT chk_orderitem_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_orderitem_price
        CHECK (unit_price >= 0),

    CONSTRAINT chk_orderitem_discount
        CHECK (discount_amount >= 0),

    CONSTRAINT chk_orderitem_tax
        CHECK (tax_amount >= 0),

    CONSTRAINT chk_orderitem_total
        CHECK (line_total >= 0),

    CONSTRAINT fk_orderitem_order
        FOREIGN KEY (order_id)
        REFERENCES SalesOrder(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_orderitem_variant
        FOREIGN KEY (variant_id)
        REFERENCES ProductVariant(variant_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);




CREATE TABLE PaymentMethod (
    payment_method_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    provider VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_paymentmethod_name
        UNIQUE (name)
);


CREATE TABLE Payment (
    payment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    payment_method_id BIGINT UNSIGNED NOT NULL,
    transaction_reference VARCHAR(150),
    amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    payment_date DATETIME,
    failure_reason VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_payment_transaction_reference
        UNIQUE (transaction_reference),

    CONSTRAINT chk_payment_amount
        CHECK (amount > 0),

    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES SalesOrder(order_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_payment_method
        FOREIGN KEY (payment_method_id)
        REFERENCES PaymentMethod(payment_method_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);



CREATE TABLE Shipment (
    shipment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    tracking_number VARCHAR(150),
    carrier VARCHAR(100),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    shipped_at DATETIME,
    estimated_delivery DATE,
    delivered_at DATETIME,
    shipping_cost DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_shipment_tracking
        UNIQUE (tracking_number),

    CONSTRAINT chk_shipment_cost
        CHECK (shipping_cost >= 0),

    CONSTRAINT fk_shipment_order
        FOREIGN KEY (order_id)
        REFERENCES SalesOrder(order_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);



CREATE TABLE ShipmentItem (
    shipment_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    shipment_id BIGINT UNSIGNED NOT NULL,
    order_item_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_shipment_orderitem
        UNIQUE (shipment_id, order_item_id),

    CONSTRAINT chk_shipmentitem_quantity
        CHECK (quantity > 0),

    CONSTRAINT fk_shipmentitem_shipment
        FOREIGN KEY (shipment_id)
        REFERENCES Shipment(shipment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_shipmentitem_orderitem
        FOREIGN KEY (order_item_id)
        REFERENCES OrderItem(order_item_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);



CREATE TABLE Promotion (
    promotion_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    discount_type VARCHAR(30) NOT NULL,
    discount_value DECIMAL(12,2) NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    minimum_order_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    maximum_discount DECIMAL(12,2),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_promotion_discount
        CHECK (discount_value >= 0),

    CONSTRAINT chk_promotion_minimum
        CHECK (minimum_order_amount >= 0),

    CONSTRAINT chk_promotion_maximum
        CHECK (maximum_discount IS NULL OR maximum_discount >= 0)
);



CREATE TABLE PromotionProduct (
    promotion_product_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    promotion_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_promotion_product
        UNIQUE (promotion_id, product_id),

    CONSTRAINT fk_promotionproduct_promotion
        FOREIGN KEY (promotion_id)
        REFERENCES Promotion(promotion_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_promotionproduct_product
        FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);



CREATE TABLE Coupon (
    coupon_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    promotion_id BIGINT UNSIGNED,
    code VARCHAR(80) NOT NULL,
    discount_type VARCHAR(30) NOT NULL,
    discount_value DECIMAL(12,2) NOT NULL,
    minimum_order_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    maximum_discount DECIMAL(12,2),
    usage_limit INT UNSIGNED,
    usage_count INT UNSIGNED NOT NULL DEFAULT 0,
    start_date DATETIME NOT NULL,
    expiry_date DATETIME NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_coupon_code
        UNIQUE (code),

    CONSTRAINT chk_coupon_discount
        CHECK (discount_value >= 0),

    CONSTRAINT chk_coupon_minimum
        CHECK (minimum_order_amount >= 0),

    CONSTRAINT chk_coupon_maximum
        CHECK (maximum_discount IS NULL OR maximum_discount >= 0),

    CONSTRAINT fk_coupon_promotion
        FOREIGN KEY (promotion_id)
        REFERENCES Promotion(promotion_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);




CREATE TABLE ProductReturn (
    return_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    return_number VARCHAR(50) NOT NULL,
    reason VARCHAR(500),
    status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED',
    requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_at DATETIME,
    received_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_productreturn_number
        UNIQUE (return_number),

    CONSTRAINT fk_productreturn_order
        FOREIGN KEY (order_id)
        REFERENCES SalesOrder(order_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);




CREATE TABLE ReturnItem (
    return_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    return_id BIGINT UNSIGNED NOT NULL,
    order_item_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    reason VARCHAR(500),
    item_condition VARCHAR(50),
    resolution VARCHAR(50),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_return_orderitem
        UNIQUE (return_id, order_item_id),

    CONSTRAINT chk_returnitem_quantity
        CHECK (quantity > 0),

    CONSTRAINT fk_returnitem_return
        FOREIGN KEY (return_id)
        REFERENCES ProductReturn(return_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_returnitem_orderitem
        FOREIGN KEY (order_item_id)
        REFERENCES OrderItem(order_item_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);



CREATE TABLE Refund (
    refund_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    return_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    refund_method VARCHAR(50),
    transaction_reference VARCHAR(150),
    processed_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_refund_transaction_reference
        UNIQUE (transaction_reference),

    CONSTRAINT chk_refund_amount
        CHECK (amount > 0),

    CONSTRAINT fk_refund_return
        FOREIGN KEY (return_id)
        REFERENCES ProductReturn(return_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);




CREATE TABLE ProductReview (
    review_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    rating TINYINT UNSIGNED NOT NULL,
    title VARCHAR(200),
    comment TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'PUBLISHED',
    verified_purchase BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_customer_product_review
        UNIQUE (customer_id, product_id),

    CONSTRAINT chk_productreview_rating
        CHECK (rating BETWEEN 1 AND 5),

    CONSTRAINT fk_productreview_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_productreview_product
        FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);



CREATE TABLE Role (
    role_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_role_name
        UNIQUE (name)
);




CREATE TABLE Employee (
    employee_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id BIGINT UNSIGNED NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    password_hash VARCHAR(255) NOT NULL,
    hire_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_employee_email
        UNIQUE (email),

    CONSTRAINT fk_employee_role
        FOREIGN KEY (role_id)
        REFERENCES Role(role_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);




CREATE TABLE AuditLog (
    audit_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT UNSIGNED,
    action VARCHAR(100) NOT NULL,
    entity_name VARCHAR(100) NOT NULL,
    entity_id BIGINT UNSIGNED,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_auditlog_employee
        FOREIGN KEY (employee_id)
        REFERENCES Employee(employee_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);


show tables;


DESCRIBE SalesOrder;
DESCRIBE OrderItem;
DESCRIBE Payment;
DESCRIBE ShipmentItem;
DESCRIBE Coupon;
DESCRIBE ProductReturn;
DESCRIBE ProductReview;
DESCRIBE AuditLog;


SELECT COUNT(*) AS total_tables
FROM information_schema.tables
WHERE table_schema = 'retail_management';


