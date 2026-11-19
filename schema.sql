CREATE TABLE contracts(
	generated_internal_id PRIMARY KEY,
	award_id VARCHAR,
	recipient_name VARCHAR NOT N,
	award_amount NUMERIC(15, 2),
	awarding_agency VARCHAR, 
	description VARCHAR
);
