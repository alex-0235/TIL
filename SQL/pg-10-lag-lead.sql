-- pg-10-lag-lead.sql

-- 매일 체중 기록
-- LAG() - 이전 값을 가져온다.
-- 전월 대비 매출 분석 시 활용

-- 매달 매출을 확인
-- 위 테이블에 증감율 컬럼 추가

-- 쌤 작성
WITH monthly_sales AS (
	SELECT
		DATE_TRUNC('month', order_date) AS 월,
		SUM(amount) as 월매출
	FROM orders
	GROUP BY 월
),
compare_before AS (
	SELECT
		TO_CHAR(월, 'YYYY-MM') as 년월,
		월매출,
		LAG(월매출, 1) OVER (ORDER BY 월) AS 전월매출
	FROM monthly_sales
)
SELECT
	*,
	월매출 - 전월매출 AS 증감액,
	CASE
		WHEN 전월매출 IS NULL THEN NULL
		ELSE ROUND((월매출 - 전월매출) * 100 / 전월매출, 2)::TEXT || '%'
	END AS 증감률
FROM compare_before
ORDER BY 년월;

-- Alex 작성 With ChatGPT 4o
WITH 월별매출 AS (
  SELECT
    DATE_TRUNC('month', order_date) AS 기준월,
    SUM(amount) AS 월매출
  FROM orders
  GROUP BY DATE_TRUNC('month', order_date)
),
전월비교 AS (
  SELECT
    TO_CHAR(기준월, 'YYYY-MM') AS "년월",
    월매출 AS "월매출",
    LAG(월매출) OVER (ORDER BY 기준월) AS "전월매출"
  FROM 월별매출
)
SELECT
  "년월",
  "월매출",
  "전월매출",
  ("월매출" - "전월매출") AS "증감액",
  ROUND(
    CASE 
      WHEN "전월매출" IS NULL OR "전월매출" = 0 THEN NULL
      ELSE (("월매출" - "전월매출") * 100.0 / "전월매출")
    END, 2
  ) AS "증감율(%)"
FROM 전월비교
ORDER BY "년월";


-- 고객별 다음 구매를 예측?
-- [고객id, 		주문일, 					구매액,
-- 		   다음구매일, 구매간격(일수), 다음구매액수, 구매금액차이]
-- 고객별로 PARTITION 필요
-- order by customer_id, order_date LIMIT 10;

-- Alex 작성 With ChatGPT 4o
WITH 고객_선택 AS (
  SELECT DISTINCT customer_id
  FROM orders
  ORDER BY customer_id
  LIMIT 10
),
고객_주문 AS (
  SELECT *
  FROM orders
  WHERE customer_id IN (SELECT customer_id FROM 고객_선택)
)
SELECT
  customer_id AS "고객ID",
  order_date AS "주문일",
  amount AS "구매액",
  LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS "다음구매일",
  LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) - order_date AS "구매간격(일수)",
  LEAD(amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS "다음구매액수",
  LEAD(amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) - amount AS "구매금액차이"
FROM 고객_주문
ORDER BY customer_id, order_date;

-- 쌤 작성
SELECT
	customer_id,
	order_date,
	amount,
	LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매일,
	LEAD(amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매금액
FROM orders
WHERE customer_id='CUST-000001'
ORDER BY customer_id, order_date

-- [고객id, 주문일, 금액, 구매 순서(ROW_NUMBER),
--	이전구매간격, 다음구매간격
-- 금액변화=(이번-저번), 금액변화율
-- 누적 구매 금액(SUM OVER)
-- [추가]누적 평균 구매 금액 (AVG OVER)
-- ]

-- Alex 작성 With ChatGPT 4o
WITH 고객_선택 AS (
  SELECT DISTINCT customer_id
  FROM orders
  ORDER BY customer_id
  LIMIT 10
),
고객_주문 AS (
  SELECT *
  FROM orders
  WHERE customer_id IN (SELECT customer_id FROM 고객_선택)
)
SELECT
  customer_id AS "고객ID",
  order_date AS "주문일",
  amount AS "금액",
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS "구매순서",
  order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS "이전구매간격(일수)",
  LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) - order_date AS "다음구매간격(일수)",
  amount - LAG(amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS "금액변화",
  ROUND(
    CASE 
      WHEN LAG(amount) OVER (PARTITION BY customer_id ORDER BY order_date) IS NULL OR 
           LAG(amount) OVER (PARTITION BY customer_id ORDER BY order_date) = 0
      THEN NULL
      ELSE ((amount - LAG(amount) OVER (PARTITION BY customer_id ORDER BY order_date)) * 100.0
            / LAG(amount) OVER (PARTITION BY customer_id ORDER BY order_date))
    END, 2
  ) AS "금액변화율(%)",
  SUM(amount) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "누적구매금액",
  ROUND(AVG(amount) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS "누적평균구매금액"
FROM 고객_주문
ORDER BY customer_id, order_date;

-- 쌤 작성
WITH customer_orders AS (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS 구매순서,
		customer_id,
		amount,
		LAG(amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 이전구매금액,
		LAG(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 이전구매일,
		order_date,
		LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS 다음구매일
	FROM orders
)
SELECT
	customer_id,
	order_date,
	amount,
	구매순서,
	-- 구매 간격
	order_date - 이전구매일 AS 이전구매간격,
	다음구매일 - order_date AS 다음구매간격,
	-- 구매금액변화
	amount - 이전구매금액 AS 금액변화,
	CASE
		WHEN 이전구매금액 IS NULL THEN NULL
		ELSE ROUND((amount - 이전구매금액) * 100 / 이전구매금액, 2)::TEXT || '%'
	END AS 금액변화율,
	--  누적 구매 통계
	SUM(amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS 누적구매금액,
	AVG(amount) OVER (
		PARTITION BY customer_id
		ORDER BY order_date
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  -- 현재 확인중인 ROW 부터 맨 앞까지
		-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW  -- 현재 확인중인 ROW 포함 총 3개
	) AS 평균구매금액,
	-- 고객 구매 단계 분류
	CASE
		WHEN 구매순서 = 1 THEN '첫구매'
		WHEN 구매순서 <= 3 THEN '초기고객'
		WHEN 구매순서 <= 10 THEN '일반고객'
		ELSE 'VIP고객'
	END AS 고객단계
FROM customer_orders
ORDER BY customer_id, order_date;



SELECT * FROM orders;  -- 데이터 확인