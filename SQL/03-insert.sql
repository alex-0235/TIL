-- 03-insert.sql

USE lecture;
DESC members; 

-- 데이터 입력
INSERT INTO members (name, email) VALUES ('장기진', 'alex@a.com');


-- 데이터 확인
SELECT * FROM members;