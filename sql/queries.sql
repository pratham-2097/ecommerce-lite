USE ecommerce_lite;

SELECT c.name AS customer_name, p.name AS product_name, pu.qty, pu.unit_price_at_purchase, pu.purchased_at
FROM Purchase pu
JOIN Customer c ON c.customer_id = pu.customer_id
JOIN Product p ON p.product_id = pu.product_id
WHERE pu.unit_price_at_purchase > 100
ORDER BY pu.purchased_at DESC;

SELECT p.product_id, p.name, p.inventory_qty, MAX(pu.purchased_at) AS last_purchased_at
FROM Product p
LEFT JOIN Purchase pu ON pu.product_id = p.product_id
WHERE p.inventory_qty < 5
GROUP BY p.product_id, p.name, p.inventory_qty
ORDER BY p.inventory_qty ASC;

SELECT c.name AS customer, cc.label, cc.last4, COUNT(pu.purchase_id) AS purchases_with_card
FROM Customer c
JOIN CreditCard cc ON cc.customer_id = c.customer_id
LEFT JOIN Purchase pu ON pu.card_id = cc.card_id
GROUP BY c.name, cc.label, cc.last4
ORDER BY c.name, purchases_with_card DESC;
