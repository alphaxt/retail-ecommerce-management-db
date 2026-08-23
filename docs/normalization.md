# Database Normalization

The Retail & E-Commerce Management Database was designed using relational normalization principles to reduce data duplication, improve consistency, and support scalable database operations.

The schema primarily follows Third Normal Form (3NF).

---

## Why Normalization Is Used

Without normalization, a retail database could contain repeated data such as:

- Customer information repeated for every order
- Product information repeated inside every cart
- Brand names repeated for every product variant
- Warehouse addresses repeated for every inventory record
- Supplier information repeated for every purchase item

This creates:

- Data duplication
- Update anomalies
- Insert anomalies
- Delete anomalies
- Increased storage requirements
- Data inconsistency

Normalization separates these concepts into related tables.

---

# First Normal Form — 1NF

A table is in First Normal Form when:

1. Each column contains atomic values.
2. There are no repeating groups.
3. Each row can be uniquely identified.

Example of a bad design:

| order_id | customer | products |
|---|---|---|
| 1 | Ali | iPhone, Mouse, Keyboard |

The `products` column contains multiple values.

Instead, the database separates:

SalesOrder

and

OrderItem

Example:

SalesOrder:

| order_id | customer_id |
|---|---|
| 1 | 10 |

OrderItem:

| order_item_id | order_id | variant_id |
|---|---|---|
| 1 | 1 | 20 |
| 2 | 1 | 35 |
| 3 | 1 | 40 |

Each field now contains one atomic value.

The schema satisfies 1NF.

---

# Second Normal Form — 2NF

Second Normal Form requires:

1. The table must already satisfy 1NF.
2. Non-key attributes must depend on the entire primary key.

The database generally uses surrogate primary keys such as:

- customer_id
- product_id
- order_id
- inventory_id
- payment_id

Many-to-many relationship tables use separate keys with composite UNIQUE constraints.

For example:

ProductCategory

contains:

- product_id
- category_id

and enforces:

UNIQUE(product_id, category_id)

Category information such as category name is not stored in ProductCategory.

Instead:

ProductCategory.category_id

references:

Category.category_id

Therefore category attributes depend on the Category entity rather than being duplicated.

---

# Third Normal Form — 3NF

Third Normal Form requires:

1. The table must satisfy 2NF.
2. Non-key columns should not depend on other non-key columns.

For example, Product stores:

- product_id
- brand_id
- name
- base_price

It does not repeatedly store:

- brand_name
- brand_logo
- brand_description

Those attributes belong to Brand.

Relationship:

Brand
1
↓
Many
Product

This prevents brand information from being duplicated across products.

---

# Customer and Address Normalization

Instead of storing all addresses directly inside Customer, the design uses:

Customer

Address

CustomerAddress

This supports:

Customer
↓
many addresses

and potentially:

Address
↓
multiple customer relationships

CustomerAddress also stores relationship-specific attributes such as:

- address_type
- is_default

These attributes belong to the customer-address relationship rather than Customer or Address individually.

---

# Product and Category Normalization

A product may belong to multiple categories.

A category may contain multiple products.

This creates a many-to-many relationship.

Bad design:

Product

category1
category2
category3

Better design:

Product
↓
ProductCategory
↓
Category

ProductCategory contains:

- product_id
- category_id

This supports any number of categories without modifying the Product table.

---

# Product and Variant Normalization

Product contains general product information.

Examples:

- Name
- Description
- Brand
- Base price

ProductVariant contains sellable configurations.

Examples:

- SKU
- Color
- Size
- Price
- Cost price
- Weight
- Barcode

This avoids duplicating the complete product record for every combination.

Example:

iPhone 16

may have:

- Black / 128 GB
- White / 256 GB

The common product information remains in Product while variation-specific information is stored in ProductVariant.

---

# Warehouse and Inventory Normalization

Inventory does not directly store:

- Warehouse name
- Warehouse city
- Product name
- Product description

Instead, it contains references:

Inventory.variant_id
→ ProductVariant

Inventory.warehouse_id
→ Warehouse

The unique constraint:

UNIQUE(variant_id, warehouse_id)

ensures one inventory record per product variant per warehouse.

---

# Sales Order Normalization

Sales order data is divided into:

SalesOrder

and

OrderItem

SalesOrder stores order-level information:

- Customer
- Order number
- Status
- Subtotal
- Shipping
- Tax
- Total

OrderItem stores line-level information:

- Product variant
- Quantity
- Unit price
- Line discount
- Tax
- Line total

This prevents order-level information from being repeated for every item.

---

# Historical Price Duplication

The schema intentionally stores `unit_price` inside OrderItem.

At first this may appear redundant because ProductVariant also stores a price.

However, this is intentional historical data.

Example:

ProductVariant.price today:
PKR 250,000

Customer purchased earlier:
PKR 235,000

If ProductVariant.price changes, old orders must still show the original purchase price.

Therefore:

ProductVariant.price
= current selling price

OrderItem.unit_price
= historical transaction price

This controlled duplication is necessary for transaction history.

---

# Purchase Order Normalization

Supplier purchasing is separated into:

Supplier

PurchaseOrder

PurchaseOrderItem

Supplier information is stored only once.

PurchaseOrder contains order-level purchasing information.

PurchaseOrderItem contains individual purchased product variants.

This prevents supplier and purchase header data from being repeated for every purchased item.

---

# Cart Normalization

Cart and CartItem are separated.

Cart contains:

- Customer
- Status
- Expiration

CartItem contains:

- Product variant
- Quantity
- Unit price

This allows one cart to contain multiple items without repeating cart metadata.

---

# Wishlist Normalization

Wishlist and WishlistItem follow the same parent-child design.

Wishlist stores collection-level information.

WishlistItem stores the variants inside the collection.

---

# Payment Normalization

Payment methods are separated from Payment.

Instead of repeatedly storing:

Credit Card

JazzCash

Easypaisa

inside every payment as uncontrolled text, the database uses:

Payment.payment_method_id
→ PaymentMethod

This allows payment method information to be managed centrally.

---

# Shipment Normalization

Shipment and ShipmentItem are separate.

This supports:

- One order with multiple shipments
- One shipment containing multiple order items
- Partial fulfillment

Shipment stores shipment-level information.

ShipmentItem stores which order lines were included.

---

# Promotion Normalization

Product-to-promotion mapping is separated using:

PromotionProduct

because:

One promotion
→ may apply to many products

One product
→ may participate in many promotions

This is a many-to-many relationship.

---

# Return Normalization

Return information is divided into:

ProductReturn

ReturnItem

Refund

ProductReturn stores return-level information.

ReturnItem stores individual returned items.

Refund stores financial reimbursement information.

This avoids mixing:

- Return workflow
- Product-level return details
- Financial refund processing

inside one large table.

---

# Employee Role Normalization

Role information is stored separately.

Employee.role_id
→ Role.role_id

This avoids repeatedly storing role descriptions inside every Employee row.

Example roles:

- ADMIN
- MANAGER
- WAREHOUSE_STAFF
- CUSTOMER_SUPPORT
- FINANCE

---

# AuditLog Design

AuditLog intentionally uses generic fields such as:

- entity_name
- entity_id
- old_values
- new_values

This is a generalized audit structure.

The JSON columns provide flexibility because different entities have different attributes.

For example:

Customer status change:

{
  "status": "ACTIVE"
}

Inventory change:

{
  "quantity_on_hand": 20,
  "quantity_reserved": 3
}

This design trades strict relational structure for audit flexibility.

---

# Controlled Denormalization

Not all duplication is bad.

Some fields are intentionally stored for historical and performance reasons.

Examples include:

OrderItem.unit_price

PurchaseOrderItem.unit_cost

CartItem.unit_price

SalesOrder.total_amount

OrderItem.line_total

These values could sometimes be recalculated from related data, but they are stored because they represent the financial state of the transaction at that time.

This is controlled denormalization.

---

# Normal Form Summary

The database generally follows:

1NF
- Atomic values
- No repeating groups

2NF
- Attributes depend on the complete key

3NF
- Non-key attributes depend on the primary key rather than other non-key attributes

Some transaction totals and historical prices are intentionally stored to preserve financial history and improve reporting performance.

---

# Result

The normalized design provides:

- Reduced data duplication
- Strong referential integrity
- Easier updates
- Better data consistency
- Flexible many-to-many relationships
- Historical transaction accuracy
- Improved maintainability
- Scalable reporting and analytics