# Mamaearth Returns & Growth Intelligence Pipeline

An end-to-end Data Analytics and Generative AI project that investigates customer returns, reconciles revenue figures, identifies high-risk customer segments, and analyses monthly revenue trends using **SQLite, Python (Pandas), and Google Gemini**.

## Business Problem

Where are customer returns concentrated, and what does the revenue picture look like after cleaning the data?

The project follows a three-layer workflow: SQL establishes the baseline using raw data, Python cleans and analyses the data, and Generative AI converts verified analytical findings into an executive-ready business narrative.

## Key Findings

The following figures are the reported results of the analysis performed on the project dataset.

- **Revenue reconciliation:** After removing five identified double-submitted orders, 175 orders remain, with cleaned revenue of **₹97,358.30**, compared with the raw SQL revenue of ₹99,860.20.
- **Overall return rate:** The reported blended return rate is **25.1%**.
- **Returns by payment method:** COD has a reported return rate of **44.4%**, compared with 14.7% for Card and 18.9% for UPI.
- **Highest-risk segment:** COD orders in Tier-2 cities have a reported return rate of **54.5% (12 of 22 orders)**.
- **Outlier analysis:** Two bulk orders, with quantities of 25 and 30, inflate January's revenue. After accounting for these outliers, **March 2026 is the reported peak month**, with revenue of ₹20,318.90.

These findings are specific to the supplied dataset. The analysis scripts should be rerun to recalculate the figures whenever the underlying data or cleaning rules change.

## Project Objectives

The project brings together three complementary analytical layers.

### 1. SQL: Relational Database and Reporting

The SQL layer loads the three raw CSV files into SQLite and executes nine business reports covering:

- Total orders, revenue, average order value, and missing ratings.
- Customers who have not placed any orders.
- Return rates by city.
- Top-spending customers.
- Revenue by product category.
- Customer name pattern matching and distinct acquisition sources.
- Customer loyalty tiers based on city tier.

### 2. Python and Pandas: Data Cleaning and Exploratory Data Analysis

The Python layer processes the raw CSV files independently of the SQL database. It standardises payment-method values, removes duplicate submissions, imputes missing values, reconciles revenue, detects quantity outliers, tests hypotheses, analyses return-rate segments, calculates correlations, and compares monthly revenue trends.

It also exports the verified findings to `narrator/findings.json` and generates two visualisations.

### 3. Generative AI: Executive Insight Narrator

The GenAI layer reads the structured findings and generates a business narrative using the **Situation, Complication, Resolution (SCR)** framework.

It supports both a Google Gemini API-based approach and an offline, template-based fallback. A numeric accuracy checker verifies five designated figures in the generated narrative.

The purpose of this layer is to communicate the analytical results clearly, not to replace the underlying calculations.

## How the Three Layers Connect

```text
                 RAW CSV DATA
        customers.csv | products.csv
                 orders.csv
                      |
          +-----------+-----------+
          |                       |
          v                       v
      SQL LAYER               PYTHON LAYER
      SQLite                  Pandas
          |                       |
          v                       v
    9 Business Reports       Data Cleaning
    Raw Data Baseline        Revenue Reconciliation
                             Return Analysis
                             Outlier Detection
                             Visualisations
                                  |
                                  v
                         narrator/findings.json
                                  |
                                  v
                         GENAI NARRATOR
                         Google Gemini
                         Offline Fallback
                                  |
                                  v
                         sample_output.txt
                         Numeric Accuracy Check
```

**Data integrity principle:** SQL establishes the raw-data baseline, Python produces the cleaned analytical results, and the narrative generator consumes the structured findings. The numeric checker validates five critical figures; other narrative claims should still be reviewed against the underlying analytical results.

---

## Repository Structure

```text
mamaearth-capstone/
├── README.md
├── requirements.txt
├── data/
│   ├── customers.csv
│   ├── products.csv
│   └── orders.csv
├── sql/
│   ├── schema.sql
│   ├── seed_data.sql
│   └── reports.sql
├── analysis/
│   ├── clean_and_eda.py
│   └── visualize.py
├── visualizations/
│   ├── return_rate_by_payment.png
│   └── monthly_revenue_trend.png
└── narrator/
    ├── findings.json
    ├── generate_narrative.py
    └── sample_output.txt
```

### File Descriptions

| File or directory | Purpose |
|---|---|
| `data/` | Contains the original customer, product, and order CSV files. |
| `sql/schema.sql` | Defines the relational database schema and table constraints. |
| `sql/seed_data.sql` | Imports the CSV data and verifies the loaded records. |
| `sql/reports.sql` | Executes the nine SQL business reports. |
| `analysis/clean_and_eda.py` | Cleans data, reconciles revenue, performs EDA, and exports findings. |
| `analysis/visualize.py` | Generates the required analytical charts. |
| `visualizations/` | Stores the generated PNG charts. |
| `narrator/findings.json` | Stores structured findings produced by the Python pipeline. |
| `narrator/generate_narrative.py` | Generates and validates the SCR business narrative. |
| `narrator/sample_output.txt` | Stores the generated business narrative and sample output. |
| `requirements.txt` | Lists the Python dependencies required by the project. |

---

## Step-by-Step Reproduction Guide

Follow the steps in order from the project root directory. This workflow is intended to reproduce the database, SQL reports, cleaned metrics, charts, and executive narrative.

## Step 0: Prerequisites and Environment Setup

### Requirements

- Python 3.10 or later.
- SQLite command-line shell (`sqlite3`).
- The three source CSV files in the `data/` directory.
- The dependencies listed in `requirements.txt`.
- A Gemini API key only if the online narrative-generation option is used.

1. Open your terminal or command prompt in the project root directory (`mamaearth-capstone/`):
   ```bash
   cd path/to/mamaearth-capstone
   ```
2. Install all required dependencies from `requirements.txt`:
   ```bash
   pip install -r requirements.txt
   ```
   *(Installs `pandas`, `matplotlib`, and `google-genai`)*.

---

### Step 1: SQL Relational Store & Reporting (`sql/`)

This layer initializes a local SQLite database (`mamaearth.db`), defines schemas, imports the raw CSV seed data, and executes all 9 business reports.

Run the following commands in this exact order:

#### 1. Load the Schema
```bash
sqlite3 mamaearth.db < sql/schema.sql
```
* **What it does:** Executes `sql/schema.sql` to create `customers`, `products`, and `orders` tables with relational primary keys, foreign keys, and nullable `discount_pct` and `rating` columns.

#### 2. Load Seed Data & Clean Blank Imports
```bash
sqlite3 mamaearth.db < sql/seed_data.sql
```
* **What it does:** Imports `data/customers.csv`, `data/products.csv`, and `data/orders.csv` using SQLite's `.import --skip 1` command.
* **Data Cleanup:** Converts empty CSV string cells (`''`) to true SQL `NULL` values so unrated orders are not mistakenly counted as valid ratings.
* **Verification Check:** Outputs the three loaded row counts in your terminal:
  ```text
  45
  16
  180
  ```
  *(Confirms 45 customers, 16 products, and 180 raw orders)*.

#### 3. Run the 9 Business Reports
```bash
sqlite3 -header -column mamaearth.db < sql/reports.sql
```
* **What it does:** Executes reports (a) through (i) on the raw data. Each query in `sql/reports.sql` contains its exact terminal output documented as comments directly above the SQL code.
* **Verified Figures Produced:**
  * **(a) Order Totals:** `total_orders = 180`, `total_revenue = 99860.20`, `avg_order_value = 554.78`.
  * **(b) Missing Ratings:** `total_orders = 180`, `rated_orders = 165`, `unrated_orders = 15`.
  * **(c) Zero-Match Customer:** Both `LEFT JOIN` and `NOT IN` queries isolate customer `C045, Vihaan`.
  * **(d) Cities with Return Rate > 20%:** Jaipur (`42.1%`), Lucknow (`30.6%`), Bangalore (`24.2%`).
  * **(e) Spending Ranks:** Top spender is `C043 Reyansh` (₹12,920.00); ranks 3–5 via `LIMIT 3 OFFSET 2` return `Meera` (₹4,564.60), `Arjun` (₹4,111.00), and `Sanya` (₹3,785.00).
  * **(f) Category Totals:** Haircare (₹44,956.10), Skincare (₹27,346.00), Babycare (₹16,805.00), PersonalCare (₹10,753.10).
  * **(g) Pattern Matching:** Exactly 10 customers whose name starts with 'A'.
  * **(h) Acquisition Channels:** Distinct sources: `Ad`, `Organic`, `Referral`, `Social`.
  * **(i) Loyalty Tiers:** `Gold` = 28 (Tier-1 cities), `Silver` = 17 (Tier-2 cities).

*(Note for Windows PowerShell users: You can also open the SQLite prompt via `sqlite3 mamaearth.db` and execute `.read sql/schema.sql`, `.read sql/seed_data.sql`, and `.read sql/reports.sql` sequentially)*.

---

### Step 2: Python Data Wrangling & EDA (`analysis/`)

This layer processes the raw CSV files directly in pandas to clean the dataset, reconcile revenue metrics, detect outliers, and export visualization charts.

Run these two commands in order:

#### 1. Execute Data Cleaning, Reconciliation, & Findings Export
```bash
python analysis/clean_and_eda.py
```
* **Order of Execution:** This script must be run before generating visualizations or AI narratives.
* **Cleaning Actions Performed:**
  * **Task 1 & 2:** Standardizes messy casing in `payment_method` from 7 variations down to 3: `CARD` (70), `UPI` (55), and `COD` (55).
  * **Task 3:** Flags and drops 5 double-submitted duplicate orders (`O0176`, `O0177`, `O0178`, `O0179`, `O0180`), reducing row count from 180 to 175.
  * **Task 4:** Imputes 12 missing `discount_pct` rows with `0` and 15 missing `rating` rows with the median rating of `3.0`.
  * **Task 5 (Revenue Reconciliation):** Computes cleaned total revenue of **₹97,358.30** across 175 rows. It explicitly attributes the exact **₹2,501.90** difference from Part 1 raw revenue (₹99,860.20) entirely to the 5 dropped duplicate orders.
  * **Task 5 Automated Findings Export:** **Task 5 of Part 2 programmatically writes `narrator/findings.json`** directly from code (never hand-typed), guaranteeing that downstream layers receive verified figures without manual data drift.
  * **Task 6 (IQR Outliers):** Computes the IQR on `quantity` (bounds: -0.5 to 3.5) and flags 2 bulk orders (`O0011` with qty 25, and `O0098` with qty 30) without dropping them.
  * **Task 7 (Hypothesis Test):** Tests return rates across payment methods: COD is **44.4%**, Card is **14.7%**, and UPI is **18.9%** (Hypothesis **Confirmed**).
  * **Task 8 (Segmentation):** Isolates the highest-risk segment: **COD in Tier-2 cities at 54.5%** return rate.
  * **Task 9 (Correlation):** Computes pairwise correlations (all pairs $< 0.20$, labeled `negligible`); busts the hypothesis that higher discounts lower return rates ($r \approx -0.09$).
  * **Task 10 (Time Series Trend):** Compares monthly revenue trends with and without outliers, proving that January's spike (₹29,582.10) was distorted by bulk orders, and **March 2026 is the true retail peak month (₹20,318.90)**.

#### 2. Generate Visualizations
```bash
python analysis/visualize.py
```
* **What it does:** Reads the cleaned merged dataset and saves two charts directly into `visualizations/`:
  * `visualizations/return_rate_by_payment.png`: Bar chart of return rate by payment method (descending), labeled with percentages on bars (`COD Returns at 44.4% — 3x Card`).
  * `visualizations/monthly_revenue_trend.png`: Line chart displaying the outlier-corrected monthly revenue series, highlighting March 2026 as the true peak month.

---

### Step 3: GenAI Insight Narrator (`narrator/`)

This layer translates the verified metrics from `narrator/findings.json` into an executive business summary structured under the **Situation, Complication, Resolution (SCR)** framework.

You can run `narrator/generate_narrative.py` using either the **Offline Fallback Path** or the **Online Gemini API Path**:

#### Option A: Running with No API Key (Offline Fallback Path — Zero Cost)
If you do not have an API key or an internet connection, run the script directly:
```bash
python narrator/generate_narrative.py
```
* **Execution:** Detects that `GEMINI_API_KEY` is not present in the environment. It automatically triggers `generate_scr_narrative_offline()`, constructs the exact SCR sections using an internal template, outputs the result to `narrator/sample_output.txt`, and runs the numeric accuracy checklist.

#### Option B: Running with a Gemini API Key (Online Path)
To use the Gemini API, configure your API key as an environment variable. Obtain the key through Google AI Studio and never commit it to the repository.

1. Set your Gemini API key as an environment variable in your terminal session:
   * **Windows Command Prompt (`cmd`):**
     ```cmd
     set GEMINI_API_KEY=your_actual_api_key_here
     ```
   * **Windows PowerShell:**
     ```powershell
     $env:GEMINI_API_KEY="your_actual_api_key_here"
     ```
   * **macOS / Linux Terminal:**
     ```bash
     export GEMINI_API_KEY="your_actual_api_key_here"
     ```
2. Execute the narrative generation script:
   ```bash
   python narrator/generate_narrative.py
   ```
* **Parameter Locking & Safety:** Calls `gemini-3.8-flash` with locked parameters (`temperature=0.0` for strict factual accuracy, explicit `max_output_tokens=2048`, and a 60-second timeout) wrapped inside a `try/except` safety block.
* **Output:** Saves the generated report into `narrator/sample_output.txt`.

---

### Step 4: Verification of Numeric Accuracy (Task 5)

Whenever `python narrator/generate_narrative.py` is executed (under Option A or Option B), it automatically reads the saved report in `narrator/sample_output.txt` and runs `check_numeric_accuracy()`.

It prints a line-by-line confirmation verifying that all 5 critical figures appear in the narrative:

```text
=================================================================
TASK 5: NUMERIC ACCURACY CHECKLIST (AUDITING SAVED REPORT)
=================================================================
 [PASS] 1. Cleaned total revenue (97,358.30 or 97358.3)
 [PASS] 2. COD return rate (44.4)
 [PASS] 3. COD + Tier-2 highest-risk segment return rate (54.5)
 [PASS] 4. Duplicate reconciliation delta (2,501.90 or 2501.9)
 [PASS] 5. True peak month (March together with 20,318.90 or 20318.9)
=================================================================
[Status] Verification Complete: All 5 figures passed against the saved report.
```
