-- 08-orderby.sql
USE lecture;
-- 특정 칼럼을 기준으로 정렬함
-- ASC 오름차순 | DESC 내림차순

SELECT * FROM students;
-- 이름 가나다 순으로 정령 -> 기본 정령 방식은 ASC
SELECT * FROM students ORDER by name;
SELECT * FROM students ORDER by name ASC;
SELECT * FROM students ORDER by name DESC;
SELECT * FROM students;

-- 테이블 구조 변경 -> 컬럼 추가 -. grade VARCHER(1) -> 기본값으로 B
ALTER TABLE students ADD grade VARCHAR(1) DEFAULT 'B';
SELECT * FROM students;
-- 데이터 변경. id 1~3은 A, id 7~10은 C
UPDATE students SET grade = 'A' WHERE id BETWEEN 1 AND 3;
SELECT * FROM students;
UPDATE students SET grade = 'C' WHERE id BETWEEN 7 AND 10;
SELECT * FROM students;

# 다중 컬럼 정렬 -> 앞에 말한 것이 우선 정렬
SELECT * FROM students ORDER BY
age ASC, 
grade DESC;

SELECT * FROM students ORDER BY
grade DESC,
age ASC;

-- 나이가 40미만인 학생들 중에서 학점 좋은 사람순, 나이 많은 순으로 상위 5명 뽑기
SELECT * FROM students WHERE age < 40
ORDER BY grade ASC, 
age DESC LIMIT 5;