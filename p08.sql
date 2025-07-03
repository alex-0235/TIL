-- p08.sql
-- practice DB에
USE practice;

-- lecture - sales, products 복사해오기
CREATE TABLE sales AS SELECT * FROM lecture.sales;
CREATE TABLE products AS SELECT * FROM lecture.products;

-- 단일값 서브쿼리
-- 1. 평균 이상 매출 주문들(성과가 좋은 주문들)
SELECT *
FROM sales
WHERE total_amount >= (
    SELECT AVG(total_amount)
    FROM sales
);

-- 2. 최고 매출 지역의 모든 주문들
SELECT * FROM sales
WHERE region = (
    SELECT region
    FROM sales
    GROUP BY region
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
);

-- 3. 각 카테고리에서 [카테고리별 평균] 보다 높은 주문들 (참고로 각 카테고리 별 평균 금액을 확인하는 쿼리는... SELECT category, AVG(total_amount) AS avg_total_amount FROM sales GROUP BY category;)
SELECT * FROM sales
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM sales
    WHERE category = category
);


-- 여러데이터 서브쿼리
-- 1. 기업 고객들의 모든 주문 내역 (강사님이 pass)

-- 2. 재고 부족(50개 미만) 제품의 매출 내역
SELECT * FROM sales
WHERE product_id IN (
    SELECT product_id
    FROM products
    WHERE stock_quantity < 50
);

-- 3. 상위 3개 매출 지역의 주문들
SELECT s.* FROM sales s
JOIN (
    SELECT region
    FROM (
        SELECT region, SUM(total_amount) AS total_sales
        FROM sales
        GROUP BY region
        ORDER BY total_sales DESC
        LIMIT 3
    ) AS top_regions
) AS r ON s.region = r.region;

-- 4. 상반기(24-01-01 ~ 24-06-30) 에 주문한 고객들의 하반기(0701~1231) 주문 내역
SELECT * FROM sales
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM sales
    WHERE MONTH(order_date) BETWEEN 1 AND 6
)
AND MONTH(order_date) BETWEEN 7 AND 12;