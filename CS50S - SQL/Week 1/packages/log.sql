
-- *** The Lost Letter ***
--SELECT "id", "contents", "from_address_id" FROM "packages" WHERE "from_address_id" = (
 --   SELECT "id" FROM "addresses" WHERE "address" = '900 Somerville Avenue'
 --   );
--SELECT "id", "address" FROM "addresses" WHERE "id" = (
--    SELECT "to_address_id" FROM "packages" WHERE "id" = 384 AND "from_address_id" = 432
 --   );
--SELECT "action" FROM "scans" WHERE "package_id" = 384 AND "address_id" = 854;
--SELECT "type" FROM "addresses" WHERE "id" = 854;

-- *** The Devious Delivery ***
--SELECT "id", "contents", "from_address_id" FROM "packages" WHERE "from_address_id" IS NULL;
--SELECT "action", "address_id" FROM "scans" WHERE "package_id" = 5098;
--SELECT "address", "type" FROM "addresses" WHERE "id" = 348;

-- *** The Forgotten Gift ***
SELECT "id", "contents" FROM "packages" WHERE "from_address_id" = (
    SELECT "id" FROM "addresses" WHERE "address" = '109 Tileston Street'
    ) AND (
        SELECT "id" FROM "addresses" WHERE "address" = '728 Maple Place'
    );
SELECT "driver_id", "action" FROM "scans" WHERE "package_id" = 9523;
SELECT "name" FROM "drivers" WHERE "id" = 17;
