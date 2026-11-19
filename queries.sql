-- Top ten award_amount and which agency recieved the awards
SELECT recipient_name, TO_CHAR(SUM(award_amount), 'FM$999,999,999,999.00') AS total_amount 
FROM contracts
GROUP BY recipient_name 
ORDER BY SUM(award_amount) DESC 
LIMIT 10;

--Which agancies spend the most in Clark County
SELECT awarding_agency AS agency, TO_CHAR(SUM(award_amount), 'FM$999,999,999,999.00') AS total_amount 
FROM contracts
GROUP BY awarding_agency 
ORDER BY SUM(award_amount) DESC
LIMIT 10;

--ORDER BY award amount "Who gets the most federal dollars"? 
SELECT 
	recipient_name, 
	TO_CHAR(SUM(award_amount), 'FM$999,999,999,999.00') AS total_amount, 
	COUNT(*) AS number_of_contracts
FROM contracts 
GROUP BY recipient_name 
ORDER BY SUM(award_amount) DESC 
LIMIT 10;

--ORDER BY number_of_contracts "Who has the most amount of contracts in the valley"
SELECT 
	recipient_name, 
	TO_CHAR(SUM(award_amount), 'FM$999,999,999,999.00') AS total_amount, 
	COUNT(*) AS number_of_contracts
FROM contracts 
GROUP BY recipient_name 
ORDER BY number_of_contracts DESC 
LIMIT 10;

