# Project Assumptions

This document records assumptions made while designing the Retail & E-Commerce Management Database.

These assumptions define the scope of the project and explain design decisions that may differ in a larger production system.

---

## 1. Currency

The default transaction currency is PKR.

SalesOrder.currency uses a three-character currency code.

The current project does not implement:

- Currency conversion
- Exchange-rate history
- Multi-currency accounting

These features could be added in a future version.

---

## 2. Authentication

Customer and employee authentication is outside the scope of the SQL project.

The database stores:

password_hash

rather than plaintext passwords.

The application layer is assumed to handle:

- Password hashing
- Password verification
- Sessions
- Authentication tokens
- Password reset workflows

---

## 3. Customer Email

Customer email addresses are assumed to uniquely identify customer accounts.

Employee email addresses are also unique.

---

## 4. Product Variants

ProductVariant represents the actual sellable SKU.

Product stores general product information.

Examples of variant attributes include:

- Color
- Size

The project does not implement a fully dynamic attribute-value system.

A larger e-commerce platform could use tables such as:

Attribute

AttributeValue

VariantAttributeValue

for unlimited product attributes.

---

## 5. Category Hierarchy

The current Category table does not contain:

parent_category_id

Therefore categories are currently treated as a flat structure.

For example:

Smartphones
Laptops
Accessories

A future version could add hierarchical categories such as:

Electronics
├── Smartphones
├── Computers
│   ├── Laptops
│   └── Desktops

A self-referencing foreign key could support this design.

---

## 6. Inventory Model

Inventory is maintained per:

ProductVariant + Warehouse

Available inventory is calculated as:

quantity_on_hand - quantity_reserved

Reserved inventory represents units committed to customers but not yet physically removed from stock.

---

## 7. Warehouse Allocation

SalesOrder and OrderItem do not directly store a fulfillment warehouse.

Warehouse selection is supplied to transaction procedures when required.

Examples:

sp_place_order

sp_fulfill_order_item

sp_cancel_order

A production system may introduce explicit fulfillment allocation tables.

---

## 8. Order Placement Procedure

The demonstration `sp_place_order` procedure accepts one product variant per call.

This keeps the transaction example understandable.

A production checkout usually contains multiple cart items.

A future implementation could process multiple items using:

- JSON parameters
- Temporary tables
- Cart conversion logic
- Application-layer transactions

---

## 9. Inventory Reservation

Placing an order reserves inventory.

It does not immediately reduce quantity_on_hand.

Example:

Before:

quantity_on_hand = 20
quantity_reserved = 3

Customer orders 2.

After reservation:

quantity_on_hand = 20
quantity_reserved = 5

Available:

15

Physical inventory is reduced when fulfillment occurs.

---

## 10. Stock Movement Logging

Business transaction procedures explicitly create stock movements.

Examples:

SALE

PURCHASE

RETURN

Generic inventory update triggers should not create duplicate movement records for the same business transaction.

Therefore generic automatic stock-increase/decrease triggers should not be used together with explicit movement logging in transaction procedures.

---

## 11. Order Pricing

OrderItem.unit_price represents the selling price at the moment the order is placed.

Changing ProductVariant.price later must not modify historical orders.

---

## 12. Order Totals

SalesOrder stores:

- subtotal
- discount_amount
- tax_amount
- shipping_amount
- total_amount

These totals are stored to preserve the financial state of the transaction.

The application or transaction procedure is assumed to calculate them consistently.

---

## 13. Current Sample Order Data

The sample dataset contains simplified financial values intended primarily for demonstrating SQL relationships and analytics.

Some line-level discount values may already be reflected in stored order subtotals.

Therefore the sample dataset should not be treated as a complete accounting ledger.

---

## 14. Payment Model

A sales order may contain multiple payment records.

This allows future support for:

- Partial payments
- Split payments
- Payment retries

The order may become CONFIRMED when successful payments reach the total order value.

---

## 15. Cash on Delivery

Cash on Delivery is represented as a payment method.

A production system may treat COD settlement differently from electronic payment settlement.

This project uses the common Payment structure for simplicity.

---

## 16. Payment Providers

Payment gateway integration is outside the scope of the database project.

Provider transaction references are stored when available.

External systems are assumed to handle:

- Payment authorization
- Gateway communication
- Security
- Card tokenization
- Fraud detection

---

## 17. Shipment Model

A sales order may have multiple shipments.

A shipment can contain multiple ShipmentItem records.

This supports partial shipment of large orders.

---

## 18. Shipping Warehouse

Shipment currently does not directly store warehouse_id.

Warehouse context is handled during fulfillment procedures.

A future version may add warehouse assignment to Shipment.

---

## 19. Returns

A return belongs to one SalesOrder.

ReturnItem references the original OrderItem.

This ensures returned products can be traced to the original purchase.

---

## 20. Refunds

Refunds are linked to ProductReturn.

A refund is assumed to be processed only after the return reaches an eligible state.

The project does not integrate with external payment gateways for real refund execution.

---

## 21. Promotions

Promotions may apply to multiple products.

A product may participate in multiple promotions.

The project does not currently define promotion-priority rules when multiple promotions apply simultaneously.

A production platform would need explicit stacking and priority rules.

---

## 22. Coupons

A coupon may optionally belong to a promotion.

A NULL promotion_id represents an independent coupon.

The project does not maintain customer-specific coupon redemption history.

Therefore usage_count represents overall usage only.

A future version could introduce:

CouponRedemption

with fields such as:

customer_id

coupon_id

order_id

redeemed_at

---

## 23. Coupon Usage

A NULL usage_limit means the coupon can be used without a global numeric limit.

usage_count should not exceed usage_limit when a limit exists.

---

## 24. Product Reviews

A customer may submit only one review per product.

Reviews may be marked as verified purchases.

The current database stores the verified_purchase flag but does not automatically prove purchase ownership through a trigger.

A production application should validate the customer's order history before assigning verified_purchase = TRUE.

---

## 25. Review Moderation

New reviews may be created with PENDING status.

A moderator or application workflow may later change the review status to:

PUBLISHED

REJECTED

HIDDEN

Only PUBLISHED reviews should normally be included in public rating calculations.

---

## 26. Customer Segmentation

Example customer segments use the following demonstration thresholds:

HIGH VALUE:
total_spent >= PKR 400,000

MEDIUM VALUE:
total_spent >= PKR 100,000

LOW VALUE:
total_spent < PKR 100,000

These thresholds are project assumptions and are not universal retail standards.

---

## 27. Profit Calculation

Estimated gross profit is calculated using:

sales revenue - product acquisition cost

It does not include:

- Salaries
- Rent
- Marketing
- Utility costs
- Gateway fees
- Shipping overhead
- Depreciation
- Income tax

Therefore the project refers to this value as:

estimated gross profit

rather than net profit.

---

## 28. Category Revenue

Products may belong to multiple categories.

Therefore a product sale can contribute revenue to multiple category reports.

Category revenue totals should not be summed together to calculate total company revenue because this could double-count sales.

---

## 29. Audit Logging

AuditLog is a generalized audit table.

Database triggers may create audit records with:

employee_id = NULL

because a trigger does not automatically know which application employee initiated the SQL operation.

Application-level actions may include employee identifiers when available.

---

## 30. IP Address

AuditLog.ip_address uses VARCHAR(45).

This supports both:

IPv4

and

IPv6

addresses.

---

## 31. Audit JSON

AuditLog.old_values and AuditLog.new_values use JSON.

This allows different types of entities to store different audit attributes without needing a separate audit table for each entity.

---

## 32. Trigger Responsibilities

Triggers are mainly used for:

- Audit logging
- Validation
- Automatic lifecycle timestamps

Complex business workflows are handled using stored procedures and transactions rather than large triggers.

---

## 33. Transaction Isolation

Critical stock operations use:

SELECT ... FOR UPDATE

to lock inventory rows during transactions.

This reduces the risk of concurrent customers reserving the same inventory.

---

## 34. Deadlocks

Concurrent transactions may still cause deadlocks.

MySQL is expected to detect deadlocks and abort one transaction.

A production application would normally retry eligible failed transactions.

---

## 35. Sample Data

The included sample data is intended to demonstrate:

- Relationships
- JOINs
- CTEs
- Window functions
- Business analytics
- Procedures
- Functions
- Triggers
- Transactions

It is not intended to represent the volume of a production retail platform.

---

## 36. Analytics

The small sample dataset may produce limited results for:

- Month-over-month growth
- Customer segmentation
- Review averages
- Supplier performance
- Return-rate analysis

The SQL logic is designed to scale to larger datasets.

---

## 37. Soft Deactivation

Where practical, records use statuses such as:

ACTIVE

INACTIVE

DISCONTINUED

rather than deleting important historical records.

This helps preserve transaction history.

---

## 38. Hard Deletes

Foreign keys with ON DELETE CASCADE are used for selected dependent relationship tables.

Important financial and historical entities should normally be retained rather than deleted from a production system.

---

## 39. Time Zone

The project stores DATETIME values without implementing explicit multi-time-zone conversion.

The database/application is assumed to operate using one configured business timezone.

A production global system may store timestamps in UTC and convert them at the application layer.

---

## 40. Scope

The database focuses on relational database design and SQL.

The following systems are outside the current scope:

- Web frontend
- Authentication server
- Payment gateway API
- Courier API
- Email notifications
- SMS notifications
- Tax engine
- Recommendation engine
- Machine learning
- Fraud detection
- Multi-vendor marketplace settlement