SELECT "districts"."name", "staff_evaluations"."evaluated" FROM "districts"
JOIN "staff_evaluations" ON "districts"."id" = "staff_evaluations"."district_id"
ORDER BY "staff_evaluations"."evaluated" DESC;
