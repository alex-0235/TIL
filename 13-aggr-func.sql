-- 13-aggr-func.sql

USE lecture;
SELECT * FROM sales;

-- COUNT
SELECT COUNT(*) AS 매출건수
FROM sales;

SELECT
	COUNT(*) AS 총주문건수,
-- 중복 제거 카운트
    COUNT(DISTINCT customer_id) AS 고객수,
    COUNT(DISTINCT product_name) AS 제품수
FROM sales;

-- SUM (총합)
SELECT
	SUM(total_amount) AS 총매출액,
    -- 천단위, 찍기
    FORMAT(SUM(total_amount), 0) AS 총매출,
    SUM(quantity) AS 총판매수량
FROM sales;

SELECT
	SUM(IF(region='서울', total_amount, 0)) AS 서울매출
FROM sales;

-- 서울 매출만 다 더하기
SELECT
	SUM(total_amount) AS 서울매출
FROM sales
WHERE region='서울';

SELECT
	SUM(IF(region='서울', total_amount, 0)) AS 서울매출,
    SUM(
			IF(
				category='전자제품', total_amount, 0
			)
		) AS 전자매출
FROM sales;

-- AVG(평균)
SELECT
	AVG(total_amount) AS 평균매출랙,
    AVG(quantity) AS 평균판매수량,
    ROUND(AVG(unit_price)) AS 평균단가
FROM sales;

-- MIN/MAX
SELECT
	MIN(total_amount) AS 최소매출액,
    MAX(total_amount) AS 최대매출액,
    MIN(order_date) AS 첫주문일,
    MAX(order_date) AS 마지막주문일
FROM sales;

