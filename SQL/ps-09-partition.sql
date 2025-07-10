-- pg-09-partition.sql

-- PARTITION BY -> 데이터를 특정 그룹으로 나누고, Window 함수로 결과를 확인
-- 동(1~4) | 층(15, 10, 20) | 호수 | 이름
-- 101 | 20 | 2001 |  <- 101동 에서는 1위
-- 102 | 15 | 2001 |  <- 102동 에서는 1위
-- 103 | 10 | 2001 |
-- 104 | 20 | 2001 |

-- 체육대회. 1, 2, 3 학년 -> 한번에 "학년 순위 | 전체 순위" 를 확인할 수 있다ㄴ

SELECT 
	region,
	customer_id,
	amount,
	ROW_NUMBER() OVER (ORDER BY amount DESC) AS 전체순위,
	ROW_NUMBER() OVER (PARTITION BY region ORDER BY amount DESC) AS 지역순위,
	RANK() OVER (ORDER BY amount DESC) AS 전체순위,
	RANK() OVER (PARTITION BY region ORDER BY amount DESC) AS 지역순위,
	DENSE_RANK() OVER (ORDER BY amount DESC) AS 전체순위,
	DENSE_RANK() OVER (PARTITION BY region ORDER BY amount DESC) AS 지역순위
FROM orders LIMIT 10;


-- SUM() OVER()
-- 일별 누적 매출액
WITH daily_sales AS (
	SELECT
		order_date,
		SUM(amount) AS 일매출
	FROM orders
	WHERE order_date BETWEEN '2024-06-01' AND '2024-08-31'
	GROUP BY order_date
	ORDER BY order_date
)
SELECT
	order_date,
	일매출,
	-- 범위 내에서 계속 누적
	SUM(일매출) OVER (ORDER BY order_date) as 누적매출,
	-- 범위 내에서, PARTITION 바뀔 때 초기화.
	SUM(일매출) OVER (
		PARTITION BY DATE_TRUNC('month', order_date)
		ORDER BY order_date
	) as 월누적매출
FROM daily_sales;

-- AVG() OVER()

WITH daily_sales AS (
	SELECT
		order_date,
		SUM(amount) AS 일매출,
		COUNT(*) AS 주문수
	FROM orders
	WHERE order_date BETWEEN '2024-06-01' AND '2024-08-31'
	GROUP BY order_date
	ORDER BY order_date
)
SELECT
	order_date,
	일매출,
	주문수,
	ROUND(AVG(일매출) OVER(
		ORDER BY order_date
		ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
	)) AS 이동평균7일,
	ROUND(AVG(일매출) OVER(
		ORDER BY order_date
		ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
	)) AS 이동평균3일
FROM daily_sales;


SELECT
	region,
	order_date,
	amount,
	AVG(amount) OVER (PARTITION BY region ORDER BY order_date) as 지역매출누적평균
FROM orders
WHERE order_date BETWEEN '2024-07-01' AND '2024-07-02';


-- 카테고리 별 인기 상품 TOP 5
-- CTE
-- [상품 카테고리, 상품ID, 상품이름, 상품가격, 해당상품의 주문건수, 해당상품판매개수, 해당상품총매출]
-- 총데이터 표시(매출순위 1~5위 기준으로 표시)

WITH product_sales AS (
  SELECT
    p.category,
    p.product_id,
    p.product_name,
    p.price,
    COUNT(o.order_id) AS order_count,
    SUM(o.quantity) AS total_quantity,
    SUM(o.amount) AS total_sales
  FROM products p
  JOIN orders o ON p.product_id = o.product_id
  GROUP BY p.category, p.product_id, p.product_name, p.price
),
ranked_sales AS (
  SELECT *,
         RANK() OVER (PARTITION BY category ORDER BY total_sales DESC) AS sales_rank
  FROM product_sales
)
SELECT
  category,
  product_id,
  product_name,
  price,
  order_count,
  total_quantity,	
  total_sales
FROM ranked_sales
WHERE sales_rank <= 5
ORDER BY category, sales_rank;



SELECT * FROM orders;  -- 데이터 확인