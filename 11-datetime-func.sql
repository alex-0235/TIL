-- 11-datetime-func.sql

USE lecture;

CREATE TABLE dt_demo (
    id          INT         AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(20) NOT NULL,
    nickname    VARCHAR(20),
    birth       DATE,
    score       FLOAT,
    salary      DECIMAL(20, 3),
    description TEXT,
    is_active   BOOL        DEFAULT TRUE,
    created_at  DATETIME    DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO dt_demo (name, nickname, birth, score, salary, description)
VALUES
('김철수', 'kim', '1995-01-01', 88.75, 3500000.50, '우수한 학생입니다.'),
('이영희', 'lee', '1990-05-15', 92.30, 4200000.00, '성실하고 열심히 공부합니다.'),
('박민수', 'park', '1988-09-09', 75.80, 2800000.75, '기타 사항 없음'),
('유태영', 'yu', '2002-07-01', 71.23, 8400000, '학생이 아님');

SELECT * FROM dt_demo;

-- 현재 날짜/시간 보는 법
-- 날짜 + 시간 같이 보는 것
SELECT NOW();
SELECT NOW() AS 지금시간;
SELECT CURRENT_TIMESTAMP();

-- 날짜
SELECT CURDATE();
SELECT CURRENT_DATE;

-- 시간
SELECT CURTIME();
SELECT CURRENT_TIME;

SELECT 
	name,
    birth AS 원본,
    DATE_FORMAT(birth, '%Y년 %m월 %d일') AS 한국식,
    DATE_FORMAT(birth, '%Y-%m') AS 년월,
    DATE_FORMAT(birth, '%M %d, %Y') AS 영문식,
    DATE_FORMAT(birth, '%w') AS 요일번호,
    DATE_FORMAT(birth, '%W') AS 요일이름 
FROM dt_demo;

SELECT
	created_at AS 원본시간,
    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') AS 분까지만,
    DATE_FORMAT(created_at, '%p %h:%i') AS 12시간
FROM dt_demo;

-- 날짜 계산 함수
SELECT
	name,
    birth, 
    DATEDIFF(CURDATE(), birth) AS 살아온날들,
    -- TIMESTAMPDIFF(결과 단위, 날짜1, 날짜2)
    TIMESTAMPDIFF(YEAR, birth, CURDATE()) AS 나이
    FROM dt_demo;
    
    -- 더하기 빼기
    SELECT
		name, birth, 
        DATE_ADD(birth, INTERVAL 100 DAY) AS 백일후,
        DATE_ADD(birth, INTERVAL 1 YEAR) AS 돌,
        DATE_SUB(birth, INTERVAL 10 MONTH) AS 등장
	FROM dt_demo;
    
    -- 계정 생성 후 경과 시간
SELECT
	name, created_at,
    TIMESTAMPDIFF(HOUR, created_at, NOW()) AS 가입후시간,
    TIMESTAMPDIFF(DAY, created_at, NOW()) AS 가입후일수
FROM dt_demo;

-- 날짜 추출
SELECT
	name, birth,
    -- birth -> DATE 정보
    YEAR(birth),
    MONTH(birth),
    DAY(birth),
    DAYOFWEEK(birth) AS 요일번호,
    DAYNAME(birth) AS 요일,
    QUARTER(birth) AS 분기
FROM dt_demo;

-- 월별, 연도별
SELECT
	YEAR(birth) AS 출생년도,
    COUNT(*) AS 인원수
FROM dt_demo
GROUP BY YEAR(birth)
ORDER BY 출생년도;

