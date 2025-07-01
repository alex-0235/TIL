-- 03-insert.sql

USE lecture;
DESC members; 

-- 데이터 입력
INSERT INTO members (name, email) VALUES ('장기진', 'alex@a.com');
INSERT INTO members (name, email) VALUES ('김영희', 'younghee@a.com');

-- 여러줄, (col1, col2) 순서 잘 맞추기!
INSERT INTO members (email, name) VALUES 
('hyun@a.com', '현정희'), 
('gisu@a.com', '장기수');

-- 데이터 전체 조회 (read)
SELECT * FROM members;
-- 단일 데이터 조회 (* -> 
SELECT * FROM members WHERE id=1;
