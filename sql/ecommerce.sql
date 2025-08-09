DROP DATABASE IF EXISTS ecommerce_lite;
CREATE DATABASE ecommerce_lite CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE ecommerce_lite;

CREATE TABLE Customer (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Staff (
  staff_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Product (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  category VARCHAR(100),
  price DECIMAL(10,2) NOT NULL,
  inventory_qty INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_by_staff_id INT NULL,
  CONSTRAINT fk_product_staff FOREIGN KEY (created_by_staff_id) REFERENCES Staff(staff_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE CreditCard (
  card_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  label VARCHAR(100),
  last4 CHAR(4) NOT NULL,
  CONSTRAINT fk_card_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_card_customer (customer_id)
) ENGINE=InnoDB;

CREATE TABLE Purchase (
  purchase_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  product_id INT NOT NULL,
  card_id INT NOT NULL,
  qty INT NOT NULL,
  unit_price_at_purchase DECIMAL(10,2) NOT NULL,
  purchased_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_purchase_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_purchase_product FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_purchase_card FOREIGN KEY (card_id) REFERENCES CreditCard(card_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_purchase_customer (customer_id),
  INDEX idx_purchase_product (product_id),
  INDEX idx_purchase_card (card_id)
) ENGINE=InnoDB;

INSERT INTO Staff (name, email) VALUES
('Admin One','admin@example.com');

INSERT INTO Customer (name, email) VALUES
('Alice Chen','alice@example.com'),
('Brian Gomez','brian@example.com'),
('Priya Singh','priya@example.com');

INSERT INTO Product (name, category, price, inventory_qty, is_active, created_by_staff_id) VALUES
('Wireless Mouse','Peripherals',25.99,20,TRUE,1),
('Mechanical Keyboard','Peripherals',89.00,10,TRUE,1),
('USB-C Hub (7-port)','Adapters',45.00,15,TRUE,1),
('27\" 4K Monitor','Displays',279.99,5,TRUE,1),
('Noise-Canceling Headphones','Audio',129.99,7,TRUE,1),
('HDMI Cable (2m)','Cables',9.99,50,TRUE,1),
('Old Model Webcam','Cameras',39.99,0,FALSE,1);

INSERT INTO CreditCard (customer_id, label, last4) VALUES
(1,'Personal Visa','4242'),
(2,'MC Travel','5512'),
(2,'Backup Visa','0011'),
(3,'Amex','3005');

INSERT INTO Purchase (customer_id, product_id, card_id, qty, unit_price_at_purchase, purchased_at) VALUES
(1,2,1,1,89.00,NOW() - INTERVAL 7 DAY),
(2,1,2,2,25.99,NOW() - INTERVAL 6 DAY),
(3,5,4,1,129.99,NOW() - INTERVAL 5 DAY),
(2,4,2,1,279.99,NOW() - INTERVAL 4 DAY),
(1,3,1,1,45.00,NOW() - INTERVAL 3 DAY),
(3,6,4,3,9.99,NOW() - INTERVAL 2 DAY),
(2,2,3,1,89.00,NOW() - INTERVAL 1 DAY),
(1,1,1,1,25.99,NOW());
