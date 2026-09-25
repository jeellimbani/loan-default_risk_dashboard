-- Check overall default rate
SELECT COUNT(*) AS total_loans,
       ROUND(100.0 * SUM(status) / COUNT(*), 2) AS default_rate_pct
FROM loan_default;

-- Check whether missing interest rate relates to default (found: data leakage)
SELECT (rate_of_interest IS NULL) AS rate_missing,
       COUNT(*) AS loans,
       ROUND(100.0 * SUM(status) / COUNT(*), 2) AS default_rate_pct
FROM loan_default
GROUP BY 1;

-- Get income percentiles to set brackets
SELECT
  MIN(income), 
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY income) AS p25,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY income) AS median,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY income) AS p75,
  MAX(income)
FROM loan_default
WHERE income > 0;

-- Build the cleaned table, excluding leakage columns (rate_of_interest, 
-- interest_rate_spread, upfront_charges), with income/credit/LTV brackets
CREATE TABLE loan_clean AS
SELECT
  loan_id,
  status,
  NULLIF(income, 0) AS income,
  CASE
    WHEN NULLIF(income, 0) IS NULL THEN 'Unknown'
    WHEN income < 3780 THEN 'Low'
    WHEN income < 8580 THEN 'Mid'
    ELSE 'High'
  END AS income_bracket,
  credit_score,
  CASE
    WHEN credit_score < 580 THEN 'Poor'
    WHEN credit_score < 670 THEN 'Fair'
    WHEN credit_score < 740 THEN 'Good'
    ELSE 'Excellent'
  END AS credit_band,
  ltv,
  CASE
    WHEN ltv < 60 THEN 'Low LTV'
    WHEN ltv < 80 THEN 'Mid LTV'
    ELSE 'High LTV'
  END AS ltv_band,
  dtir1,
  loan_amount,
  loan_type,
  loan_purpose,
  age,
  gender,
  credit_type,
  occupancy_type,
  INITCAP(TRIM(region)) AS region,
  business_or_commercial,
  neg_ammortization,
  interest_only,
  lump_sum_payment,
  approv_in_adv,
  submission_of_application,
  credit_worthiness
FROM loan_default;

-- Add property_value (missed in the first pass)
ALTER TABLE loan_clean ADD COLUMN property_value NUMERIC;

UPDATE loan_clean lc
SET property_value = ld.property_value
FROM loan_default ld
WHERE lc.loan_id = ld.loan_id;

-- Add a numeric sort-order column so age brackets display in true order in BI tools
ALTER TABLE loan_clean ADD COLUMN age_sort_order INT;

UPDATE loan_clean SET age_sort_order = CASE age
  WHEN '<25' THEN 1
  WHEN '25-34' THEN 2
  WHEN '35-44' THEN 3
  WHEN '45-54' THEN 4
  WHEN '55-64' THEN 5
  WHEN '65-74' THEN 6
  WHEN '>74' THEN 7
END;

SELECT COUNT(*) FROM loan_clean;