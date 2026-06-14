CREATE INDEX order_product_order_id_idx ON order_product(order_id);
CREATE INDEX orders_status_date_idx ON orders(status, date_created);

SELECT setval(
    pg_get_serial_sequence('orders', 'id'),
    (SELECT MAX(id) FROM orders)
);

SELECT setval(
    pg_get_serial_sequence('product', 'id'),
    (SELECT MAX(id) FROM product)
);
