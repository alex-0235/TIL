-- 24-many-to-many.sql
USE lecture;

DROP TABLE IF EXISTS students_courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;

CREATE TABLE students (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(20)
);

CREATE TABLE courses (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50),
  classroom VARCHAR(20)  
);

-- 중간테이블 (Junction Table)  students:courses = M : N
CREATE TABLE students_courses (
  student_id INT,
  course_id INT,
  grade VARCHAR(5),
  PRIMARY KEY (student_id, course_id),  -- 복합 PK
  FOREIGN KEY(student_id) REFERENCES students(id),
  FOREIGN KEY(course_id) REFERENCES courses(id)
);

-- 데이터 삽입
INSERT INTO students VALUES
(1, '김학생'),
(2, '이학생' ),
(3, '박학생');

INSERT INTO courses VALUES
(1, 'MySQL 데이터베이스', 'A관 101호'),
(2, 'PostgreSQL 고급', 'B관 203호'),
(3, '데이터 분석', 'A관 704호');

INSERT INTO students_courses VALUES
(1, 1, 'A'),  -- 김학생이 MySQL 수강
(1, 2,'B+'), -- 김학생이 PostgreSQL 수강
(2, 1, 'A-'), -- 이학생이 MySQL 수강
(2, 3, 'B'),  -- 이학생이 데이터분석 수강
(3, 2, 'A+'), -- 박학생이 PostgreSQL 수강
(3, 3, 'A');  -- 박학생이 데이터분석 수강


-- 학생 별 수강 과목
SELECT 
  s.id AS student_id,
  s.name AS student_name,
  c.id AS course_id,
  c.name AS course_name
FROM students s
JOIN students_courses sc ON s.id = sc.student_id
JOIN courses c ON sc.course_id = c.id
ORDER BY s.id;

-- 과목 별 수강 학생
-- [과목명, 강의실, 수강인원, 수강학생들(,), 학점 평균(A+ 4.3 / A 4.0 / A- 3.7 / B+ 3.3 / B 3.0 )
SELECT 
  c.name AS course_name,
  c.classroom AS lecture_room,
  COUNT(sc.student_id) AS student_count,
  GROUP_CONCAT(s.name SEPARATOR ', ') AS student_names,
  ROUND(AVG(
    CASE
      WHEN sc.grade = 'A+' THEN 4.3
      WHEN sc.grade = 'A'  THEN 4.0
      WHEN sc.grade = 'A-' THEN 3.7
      WHEN sc.grade = 'B+' THEN 3.3
      WHEN sc.grade = 'B'  THEN 3.0
      ELSE NULL
    END
  ), 2) AS avg_gpa
FROM courses c
JOIN students_courses sc ON c.id = sc.course_id
JOIN students s ON sc.student_id = s.id
GROUP BY c.id, c.name, c.classroom
ORDER BY c.name;

DESCRIBE courses;
SHOW CREATE TABLE students_courses;
SELECT * FROM students_courses;