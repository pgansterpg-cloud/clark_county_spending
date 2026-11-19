SELECT recipient_name, SUM(award_amount) AS total_amount 
FROM contracts
GROUP BY recipient_name 
ORDER BY total_amount DESC 
LIMIT 10;