-- 20-subquery3.sql

USE lecture;

-- 각 카테고리 별 평균매출중에서 50만원 이상만 구하기 [샘 작성]
SELECT 
  category,
  AVG(total_amount) AS 평균매출액
FROM sales GROUP BY category
HAVING 평균매출액 > 500000;

-- 인라인 뷰(View) => 내가 만든 테이블
SELECT *
FROM (
  SELECT 
    category,
  AVG(total_amount) AS 평균매출액
  FROM sales GROUP BY category
) AS cateogry_summary
WHERE 평균매출액 >= 500000;

--  category_suammry
-- ┌─────────────┬─────────────┐
-- │  category   │   평균매출액   │
-- ├─────────────┼─────────────┤
-- │  전자제품     │   890,000   │
-- │  의류        │   420,000   │
-- │  생활용품     │   650,000   │
-- │  식품        │   180,000   │
-- └─────────────┴─────────────┘
-- SELECT * FROM category_summary WHERE 평균매출액 > 500000

--------------------------------------------------------------------

-- 각 카테고리 평균매출중에서 50만원 이상의 카테고리 [장기진 작성 with Chat GPT)
SELECT 
    category,
    COUNT(id) AS order_count,
    SUM(total_amount) AS total_sales,
    ROUND(AVG(total_amount), 2) AS avg_order_amount
FROM sales GROUP BY category
HAVING AVG(total_amount) >= 500000
ORDER BY avg_order_amount DESC;

-- 1. 카테고리 별 매출 분석 후 필터링
-- 카테고리명, 주문건수, 총매출, 평균매출, 40만원 미만 저단가, 80만원 미만 중단가 80만원 미만은 고단가로 표시함 
SELECT 
    s.category AS category_name,
    COUNT(s.id) AS order_count,
    SUM(s.total_amount) AS total_sales,
    ROUND(AVG(s.total_amount), 2) AS avg_order_amount,
    
    CASE
        WHEN AVG(s.total_amount) < 400000 THEN '저단가'
        WHEN AVG(s.total_amount) < 800000 THEN '중단가'
        ELSE '고단가'
    END AS 평균매출구분
FROM sales s
GROUP BY s.category
ORDER BY avg_order_amount DESC;


-- 영업사월 별 성과 등급 분류 [영업사원, 총매출액, 주문건수, 평균주문액, 매출등급, 주문등급]
-- 매출등급- 총매출[0 < C <= 백만 < B < 3백만 <= A < 5백만 <= S]
-- 주문등급 - 주문건수 [0 <= C < 15 <= B < 30 <= A]
-- ORDFR BY 총매출액 DESC

-- [장기진 작성 with Chat GPT] 
SELECT
    s.sales_rep AS 영업사원명,
    SUM(s.total_amount) AS 총매출액,
    COUNT(s.id) AS 주문건수,
    ROUND(AVG(s.total_amount), 2) AS 평균주문액,
    -- 매출등급
    CASE
        WHEN SUM(s.total_amount) <= 1000000 THEN 'C'
        WHEN SUM(s.total_amount) < 3000000 THEN 'B'
        WHEN SUM(s.total_amount) < 5000000 THEN 'A'
        ELSE 'S'
    END AS 매출등급,
    -- 주문등급
    CASE
        WHEN COUNT(s.id) < 15 THEN 'C'
        WHEN COUNT(s.id) < 30 THEN 'B'
        ELSE 'A'
    END AS 주문등급

FROM sales s
GROUP BY s.sales_rep
ORDER BY 총매출액 DESC;

-- HOXY 영업사원이 등록되어 있지 않은 매출이 있을수도 있으니... 해당 내용 확인 쿼리!!!
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM sales 
            WHERE sales_rep IS NULL OR TRIM(sales_rep) = ''
        ) THEN 'O'
        ELSE 'X'
    END AS 영업사원_미입력여부;

-- [샘 작성]
SELECT
  영업사원, 총매출액, 주문건수, 평균주문액,
  CASE
    WHEN 총매출액 >= 15000000 THEN 'S'
    WHEN 총매출액 >= 3000000 THEN 'A'
    WHEN 총매출액 >= 1000000 THEN 'B'
    ELSE 'C'
  END AS 매출등급,
  CASE
    WHEN 주문건수 >= 20 THEN 'A'
    WHEN 주문건수 >= 10 THEN 'B'
    ELSE 'C'
  END AS 주문등급
FROM (
  SELECT
    coalesce(sales_rep, '확인불가') AS 영업사원,
    SUM(total_amount) AS 총매출액,
    COUNT(*) AS 주문건수,
    AVG(total_amount) AS 평균주문액
  FROM sales
  GROUP BY sales_rep
) AS rep_analyze
ORDER BY 총매출액 DESC;
