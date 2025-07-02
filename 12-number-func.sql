-- 12-number-func.sql

USE lecture;

-- 실수(소수점) 함수들
SELECT
	name,
    score AS 원점수,
    ROUND(score) AS 반올림,
    ROUND(score, 1) AS 소수1반올림,
    CEIL(score) AS 올림,
    FLOOR(score) AS 내림,
    TRUNCATE(score, 1) AS 소수1버림
FROM dt_demo;

-- 사칙연산
SELECT
	10 + 5 AS plus,
    10 - 5 AS minus,
    10 * 5 AS multiply,
    10 / 5 AS divide,
    10 DIV 3 AS 몫,
    10 % 3 AS 나머지,
    MOD(10, 3) AS 나머지2,
    POWER(10, 3) AS 거듭제곰,
    SQRT(16) AS 루트;
    
SELECT
	id, name,
    id % 2 AS 나머지,
    CASE
		WHEN id % 2 = 0 THEN '짝수' 
        ELSE '홀수'
        END AS 홀짝
FROM dt_demo;

-- 조건문 CASE

SELECT
	name, score,
    IF(score >= 80, '우수', '보통') AS 평가
FROM dt_demo;

SELECT
	name, score,
    CASE
		WHEN score >= 90 THEN 'A'
        WHEN score >= 80 THEN 'B'
        WHEN score >= 70 THEN 'C'
        ELSE 'D'
	END AS 학점
FROM dt_demo;

SELECT * FROM dt_demo;






    


