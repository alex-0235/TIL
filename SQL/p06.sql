-- p06.sql

USE practice;

SHOW TABLES;

DESC userinfo;

SELECT * FROM userinfo;

-- 별명 길이 확인
SELECT nickname, CHAR_LENGTH(nickname) FROM userinfo;

-- 별명 과 email 을 '-' 로 합쳐서 info (가상)컬럼으로 확인해 보기
SELECT 
	nickname, 
	email, 
	CONCAT(nickname, '-', email) AS info 
FROM userinfo;

-- 별명 은 모두 대문자로, email은 모두 소문자로 확인
SELECT 
	UPPER(nickname) AS nickname_upper, 
	LOWER(email) AS email_lower 
FROM userinfo;

-- email 에서 gmail.com 을 naver.com 으로 모두 new_email 컬럼으로 추출
SELECT 
	email, 
	REPLACE(email, 'gmail.com', 'naver.com') AS new_email 
FROM userinfo;

-- email 앞에 붙은 단어만 username 컬럼 으로 확인 
SELECT 
	email, 
	SUBSTRING_INDEX(email, '@', 1) AS username 
FROM userinfo;

-- (추가 과제 -> email 이 NULL 인 경우 'No Mail' 이라고 표시
SELECT 
	IFNULL(email, 'No Mail') AS email_display 
FROM userinfo;