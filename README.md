# Loan Default Risk Dashboard

A BFSI risk-scoring dashboard built to help a credit team identify which
loan applications should be flagged for manual review, based on real
default patterns in a 148,670-loan dataset.

## Business Question

Which customer segments have the highest loan default probability, and
which applications should the credit team manually review?

## Dataset

- Source: Kaggle loan default dataset (~148,670 rows, 34 columns)
- Fields used: income, credit score, loan-to-value ratio (LTV),
  debt-to-income ratio (DTI), loan type, loan amount, property value,
  region, age, and loan status (default flag)

## Tools

- **PostgreSQL** — data cleaning, feature engineering, and all business-question analysis
- **Power BI** — interactive dashboard and DAX measures

## Process

1. **Loaded** the raw dataset into PostgreSQL (`01_create_table.sql`)
2. **Cleaned and engineered features** (`02_data_cleaning.sql`):
   - Identified and excluded three columns (`rate_of_interest`,
     `interest_rate_spread`, `upfront_charges`) after discovering they
     were populated only for non-defaulted loans — a data leakage issue,
     not a real risk signal
   - Built income brackets (Low / Mid / High / Unknown) using income
     percentiles, plus credit score bands and LTV bands
   - Added a numeric sort-order column for age brackets so they display
     in true age order rather than alphabetical order
3. **Analyzed default rate by segment** (`03_business_analysis.sql`) —
   by income bracket, loan type, region, credit score band, and age
4. **Built a combined risk score** (`04_risk_segments.sql`) — grouped
   loans by income bracket × loan type × region, kept only segments with
   at least 100 loans, and tiered each into Low / Medium / High risk
   based on its default rate
5. **Built the Power BI dashboard** on the cleaned tables, with slicers,
   KPI cards, finding-based charts, and a risk-ranked segment view

## Key Findings

1. **Low-income applicants default at 33.15%**, about 1.6x the rate of
   high-income applicants (20.22%)
2. **Type2 loans are the riskiest loan type at 34.54%**, despite being
   only about 14% of loan volume, versus 22.77% for type1
3. **South defaults at 26.63% vs. 22.51% for North** — a meaningful gap
   on two large, comparable sample sizes (North-East shows a higher rate
   at 30.45%, but its sample size of 1,235 loans is too small to be a
   reliable headline finding)
4. **Credit score is a weak predictor of default** in this dataset — all
   four credit bands (Poor, Fair, Good, Excellent) cluster tightly
   between 24.16% and 24.93%, while income and loan type explain far
   more of the variation
5. **Both the youngest (`<25`) and oldest (`>74`) age groups default
   most**, at 28.95% and 30.01% respectively, while ages 25-34 (22.19%)
   and 55-64 (22.37%) are the lowest-risk age bands
6. **Data leakage caught and excluded**: `rate_of_interest` was missing
   for 100% of defaulted loans and present for 99.82% of non-defaulted
   loans — these fields are only populated after a loan is fully
   processed, so including them would have produced a misleading,
   unusable "predictor" rather than a real risk signal

## Risk Segmentation

Combining income bracket, loan type, and region surfaced risk
combinations that are invisible when looking at any single factor
alone. The two highest-risk segments found were **"Unknown income +
type1 loans" in the South (83.25% default rate) and North (73.56%)** —
far higher than either income or loan type shows on its own. Of the 38
segments with at least 100 loans, **10 fall into the High Risk tier,
covering about 13,471 loans (roughly 9% of the total loan book)**.

## Dashboard

**Loan Default Risk Dashboard (single page)**
- KPI cards: total loans, default rate, high-risk loan count, flagged
  segments, average loan amount, average property value, average DTI,
  and average LTV
- Slicers: filter by region, loan type, and income bracket
- Four bar charts, each titled with its finding: default rate by income
  bracket, by loan type, by region, and by age
- Top 5 riskiest segments (minimum 100 loans per segment), ranked and
  color-coded by risk level
- A business insights panel summarizing the findings above in plain
  language

## Repository Structure

loan-default-risk-dashboard/
├── README.md
├── sql/
│ ├── 01_create_table.sql
│ ├── 02_data_cleaning.sql
│ ├── 03_business_analysis.sql
│ └── 04_risk_segments.sql
├── dashboard/
│ └── loan_default_risk_dashboard.pbix
└── images/
└── dashboard_page1.png


## Author

Jeel Limbani

![Dashboard](images/dashboard_page1.png)

## Repository Structure
