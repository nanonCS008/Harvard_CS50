DROP TABLE IF EXISTS "passengers";
DROP TABLE IF EXISTS "check_ins";
DROP TABLE IF EXISTS "airlines";
DROP TABLE IF EXISTS "flights";

CREATE TABLE "passengers" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "age" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "check_ins" (
    "id" INTEGER,
    "date_time" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "passenger_id" INTEGER,
    "flight_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("passenger_id") REFERENCES "passengers"("id"),
    FOREIGN KEY("flight_id") REFERENCES "flights"("id")
);

CREATE TABLE "airlines" (
    "id" INTEGER,
    "airlines_name" TEXT NOT NULL UNIQUE,
    "concourse" TEXT NOT NULL CHECK("concourse" IN ("A", "B", "C", "D", "E", "F", "T")),
    PRIMARY KEY("id")
);

CREATE TABLE "flights" (
    "id" INTEGER,
	"flight_number" INTEGER NOT NULL,
	"airline_id" INTEGER,
	"from_airport_code" TEXT NOT NULL,
	"to_airport_code" TEXT NOT NULL,
	"departure_time" TEXT NOT NULL,
	"arrival_time" TEXT NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("airline_id") REFERENCES "airlines"("id")
);
