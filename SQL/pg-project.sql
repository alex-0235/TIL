-- 하 난이도

-- 1. 모든 고객 목록 조회
-- 고객의 customer_id, first_name, last_name, country를 조회하고, customer_id 오름차순으로 정렬하세요.
SELECT customer_id, first_name, last_name, country 
FROM customers
ORDER BY customer_id;

-- 2. 모든 앨범과 해당 아티스트 이름 출력
-- 각 앨범의 title과 해당 아티스트의 name을 출력하고, 앨범 제목 기준 오름차순 정렬하세요.
SELECT albums.title, artists.name
FROM albums
JOIN artists ON albums.artist_id = artists.artist_id
ORDER BY albums.title;

-- 3. 트랙(곡)별 단가와 재생 시간 조회
-- tracks 테이블에서 각 곡의 name, unit_price, milliseconds를 조회하세요.
-- 5분(300,000 milliseconds) 이상인 곡만 출력하세요.
SELECT name, unit_price, milliseconds
FROM tracks
WHERE milliseconds >= 300000;

-- 4. 국가별 고객 수 집계
-- 각 국가(country)별로 고객 수를 집계하고, 고객 수가 많은 순서대로 정렬하세요.
SELECT country, COUNT(*) AS customer_count
FROM customers
GROUP BY country
ORDER BY customer_count DESC;

-- 5. 각 장르별 트랙 수 집계
-- 각 장르(genres.name)별로 트랙 수를 집계하고, 트랙 수 내림차순으로 정렬하세요.
SELECT genres.name AS genre_name, COUNT(*) AS track_count
FROM tracks
JOIN genres ON tracks.genre_id = genres.genre_id
GROUP BY genres.name
ORDER BY track_count DESC;

-- 중 난이도
-- 1. 직원별 담당 고객 수 집계
-- 각 직원(employee_id, first_name, last_name)이 담당하는 고객 수를 집계하세요.
-- 고객이 한 명도 없는 직원도 모두 포함하고, 고객 수 내림차순으로 정렬하세요.
SELECT 
    e.employee_id, 
    e.first_name, 
    e.last_name, 
    COUNT(c.customer_id) AS customer_count
FROM employees e
LEFT JOIN customers c ON e.employee_id = c.support_rep_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY customer_count DESC;

-- 2. 가장 많이 팔린 트랙 TOP 5
-- 판매량(구매된 수량)이 가장 많은 트랙 5개(track_id, name, 총 판매수량)를 출력하세요.
-- 동일 판매수량일 경우 트랙 이름 오름차순 정렬하세요.
SELECT 
    t.track_id,
    t.name,
    SUM(ii.quantity) AS total_quantity_sold
FROM invoice_items ii
JOIN tracks t ON ii.track_id = t.track_id
GROUP BY t.track_id, t.name
ORDER BY total_quantity_sold DESC, t.name ASC
LIMIT 1000;

-- 3. 2010년 이전에 가입한 고객 목록
-- 2010년 1월 1일 이전에 첫 인보이스를 발행한 고객의 customer_id, first_name, last_name, 첫구매일을 조회하세요.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    MIN(i.invoice_date) AS "첫구매일"
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING MIN(i.invoice_date) < '2010-01-01'
ORDER BY "첫구매일";

-- 4. 국가별 총 매출 집계 (상위 10개 국가)
-- 국가(billing_country)별 총 매출을 집계해, 매출이 많은 상위 10개 국가의 국가명과 총 매출을 출력하세요.
SELECT 
    billing_country,
    SUM(total) AS "총매출"
FROM invoices
GROUP BY billing_country
ORDER BY "총매출" DESC
LIMIT 10;

-- 5. 각 고객의 최근 구매 내역
-- 각 고객별로 가장 최근 인보이스(invoice_id, invoice_date, total) 정보를 출력하세요.
SELECT 
    i.customer_id,
    i.invoice_id,
    i.invoice_date,
    i.total
FROM invoices i
INNER JOIN (
    SELECT customer_id, MAX(invoice_date) AS latest_date
    FROM invoices
    GROUP BY customer_id
) latest_invoice
ON i.customer_id = latest_invoice.customer_id
AND i.invoice_date = latest_invoice.latest_date
ORDER BY i.customer_id;


-- 상 난이도

-- 1. 월별 매출 및 전월 대비 증감률
-- 각 연월(YYYY-MM)별 총 매출과, 전월 대비 매출 증감률을 구하세요.
-- 결과는 연월 오름차순 정렬하세요.
WITH monthly_sales AS (
    SELECT 
        TO_CHAR(invoice_date, 'YYYY-MM') AS "연월",
        SUM(total) AS "총매출"
    FROM invoices
    GROUP BY TO_CHAR(invoice_date, 'YYYY-MM')
),
sales_with_diff AS (
    SELECT 
        "연월",
        "총매출",
        LAG("총매출") OVER (ORDER BY "연월") AS prev_month_sales
    FROM monthly_sales
)
SELECT 
    "연월",
    "총매출",
    ROUND(
        CASE 
            WHEN prev_month_sales = 0 OR prev_month_sales IS NULL THEN NULL
            ELSE (("총매출" - prev_month_sales) / prev_month_sales) * 100
        END, 
        2
    ) AS "전월대비증감(%)"
FROM sales_with_diff
ORDER BY "연월";

-- 2. 장르별 상위 3개 아티스트 및 트랙 수
-- 각 장르별로 트랙 수가 가장 많은 상위 3명의 아티스트(artist_id, name, track_count)를 구하세요.
-- 동점일 경우 아티스트 이름 오름차순 정렬.
WITH artist_genre_tracks AS (
    SELECT 
        g.genre_id,
        g.name AS genre_name,
        a.artist_id,
        a.name AS artist_name,
        COUNT(*) AS track_count
    FROM tracks t
    JOIN genres g ON t.genre_id = g.genre_id
    JOIN albums al ON t.album_id = al.album_id
    JOIN artists a ON al.artist_id = a.artist_id
    GROUP BY g.genre_id, g.name, a.artist_id, a.name
),
top_artists AS (
    SELECT *,
        RANK() OVER (
            PARTITION BY genre_id
            ORDER BY track_count DESC, artist_name ASC
        ) AS rank
    FROM artist_genre_tracks
)
SELECT 
    genre_name,
    artist_id,
    artist_name,
    track_count
FROM top_artists
WHERE rank <= 3
ORDER BY genre_name, rank;



-- 3. 고객별 누적 구매액 및 등급 산출
-- 각 고객의 누적 구매액을 구하고,
-- 상위 20%는 'VIP', 하위 20%는 'Low', 나머지는 'Normal' 등급을 부여하세요.
WITH customer_sales AS (
    SELECT 
        c.customer_id,
        SUM(i.total) AS "누적구매액"
    FROM customers c
    JOIN invoices i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
ranked_customers AS (
    SELECT 
        customer_id,
        "누적구매액",
        NTILE(5) OVER (ORDER BY "누적구매액" DESC) AS bucket
    FROM customer_sales
)
SELECT 
    customer_id,
    "누적구매액",
    CASE 
        WHEN bucket = 1 THEN 'VIP'
        WHEN bucket = 5 THEN 'Low'
        ELSE 'Normal'
    END AS "등급"
FROM ranked_customers
ORDER BY "누적구매액" DESC;

-- 4. 국가별 재구매율(Repeat Rate)
-- 각 국가별로 전체 고객 수, 2회 이상 구매한 고객 수, 재구매율을 구하세요.
-- 결과는 재구매율 내림차순 정렬.
WITH purchase_counts AS (
    SELECT 
        c.country,
        c.customer_id,
        COUNT(i.invoice_id) AS purchase_count
    FROM customers c
    JOIN invoices i ON c.customer_id = i.customer_id
    GROUP BY c.country, c.customer_id
),
country_summary AS (
    SELECT 
        country,
        COUNT(*) AS "전체고객수",
        COUNT(CASE WHEN purchase_count >= 2 THEN 1 END) AS "2회이상 구매고객수"
    FROM purchase_counts
    GROUP BY country
)
SELECT 
    country,
    "전체고객수",
    "2회이상 구매고객수",
    ROUND(("2회이상 구매고객수"::DECIMAL / "전체고객수") * 100, 2) AS "재구매(%)"
FROM country_summary
ORDER BY "재구매(%)" DESC;

-- 5. 최근 1년간 월별 신규 고객 및 잔존 고객
-- 최근 1년(마지막 인보이스 기준 12개월) 동안,
-- 각 월별 신규 고객 수와 해당 월에 구매한 기존 고객 수를 구하세요.
WITH customer_first AS (
    SELECT customer_id, MIN(invoice_date) AS first_date
    FROM invoices
    GROUP BY customer_id
),
last_invoice AS (
    SELECT MAX(invoice_date) AS max_date FROM invoices
),
invoice_months AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', invoice_date) AS month
    FROM invoices, last_invoice
    WHERE invoice_date >= max_date - INTERVAL '12 months'
),
classified AS (
    SELECT 
        im.month,
        im.customer_id,
        CASE 
            WHEN DATE_TRUNC('month', cf.first_date) = im.month THEN '신규고객'
            WHEN DATE_TRUNC('month', cf.first_date) < im.month THEN '잔존고객'
            ELSE NULL
        END AS 고객유형
    FROM invoice_months im
    JOIN customer_first cf ON im.customer_id = cf.customer_id
)
SELECT 
    TO_CHAR(month, 'YYYY/MM') AS "년/월",
    COUNT(DISTINCT CASE WHEN 고객유형 = '신규고객' THEN customer_id END) AS "신규고객",
    COUNT(DISTINCT CASE WHEN 고객유형 = '잔존고객' THEN customer_id END) AS "잔존고객"
FROM classified
GROUP BY month
ORDER BY "년/월";



-- 대륙별 선호 장르 Top 3
WITH genre_counts AS (
    SELECT 
        CASE
            WHEN c.country IN ('USA', 'Canada') THEN '북아메리카'
            WHEN c.country IN ('Brazil', 'Argentina', 'Chile') THEN '남아메리카'
            WHEN c.country IN ('India') THEN '아시아'
            WHEN c.country IN ('Australia') THEN '오세아니아'
            WHEN c.country IN (
                'Germany', 'France', 'United Kingdom', 'Norway', 'Sweden',
                'Austria', 'Belgium', 'Czech Republic', 'Denmark', 'Finland',
                'Hungary', 'Ireland', 'Italy', 'Netherlands', 'Poland', 'Portugal', 'Spain'
            ) THEN '유럽'
            ELSE '아프리카'  -- 남은 건 없지만 혹시 모를 예외 대비
        END AS continent,
        g.name AS genre,
        COUNT(*) AS track_count
    FROM customers c
    JOIN invoices i ON c.customer_id = i.customer_id
    JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
    JOIN tracks t ON ii.track_id = t.track_id
    JOIN genres g ON t.genre_id = g.genre_id
    GROUP BY continent, g.name
),
ranked_genres AS (
    SELECT 
        continent,
        genre,
        track_count,
        RANK() OVER (PARTITION BY continent ORDER BY track_count DESC) AS genre_rank,
        SUM(track_count) OVER (PARTITION BY continent) AS total_tracks
    FROM genre_counts
)
SELECT 
    continent,
    genre,
    genre_rank,
    track_count,
    ROUND((track_count::DECIMAL / total_tracks) * 100, 2) AS percentage
FROM ranked_genres
WHERE genre_rank <= 3
ORDER BY continent, genre_rank;

-- 각 나라/연도 별 Top 1 구매 장르, 점유율
WITH sales_data AS (
    SELECT
        c.country,
        EXTRACT(YEAR FROM i.invoice_date) AS year,
        g.name AS genre,
        SUM(ii.quantity) AS total_quantity
    FROM customers c
    JOIN invoices i ON c.customer_id = i.customer_id
    JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
    JOIN tracks t ON ii.track_id = t.track_id
    JOIN genres g ON t.genre_id = g.genre_id
    GROUP BY c.country, year, g.name
),
ranked_genres AS (
    SELECT *,
        RANK() OVER (PARTITION BY country, year ORDER BY total_quantity DESC) AS genre_rank,
        SUM(total_quantity) OVER (PARTITION BY country, year) AS yearly_total
    FROM sales_data
)
SELECT
    country,
    year,
    genre AS top_genre,
    total_quantity,
    ROUND(100.0 * total_quantity / yearly_total, 2) AS 점유율_퍼센트
FROM ranked_genres
WHERE genre_rank = 1
ORDER BY country, year;

