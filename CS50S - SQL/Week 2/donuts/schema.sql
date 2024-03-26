DROP TABLE IF EXISTS "ingredients";
DROP TABLE IF EXISTS "donuts";
DROP TABLE IF EXISTS "orders";
DROP TABLE IF EXISTS "customers";

CREATE TABLE "ingredients" (
    "id" INTEGER,
    "ingredient" TEXT NOT NULL UNIQUE,
    "amount" INTEGER NOT NULL,
    "unit" INTEGER NOT NULL,
    "price" REAL NOT NULL,
    "donut_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("donut_id") REFERENCES "donuts"("id")
);

CREATE TABLE "donuts" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "gluten_free" TEXT NOT NULL CHECK("gluten_free" IN ("y", "n")),
    "price" REAL NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "orders" (
    "id" INTEGER,
    "order_number" INTEGER NOT NULL UNIQUE,
    "amount" INTEGER NOT NULL,
    "donut_id" INTEGER,
    "customer_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("donut_id") REFERENCES "donuts"("id"),
    FOREIGN KEY("customer_id") REFERENCES "customers"("id")
);

CREATE TABLE "customers" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "order_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("order_id") REFERENCES "orders"("id")
);
