-- Represent the students enrolled at the university
CREATE TABLE "students" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "birth_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "address" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "phone_number" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

-- Represent the professors who teach at the university
CREATE TABLE "professors" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "academic_title" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "phone_number" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

-- Represent the subjects taught at the university
CREATE TABLE "subjects" (
    "id" INTEGER,
    "subject_name" TEXT NOT NULL,
    "subject_code" TEXT NOT NULL UNIQUE,
    "description" TEXT NOT NULL,
    "credits" INTEGER NOT NULL,
    "professor_id" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY ("professor_id") REFERENCES "professors"("id")
);

-- Represent subject enrollments at the university
CREATE TABLE "enrollments" (
    "id" INTEGER,
    "student_id" INTEGER NOT NULL,
    "subject_id" INTEGER NOT NULL,
    "enrollment_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" TEXT NOT NULL CHECK("status" IN ("registered", "withdraw")),
    PRIMARY KEY("id"),
    FOREIGN KEY ("student_id") REFERENCES "students"("id"),
    FOREIGN KEY ("subject_id") REFERENCES "subjects"("id")
);

-- Represent students' grades in a subject at the university
CREATE TABLE "grades" (
    "id" INTEGER,
    "student_id" INTEGER NOT NULL,
    "subject_id" INTEGER NOT NULL,
    "grade" REAL NOT NULL,
    "grade_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY ("student_id") REFERENCES "students"("id"),
    FOREIGN KEY ("subject_id") REFERENCES "subjects"("id")
);

-- Create indexes to speed common searches
CREATE INDEX "student_name_search" ON "students"("first_name", "last_name");
CREATE INDEX "student_email_search" ON "students"("first_name", "last_name", "email");
CREATE INDEX "professors_name_search" ON "professors"("first_name", "last_name");
CREATE INDEX "subject_name_search" ON "subjects"("subject_name");

-- Create views to simplify queries
CREATE VIEW "student_grades" AS
SELECT "students"."id", "students"."first_name", "students"."last_name", "enrollments"."subject_id", "subjects"."subject_name", "grades"."grade"
FROM "students"
JOIN "enrollments" ON "students"."id" = "enrollments"."student_id"
JOIN "grades" ON "students"."id" = "grades"."student_id" AND "enrollments"."subject_id" = "grades"."subject_id"
JOIN "subjects" ON "enrollments"."subject_id" = "subjects"."subject_id";

CREATE VIEW course_professor AS
SELECT "subjects"."subject_id", "subjects"."subject_name", "subjects"."subject_code", "subjects"."credits", "professors"."first_name", "professors"."last_name"
FROM "subjects"
JOIN "professors" ON "subjects"."professor_id" = "professors"."id";
