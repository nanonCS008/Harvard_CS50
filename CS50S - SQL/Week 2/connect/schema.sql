DROP TABLE IF EXISTS "users";
DROP TABLE IF EXISTS "schools";
DROP TABLE IF EXISTS "companies";
DROP TABLE IF EXISTS "connections";

CREATE TABLE "users" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "username" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "schools" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "type" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "year_foundation" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "companies" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "industry" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "connections" (
    "id" INTEGER,
    "user_id_1" INTEGER NOT NULL,
    "user_id_2" INTEGER,
    "date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "type" TEXT NOT NULL CHECK("type" IN ("Person", "School", "Company")),
    "affiliation_id" INTEGER,
    "affiliation_type" TEXT CHECK("affiliation_type" IN ("School", "Company")),
    "affiliation_start_date" NUMERIC DEFAULT CURRENT_TIMESTAMP,
    "affiliation_end_date" NUMERIC DEFAULT CURRENT_TIMESTAMP,
    "degree_title" TEXT CHECK("affiliation_type" = 'School'),
    "job_title" TEXT CHECK("affiliation_type" = 'Company'),
    PRIMARY KEY("id"),
    FOREIGN KEY ("user_id_1") REFERENCES "users"("id"),
    FOREIGN KEY ("user_id_2") REFERENCES "users"("id"),
    FOREIGN KEY ("affiliation_id") REFERENCES "companies"("id"),
    FOREIGN KEY ("affiliation_id") REFERENCES "schools"("id")
);
