-- 16-subquery1.sql

USE lecture;

-- 매출 평균보다 더 높은 금액을 주문한 판매데이터(*)를 보여줘
SELECT AVG(total_amount) FROM sales;
SELECT * FROM sales WHERE total_amount > 612862;

-- 서브쿼리
SELECT * FROM sales
WHERE total_amount > (SELECT AVG(total_amount) FROM sales);

SELECT
	product_name AS 이름,
    total_amount AS 판매액,
    total_amount - (SELECT AVG(total_amount) FROM sales) AS 평균차이
FROM sales

--  평균보다 더 주문한
WHERE total_mount > (SELECT AVG(total_amount) FROM sales);

-- 데이터가 하나 나오는 경우
SELECT AVG(quantity) FROM sales;

-- sales에서 | 가장 비싼 주문
SELECT * FROM sales ORDER BY total_amount DESC LIMIT 1;
SELECT * FROM sales WHERE total_amount = (SELECT MAX(total_amount) FROM sales);

-- 가장 최근 주문일의 주문데이터
SELECT * FROM sales
WHERE order_date = (SELECT MAX(order_date) FROM sales);

-- 가장 주문액수 평균과 유사한 주문데이터 5개
SELECT * FROM sales
ORDER BY ABS(total_amount - (
    SELECT AVG(total_amount)
    FROM sales
)) ASC
LIMIT 5;














