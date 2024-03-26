SELECT "players"."first_name", "players"."last_name"
FROM "players"
JOIN "salaries" ON "players"."id" = "salaries"."player_id"
WHERE "salaries"."salary" = (
    SELECT MAX("salary") FROM "salaries"
)
LIMIT 1;
