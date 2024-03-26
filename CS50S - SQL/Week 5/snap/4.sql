SELECT "users"."username"
FROM "users"
JOIN (
    SELECT "to_user_id"
    FROM "messages"
    GROUP BY "to_user_id"
    ORDER BY COUNT(*) DESC
    LIMIT 1
) "m" ON "users"."id" = "m"."to_user_id";
