CREATE DATABASE marketplace_umov;
\connect marketplace_umov
CREATE TABLE sellers (id SERIAL PRIMARY KEY, company_name VARCHAR(100) NOT NULL, inn VARCHAR(12) NOT NULL UNIQUE, rating DECIMAL(3,2) NOT NULL CHECK (rating BETWEEN 0 AND 5));
CREATE TABLE products (id SERIAL PRIMARY KEY, product_name VARCHAR(200) NOT NULL, seller_id INT NOT NULL, price DECIMAL(10,2) NOT NULL CHECK (price >= 0), stock INT NOT NULL CHECK (stock >= 0));
CREATE TABLE customers (id SERIAL PRIMARY KEY, full_name VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL UNIQUE, phone VARCHAR(20));
CREATE TABLE orders (id SERIAL PRIMARY KEY, customer_id INT NOT NULL, product_id INT NOT NULL, quantity INT NOT NULL CHECK (quantity > 0), total DECIMAL(10,2) NOT NULL CHECK (total >= 0), order_date DATE NOT NULL);
INSERT INTO sellers(company_name,inn,rating) VALUES
 ('ООО "ТехноМир"','770123456789',4.80),('ИП Иванов А.А.','770987654321',4.20),('ООО "ЭкоПродукт"','770555444333',4.90),('ООО "СтройМастер"','770111222333',3.70);
INSERT INTO products(product_name,seller_id,price,stock) VALUES
 ('Смартфон Galaxy X',1,59990.00,15),('Ноутбук Pro 15',1,89990.00,8),('Наушники AirSound',2,12990.00,30),('Кофеварка BrewMaster',3,8990.00,12),('Пылесос CleanHome',3,15990.00,5),('Дрель MasterTool',4,6490.00,20),('Товар без продавца',999,1000.00,1);
INSERT INTO customers(full_name,email,phone) VALUES
 ('Иванов Иван Иванович','ivanov@mail.ru','+7-999-111-22-33'),('Петрова Анна Сергеевна','petrova@mail.ru','+7-999-222-33-44'),('Сидоров Пётр Алексеевич','sidorov@mail.ru','+7-999-333-44-55'),('Кузнецова Мария Игоревна','kuznetsova@mail.ru','+7-999-444-55-66');
INSERT INTO orders(customer_id,product_id,quantity,total,order_date) VALUES
 (1,1,1,59990.00,'2026-09-01'),(1,3,2,25980.00,'2026-09-02'),(2,2,1,89990.00,'2026-09-03'),(3,4,1,8990.00,'2026-09-04'),(3,5,1,15990.00,'2026-09-05'),(4,6,3,19470.00,'2026-09-06'),(999,1,1,59990.00,'2026-09-07');
SELECT p.id,p.product_name,p.price,s.company_name FROM products p LEFT JOIN sellers s ON p.seller_id=s.id ORDER BY p.id;
INSERT INTO sellers(company_name,inn,rating) VALUES ('ООО "Новый продавец"','771234567890',4.10);
INSERT INTO customers(full_name,email,phone) VALUES ('Покупатель без заказов','no_orders@mail.ru','+7-999-555-66-77');
SELECT s.id,s.company_name,p.product_name,p.price FROM products p RIGHT JOIN sellers s ON p.seller_id=s.id ORDER BY s.id,p.id;
SELECT 'Товар без продавца'::text AS нарушение,p.id AS запись_id,p.product_name AS объект FROM products p LEFT JOIN sellers s ON p.seller_id=s.id WHERE s.id IS NULL
UNION ALL
SELECT 'Заказ без покупателя',o.id,'Заказ покупателя ' || o.customer_id FROM orders o LEFT JOIN customers c ON o.customer_id=c.id WHERE c.id IS NULL;
SELECT s.id,s.company_name,COUNT(p.id) AS product_count FROM sellers s LEFT JOIN products p ON s.id=p.seller_id GROUP BY s.id,s.company_name ORDER BY product_count DESC,s.id;
SELECT c.id,c.full_name,COUNT(o.id) AS order_count,COALESCE(SUM(o.total),0)::numeric(12,2) AS total_sum FROM customers c LEFT JOIN orders o ON c.id=o.customer_id GROUP BY c.id,c.full_name ORDER BY total_sum DESC,c.id;
DELETE FROM products p WHERE NOT EXISTS (SELECT 1 FROM sellers s WHERE s.id=p.seller_id);
INSERT INTO products(product_name,seller_id,price,stock) VALUES ('Товар для исправления',999,1000.00,2);
UPDATE products SET seller_id=1 WHERE product_name='Товар для исправления' AND seller_id=999;
UPDATE products SET seller_id=999 WHERE product_name='Товар для исправления';
INSERT INTO sellers(id,company_name,inn,rating) VALUES (999,'ООО Восстановленный продавец','999999999999',4.50);
INSERT INTO customers(id,full_name,email,phone) VALUES (999,'Восстановленный покупатель','customer999@mail.ru','+7-999-999-99-99');
ALTER TABLE products ADD CONSTRAINT fk_products_seller FOREIGN KEY (seller_id) REFERENCES sellers(id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_product FOREIGN KEY (product_id) REFERENCES products(id);
SELECT (SELECT COUNT(*) FROM products p LEFT JOIN sellers s ON p.seller_id=s.id WHERE s.id IS NULL) AS products_without_seller,
       (SELECT COUNT(*) FROM orders o LEFT JOIN customers c ON o.customer_id=c.id WHERE c.id IS NULL) AS orders_without_customer;
