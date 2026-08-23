USE retail_management;

START TRANSACTION;


INSERT INTO Customer (
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    password_hash,
    date_of_birth,
    status
)
VALUES
(1, 'Ali', 'Khan', 'ali.khan@example.com', '+92-300-1111111',
 '$2y$10$samplehash001', '1999-04-12', 'ACTIVE'),

(2, 'Sara', 'Ahmed', 'sara.ahmed@example.com', '+92-301-2222222',
 '$2y$10$samplehash002', '2001-08-20', 'ACTIVE'),

(3, 'Hamza', 'Malik', 'hamza.malik@example.com', '+92-302-3333333',
 '$2y$10$samplehash003', '1998-11-05', 'ACTIVE'),

(4, 'Ayesha', 'Raza', 'ayesha.raza@example.com', '+92-303-4444444',
 '$2y$10$samplehash004', '2000-01-17', 'ACTIVE'),

(5, 'Usman', 'Sheikh', 'usman.sheikh@example.com', '+92-304-5555555',
 '$2y$10$samplehash005', '1997-07-24', 'INACTIVE');
 
 
 INSERT INTO Address (
    address_id,
    recipient_name,
    phone,
    address_line1,
    address_line2,
    city,
    state,
    postal_code,
    country
)
VALUES
(1, 'Ali Khan', '+92-300-1111111',
 '12 Model Town', 'Block C',
 'Lahore', 'Punjab', '54700', 'Pakistan'),

(2, 'Sara Ahmed', '+92-301-2222222',
 '45 Gulberg III', NULL,
 'Lahore', 'Punjab', '54660', 'Pakistan'),

(3, 'Hamza Malik', '+92-302-3333333',
 '22 Clifton', 'Block 5',
 'Karachi', 'Sindh', '75600', 'Pakistan'),

(4, 'Ayesha Raza', '+92-303-4444444',
 '17 F-10 Markaz', NULL,
 'Islamabad', 'ICT', '44000', 'Pakistan'),

(5, 'Usman Sheikh', '+92-304-5555555',
 '8 Satellite Town', NULL,
 'Rawalpindi', 'Punjab', '46300', 'Pakistan');
 
 
 INSERT INTO CustomerAddress (
    customer_address_id,
    customer_id,
    address_id,
    address_type,
    is_default
)
VALUES
(1, 1, 1, 'HOME', TRUE),
(2, 2, 2, 'HOME', TRUE),
(3, 3, 3, 'HOME', TRUE),
(4, 4, 4, 'HOME', TRUE),
(5, 5, 5, 'HOME', TRUE);


INSERT INTO Brand (
    brand_id,
    name,
    slug,
    description,
    logo_url,
    is_active
)
VALUES
(1, 'Apple', 'apple',
 'Consumer electronics and technology products.',
 'https://example.com/images/apple.png', TRUE),

(2, 'Samsung', 'samsung',
 'Electronics and consumer technology products.',
 'https://example.com/images/samsung.png', TRUE),

(3, 'Lenovo', 'lenovo',
 'Computers, laptops and technology products.',
 'https://example.com/images/lenovo.png', TRUE),

(4, 'Nike', 'nike',
 'Sportswear, footwear and accessories.',
 'https://example.com/images/nike.png', TRUE),

(5, 'Logitech', 'logitech',
 'Computer peripherals and accessories.',
 'https://example.com/images/logitech.png', TRUE);
 
 
 INSERT INTO Category (
    category_id,
    name,
    slug,
    description,
    is_active
)
VALUES
(1, 'Smartphones', 'smartphones',
 'Mobile smartphones and related devices.', TRUE),

(2, 'Laptops', 'laptops',
 'Portable personal computers.', TRUE),

(3, 'Accessories', 'accessories',
 'Technology and computer accessories.', TRUE),

(4, 'Footwear', 'footwear',
 'Shoes and athletic footwear.', TRUE),

(5, 'Wearables', 'wearables',
 'Smart watches and wearable technology.', TRUE),

(6, 'Computer Peripherals', 'computer-peripherals',
 'Keyboards, mice and other peripherals.', TRUE);
 
 
 
 INSERT INTO Product (
    product_id,
    brand_id,
    name,
    slug,
    description,
    base_price,
    status
)
VALUES
(1, 1, 'iPhone 16',
 'iphone-16',
 'Apple smartphone with modern camera and performance features.',
 250000.00, 'ACTIVE'),

(2, 2, 'Galaxy S25',
 'galaxy-s25',
 'Samsung flagship smartphone.',
 225000.00, 'ACTIVE'),

(3, 3, 'ThinkPad T14',
 'thinkpad-t14',
 'Business-class Lenovo laptop.',
 185000.00, 'ACTIVE'),

(4, 4, 'Nike Air Max',
 'nike-air-max',
 'Athletic lifestyle footwear.',
 32000.00, 'ACTIVE'),

(5, 5, 'MX Master Mouse',
 'mx-master-mouse',
 'Wireless productivity mouse.',
 25000.00, 'ACTIVE'),

(6, 1, 'Apple Watch Series 10',
 'apple-watch-series-10',
 'Smart wearable from Apple.',
 115000.00, 'ACTIVE'),

(7, 2, 'Galaxy Watch 7',
 'galaxy-watch-7',
 'Samsung smart wearable.',
 85000.00, 'ACTIVE'),

(8, 5, 'G Pro Keyboard',
 'g-pro-keyboard',
 'Mechanical gaming keyboard.',
 29000.00, 'ACTIVE');
 
 
 
 INSERT INTO ProductCategory (
    product_category_id,
    product_id,
    category_id
)
VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 2),
(4, 4, 4),
(5, 5, 3),
(6, 5, 6),
(7, 6, 5),
(8, 7, 5),
(9, 8, 6),
(10, 8, 3);


INSERT INTO ProductVariant (
    variant_id,
    product_id,
    sku,
    color,
    size,
    price,
    cost_price,
    weight,
    barcode,
    is_active
)
VALUES
(1, 1, 'APL-IP16-BLK-128', 'Black', '128GB',
 250000.00, 220000.00, 0.170, '100000000001', TRUE),

(2, 1, 'APL-IP16-WHT-256', 'White', '256GB',
 285000.00, 250000.00, 0.170, '100000000002', TRUE),

(3, 2, 'SAM-S25-BLK-256', 'Black', '256GB',
 225000.00, 195000.00, 0.165, '100000000003', TRUE),

(4, 2, 'SAM-S25-BLU-256', 'Blue', '256GB',
 225000.00, 195000.00, 0.165, '100000000004', TRUE),

(5, 3, 'LEN-T14-16-512', 'Black', '16GB/512GB',
 185000.00, 155000.00, 1.450, '100000000005', TRUE),

(6, 3, 'LEN-T14-32-1TB', 'Black', '32GB/1TB',
 225000.00, 190000.00, 1.450, '100000000006', TRUE),

(7, 4, 'NIKE-AM-BLK-42', 'Black', '42',
 32000.00, 21000.00, 0.800, '100000000007', TRUE),

(8, 4, 'NIKE-AM-WHT-43', 'White', '43',
 32000.00, 21000.00, 0.800, '100000000008', TRUE),

(9, 5, 'LOG-MXM-GRY', 'Graphite', NULL,
 25000.00, 17000.00, 0.141, '100000000009', TRUE),

(10, 6, 'APL-WATCH10-BLK', 'Black', '46mm',
 115000.00, 92000.00, 0.040, '100000000010', TRUE),

(11, 7, 'SAM-WATCH7-GRN', 'Green', '44mm',
 85000.00, 67000.00, 0.034, '100000000011', TRUE),

(12, 8, 'LOG-GPRO-BLK', 'Black', NULL,
 29000.00, 19000.00, 0.980, '100000000012', TRUE);
 
 
 INSERT INTO ProductImage (
    image_id,
    product_id,
    image_url,
    alt_text,
    display_order,
    is_primary
)
VALUES
(1, 1, 'https://example.com/products/iphone16-1.jpg',
 'iPhone 16 front view', 0, TRUE),

(2, 1, 'https://example.com/products/iphone16-2.jpg',
 'iPhone 16 rear view', 1, FALSE),

(3, 2, 'https://example.com/products/s25.jpg',
 'Samsung Galaxy S25', 0, TRUE),

(4, 3, 'https://example.com/products/t14.jpg',
 'Lenovo ThinkPad T14', 0, TRUE),

(5, 4, 'https://example.com/products/airmax.jpg',
 'Nike Air Max shoes', 0, TRUE),

(6, 5, 'https://example.com/products/mxmaster.jpg',
 'Logitech MX Master Mouse', 0, TRUE),

(7, 6, 'https://example.com/products/applewatch.jpg',
 'Apple Watch Series 10', 0, TRUE),

(8, 7, 'https://example.com/products/galaxywatch.jpg',
 'Samsung Galaxy Watch 7', 0, TRUE),

(9, 8, 'https://example.com/products/gprokeyboard.jpg',
 'Logitech G Pro Keyboard', 0, TRUE);
 
 
 
 INSERT INTO Warehouse (
    warehouse_id,
    name,
    code,
    phone,
    address_line1,
    city,
    state,
    postal_code,
    country,
    status
)
VALUES
(1, 'Lahore Central Warehouse', 'LHR-WH-01',
 '+92-42-1111111', 'Industrial Estate Road',
 'Lahore', 'Punjab', '54000', 'Pakistan', 'ACTIVE'),

(2, 'Karachi Distribution Center', 'KHI-WH-01',
 '+92-21-2222222', 'Korangi Industrial Area',
 'Karachi', 'Sindh', '74900', 'Pakistan', 'ACTIVE'),

(3, 'Islamabad Warehouse', 'ISB-WH-01',
 '+92-51-3333333', 'I-9 Industrial Area',
 'Islamabad', 'ICT', '44000', 'Pakistan', 'ACTIVE');
 
 
 
 INSERT INTO Inventory (
    inventory_id,
    variant_id,
    warehouse_id,
    quantity_on_hand,
    quantity_reserved,
    reorder_level
)
VALUES
(1, 1, 1, 25, 3, 5),
(2, 2, 1, 15, 2, 5),
(3, 3, 2, 30, 4, 6),
(4, 4, 2, 18, 2, 5),
(5, 5, 1, 12, 1, 4),
(6, 7, 3, 40, 5, 10),
(7, 9, 1, 35, 3, 8),
(8, 10, 2, 16, 2, 4),
(9, 11, 3, 22, 1, 5),
(10, 12, 1, 28, 4, 7);



INSERT INTO StockMovement (
    movement_id,
    inventory_id,
    movement_type,
    quantity,
    reference_type,
    reference_id,
    notes,
    created_at
)
VALUES
(1, 1, 'PURCHASE', 30, 'PURCHASE_ORDER', 1,
 'Initial iPhone stock received.', '2026-07-01 10:00:00'),

(2, 3, 'PURCHASE', 35, 'PURCHASE_ORDER', 2,
 'Galaxy S25 shipment received.', '2026-07-02 11:00:00'),

(3, 5, 'PURCHASE', 15, 'PURCHASE_ORDER', 3,
 'ThinkPad stock received.', '2026-07-05 12:00:00'),

(4, 6, 'PURCHASE', 50, 'PURCHASE_ORDER', 4,
 'Nike stock received.', '2026-07-08 09:30:00'),

(5, 1, 'SALE', 2, 'SALES_ORDER', 1,
 'Customer order fulfillment.', '2026-08-01 13:00:00'),

(6, 7, 'SALE', 1, 'SALES_ORDER', 2,
 'Mouse sold.', '2026-08-03 15:00:00'),

(7, 3, 'SALE', 2, 'SALES_ORDER', 3,
 'Galaxy S25 sold.', '2026-08-05 16:00:00'),

(8, 6, 'RETURN', 1, 'RETURN', 1,
 'Returned Nike Air Max restocked.', '2026-08-12 11:30:00');
 
 
 
 INSERT INTO Supplier (
    supplier_id,
    name,
    contact_name,
    email,
    phone,
    tax_number,
    address_line1,
    city,
    country,
    status
)
VALUES
(1, 'Tech Distribution Pakistan', 'Kamran Ali',
 'sales@techdistribution.example', '+92-300-7000001',
 'NTN-TECH-001', 'Main Boulevard Gulberg',
 'Lahore', 'Pakistan', 'ACTIVE'),

(2, 'Mobile World Distributors', 'Ahmed Raza',
 'orders@mobileworld.example', '+92-300-7000002',
 'NTN-MOB-002', 'Shahrah-e-Faisal',
 'Karachi', 'Pakistan', 'ACTIVE'),

(3, 'Computer Supply Hub', 'Bilal Khan',
 'sales@computersupply.example', '+92-300-7000003',
 'NTN-PC-003', 'Blue Area',
 'Islamabad', 'Pakistan', 'ACTIVE'),

(4, 'Sports Wholesale PK', 'Hassan Malik',
 'orders@sportswholesale.example', '+92-300-7000004',
 'NTN-SPT-004', 'Sialkot Road',
 'Sialkot', 'Pakistan', 'ACTIVE');
 
 
 
 INSERT INTO PurchaseOrder (
    purchase_order_id,
    supplier_id,
    order_date,
    expected_date,
    status,
    subtotal,
    tax_amount,
    shipping_cost,
    total_amount
)
VALUES
(1, 1, '2026-06-25 10:00:00', '2026-07-01',
 'RECEIVED', 6600000.00, 0.00, 25000.00, 6625000.00),

(2, 2, '2026-06-27 11:00:00', '2026-07-02',
 'RECEIVED', 6825000.00, 0.00, 30000.00, 6855000.00),

(3, 3, '2026-07-01 09:00:00', '2026-07-05',
 'RECEIVED', 2325000.00, 0.00, 20000.00, 2345000.00),

(4, 4, '2026-07-03 12:00:00', '2026-07-08',
 'RECEIVED', 1050000.00, 0.00, 15000.00, 1065000.00);
 
 
 INSERT INTO PurchaseOrderItem (
    purchase_order_item_id,
    purchase_order_id,
    variant_id,
    quantity,
    unit_cost,
    tax_amount,
    line_total
)
VALUES
(1, 1, 1, 30, 220000.00, 0.00, 6600000.00),
(2, 2, 3, 35, 195000.00, 0.00, 6825000.00),
(3, 3, 5, 15, 155000.00, 0.00, 2325000.00),
(4, 4, 7, 50, 21000.00, 0.00, 1050000.00);



INSERT INTO Cart (
    cart_id,
    customer_id,
    status,
    created_at,
    expires_at
)
VALUES
(1, 1, 'ACTIVE', '2026-08-15 10:00:00', '2026-08-22 10:00:00'),
(2, 2, 'ACTIVE', '2026-08-16 12:00:00', '2026-08-23 12:00:00'),
(3, 3, 'ABANDONED', '2026-08-01 15:00:00', '2026-08-08 15:00:00'),
(4, 4, 'CONVERTED', '2026-08-04 09:00:00', '2026-08-11 09:00:00');


INSERT INTO CartItem (
    cart_item_id,
    cart_id,
    variant_id,
    quantity,
    unit_price
)
VALUES
(1, 1, 9, 1, 25000.00),
(2, 1, 12, 1, 29000.00),
(3, 2, 10, 1, 115000.00),
(4, 2, 1, 1, 250000.00),
(5, 3, 7, 2, 32000.00);



INSERT INTO Wishlist (
    wishlist_id,
    customer_id,
    name
)
VALUES
(1, 1, 'Gaming Setup'),
(2, 2, 'Tech Wishlist'),
(3, 3, 'Future Purchases');


INSERT INTO WishlistItem (
    wishlist_item_id,
    wishlist_id,
    variant_id
)
VALUES
(1, 1, 12),
(2, 1, 9),
(3, 2, 10),
(4, 2, 2),
(5, 3, 5);


INSERT INTO SalesOrder (
    order_id,
    customer_id,
    order_number,
    order_date,
    status,
    subtotal,
    discount_amount,
    tax_amount,
    shipping_amount,
    total_amount,
    currency
)
VALUES
(1, 1, 'ORD-2026-0001',
 '2026-08-01 10:00:00', 'DELIVERED',
 250000.00, 10000.00, 0.00, 500.00, 240500.00, 'PKR'),

(2, 2, 'ORD-2026-0002',
 '2026-08-03 12:00:00', 'DELIVERED',
 25000.00, 0.00, 0.00, 300.00, 25300.00, 'PKR'),

(3, 3, 'ORD-2026-0003',
 '2026-08-05 15:30:00', 'SHIPPED',
 450000.00, 15000.00, 0.00, 500.00, 435500.00, 'PKR'),

(4, 4, 'ORD-2026-0004',
 '2026-08-07 11:00:00', 'DELIVERED',
 32000.00, 2000.00, 0.00, 300.00, 30300.00, 'PKR'),

(5, 1, 'ORD-2026-0005',
 '2026-08-10 14:00:00', 'CONFIRMED',
 144000.00, 0.00, 0.00, 500.00, 144500.00, 'PKR'),

(6, 2, 'ORD-2026-0006',
 '2026-08-12 16:00:00', 'PENDING',
 115000.00, 5000.00, 0.00, 300.00, 110300.00, 'PKR');
 
 
 
 INSERT INTO OrderItem (
    order_item_id,
    order_id,
    variant_id,
    quantity,
    unit_price,
    discount_amount,
    tax_amount,
    line_total
)
VALUES
(1, 1, 1, 1, 250000.00, 10000.00, 0.00, 240000.00),

(2, 2, 9, 1, 25000.00, 0.00, 0.00, 25000.00),

(3, 3, 3, 2, 225000.00, 15000.00, 0.00, 435000.00),

(4, 4, 7, 1, 32000.00, 2000.00, 0.00, 30000.00),

(5, 5, 10, 1, 115000.00, 0.00, 0.00, 115000.00),

(6, 5, 8, 1, 32000.00, 3000.00, 0.00, 29000.00),

(7, 6, 10, 1, 115000.00, 5000.00, 0.00, 110000.00);



INSERT INTO PaymentMethod (
    payment_method_id,
    name,
    provider,
    is_active
)
VALUES
(1, 'Cash on Delivery', 'Internal', TRUE),
(2, 'Credit Card', 'Visa/Mastercard', TRUE),
(3, 'JazzCash', 'JazzCash', TRUE),
(4, 'Easypaisa', 'Easypaisa', TRUE);



INSERT INTO Payment (
    payment_id,
    order_id,
    payment_method_id,
    transaction_reference,
    amount,
    status,
    payment_date
)
VALUES
(1, 1, 2, 'TXN-CC-0001',
 240500.00, 'PAID', '2026-08-01 10:05:00'),

(2, 2, 1, NULL,
 25300.00, 'PAID', '2026-08-05 14:00:00'),

(3, 3, 3, 'TXN-JC-0003',
 435500.00, 'PAID', '2026-08-05 15:35:00'),

(4, 4, 4, 'TXN-EP-0004',
 30300.00, 'PAID', '2026-08-07 11:05:00'),

(5, 5, 2, 'TXN-CC-0005',
 144500.00, 'AUTHORIZED', '2026-08-10 14:05:00'),

(6, 6, 3, 'TXN-JC-0006',
 110300.00, 'PENDING', NULL);
 
 
 
 INSERT INTO Shipment (
    shipment_id,
    order_id,
    tracking_number,
    carrier,
    status,
    shipped_at,
    estimated_delivery,
    delivered_at,
    shipping_cost
)
VALUES
(1, 1, 'TRK-000001', 'TCS',
 'DELIVERED', '2026-08-02 09:00:00',
 '2026-08-04', '2026-08-04 15:00:00', 500.00),

(2, 2, 'TRK-000002', 'Leopards',
 'DELIVERED', '2026-08-04 10:00:00',
 '2026-08-06', '2026-08-05 14:00:00', 300.00),

(3, 3, 'TRK-000003', 'TCS',
 'IN_TRANSIT', '2026-08-06 11:00:00',
 '2026-08-09', NULL, 500.00),

(4, 4, 'TRK-000004', 'Leopards',
 'DELIVERED', '2026-08-08 10:00:00', '2026-08-10', '2026-08-09 09:00:00', 300.00),

(5, 5, 'TRK-000005', 'M&P',
 'PENDING', NULL, '2026-08-14', NULL, 500.00);
 
 
 
 INSERT INTO ShipmentItem (
    shipment_item_id,
    shipment_id,
    order_item_id,
    quantity
)
VALUES
(1, 1, 1, 1),
(2, 2, 2, 1),
(3, 3, 3, 2),
(4, 4, 4, 1),
(5, 5, 5, 1),
(6, 5, 6, 1);



INSERT INTO Promotion (
    promotion_id,
    name,
    description,
    discount_type,
    discount_value,
    start_date,
    end_date,
    minimum_order_amount,
    maximum_discount,
    is_active
)
VALUES
(1, 'Summer Tech Sale',
 'Discount on selected electronics.',
 'PERCENTAGE', 10.00,
 '2026-08-01 00:00:00',
 '2026-08-31 23:59:59',
 50000.00, 20000.00, TRUE),

(2, 'Accessories Discount',
 'Fixed discount on selected accessories.',
 'FIXED_AMOUNT', 3000.00,
 '2026-08-01 00:00:00',
 '2026-09-15 23:59:59',
 15000.00, 3000.00, TRUE),

(3, 'Wearables Sale',
 'Special promotion for smart watches.',
 'PERCENTAGE', 5.00,
 '2026-08-10 00:00:00',
 '2026-09-10 23:59:59',
 50000.00, 10000.00, TRUE);
 
 
 
 INSERT INTO PromotionProduct (
    promotion_product_id,
    promotion_id,
    product_id
)
VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),
(4, 2, 5),
(5, 2, 8),
(6, 3, 6),
(7, 3, 7);



INSERT INTO Coupon (
    coupon_id,
    promotion_id,
    code,
    discount_type,
    discount_value,
    minimum_order_amount,
    maximum_discount,
    usage_limit,
    usage_count,
    start_date,
    expiry_date,
    is_active
)
VALUES
(1, 1, 'TECH10',
 'PERCENTAGE', 10.00,
 50000.00, 15000.00,
 100, 12,
 '2026-08-01 00:00:00',
 '2026-08-31 23:59:59',
 TRUE),

(2, 2, 'ACCESSORY3000',
 'FIXED_AMOUNT', 3000.00,
 15000.00, 3000.00,
 50, 8,
 '2026-08-01 00:00:00',
 '2026-09-15 23:59:59',
 TRUE),

(3, 3, 'WATCH5',
 'PERCENTAGE', 5.00,
 50000.00, 10000.00,
 75, 4,
 '2026-08-10 00:00:00',
 '2026-09-10 23:59:59',
 TRUE),

(4, NULL, 'WELCOME2000',
 'FIXED_AMOUNT', 2000.00,
 10000.00, 2000.00,
 500, 25,
 '2026-01-01 00:00:00',
 '2026-12-31 23:59:59',
 TRUE);
 
 
 INSERT INTO ProductReturn (
    return_id,
    order_id,
    return_number,
    reason,
    status,
    requested_at,
    approved_at,
    received_at
)
VALUES
(1, 4, 'RET-2026-0001',
 'Incorrect shoe size.',
 'COMPLETED',
 '2026-08-09 10:00:00',
 '2026-08-09 14:00:00',
 '2026-08-11 12:00:00'),

(2, 2, 'RET-2026-0002',
 'Mouse scroll wheel issue.',
 'APPROVED',
 '2026-08-10 13:00:00',
 '2026-08-10 16:00:00',
 NULL);
 
 
 INSERT INTO ReturnItem (
    return_item_id,
    return_id,
    order_item_id,
    quantity,
    reason,
    item_condition,
    resolution
)
VALUES
(1, 1, 4, 1,
 'Size does not fit.',
 'OPENED',
 'REFUND'),

(2, 2, 2, 1,
 'Scroll wheel is defective.',
 'DEFECTIVE',
 'REPLACEMENT');
 
 
 
 INSERT INTO Refund (
    refund_id,
    return_id,
    amount,
    status,
    refund_method,
    transaction_reference,
    processed_at
)
VALUES
(1, 1, 30000.00,
 'COMPLETED',
 'Easypaisa',
 'REF-TXN-0001',
 '2026-08-12 10:00:00'),

(2, 2, 25000.00,
 'PENDING',
 'Original Payment Method',
 'REF-TXN-0002',
 NULL);
 
 
 
 INSERT INTO ProductReview (
    review_id,
    customer_id,
    product_id,
    rating,
    title,
    comment,
    status,
    verified_purchase
)
VALUES
(1, 1, 1, 5,
 'Excellent phone',
 'Very good performance and camera quality.',
 'PUBLISHED', TRUE),

(2, 2, 5, 4,
 'Great productivity mouse',
 'Comfortable mouse with useful features.',
 'PUBLISHED', TRUE),

(3, 3, 2, 5,
 'Excellent Android flagship',
 'Fast performance and very good display.',
 'PUBLISHED', TRUE),

(4, 4, 4, 3,
 'Good shoe but sizing issue',
 'Quality is good but the size did not fit me.',
 'PUBLISHED', TRUE),

(5, 1, 6, 4,
 'Useful smart watch',
 'Works very well with my phone.',
 'PUBLISHED', TRUE);
 
 
 
 INSERT INTO Role (
    role_id,
    name,
    description
)
VALUES
(1, 'ADMIN',
 'Full system administration access.'),

(2, 'MANAGER',
 'Retail and operations management.'),

(3, 'WAREHOUSE_STAFF',
 'Inventory and warehouse operations.'),

(4, 'CUSTOMER_SUPPORT',
 'Customer orders, returns and support.'),

(5, 'FINANCE',
 'Payments and refund management.');
 
 
 
 INSERT INTO Employee (
    employee_id,
    role_id,
    first_name,
    last_name,
    email,
    phone,
    password_hash,
    hire_date,
    status
)
VALUES
(1, 1, 'Danish', 'Admin',
 'danish.admin@retail.example',
 '+92-300-9000001',
 '$2y$10$employeehash001',
 '2024-01-10', 'ACTIVE'),

(2, 2, 'Ahmed', 'Manager',
 'ahmed.manager@retail.example',
 '+92-300-9000002',
 '$2y$10$employeehash002',
 '2024-03-15', 'ACTIVE'),

(3, 3, 'Bilal', 'Warehouse',
 'bilal.warehouse@retail.example',
 '+92-300-9000003',
 '$2y$10$employeehash003',
 '2025-01-05', 'ACTIVE'),

(4, 4, 'Sara', 'Support',
 'sara.support@retail.example',
 '+92-300-9000004',
 '$2y$10$employeehash004',
 '2025-05-20', 'ACTIVE'),

(5, 5, 'Hamza', 'Finance',
 'hamza.finance@retail.example',
 '+92-300-9000005',
 '$2y$10$employeehash005',
 '2025-09-01', 'ACTIVE');
 
 
 
 INSERT INTO AuditLog (
    audit_id,
    employee_id,
    action,
    entity_name,
    entity_id,
    old_values,
    new_values,
    ip_address,
    user_agent,
    created_at
)
VALUES
(
    1,
    2,
    'STATUS_CHANGE',
    'SalesOrder',
    1,
    JSON_OBJECT('status', 'SHIPPED'),
    JSON_OBJECT('status', 'DELIVERED'),
    '192.168.1.10',
    'Retail Admin Portal',
    '2026-08-04 15:05:00'
),
(
    2,
    3,
    'UPDATE',
    'Inventory',
    1,
    JSON_OBJECT('quantity_on_hand', 27),
    JSON_OBJECT('quantity_on_hand', 25),
    '192.168.1.20',
    'Warehouse Management System',
    '2026-08-01 13:05:00'
),
(
    3,
    4,
    'STATUS_CHANGE',
    'ProductReturn',
    1,
    JSON_OBJECT('status', 'REQUESTED'),
    JSON_OBJECT('status', 'APPROVED'),
    '192.168.1.30',
    'Customer Support Portal',
    '2026-08-09 14:00:00'
),
(
    4,
    5,
    'STATUS_CHANGE',
    'Refund',
    1,
    JSON_OBJECT('status', 'PENDING'),
    JSON_OBJECT('status', 'COMPLETED'),
    '192.168.1.40',
    'Finance Portal',
    '2026-08-12 10:00:00'
),
(
    5,
    1,
    'UPDATE',
    'Promotion',
    1,
    JSON_OBJECT('is_active', FALSE),
    JSON_OBJECT('is_active', TRUE),
    '192.168.1.50',
    'Admin Portal',
    '2026-08-01 09:00:00'
);


COMMIT;


SELECT COUNT(*) FROM Customer;
SELECT COUNT(*) FROM Product;
SELECT COUNT(*) FROM ProductVariant;
SELECT COUNT(*) FROM Inventory;
SELECT COUNT(*) FROM SalesOrder;
SELECT COUNT(*) FROM OrderItem;
SELECT COUNT(*) FROM Payment;
SELECT COUNT(*) FROM ProductReview;


SELECT 'Customer' AS table_name, COUNT(*) AS rows_count
FROM Customer

UNION ALL
SELECT 'Product', COUNT(*) FROM Product

UNION ALL
SELECT 'ProductVariant', COUNT(*) FROM ProductVariant

UNION ALL
SELECT 'Inventory', COUNT(*) FROM Inventory

UNION ALL
SELECT 'SalesOrder', COUNT(*) FROM SalesOrder

UNION ALL
SELECT 'OrderItem', COUNT(*) FROM OrderItem

UNION ALL
SELECT 'Payment', COUNT(*) FROM Payment

UNION ALL
SELECT 'Shipment', COUNT(*) FROM Shipment

UNION ALL
SELECT 'ProductReturn', COUNT(*) FROM ProductReturn

UNION ALL
SELECT 'ProductReview', COUNT(*) FROM ProductReview;

