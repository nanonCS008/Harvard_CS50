SELECT "city", count("name")
FROM "schools"
WHERE "type" = 'Public School'
GROUP BY "city"
ORDER BY count("name") DESC, "city"
LIMIT 10;
