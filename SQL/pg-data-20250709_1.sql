-- 외래 키 제약 조건 때문에 순서대로 삭제
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- 고객 테이블 생성
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    region VARCHAR(50),
    registration_date DATE,
    status VARCHAR(20) DEFAULT 'active'
);

-- 고객 데이터 삽입 (1,000명)
INSERT INTO customers (customer_id, customer_name, email, phone, region, registration_date, status)
SELECT 
    'CUST-' || LPAD(generate_series::text, 6, '0') as customer_id,
    '고객' || generate_series as customer_name,
    'customer' || generate_series || '@example.com' as email,
    '010-' || LPAD((random() * 9000 + 1000)::int::text, 4, '0') || '-' || LPAD((random() * 9000 + 1000)::int::text, 4, '0') as phone,
    (ARRAY['서울', '부산', '대구', '인천', '광주', '대전', '울산'])[floor(random() * 7) + 1] as region,
    '2023-01-01'::date + (random() * 365)::int as registration_date,
    CASE WHEN random() < 0.95 THEN 'active' ELSE 'inactive' END as status
FROM generate_series(1, 1000);

-- 상품 테이블 생성
CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10, 2),
    stock_quantity INTEGER,
    supplier VARCHAR(100)
);

-- 상품 데이터 삽입 (500개)
INSERT INTO products (product_id, product_name, category, price, stock_quantity, supplier)
SELECT 
    'PROD-' || LPAD(generate_series::text, 5, '0') as product_id,
    (ARRAY['스마트폰', '노트북', '태블릿', '이어폰', '키보드', '마우스', '모니터', '스피커', '충전기', '케이블'])[floor(random() * 10) + 1] || ' ' || 
    (ARRAY['프리미엄', '스탠다드', '베이직', '프로', '울트라', '맥스'])[floor(random() * 6) + 1] || ' ' || generate_series as product_name,
    (ARRAY['전자제품', '컴퓨터', '액세서리', '모바일', '음향기기'])[floor(random() * 5) + 1] as category,
    (random() * 1900000 + 100000)::decimal(10,2) as price,
    (random() * 1000 + 10)::int as stock_quantity,
    '공급업체' || (floor(random() * 20) + 1)::text as supplier
FROM generate_series(1, 500);

-- 주문 테이블 생성
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INTEGER,
    unit_price DECIMAL(10, 2),
    amount DECIMAL(12, 2),
    order_date DATE,
    status VARCHAR(20),
    region VARCHAR(50),
    payment_method VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 스마트 주문 데이터 생성 (50,000건)
WITH customer_weights AS (
    -- 고객별 주문 가중치 설정 (현실적 분포)
    SELECT 
        customer_id,
        region,
        CASE 
            WHEN random() < 0.05 THEN 50    -- 5% 고객: VIP (많은 주문)
            WHEN random() < 0.15 THEN 20    -- 10% 고객: 우수 고객
            WHEN random() < 0.40 THEN 8     -- 25% 고객: 일반 고객
            WHEN random() < 0.70 THEN 3     -- 30% 고객: 가끔 구매
            WHEN random() < 0.90 THEN 1     -- 20% 고객: 가끔 구매
            ELSE 0                          -- 10% 고객: 미구매
        END as weight
    FROM customers
),
product_weights AS (
    -- 상품별 인기도 설정 (파레토 법칙 적용)
    SELECT 
        product_id,
        category,
        price,
        CASE 
            WHEN random() < 0.15 THEN 30    -- 15% 상품: 인기 상품
            WHEN random() < 0.35 THEN 15    -- 20% 상품: 보통 인기
            WHEN random() < 0.65 THEN 8     -- 30% 상품: 평균적 판매
            WHEN random() < 0.85 THEN 3     -- 20% 상품: 저조한 판매
            ELSE 1                          -- 15% 상품: 거의 안 팔림
        END as popularity
    FROM products
),
expanded_customers AS (
    -- 가중치에 따라 고객 확장
    SELECT 
        customer_id,
        region,
        row_number() OVER () as seq
    FROM customer_weights
    CROSS JOIN generate_series(1, weight)
    WHERE weight > 0
),
expanded_products AS (
    -- 가중치에 따라 상품 확장
    SELECT 
        product_id,
        category,
        price,
        row_number() OVER () as seq
    FROM product_weights
    CROSS JOIN generate_series(1, popularity)
),
random_combinations AS (
    -- 랜덤 조합 생성
    SELECT 
        ec.customer_id,
        ec.region,
        ep.product_id,
        ep.category,
        ep.price,
        row_number() OVER () as order_seq
    FROM (
        SELECT *, row_number() OVER (ORDER BY random()) as rn
        FROM expanded_customers
    ) ec
    JOIN (
        SELECT *, row_number() OVER (ORDER BY random()) as rn  
        FROM expanded_products
    ) ep ON ec.rn = ep.rn
    LIMIT 50000
)
INSERT INTO orders (order_id, customer_id, product_id, quantity, unit_price, amount, order_date, status, region, payment_method)
SELECT 
    'ORDER-' || LPAD(order_seq::text, 8, '0') as order_id,
    customer_id,
    product_id,
    (floor(random() * 5) + 1)::int as quantity,
    price * (0.8 + random() * 0.4) as unit_price, -- 상품 가격의 80~120%
    0 as amount, -- 나중에 계산
    '2024-01-01'::date + (random() * 210)::int as order_date,
    (ARRAY['pending', 'processing', 'shipped', 'delivered', 'cancelled'])[floor(random() * 5) + 1] as status,
    region,
    (ARRAY['card', 'cash', 'transfer', 'mobile'])[floor(random() * 4) + 1] as payment_method
FROM random_combinations;

-- 주문 금액 계산
UPDATE orders SET amount = quantity * unit_price;



SELECT * FROM customers LIMIT 10;  -- 데이터 확인!!!

