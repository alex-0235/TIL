CREATE DATABASE mypractice;
USE mypractice;
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  age INT
);
SHOW TABLES;
DESC users;
INSERT INTO users (name, age) VALUES ('Alice', 25);
INSERT INTO users (name, age) VALUES ('Bob', 30);
SELECT * FROM users;
ALTER TABLE users ADD email VARCHAR(100);
SELECT * FROM users;
UPDATE users SET email = 'alice@example.com' WHERE id = 2;
UPDATE users SET email = 'bob@example.com' WHERE id = 1;
SELECT * FROM users;