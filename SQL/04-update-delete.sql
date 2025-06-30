-- 04-update-delete.sql

SELECT * FROM members;

-- Update (데이터 수정)
UPDATE members SET name='홍길동', email='hong@a.com' WHERE id=4;
-- 원치 않는 게이스 (NAME 같으면 동시 수정)
UPDATE members SET name='No name' WHERE name='유태영'

-- DELETE (데이터 삭제)
DELETE FROM members WHERE id=3;
