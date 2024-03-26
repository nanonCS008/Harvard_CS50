UPDATE "users" SET "password" = '982c0381c279d139fd221fce974916e7' WHERE "username" = 'admin';

DELETE FROM "user_logs" WHERE "type" = 'update' AND "old_password" IS NOT NULL;

INSERT INTO "user_logs" ("type", "old_username", "new_password")
SELECT 'update', (
    SELECT "username"
    FROM "users"
    WHERE "username" = 'admin'
), (
    SELECT "password"
    FROM "users"
    WHERE "username" = 'emily33'
);
