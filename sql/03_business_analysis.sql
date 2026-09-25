-- Default rate by income bracket
SELECT income_bracket, COUNT(*), 
       ROUND(100.0 * SUM(status) / COUNT(*), 2) AS default_rate_pct
FROM loan_clean
GROUP BY income_bracket
ORDER BY income_bracket;

-- Default rate by loan type
SELECT loan_type, COUNT(*) AS count,
       ROUND(100.0 * SUM(status) / COUNT(*), 2) AS default_rate_pct
FROM loan_clean
GROUP BY loan_type
ORDER BY default_rate_pct DESC;

-- Default rate by region
SELECT region, COUNT(*) AS count,
       ROUND(100.0 * SUM(status) / COUNT(*), 2) AS default_rate_pct
FROM loan_clean
GROUP BY region
ORDER BY default_rate_pct DESC;

-- Default rate by credit band (finding: credit score barely predicts default)
SELECT credit_band, COUNT(*) AS count,
       ROUND(100.0 * SUM(status) / COUNT(*), 2) AS default_rate_pct
FROM loan_clean
GROUP BY credit_band
ORDER BY 
  CASE credit_band 
    WHEN 'Poor' THEN 1 
    WHEN 'Fair' THEN 2 
    WHEN 'Good' THEN 3 
    WHEN 'Excellent' THEN 4 
  END;

-- Sanity check: confirm credit_score has real spread (rules out a data issue)
SELECT MIN(credit_score), MAX(credit_score), AVG(credit_score), COUNT(DISTINCT credit_score)
FROM loan_clean;

-- Default rate by age bracket
SELECT age, age_sort_order, COUNT(*) AS count,
       ROUND(100.0 * SUM(status) / COUNT(*), 2) AS default_rate_pct
FROM loan_clean
GROUP BY age, age_sort_order
ORDER BY age_sort_order;