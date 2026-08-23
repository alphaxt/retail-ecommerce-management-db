# Business Rules

This document defines the business rules for the Retail & E-Commerce Management Database.

The rules describe how customers, products, inventory, orders, payments, shipments, returns, promotions, employees, and audit records are expected to behave.

---

## 1. Customer Rules

1. Each customer must have a unique email address.

2. A customer may have multiple addresses.

3. The same address may be associated with multiple customers if required.

4. A customer-address combination must be unique.

5. A customer may have different address types such as:
   - Billing
   - Shipping
   - Home
   - Office

6. A customer may mark one address as the default address.

7. Customer status must be one of:
   - ACTIVE
   - INACTIVE
   - SUSPENDED

8. Customer passwords must never be stored as plain text.

9. Only a password hash should be stored in the database.

---

## 2. Brand Rules

1. Each brand must have a unique name.

2. Each brand must have a unique slug.

3. A brand may contain multiple products.

4. A product belongs to one brand.

5. A brand may be active or inactive.

---

## 3. Category Rules

1. Each category must have a unique name.

2. Each category must have a unique slug.

3. A product may belong to multiple categories.

4. A category may contain multiple products.

5. The ProductCategory table resolves the many-to-many relationship between Product and Category.

6. A product-category combination must be unique.

---

## 4. Product Rules

1. Every product must belong to a brand.

2. Every product must have a unique slug.

3. Product status must be one of:
   - ACTIVE
   - INACTIVE
   - DISCONTINUED

4. A product may have multiple variants.

5. A product may have multiple images.

6. A product may belong to multiple categories.

7. A product may participate in multiple promotions.

8. A product may receive multiple customer reviews.

9. Product prices must not be stored using floating-point datatypes.

10. Monetary values should use DECIMAL.

---

## 5. Product Variant Rules

1. Every product variant belongs to exactly one product.

2. Every product variant must have a unique SKU.

3. Barcode values must be unique when provided.

4. A product variant may define attributes such as:
   - Color
   - Size
   - Weight

5. A product variant has:
   - Selling price
   - Cost price

6. Product variants may exist in multiple warehouses.

7. The same variant may have different inventory quantities in different warehouses.

---

## 6. Product Image Rules

1. A product may contain multiple images.

2. Each image must belong to one product.

3. Images may have a display order.

4. An image may be marked as the primary product image.

---

## 7. Warehouse Rules

1. Each warehouse must have a unique warehouse code.

2. A warehouse may store multiple product variants.

3. The same product variant may exist in multiple warehouses.

4. Warehouse status must be one of:
   - ACTIVE
   - INACTIVE
   - MAINTENANCE

---

## 8. Inventory Rules

1. Inventory represents the stock of one product variant in one warehouse.

2. The combination of variant and warehouse must be unique.

3. Inventory maintains:
   - Quantity on hand
   - Quantity reserved
   - Reorder level

4. Reserved quantity must never exceed quantity on hand.

5. Available inventory is calculated as:

   quantity_on_hand - quantity_reserved

6. Available inventory should be checked before reserving stock.

7. Inventory should not become negative.

8. Inventory rows should be locked during critical stock transactions to prevent overselling.

---

## 9. Stock Movement Rules

1. Every stock movement belongs to an inventory record.

2. Movement quantity must always be greater than zero.

3. Direction and purpose are represented by movement type.

4. Valid movement types are:
   - PURCHASE
   - SALE
   - RETURN
   - TRANSFER_IN
   - TRANSFER_OUT
   - ADJUSTMENT

5. Stock movements may reference the business transaction that caused the movement.

6. Example reference types include:
   - SALES_ORDER
   - PURCHASE_ORDER
   - RETURN
   - INVENTORY_UPDATE

---

## 10. Supplier Rules

1. A supplier may provide multiple purchase orders.

2. Supplier tax numbers must be unique when provided.

3. Supplier status must be one of:
   - ACTIVE
   - INACTIVE
   - SUSPENDED

---

## 11. Purchase Order Rules

1. Every purchase order belongs to a supplier.

2. A purchase order may contain multiple purchase order items.

3. Expected delivery date cannot be earlier than the purchase order date.

4. Purchase order status must be one of:
   - PENDING
   - APPROVED
   - ORDERED
   - PARTIALLY_RECEIVED
   - RECEIVED
   - CANCELLED

5. Each purchase order item references one product variant.

6. The same variant should appear only once per purchase order.

7. Purchase receipt operations should update inventory and create a PURCHASE stock movement.

---

## 12. Cart Rules

1. A customer may have carts.

2. A cart may contain multiple cart items.

3. Each cart item references one product variant.

4. The same variant should not appear more than once inside the same cart.

5. Cart status must be one of:
   - ACTIVE
   - ABANDONED
   - CONVERTED
   - EXPIRED

6. Cart items store the unit price at the time they are added.

---

## 13. Wishlist Rules

1. A customer may have one or more wishlists.

2. A wishlist may contain multiple product variants.

3. A variant may appear only once in the same wishlist.

---

## 14. Sales Order Rules

1. Every sales order belongs to one customer.

2. Every sales order must have a unique order number.

3. A sales order may contain multiple order items.

4. Each order item references a product variant.

5. Sales order status must be one of:
   - PENDING
   - CONFIRMED
   - PROCESSING
   - SHIPPED
   - DELIVERED
   - CANCELLED
   - RETURNED

6. The order stores monetary values such as:
   - Subtotal
   - Discount amount
   - Tax amount
   - Shipping amount
   - Total amount

7. Currency is stored using a three-character currency code.

8. Placing an order should be treated as a transaction.

9. Order placement should validate available inventory before reservation.

10. A cancelled order should release its reserved inventory.

---

## 15. Order Item Rules

1. Every order item belongs to one sales order.

2. Every order item references one product variant.

3. Order item quantity must be positive.

4. The order item stores the selling price at the time of purchase.

5. Historical order prices should not change when the current ProductVariant price changes.

6. Line total can be calculated using:

   quantity × unit_price - discount_amount + tax_amount

---

## 16. Payment Rules

1. A sales order may have multiple payments.

2. Every payment uses one payment method.

3. Transaction references must be unique when provided.

4. Payment amount must be greater than zero.

5. Payment status must be one of:
   - PENDING
   - AUTHORIZED
   - PAID
   - FAILED
   - CANCELLED
   - REFUNDED

6. An order may use multiple payments to reach the full order total.

7. An order can be confirmed when successful payments cover the total order amount.

8. When a payment transitions to PAID, payment_date may be assigned automatically.

---

## 17. Payment Method Rules

1. Each payment method must have a unique name.

2. Payment methods may represent:
   - Cash on Delivery
   - Credit Card
   - JazzCash
   - Easypaisa
   - Other providers

3. Payment methods may be enabled or disabled.

---

## 18. Shipment Rules

1. A sales order may have multiple shipments.

2. A shipment may contain multiple shipment items.

3. A shipment item references an order item.

4. Tracking numbers must be unique when provided.

5. Shipment status must be one of:
   - PENDING
   - PACKED
   - SHIPPED
   - IN_TRANSIT
   - DELIVERED
   - FAILED
   - RETURNED

6. Delivery date cannot logically occur before shipment date.

7. Shipment information may include:
   - Carrier
   - Tracking number
   - Shipping cost
   - Estimated delivery
   - Shipped time
   - Delivered time

---

## 19. Promotion Rules

1. A promotion may apply to multiple products.

2. A product may participate in multiple promotions.

3. The PromotionProduct table resolves this many-to-many relationship.

4. Promotion discount type must be:
   - PERCENTAGE
   - FIXED_AMOUNT

5. Percentage discounts cannot exceed 100%.

6. Promotion end date must not be earlier than start date.

7. Promotions may define:
   - Minimum order amount
   - Maximum discount

8. Promotions may be active or inactive.

---

## 20. Coupon Rules

1. Every coupon must have a unique code.

2. A coupon may optionally be linked to a promotion.

3. A coupon may also operate independently.

4. Coupon discount type must be:
   - PERCENTAGE
   - FIXED_AMOUNT

5. Percentage discounts cannot exceed 100%.

6. Coupon expiry date must not be earlier than its start date.

7. Usage count must not exceed usage limit when a usage limit exists.

8. A NULL usage limit represents unlimited use.

---

## 21. Return Rules

1. A product return belongs to one sales order.

2. Every return must have a unique return number.

3. A return may contain multiple return items.

4. Each return item references an original order item.

5. Return status must be one of:
   - REQUESTED
   - APPROVED
   - REJECTED
   - RECEIVED
   - COMPLETED
   - CANCELLED

6. Return item condition must be one of:
   - UNOPENED
   - OPENED
   - USED
   - DAMAGED
   - DEFECTIVE

7. Return resolution must be one of:
   - REFUND
   - REPLACEMENT
   - STORE_CREDIT
   - REJECTED

8. Approved and received timestamps may be assigned automatically when status changes.

---

## 22. Refund Rules

1. Every refund belongs to one product return.

2. Refund amount must be greater than zero.

3. Refund transaction references must be unique when provided.

4. Refund status must be one of:
   - PENDING
   - PROCESSING
   - COMPLETED
   - FAILED
   - CANCELLED

5. A refund should only be processed for an eligible return.

6. When a refund becomes COMPLETED, processed_at may be assigned automatically.

---

## 23. Review Rules

1. A customer may review a product.

2. A customer may submit only one review per product.

3. Rating must be between 1 and 5.

4. Review status must be one of:
   - PENDING
   - PUBLISHED
   - REJECTED
   - HIDDEN

5. Reviews may be marked as verified purchases.

6. Only published reviews should normally be used in public rating calculations.

---

## 24. Employee and Role Rules

1. Every employee belongs to one role.

2. A role may be assigned to multiple employees.

3. Role names must be unique.

4. Employee email addresses must be unique.

5. Employee passwords must be stored as hashes.

6. Employee status must be one of:
   - ACTIVE
   - INACTIVE
   - SUSPENDED
   - TERMINATED

---

## 25. Audit Rules

1. Audit records store important database actions.

2. Supported audit actions include:
   - INSERT
   - UPDATE
   - DELETE
   - LOGIN
   - LOGOUT
   - STATUS_CHANGE

3. Audit records may optionally reference an employee.

4. Database-generated audit events may have employee_id set to NULL.

5. Audit records may store old and new values using JSON.

6. Audit logs should generally not be modified after creation.

---

## 26. Transaction Rules

Critical operations should use transactions.

Examples include:

- Placing an order
- Reserving inventory
- Fulfilling an order
- Cancelling an order
- Receiving purchased stock
- Processing payments
- Processing refunds

A transaction should either:

- Commit all related changes, or
- Roll back all related changes if any step fails.

Inventory rows should be locked with SELECT ... FOR UPDATE when concurrent stock modifications are possible.