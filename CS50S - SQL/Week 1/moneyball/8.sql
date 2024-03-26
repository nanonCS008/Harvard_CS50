SELECT "salaries"."salary"
FROM "salaries"
JOIN "performances" ON "performances"."player_id" = "players"."id"
JOIN "players" ON "players"."id" = "salaries"."player_id"
WHERE "salaries"."year" = 2001
AND "performances"."HR" = (
    SELECT MAX("HR") FROM "performances"
);
