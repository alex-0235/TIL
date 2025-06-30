-- p03.sql

-- practice db 사용
USE practice;
-- 스키마 확인 & 데이터 확인 (주기적으로)

-- userinfo 에 email userinfo컬럼 추가 40글자 제한, 중복 안됨, 기본값은 ex@gmail.com
ALTER TABLE userinfo
ADD COLUMN email VARCHAR(40) UNIQUE DEFAULT 'ex@gmail.com';
SHOW TABLES;
CREATE TABLE userinfo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nickname VARCHAR(20) NOT NULL,
    phone VARCHAR(11) UNIQUE,
    reg_date DATE DEFAULT (CURRENT_DATE)
);
ALTER TABLE userinfo ADD COLUMN email VARCHAR(40) UNIQUE DEFAULT 'ex@gmail.com';
-- nickname 길이제한 100자로 늘리기
ALTER TABLE userinfo MODIFY COLUMN nickname VARCHAR(100) NOT NULL;
-- reg_date 컬럼 삭제
ALTER TABLE userinfo DROP COLUMN reg_date;
SELECT * FROM userinfo
-- 실제 한명의 email 을 수정하기 (-- 기존에 데이터를 삭제한 상황이라 수정 데이터가 없음 ㅠㅠ)