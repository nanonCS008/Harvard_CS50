-- Find all courses with teacher details
SELECT "subjects"."id", "subjects"."subject_name", "subjects"."subject_code", "professors"."first_name", "professors"."last_name"
FROM "subjects"
JOIN "professors" ON "subjects"."professor_id" = "professors"."id";

-- Find grades for a specific student
SELECT "students"."first_name", "students"."last_name", "subjects"."subject_name", "grades"."grade"
FROM "students"
JOIN "grades" ON "students"."id" = "grades"."student_id"
JOIN "subjects" ON "grades"."subject_id" = "subjects"."id"
WHERE "students"."id" = (
    SELECT "id" FROM "students" WHERE "first_name" = 'Nel' AND "last_name" = 'Gracia'
);

-- Insert a new student
INSERT INTO "students" ("first_name", "last_name", "birth_date", "address", "email", "phone_number")
VALUES ('Nel', 'Gracia', '1999-04-23', '1114 College Avenue', 'gracianel@outlook.com', '7874256521');

INSERT INTO "professors" ("first_name", "last_name", "academic_title", "email", "phone_number")
VALUES ('Carter', 'Zenke', 'Bachelor Computer Science', 'carter@cs50.harvard.edu', '5456215495');

-- Insert a new subject
INSERT INTO "subjects" ("subject_name", "subject_code", "description", "credits", "professor_id")
VALUES ('Introduction to Programming', 'INF5018', 'An introductory course on programming using C++', 4, 1);

-- Update a student's email
UPDATE "students" SET "email" = 'gracianel23@hotmail.com' WHERE "id" = 1;

-- Update a student's grade in a subject
UPDATE "grades" SET "grade" = 90 WHERE "student_id" = 1 AND "subject_id" = 1;
