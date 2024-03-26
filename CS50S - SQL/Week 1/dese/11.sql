SELECT "schools"."name", "expenditures"."per_pupil_expenditure", "graduation_rates"."graduated"
FROM "schools"
JOIN "expenditures" ON "districts"."id" = "expenditures"."district_id"
JOIN "districts" ON "schools"."district_id" = "districts"."id"
JOIN "graduation_rates" ON "schools"."id" = "graduation_rates"."school_id"
ORDER BY "expenditures"."per_pupil_expenditure" DESC, "schools"."name";
