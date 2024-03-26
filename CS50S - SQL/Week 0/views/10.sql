SELECT "english_title",  "artist", "japanese_title"
FROM "views"
WHERE "contrast" BETWEEN 0.40 AND 0.50
ORDER BY "entropy";

