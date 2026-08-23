# Data Dictionary

This document describes the main tables and attributes used in the Retail & E-Commerce Management Database.

---

## Customer

Stores registered customer accounts.

| Column | Description |
|---|---|
| customer_id | Unique customer identifier |
| first_name | Customer first name |
| last_name | Customer last name |
| email | Unique customer email |
| phone | Customer phone number |
| password_hash | Hashed password |
| date_of_birth | Customer date of birth |
| status | ACTIVE, INACTIVE, or SUSPENDED |
| created_at | Record creation timestamp |
| updated_at | Last modification timestamp |

---

## Address

Stores reusable postal addresses.

| Column | Description |
|---|---|
| address_id | Unique address identifier |
| recipient_name | Person receiving delivery |
| phone | Contact phone |
| address_line1 | Primary address |
| address_line2 | Additional address details |
| city | City |
| state | State or province |
| postal_code | Postal code |
| country | Country |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## CustomerAddress

Associates customers with addresses.

| Column | Description |
|---|---|
| customer_address_id | Unique relationship identifier |
| customer_id | Customer reference |
| address_id | Address reference |
| address_type | Shipping, billing, home, etc. |
| is_default | Whether address is default |
| created_at | Creation timestamp |

---

## Brand

Stores product brands.

| Column | Description |
|---|---|
| brand_id | Unique brand identifier |
| name | Unique brand name |
| slug | URL-friendly unique identifier |
| description | Brand description |
| logo_url | Brand logo location |
| is_active | Brand availability |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## Category

Stores product categories.

| Column | Description |
|---|---|
| category_id | Unique category identifier |
| name | Unique category name |
| slug | URL-friendly identifier |
| description | Category description |
| is_active | Category availability |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## Product

Stores general product information.

| Column | Description |
|---|---|
| product_id | Unique product identifier |
| brand_id | Product brand |
| name | Product name |
| slug | Unique URL-friendly product identifier |
| description | Product description |
| base_price | Default product price |
| status | ACTIVE, INACTIVE, or DISCONTINUED |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## ProductCategory

Many-to-many relationship between Product and Category.

| Column | Description |
|---|---|
| product_category_id | Relationship identifier |
| product_id | Product reference |
| category_id | Category reference |
| created_at | Creation timestamp |

---

## ProductVariant

Stores specific sellable product variants.

| Column | Description |
|---|---|
| variant_id | Unique variant identifier |
| product_id | Parent product |
| sku | Unique stock keeping unit |
| color | Variant color |
| size | Variant size |
| price | Selling price |
| cost_price | Acquisition cost |
| weight | Product weight |
| barcode | Unique barcode when available |
| is_active | Variant availability |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## ProductImage

Stores product image references.

| Column | Description |
|---|---|
| image_id | Unique image identifier |
| product_id | Product reference |
| image_url | Image location |
| alt_text | Alternative text |
| display_order | Image display sequence |
| is_primary | Primary image indicator |
| created_at | Creation timestamp |

---

## Warehouse

Stores warehouse locations.

| Column | Description |
|---|---|
| warehouse_id | Unique warehouse identifier |
| name | Warehouse name |
| code | Unique warehouse code |
| phone | Contact number |
| address_line1 | Primary address |
| address_line2 | Additional address |
| city | City |
| state | State/province |
| postal_code | Postal code |
| country | Country |
| status | ACTIVE, INACTIVE, MAINTENANCE |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## Inventory

Stores stock per product variant and warehouse.

| Column | Description |
|---|---|
| inventory_id | Unique inventory identifier |
| variant_id | Product variant |
| warehouse_id | Warehouse |
| quantity_on_hand | Physical stock |
| quantity_reserved | Reserved stock |
| reorder_level | Restocking threshold |
| last_updated | Last inventory update |

Available stock is calculated as:

`quantity_on_hand - quantity_reserved`

---

## StockMovement

Stores inventory movement history.

| Column | Description |
|---|---|
| movement_id | Unique movement identifier |
| inventory_id | Inventory reference |
| movement_type | PURCHASE, SALE, RETURN, TRANSFER_IN, TRANSFER_OUT, ADJUSTMENT |
| quantity | Positive quantity moved |
| reference_type | Type of business record causing movement |
| reference_id | Identifier of related record |
| notes | Additional explanation |
| created_at | Movement timestamp |

---

## Supplier

Stores supplier information.

| Column | Description |
|---|---|
| supplier_id | Unique supplier identifier |
| name | Supplier name |
| contact_name | Contact person |
| email | Supplier email |
| phone | Supplier phone |
| tax_number | Unique tax identifier when provided |
| address_line1 | Address |
| address_line2 | Additional address |
| city | City |
| country | Country |
| status | ACTIVE, INACTIVE, SUSPENDED |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## PurchaseOrder

Stores purchases from suppliers.

| Column | Description |
|---|---|
| purchase_order_id | Unique purchase order identifier |
| supplier_id | Supplier |
| order_date | Purchase order date |
| expected_date | Expected delivery |
| status | Purchase order status |
| subtotal | Item subtotal |
| tax_amount | Tax |
| shipping_cost | Shipping cost |
| total_amount | Final purchase total |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## PurchaseOrderItem

Stores individual variants ordered from suppliers.

| Column | Description |
|---|---|
| purchase_order_item_id | Unique item identifier |
| purchase_order_id | Purchase order |
| variant_id | Product variant |
| quantity | Quantity ordered |
| unit_cost | Cost per unit |
| tax_amount | Tax |
| line_total | Final line amount |

---

## Cart

Stores customer shopping carts.

| Column | Description |
|---|---|
| cart_id | Unique cart identifier |
| customer_id | Cart owner |
| status | ACTIVE, ABANDONED, CONVERTED, EXPIRED |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |
| expires_at | Expiration time |

---

## CartItem

Stores products added to carts.

| Column | Description |
|---|---|
| cart_item_id | Unique cart item |
| cart_id | Cart |
| variant_id | Product variant |
| quantity | Quantity |
| unit_price | Price when added |
| added_at | Date added |
| updated_at | Last update |

---

## Wishlist

Stores customer wishlist collections.

| Column | Description |
|---|---|
| wishlist_id | Unique wishlist identifier |
| customer_id | Wishlist owner |
| name | Wishlist name |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## WishlistItem

Stores products inside wishlists.

| Column | Description |
|---|---|
| wishlist_item_id | Unique relationship |
| wishlist_id | Wishlist |
| variant_id | Product variant |
| added_at | Date added |

---

## SalesOrder

Stores customer sales orders.

| Column | Description |
|---|---|
| order_id | Unique order identifier |
| customer_id | Customer |
| order_number | Unique public order number |
| order_date | Order timestamp |
| status | Order status |
| subtotal | Item subtotal |
| discount_amount | Discounts |
| tax_amount | Tax |
| shipping_amount | Shipping fee |
| total_amount | Final order amount |
| currency | Three-letter currency code |
| notes | Optional notes |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## OrderItem

Stores products contained in sales orders.

| Column | Description |
|---|---|
| order_item_id | Unique line identifier |
| order_id | Sales order |
| variant_id | Product variant |
| quantity | Quantity purchased |
| unit_price | Historical unit selling price |
| discount_amount | Line discount |
| tax_amount | Line tax |
| line_total | Final line amount |

---

## PaymentMethod

Stores available payment options.

| Column | Description |
|---|---|
| payment_method_id | Unique payment method identifier |
| name | Payment method name |
| provider | External provider |
| is_active | Availability |
| created_at | Creation timestamp |

---

## Payment

Stores customer payment attempts and transactions.

| Column | Description |
|---|---|
| payment_id | Unique payment identifier |
| order_id | Sales order |
| payment_method_id | Payment method |
| transaction_reference | External transaction identifier |
| amount | Payment amount |
| status | Payment status |
| payment_date | Payment timestamp |
| failure_reason | Failure explanation |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## Shipment

Stores order shipment records.

| Column | Description |
|---|---|
| shipment_id | Unique shipment identifier |
| order_id | Sales order |
| tracking_number | Carrier tracking number |
| carrier | Courier/company |
| status | Shipment status |
| shipped_at | Shipment timestamp |
| estimated_delivery | Estimated date |
| delivered_at | Actual delivery timestamp |
| shipping_cost | Shipment cost |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## ShipmentItem

Maps order items to shipments.

| Column | Description |
|---|---|
| shipment_item_id | Unique shipment-item identifier |
| shipment_id | Shipment |
| order_item_id | Order item |
| quantity | Quantity shipped |
| created_at | Creation timestamp |

---

## Promotion

Stores marketing promotions.

| Column | Description |
|---|---|
| promotion_id | Unique promotion identifier |
| name | Promotion name |
| description | Promotion description |
| discount_type | PERCENTAGE or FIXED_AMOUNT |
| discount_value | Discount value |
| start_date | Promotion start |
| end_date | Promotion end |
| minimum_order_amount | Minimum qualifying order |
| maximum_discount | Maximum discount allowed |
| is_active | Promotion availability |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## PromotionProduct

Maps promotions to products.

| Column | Description |
|---|---|
| promotion_product_id | Relationship identifier |
| promotion_id | Promotion |
| product_id | Product |
| created_at | Creation timestamp |

---

## Coupon

Stores coupon codes.

| Column | Description |
|---|---|
| coupon_id | Unique coupon identifier |
| promotion_id | Optional promotion |
| code | Unique coupon code |
| discount_type | PERCENTAGE or FIXED_AMOUNT |
| discount_value | Discount |
| minimum_order_amount | Minimum qualifying value |
| maximum_discount | Maximum allowed discount |
| usage_limit | Maximum number of uses |
| usage_count | Number of uses |
| start_date | Start date |
| expiry_date | Expiry |
| is_active | Coupon status |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## ProductReturn

Stores return requests.

| Column | Description |
|---|---|
| return_id | Unique return identifier |
| order_id | Original order |
| return_number | Unique public return number |
| reason | Customer reason |
| status | Return status |
| requested_at | Request timestamp |
| approved_at | Approval timestamp |
| received_at | Warehouse receipt timestamp |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## ReturnItem

Stores returned order items.

| Column | Description |
|---|---|
| return_item_id | Unique return item |
| return_id | Return request |
| order_item_id | Original order item |
| quantity | Quantity returned |
| reason | Item reason |
| item_condition | UNOPENED, OPENED, USED, DAMAGED, DEFECTIVE |
| resolution | REFUND, REPLACEMENT, STORE_CREDIT, REJECTED |
| created_at | Creation timestamp |

---

## Refund

Stores refund transactions.

| Column | Description |
|---|---|
| refund_id | Unique refund identifier |
| return_id | Product return |
| amount | Refund amount |
| status | Refund status |
| refund_method | Refund method |
| transaction_reference | External reference |
| processed_at | Completion timestamp |
| created_at | Creation timestamp |

---

## ProductReview

Stores customer reviews.

| Column | Description |
|---|---|
| review_id | Unique review identifier |
| customer_id | Customer |
| product_id | Product |
| rating | Rating from 1 to 5 |
| title | Review title |
| comment | Review content |
| status | PENDING, PUBLISHED, REJECTED, HIDDEN |
| verified_purchase | Verified purchase flag |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## Role

Stores employee roles.

| Column | Description |
|---|---|
| role_id | Unique role identifier |
| name | Unique role name |
| description | Role description |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## Employee

Stores administrative employees.

| Column | Description |
|---|---|
| employee_id | Unique employee identifier |
| role_id | Assigned role |
| first_name | First name |
| last_name | Last name |
| email | Unique employee email |
| phone | Employee phone |
| password_hash | Password hash |
| hire_date | Employment start date |
| status | ACTIVE, INACTIVE, SUSPENDED, TERMINATED |
| created_at | Creation timestamp |
| updated_at | Modification timestamp |

---

## AuditLog

Stores system and employee activity history.

| Column | Description |
|---|---|
| audit_id | Unique audit identifier |
| employee_id | Optional employee |
| action | INSERT, UPDATE, DELETE, LOGIN, LOGOUT, STATUS_CHANGE |
| entity_name | Affected entity/table |
| entity_id | Identifier of affected record |
| old_values | Previous values stored as JSON |
| new_values | New values stored as JSON |
| ip_address | IPv4 or IPv6 address |
| user_agent | Application/client description |
| created_at | Audit timestamp |