SELECT "first_name" AS "First Name", "last_name" AS "Last Name", "debut" AS "Debut"
FROM "players"
WHERE "debut" LIKE '2000%'
ORDER BY "first_name", "last_name", "debut";
