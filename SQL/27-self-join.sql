-- 27-self-join.sql

SELECT * FROM employees;
-- id 가 1 차이나면 적은사람이 상사, 많은사람이 직원
SELECT
  상사.name AS 상사명,
  직원.name AS 직원명
FROM employees 상사
LEFT JOIN employees 직원 ON 직원.id = 상사.id + 1;

-- 고객 간 구매 패턴 유사성
-- customers <-ij-> sales <-ij-> customers
-- [손님1, 손님2, 공통구매카테고리수, 공통카테고리이름(GROUP_CONACT)]

SELECT
	c1.customer_name AS customer1,
    c2.customer_name AS customer2,
    COUNT(DISTINCT s1.category) AS common_category_count,
    GROUP_CONCAT(DISTINCT s1.category SEPARATOR ', ') AS common_categories
FROM customers c1
JOIN sales s1 ON c1.customer_id = s1.customer_id

JOIN customers c2 ON c1.customer_id < c2.customer_id
JOIN sales s2 ON c2.customer_id = s2.customer_id
	AND s1.category = s2.category

GROUP BY c1.customer_id, c2.customer_id
ORDER BY common_category_count DESC;




SELECT * FROM sales;
SELECT * FROM customers;