SELECT "city", count("name")
FROM "schools"
WHERE "type" = 'Public School'
GROUP BY "city"
HAVING count("name") <= 3
ORDER BY count("name") DESC, "city";
