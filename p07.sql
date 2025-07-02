-- p07.sql
USE practice;

CREATE TABLE dt_demo2 AS SELECT * FROM lecture.dt_demo;

SELECT * FROM dt_demo2;
SHOW COLUMNS FROM dt_demo2;

-- id
SELECT id FROM dt_demo2;

-- name
SELECT name FROM dt_demo2;

-- 닉네임 (NULL -> '미설정')
SELECT 
	IFNULL(nickname, '미설정') AS nickname 
FROM dt_demo2;

-- 출생년도 (19xx년생)
ALTER TABLE dt_demo2
ADD COLUMN 출생연도 VARCHAR(4);
DESC dt_demo2;
SELECT * FROM dt_demo2;
ALTER TABLE dt_demo2 DROP COLUMN birth_year;
SELECT * FROM dt_demo2;
UPDATE dt_demo2
SET `출생연도` = LEFT(birth, 4);
SELECT * FROM dt_demo2;

-- 나이 (TIMESTAMPDIFF 로 나이만 표시)
ALTER TABLE dt_demo2
	ADD COLUMN `나이` INT;
UPDATE dt_demo2
	SET `나이` = TIMESTAMPDIFF(YEAR, birth, CURDATE());
SELECT * FROM dt_demo2;

-- 점수 (소수 1자리 반올림, Null -> 0)
SELECT id, 
	ROUND(IFNULL(score, 0), 1) AS score_rounded
FROM dt_demo2;
UPDATE dt_demo2
	SET score = ROUND(IFNULL(score, 0), 1);
SELECT * FROM dt_demo2;
    
-- 등급 (A >= 90 / B >= 80 / C >= 70 / D)
ALTER TABLE dt_demo2
ADD COLUMN `등급` CHAR(1);
SELECT * FROM dt_demo2;
UPDATE dt_demo2
SET `등급` = 
	CASE
		WHEN score >= 90 THEN 'A'
        WHEN score >= 80 THEN 'B'
        WHEN score >= 70 THEN 'C'
    ELSE 'D'
  END;
SELECT * FROM dt_demo2;

-- 상태 (is_active 가 1 이면 '활성' / 0 '비활성')
SELECT id, is_active,
       CASE is_active
         WHEN 1 THEN '활성'
         WHEN 0 THEN '비활성'
         ELSE '미지정'
       END AS 상태
FROM dt_demo2;
SELECT * FROM dt_demo2;

-- 연령대 (청년 < 30 < 청장년 < 50 < 장년)
SELECT id, `나이`,
	CASE
		WHEN `나이` < 30 THEN '청년'
		WHEN `나이` < 50 THEN '청장년'
		ELSE '장년'
  END AS 연령대
FROM dt_demo2;
