-- Combine income bracket, loan type, and region (the 3 strongest factors) into risk segments
SELECT 
  income_bracket,
  loan_type,
  region,
  COUNT(*) AS total_loans,
  SUM(status) AS defaults,
  ROUND(100.0 * SUM(status) / COUNT(*), 2) AS default_rate_pct
FROM loan_clean
GROUP BY income_bracket, loan_type, region
HAVING COUNT(*) >= 100
ORDER BY default_rate_pct DESC
LIMIT 20;

-- Build the final risk segments table with risk tiers
CREATE TABLE loan_risk_segments AS
SELECT 
  income_bracket,
  loan_type,
  region,
  COUNT(*) AS total_loans,
  SUM(status) AS defaults,
  ROUND(100.0 * SUM(status) / COUNT(*), 2) AS default_rate_pct,
  CASE
    WHEN 100.0 * SUM(status) / COUNT(*) >= 35 THEN 'High Risk'
    WHEN 100.0 * SUM(status) / COUNT(*) >= 25 THEN 'Medium Risk'
    ELSE 'Low Risk'
  END AS risk_tier
FROM loan_clean
GROUP BY income_bracket, loan_type, region
HAVING COUNT(*) >= 100;

-- Loan book coverage by risk tier
SELECT risk_tier, COUNT(*) AS segments, SUM(total_loans) AS loans_covered
FROM loan_risk_segments
GROUP BY risk_tier;

-- Top 5 riskiest segments (used in the dashboard)
SELECT * FROM loan_risk_segments ORDER BY default_rate_pct DESC LIMIT 5;