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

--What were the 10 biggest single contracts and what were they for?
SELECT 
	recipient_name,
	awarding_agency,
	TO_CHAR(award_amount, 'FM$999,999,999,999.00') AS amount,
	description 
FROM contracts 
ORDER BY award_amount DESC
LIMIT 10;

--What is the average contract size and the total amount of all contracts and the amount of contracts that were given out?
SELECT 
	TO_CHAR(AVG(award_amount), 'FM$999,999,999,999.00') AS average_contract_amount,
	TO_CHAR(SUM(award_amount), 'FM$999,999,999,999.00') AS total_contract_amount,
	TO_CHAR(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY award_amount), 'FM$99,999') AS median_contract_amount,
	TO_CHAR(COUNT(*), 'FM99,999') AS amount_of_contracts,
	COUNT(DISTINCT recipient_name) AS number_of_companies
FROM contracts;

--What % of all the money went to the top 10 companies 
SELECT ROUND(SUM(company_total) / (SELECT SUM(award_amount) FROM contracts) * 100, 2) AS top_10_percent
FROM (
	SELECT SUM(award_amount) AS company_total, recipient_name
	FROM contracts
	GROUP BY recipient_name
	ORDER BY SUM(award_amount) DESC
	LIMIT 10
) AS top_10;


