-- p01.sql

-- 1. practice db 사용
-- 2. userinfo 테이블 생성
	-- id PK, auto inc, int
    -- nickname: 글자 20자 까지, 필수 입력
    -- phone 글자 11 글자까지, 중복 방지
    -- reg-date 날짜, 기본값(오늘 날짜)
    
-- 3. desc 로 테이블 정보 확인

CREATE TABLE userinfo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nickname VARCHAR(20) NOT NULL,
    phone VARCHAR(11) UNIQUE,
    reg_date DATE DEFAULT(CURRENT_DATE)
);

DESC userinfo;