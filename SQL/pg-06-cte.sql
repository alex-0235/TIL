-- pg-06-cte.sql

-- CTE (Common Table Expression) -> 쿼리 속의 '이름이 있는' 임시 테이블
-- 가독성: 복잡한 쿼리를 단계별로 나누어 이해하기 쉬움
-- 재사용: 한 번 정의한 결과를 여러 번 사용 가능
-- 유지보수: 각 단계별로 수정이 용이
-- 디버깅: 단계별로 결과를 확인할 수 있음


--[평균 주문 금액] 보다 큰 주문들의 고객 정보

-- Alex 씀. With ChatGPT [order_amount가 평균보다 큰 금액에서 중복 고객 제외]
SELECT DISTINCT c.*
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.amount > (
    SELECT AVG(amount) FROM orders
)
LIMIT 10;


-- 쌤 작성.
SELECT c.customer_name, o.amount
FROM customers c
INNER JOIN orders o ON c.customer_id=o.customer_id
WHERE o.amount > (SELECT AVG(amount) FROM orders)
LIMIT 10;

EXPLAIN ANALYSE  -- 1.58
WITH avg_order AS (
    SELECT AVG(amount) as avg_amount
    FROM orders
)
SELECT c.customer_name, o.amount, ao.avg_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN avg_order ao ON o.amount > ao.avg_amount
LIMIT 10;


-- 서브쿼리가 여러 번 실행됨 (비효율적)
EXPLAIN ANALYSE  -- 4.75
SELECT 
    customer_id,
    (SELECT AVG(amount) FROM orders) as avg_amount,
    amount,
    amount - (SELECT AVG(amount) FROM orders) as diff
FROM orders
WHERE amount > (SELECT AVG(amount) FROM orders);

-- 각 월마다 매출과, 전월

WITH 
	aaa AS (),
	bbb AS (),
	ccc AS ()
SELECT 


-- 각 지역별 주문한 고객 수와 주문 수를 계산하세요.
SELECT 
    COALESCE(c.region, o.region) AS region,
    c.customer_count,
    o.order_count
FROM (
    SELECT region, COUNT(*) AS customer_count
    FROM customers
    GROUP BY region
) c
FULL OUTER JOIN (
    SELECT region, COUNT(*) AS order_count
    FROM orders
    GROUP BY region
) o ON c.region = o.region
ORDER BY region;

-- 지역별 평균 주문 금액도 함께 표시하세요
SELECT
    region,
    COUNT(DISTINCT customer_id) AS customer_count,
    COUNT(*) AS order_count,
    AVG(amount)::NUMERIC(12,2) AS avg_order_amount
FROM orders
GROUP BY region
ORDER BY region;

--고객 수가 많은 지역 순으로 정렬하세요
WITH customer_region_count AS (
    SELECT region, COUNT(*) AS customer_count
    FROM customers
    GROUP BY region
)
SELECT
    o.region,
    c.customer_count,
    COUNT(*) AS order_count,
    AVG(o.amount)::NUMERIC(12,2) AS avg_order_amount
FROM orders o
JOIN customer_region_count c ON o.region = c.region
GROUP BY o.region, c.customer_count
ORDER BY c.customer_count DESC;

-- 먼저 지역별 기본 통계[ 지역명, 고객수, 주문수, 평균주문금액 ]를 CTE로 쿼리 짠 경우
WITH region_summary AS (
    SELECT
        region,
        COUNT(DISTINCT customer_id) AS customer_count,
        COUNT(*) AS order_count,
        AVG(amount)::NUMERIC(12,2) AS avg_order_amount
    FROM orders
    GROUP BY region
)
SELECT *
FROM region_summary;


-- 각 상품의 총 판매량과 총 매출액을 계산하는데 상품 카테고리별로 그룹화하여 표시하고
-- 각 카테고리 내에서 매출액이 높은 순서로 정렬. 추가로 각 상품의 평균 주문 금액도 
-- 함께 표시해 주는 쿼리... 단 , 인덱싱 등 성능 효율화를 반영한 쿼리.

WITH product_sales AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(o.quantity) AS total_quantity,
        SUM(o.amount)::NUMERIC(14,2) AS total_sales,
        AVG(o.amount)::NUMERIC(14,2) AS avg_order_amount
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT *
FROM product_sales
ORDER BY category, total_sales DESC;


-- 각 상품 카테고리 중 최고 매출을 달성한 상품의 총매출액
WITH product_sales AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(o.amount)::NUMERIC(14,2) AS total_sales
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_id, p.product_name
),
ranked_sales AS (
    SELECT *,
           RANK() OVER (PARTITION BY category ORDER BY total_sales DESC) AS rnk
    FROM product_sales
)
SELECT category, product_id, product_name, total_sales
FROM ranked_sales
WHERE rnk = 1
ORDER BY total_sales DESC;


-- 고객 구매금액에 따라 VIP(상위 20%) / 일반(전체평균보다 높음) / 신규(나머지) 로 나누어
-- 등급통계를 보자.
-- [등급, 등급별 회원수, 등급별 구매액 총합, 등급별 평균 주문수]
-- 중간 계산은 최소화, 인덱스 기반

WITH customer_orders AS (
    SELECT
        customer_id,
        SUM(amount) AS total_spent,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
),
-- 상위 20% 기준선 계산 (PERCENTILE은 비싼 연산이므로 이 단계만 비용 높음)
-- Alex 씀. With ChatGPT 
cutoff AS (
    SELECT PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY total_spent) AS vip_cutoff
    FROM customer_orders
),
-- 전체 평균
avg_spent AS (
    SELECT AVG(total_spent) AS avg_total
    FROM customer_orders
),
-- 등급 매핑
classified AS (
    SELECT
        c.customer_id,
        c.total_spent,
        c.order_count,
        CASE
            WHEN c.total_spent >= ct.vip_cutoff THEN 'VIP'
            WHEN c.total_spent > avg.avg_total THEN '일반'
            ELSE '신규'
        END AS grade
    FROM customer_orders c
    CROSS JOIN cutoff ct
    CROSS JOIN avg_spent avg
)
-- 등급별 통계 요약
SELECT
    grade,
    COUNT(*) AS member_count,
    SUM(total_spent)::NUMERIC(14,2) AS total_spending,
    ROUND(AVG(order_count), 2) AS avg_orders
FROM classified
GROUP BY grade
ORDER BY 
    CASE grade
        WHEN 'VIP' THEN 1
        WHEN '일반' THEN 2
        ELSE 3
    END;

-- 쌤 작성
-- 1. 고객별 총 구매 금액 + 주문수
WITH customer_total AS (
	SELECT
		customer_id,
		SUM(amount) as 총구매액,
		COUNT(*) AS 총주문수
	FROM orders
	GROUP BY customer_id
),
-- 2. 구매 금액 기준 계산
purchase_threshold AS (
	SELECT
		AVG(총구매액) AS 일반기준,
		-- 상위 20% 기준값 구하기
		PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY 총구매액) AS vip기준
	FROM customer_total
),
-- 3. 고객 등급 분류
customer_grade AS (
	SELECT
		ct.customer_id,
		ct.총구매액,
		ct.총주문수,
		CASE 
			WHEN ct.총구매액 >= pt.vip기준 THEN 'VIP'
			WHEN ct.총구매액 >= pt.일반기준 THEN '일반'
			ELSE '신규'
		END AS 등급
	FROM customer_total ct
	CROSS JOIN purchase_threshold pt
)
-- 4. 등급별 통계 출력
SELECT
	등급,
	COUNT(*) AS 등급별고객수,
	SUM(총구매액) AS 등급별총구매액,
	ROUND(AVG(총주문수), 2) AS 등급별평균주문수
FROM customer_grade
GROUP BY 등급




