DROP TABLE IF EXISTS "phrases";
DROP VIEW IF EXISTS "message";

CREATE TABLE "phrases" (
    "id" INTEGER,
    "sentence" TEXT NOT NULL,
    "phrase" TEXT,
    PRIMARY KEY("id"),
    FOREIGN KEY("id") REFERENCES "sentences"("id")
);

INSERT INTO "phrases" ("id", "sentence")
SELECT "id", "sentence" FROM "sentences" WHERE "id" IN (14, 114, 618, 630, 932, 2230, 2346, 3041);

UPDATE "phrases" SET "phrase" = (SELECT substr("sentence", 98, 4) FROM "phrases" WHERE "id" = 14) WHERE "id" = 14;
UPDATE "phrases" SET "phrase" = (SELECT substr("sentence", 3, 5) FROM "phrases" WHERE "id" = 114) WHERE "id" = 114;
UPDATE "phrases" SET "phrase" = (SELECT substr("sentence", 72, 9) FROM "phrases" WHERE "id" = 618) WHERE "id" = 618;
UPDATE "phrases" SET "phrase" = (SELECT substr("sentence", 7, 3) FROM "phrases" WHERE "id" = 630) WHERE "id" = 630;
UPDATE "phrases" SET "phrase" = (SELECT substr("sentence", 12, 5) FROM "phrases" WHERE "id" = 932) WHERE "id" = 932;
UPDATE "phrases" SET "phrase" = (SELECT substr("sentence", 50, 7) FROM "phrases" WHERE "id" = 2230) WHERE "id" = 2230;
UPDATE "phrases" SET "phrase" = (SELECT substr("sentence", 44, 10) FROM "phrases" WHERE "id" = 2346) WHERE "id" = 2346;
UPDATE "phrases" SET "phrase" = (SELECT substr("sentence", 14, 5) FROM "phrases" WHERE "id" = 3041) WHERE "id" = 3041;

CREATE VIEW "message" AS
SELECT "phrase" FROM "phrases";

SELECT * FROM "message";
