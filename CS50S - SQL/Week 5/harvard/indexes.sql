CREATE INDEX "enrollments_student_course"
ON "enrollments" ("student_id", "course_id");

CREATE INDEX "enrollments_course"
ON "enrollments" ("course_id");

CREATE INDEX "courses_semester_enrollments"
ON "courses" ("semester");

CREATE INDEX "enrollments_course_enrollment"
ON "enrollments" ("course_id");

CREATE INDEX "courses_department_semester"
ON "courses" ("department", "semester");

CREATE INDEX "courses_title_semester"
ON "courses" ("title", "semester");

CREATE INDEX "satisfies_course"
ON "satisfies" ("course_id");

CREATE INDEX "enrollments_student_course_req"
ON "enrollments" ("student_id", "course_id");

CREATE INDEX "satisfies_req_course"
ON "satisfies" ("requirement_id", "course_id");

CREATE INDEX "search_courses_title_semester"
ON "courses" ("title", "semester");
