DROP TABLE IF EXISTS "users";
DROP TABLE IF EXISTS "schools";
DROP TABLE IF EXISTS "companies";
DROP TABLE IF EXISTS "connections";

CREATE TABLE "users" (
    "id" INT AUTO_INCREMENT,
    "first_name" VARCHAR(25) NOT NULL,
    "last_name" VARCHAR(25) NOT NULL,
    "username" VARCHAR(30) NOT NULL UNIQUE,
    "password" VARCHAR(15) NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "schools" (
    "id" INT AUTO_INCREMENT,
    "name" VARCHAR(50) NOT NULL UNIQUE,
    "type" VARCHAR(25) NOT NULL,
    "location" VARCHAR(50) NOT NULL,
    "year_foundation" INT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "companies" (
    "id" INT AUTO_INCREMENT,
    "name" VARCHAR(50) NOT NULL UNIQUE,
    "industry" VARCHAR(25) NOT NULL,
    "location" VARCHAR(50) NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "connections" (
    "id" INT AUTO_INCREMENT,
    "user_id_1" INT NOT NULL,
    "user_id_2" INT,
    "date" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "type" VARCHAR(25) ENUM("Person", "School", "Company") NOT NULL,
    "affiliation_id" INT,
    "affiliation_type" VARCHAR(25) ENUM("School", "Company"),
    "affiliation_start_date" DATETIME DEFAULT CURRENT_TIMESTAMP,
    "affiliation_end_date" DATETIME DEFAULT CURRENT_TIMESTAMP,
    "degree_title" VARCHAR(25),
    "job_title" VARCHAR(25),
    PRIMARY KEY("id"),
    FOREIGN KEY ("user_id_1") REFERENCES "users"("id"),
    FOREIGN KEY ("user_id_2") REFERENCES "users"("id"),
    FOREIGN KEY ("affiliation_id") REFERENCES "companies"("id"),
    FOREIGN KEY ("affiliation_id") REFERENCES "schools"("id")
);
