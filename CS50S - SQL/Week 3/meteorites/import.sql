DROP TABLE IF EXISTS "meteorites_temp";
DROP TABLE IF EXISTS "meteorites";

CREATE TABLE "meteorites" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "class" TEXT NOT NULL,
    "mass" REAL,
    "discovery" TEXT NOT NULL,
    "year" INTEGER,
    "lat" REAL,
    "long" REAL,
    PRIMARY KEY("id")
);

CREATE TABLE "meteorites_temp" (
    "name" TEXT NOT NULL,
    "id" INTEGER,
    "nametype" TEXT NOT NULL,
    "class" TEXT NOT NULL,
    "mass" REAL,
    "discovery" TEXT NOT NULL,
    "year" INTEGER,
    "lat" REAL,
    "long" REAL,
    PRIMARY KEY("id")
);

.import --csv --skip 1 meteorites.csv meteorites_temp

UPDATE "meteorites_temp" SET "mass" = NULL WHERE "mass" = '';
UPDATE "meteorites_temp" SET "year" = NULL WHERE "year" = '';
UPDATE "meteorites_temp" SET "lat" = NULL WHERE "lat" = '';
UPDATE "meteorites_temp" SET "long" = NULL WHERE "long" = '';

UPDATE "meteorites_temp" SET "mass" = ROUND("mass", 2);
UPDATE "meteorites_temp" SET "lat" = ROUND("lat", 2);
UPDATE "meteorites_temp" SET "long" = ROUND("long", 2);

DELETE FROM "meteorites_temp" WHERE "nametype" = 'Relict';

INSERT INTO "meteorites" ("name", "class", "mass", "discovery", "year", "lat", "long")
SELECT "name", "class", "mass", "discovery", "year", "lat", "long" FROM "meteorites_temp" ORDER BY "year" ASC, "name" ASC;
