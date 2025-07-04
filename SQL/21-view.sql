-- 21-view.sql
USE lecture;

CREATE VIEW customer_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS 주문횟수,
    COALESCE(SUM(s.total_amount), 0) AS 총구매액,
    COALESCE(AVG(s.total_amount), 0) AS 평균주문액,
    COALESCE(MAX(s.order_date), '주문없음') AS 최근주문일
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type;

-- 등급별 구매 평균
SELECT 
  customer_type,
  AVG(총구매액)
FROM customer_summary
GROUP BY customer_type;

SELECT * FROM customer_summary;

-- 충성고객 -> 주문횟수 5이상
SELECT * FROM customer_summary
WHERE 주문횟수 >= 5;

-- 잠재고객 -> 최근주문 빠른 10명
SELECT * FROM customer_summary
WHERE 최근주문일 != '주문없음'
ORDER BY 최근주문일 DESC
LIMIT 10;

-- View 2: 카테고리별 성과 요약 View
-- 카테고리 별로, 총 주문건수, 총매출액, 평균주문금액, 구매고객수, 판매상품수, 매출비중(전체매출에서 해당 카테고리가 차지하는비율)

SELECT
    category_name,
    총주문건수,
    총매출액,
    평균주문금액,
    구매고객수,
    판매상품수,
    ROUND(총매출액 / 전체매출액 * 100, 2) AS 매출비중_퍼센트
FROM (
    SELECT
        s.category AS category_name,
        COUNT(s.id) AS 총주문건수,
        SUM(s.total_amount) AS 총매출액,
        ROUND(AVG(s.total_amount), 2) AS 평균주문금액,
        COUNT(DISTINCT s.customer_id) AS 구매고객수,
        COUNT(DISTINCT s.product_id) AS 판매상품수,
        (SELECT SUM(total_amount) FROM sales) AS 전체매출액
    FROM sales s
    GROUP BY s.category
) AS category_summary
ORDER BY 총매출액 DESC;

SELECT * FROM sales;

-- View 3: 월별 매출 요약
-- 년월(24-07), 월주문건수, 월평균매출액, 월활성고객수, 월신규고객수

SELECT 
  DATE_FORMAT(s.order_date, '%y-%m') AS 월,
  COUNT(s.id) AS 월주문건수,
  ROUND(AVG(s.total_amount), 2) AS 월평균매출액,
  COUNT(DISTINCT s.customer_id) AS 월활성고객수,
  
  COUNT(DISTINCT CASE 
    WHEN DATE_FORMAT(s.order_date, '%y-%m') = DATE_FORMAT(c.join_date, '%y-%m')
         THEN s.customer_id
  END) AS 월신규고객수

FROM sales s
JOIN customers c ON TRIM(s.customer_id) = TRIM(c.customer_id)
GROUP BY DATE_FORMAT(s.order_date, '%y-%m')
ORDER BY 월;