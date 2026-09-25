# Loan Default Risk Dashboard

A BFSI risk-scoring dashboard built to help a credit team identify which
loan applications should be flagged for manual review, based on real
default patterns in a 148,670-loan dataset.

## Business Question

Which customer segments have the highest loan default probability, and
which applications should the credit team manually review?

## Dataset

- Source: [Kaggle — Loan Default Dataset](https://www.kaggle.com/) (~148,670 rows, 34 columns)
- Fields used: income, credit score, loan-to-value ratio (LTV),
  debt-to-income ratio (DTI), loan type, loan amount, region, age,
  property value, and loan status (default flag)

## Tools

- **PostgreSQL** — data cleaning, feature engineering, and all business-question analysis
- **Power BI** — interactive dashboard, DAX measures, risk-tier scoring

## Process

1. **Loaded** the raw dataset into PostgreSQL (`01_create_table.sql`)
2. **Cleaned and engineered features** (`02_data_cleaning.sql`):
   - Identified and excluded three columns (`rate_of_interest`,
     `interest_rate_spread`, `upfront_charges`) after discovering they
     were populated only for non-defaulted loans — a data leakage issue,
     not a real risk signal
   - Built income brackets (Low / Mid / High / Unknown) from income
     percentiles, credit score bands, and LTV bands
3. **Analyzed default rate by segment** (`03_business_analysis.sql`) —
   income, loan type, region, credit score, and age
4. **Built a combined risk score** (`04_risk_segments.sql`) — grouped
   loans by income bracket × loan type × region, filtered to segments
   with at least 100 loans, and tiered each into Low / Medium / High risk
5. **Built the Power BI dashboard** on top of the cleaned tables, with
   slicers, KPI cards, and a segment-level risk table for the credit team

## Key Findings

1. **Low-income applicants default at 33.2%**, nearly 1.6x the rate of
   high-income applicants (20.2%)
2. **Type2 loans are the riskiest loan type at 34.5%**, despite making up
   only ~14% of loan volume
3. **South region defaults at 26.6% vs. 22.5% for North** — a meaningful
   gap on large, comparable sample sizes
4. **Credit score is a weak predictor of default** in this dataset — all
   four credit bands cluster tightly around 24.2%–24.9%, while income
   and loan type explain far more of the variation
5. **Both the youngest (`<25`) and oldest (`>74`) age groups default
   most** (28.95% and 30.01%), while 25–34 and 55–64 are the lowest-risk
   age bands
6. **Data leakage caught and excluded**: `rate_of_interest` and related
   charge fields were missing for 100% of defaulted loans — these fields
   are populated only after a loan is fully processed, so including them
   would have produced a misleading, unusable "predictor"

## Risk Segmentation

Combining income bracket, loan type, and region surfaced risk
combinations invisible when looking at any single factor alone. For
example, **"Unknown income + type1 loans" defaults at 73–83%** in the
South and North regions — far higher than either factor shows on its
own. About **9% of the loan book (13,471 loans across 10 segments)**
falls into High Risk tiers under this combined view.

## Dashboard

**Page 1 — Executive Overview**
- KPI cards: total loans, default rate, high-risk loan count, flagged
  segments, average loan amount, property value, DTI, and LTV
- Four finding-titled bar charts (income, loan type, region, age)
- Top 5 riskiest segments (minimum 100 loans per segment)
- Business insights panel summarizing the findings above

**Page 2 — Risk Segment Explorer** *(in progress)*
- Interactive table of all risk segments, filterable by region, loan
  type, and income bracket, with conditional formatting by risk tier


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
