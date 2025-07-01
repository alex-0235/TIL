-- 09-datatype.sql

USE lecture;

DESC userinfo;

CREATE TABLE dt_demo (
	id 		 	INT 		AUTO_INCREMENT PRIMARY KEY,
    name 	 	VARCHAR(20) NOT NULL,
    nickname 	VARCHAR(20),
    birth 	 	DATE,
    score 	 	FLOAT,
    salary      DECIMAL(20, 3),
    description TEXT,
    is_active 	BOOL 		DEFAULT TRUE,
    created_at 	DATETIME 	DEFAULT CURRENT_TIMESTAMP
);

DESC dt_demo;

INSERT INTO dt_demo (name, nickname, birth, score, salary, description)
VALUES
('김철수', 'kim', '1995-01-01', 88.75, 3500000.50, '우수한 학생입니다.'),
('이영희', 'lee', '1990-05-15', 92.30, 4200000.00, '성실하고 열심히 공부합니다.'),
('박민수', 'park', '1988-09-09', 75.80, 2800000.75, '기타 사항 없음'),
('장기진', 'chang', '1970-11-27', 98.90, 9000000.50, '만학도 입니다');

SELECT * FROM dt_demo;
drop table dt_demo; -- 이중 생성으로 드랍 후 다시 생성함

-- 80점 이상만 조회
SELECT * FROM dt_demo WHERE score >= 80;
-- description에 '학생'이라는 말이 없는 사람
SELECT * FROM dt_demo WHERE description NOT LIKE '%학생%';
-- 00년 이전 출생자만 조회
SELECT * FROM dt_demo WHERE birth < '2000-01-01';
