-- p09.sql
USE practice;

DROP TABLE sales;
DROP TABLE products;
DROP TABLE customers;

CREATE TABLE sales AS SELECT * FROM lecture.sales;
CREATE TABLE products AS SELECT * FROM lecture.products;
CREATE TABLE customers AS SELECT * FROM lecture.customers;

SELECT COUNT(*) FROM sales
UNION
SELECT COUNT(*) FROM customers;

-- 주문 거래액이 가장 높은 10건을 높은순으로 [고객명, 상품명, 주문금액]을 보여주자.
SELECT
  c.customer_name AS 고객명,
  s.product_name AS 상품명,
  s.total_amount AS 주문금액
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
ORDER BY s.total_amount DESC
LIMIT 10;
-- 고객 유형별 [고객유형, 주문건수, 평균주문금액] 을 평균주문금액 높은순으로 정렬해서 보여주자.
SELECT
  c.customer_type AS 고객유형,
  COUNT(*) AS 주문건수,
  AVG(s.total_amount) AS 평균주문금액
FROM customers c
-- INNER JOIN 은 구매자들끼리 평균 / customers LEFT JOIN 는 모든 고객을 분석
INNER JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_type;

-- 문제 1: 모든 고객의 이름과 구매한 상품명 조회
SELECT
  c.customer_name AS 고객명,
  coalesce(s.product_name, '🙀') AS 상품명
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
ORDER BY c.customer_name;

-- 문제 2: 고객 정보와 주문 정보를 모두 포함한 상세 조회
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_type,
    c.join_date,
    s.id AS order_id,
    s.order_date,
    s.product_id,
    s.product_name,
    s.quantity,
    s.unit_price,
    s.total_amount,
    s.sales_rep,
    s.region
FROM customers c
LEFT JOIN sales s 
    ON TRIM(c.customer_id) = TRIM(s.customer_id)
ORDER BY c.customer_id, s.order_date;

-- 문제 3: VIP 고객들의 구매 내역만 조회
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_type,
    s.id AS order_id,
    s.order_date,
    s.product_id,
    s.product_name,
    s.quantity,
    s.unit_price,
    s.total_amount,
    s.sales_rep,
    s.region
FROM customers c
JOIN sales s 
    ON TRIM(c.customer_id) = TRIM(s.customer_id)
WHERE c.customer_type = 'VIP'
ORDER BY s.order_date DESC;

-- 문제 4: 건당 50만원 이상 주문한 기업 고객들
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_type,
    s.id AS order_id,
    s.order_date,
    s.product_id,
    s.product_name,
    s.quantity,
    s.unit_price,
    s.total_amount,
    s.sales_rep,
    s.region
FROM customers c
JOIN sales s 
    ON TRIM(c.customer_id) = TRIM(s.customer_id)
WHERE c.customer_type = '기업'
  AND s.total_amount >= 500000
ORDER BY s.total_amount DESC;

-- 문제 5: 2024년 하반기(7월~12월) 전자제품 구매 내역
SELECT 
    s.id AS order_id,
    s.order_date,
    s.customer_id,
    s.product_id,
    s.product_name,
    s.category,
    s.quantity,
    s.unit_price,
    s.total_amount,
    s.sales_rep,
    s.region
FROM sales s
WHERE s.category = '전자제품'
  AND s.order_date BETWEEN '2024-07-01' AND '2024-12-31'
ORDER BY s.order_date;

-- 문제 6: 고객별 주문 통계 (INNER JOIN) [고객명, 유형, 주문횟수, 총구매, 평균구매, 최근주문일]
SELECT 
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS order_count,
    COALESCE(SUM(s.total_amount), 0) AS total_amount,
    ROUND(COALESCE(AVG(s.total_amount), 0), 2) AS avg_amount,
    MAX(s.order_date) AS last_order_date
FROM customers c
LEFT JOIN sales s 
    ON TRIM(c.customer_id) = TRIM(s.customer_id)
GROUP BY c.customer_id, c.customer_name, c.customer_type
ORDER BY total_amount DESC;

-- 문제 7: 모든 고객의 주문 통계 (LEFT JOIN) - 주문 없는 고객도 포함
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS order_count,
    COALESCE(SUM(s.total_amount), 0) AS total_amount,
    ROUND(COALESCE(AVG(s.total_amount), 0), 2) AS avg_amount,
    MAX(s.order_date) AS last_order_date
FROM customers c
LEFT JOIN sales s 
    ON TRIM(c.customer_id) = TRIM(s.customer_id)
GROUP BY c.customer_id, c.customer_name, c.customer_type
ORDER BY total_amount DESC;

-- 문제 8: 카테고리별 고객 유형 분석
SELECT 
    s.category,
    c.customer_type,
    COUNT(s.id) AS order_count,
    SUM(s.total_amount) AS total_amount,
    ROUND(AVG(s.total_amount), 2) AS avg_amount
FROM sales s
JOIN customers c 
    ON TRIM(s.customer_id) = TRIM(c.customer_id)
GROUP BY s.category, c.customer_type
ORDER BY s.category, total_amount DESC;

-- 문제 9: 고객별 등급 분류
-- 활동등급(구매횟수) : [0(잠재고객) < 브론즈 < 3 <= 실버 < 5 <= 골드 < 10 <= 플래티넘]
-- 구매등급(구매총액) : [0(신규) < 일반 <= 10만 < 우수 <= 20만 < 최우수 < 50만 <= 로얄]
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS order_count,
    COALESCE(SUM(s.total_amount), 0) AS total_amount,

    -- 활동 등급 (구매 횟수 기준)
    CASE
        WHEN COUNT(s.id) = 0 THEN '잠재고객'
        WHEN COUNT(s.id) < 3 THEN '브론즈'
        WHEN COUNT(s.id) < 5 THEN '실버'
        WHEN COUNT(s.id) < 10 THEN '골드'
        ELSE '플래티넘'
    END AS activity_grade,

    -- 구매 등급 (총 구매 금액 기준)
    CASE
        WHEN SUM(s.total_amount) IS NULL OR SUM(s.total_amount) = 0 THEN '신규'
        WHEN SUM(s.total_amount) < 100000 THEN '일반'
        WHEN SUM(s.total_amount) < 200000 THEN '우수'
        WHEN SUM(s.total_amount) < 500000 THEN '최우수'
        ELSE '로얄'
    END AS purchase_grade

FROM customers c
LEFT JOIN sales s 
    ON TRIM(c.customer_id) = TRIM(s.customer_id)
GROUP BY c.customer_id, c.customer_name, c.customer_type
ORDER BY total_amount DESC;

-- 문제 10: 활성 고객 분석
-- 고객상태(최종구매일) [NULL(구매없음) | 활성고객 <= 30 < 관심고객 <= 90 관심고객 < 휴면고객]별로 
-- 고객수, 총주문건수, 총매출액, 평균주문금액 분석

SELECT
  customer_status,
  COUNT(customer_id) AS customer_count,
  SUM(order_count) AS total_orders,
  SUM(total_amount) AS total_sales,
  ROUND(SUM(total_amount) / NULLIF(SUM(order_count), 0), 2) AS avg_order_amount
FROM (
  SELECT 
    c.customer_id,
    CASE
      WHEN MAX(s.order_date) IS NULL THEN '미구매'
      WHEN DATEDIFF('2024-12-31', MAX(s.order_date)) <= 30 THEN '활성고객'
      WHEN DATEDIFF('2024-12-31', MAX(s.order_date)) <= 90 THEN '관심고객'
      ELSE '휴면고객'
    END AS customer_status,
    COUNT(s.id) AS order_count,
    COALESCE(SUM(s.total_amount), 0) AS total_amount
  FROM customers c
  LEFT JOIN sales s ON TRIM(c.customer_id) = TRIM(s.customer_id)
  GROUP BY c.customer_id
) AS customer_summary
GROUP BY customer_status
ORDER BY FIELD(customer_status, '활성고객', '관심고객', '휴면고객', '미구매');

-----------------------------------------------------------------------------------



SELECT * FROM customers;

