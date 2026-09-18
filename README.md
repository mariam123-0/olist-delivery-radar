# 📦 Olist E-Commerce — End-to-End Data Analysis & Machine Learning

An end-to-end data project on the **Brazilian E-Commerce (Olist) dataset** (~100K real orders), covering the full pipeline from raw CSVs to a deployed, interactive machine learning app:

**PostgreSQL & Data Modeling (DBeaver) → SQL Analysis → Python (EDA & KPIs) → Power BI Dashboard → Machine Learning (XGBoost) → Streamlit Deployment**

> 🎯 **Core business question:** Can we predict whether an order will arrive **late** — before it even ships — so operations teams can act proactively instead of reactively?

---

## 📌 Table of Contents
- [Project Architecture](#-project-architecture)
- [Project Structure](#-project-structure)
- [Dataset](#-dataset)
- [Step 1 — Database Design & SQL Analysis (DBeaver + PostgreSQL)](#step-1--database-design--sql-analysis-dbeaver--postgresql)
- [Step 2 — Python: Data Cleaning & KPI Analysis](#step-2--python-data-cleaning--kpi-analysis)
- [Step 3 — Power BI Dashboard](#step-3--power-bi-dashboard)
- [Step 4 — Machine Learning: Late Delivery Prediction](#step-4--machine-learning-late-delivery-prediction)
- [Step 5 — Deployment: Streamlit App](#step-5--deployment-streamlit-app)
- [Skills Applied](#-skills-applied)
- [Challenges & Solutions](#-challenges--solutions)
- [How to Run This Project](#-how-to-run-this-project)
- [Tech Stack](#-tech-stack)

---

## 🏗 Project Architecture

Data moves through five stages, each one handing its output to the next:

![Architecture Pipeline](assets/screenshots/architecture_pipeline.png)

Each stage is documented in its own section below, with the actual outputs (screenshots, SQL, DAX, model metrics) included.

> 📸 **Note on screenshots:** the images referenced throughout this README live in `assets/screenshots/` — copy your exported PNGs there (ERD, DBeaver, dashboard, SHAP plots, app screens) using the file names referenced below, or update the paths to match your own naming.

---

## 📁 Project Structure

```
Olist/
│
├── README.md
├── requirements.txt
├── .gitignore
│
├── assets/
│   └── screenshots/                          # README images (ERD, dashboard, app, SHAP, etc.)
│
├── data/
│   └── ...csv files                          # Raw Olist CSVs (Kaggle source)
│
├── sql/
│   ├── 01_create_tables.sql                  # Schema definition (9 tables)
│   ├── 02_check_nulls_and_types.sql          # Data quality audit
│   ├── 03_relationships.sql                  # Foreign keys
│   ├── 04_joins.sql                          # Multi-table joins
│   ├── 05_aggregations_ctes_window_functions.sql
│   └── 06_data_analysis_questions.sql        # Business-question queries
│
├── notebooks/
│   ├── 01_eda_kpis.ipynb                     # Data cleaning + exploratory KPIs
│   └── 02_model_training.ipynb               # Feature engineering + ML training
│
├── models/
│   ├── xgb_model.joblib                      # Trained XGBoost classifier
│   └── model_columns.joblib                  # Feature schema for inference
│
├── app/
│   └── app.py                                # Streamlit late-delivery predictor
│
└── powerbi/
    ├── olist_dashboard.pdf
    ├── olist_powerbi_dax_reference.md        # All DAX measures/columns used
    └── powerbi_dashboard.pbix
```

---

## 📊 Dataset

**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle)

~100K real orders placed on the Olist marketplace between 2016–2018, spread across 9 relational tables:

| Table | Rows (approx.) | Contents |
|---|---:|---|
| `orders` | 99,441 | Order status, purchase/approval/delivery timestamps |
| `order_items` | 112,650 | Products per order, price, freight |
| `order_payments` | 103,886 | Payment type, installments, value |
| `order_reviews` | 99,224 | Review score, comments |
| `customers` | 99,441 | Customer ID, location |
| `sellers` | 3,095 | Seller ID, location |
| `products` | 32,951 | Category, weight, dimensions |
| `geolocation` | 1,000,163 | Zip code → lat/lng |
| `category_translation` | 71 | Portuguese → English category names |

---

## Step 1 — Database Design & SQL Analysis (DBeaver + PostgreSQL)

Before any analysis, the raw CSVs were loaded into a **PostgreSQL** database and explored using **DBeaver** as the database client — building a proper relational model rather than working from flat, disconnected files.

### Entity-Relationship Diagram (ERD)
Built directly in DBeaver's schema diagram tool to map out how the 9 tables connect through primary/foreign keys:

![ERD Diagram](assets/screenshots/ERD.png)

### Database & table inspection in DBeaver
Verified row counts and table structure directly against the live PostgreSQL schema before writing any queries:

![DBeaver Table Overview](assets/screenshots/DBeaver.png)

### SQL work breakdown (`sql/`)

| File | What it covers |
|---|---|
| `01_create_tables.sql` | `CREATE TABLE` statements for all 9 tables, with appropriate data types and primary keys |
| `02_check_nulls_and_types.sql` | Column-by-column null audits (`COUNT(*) - COUNT(column)`) and data type checks via `INFORMATION_SCHEMA.COLUMNS` for every table |
| `03_relationships.sql` | Foreign key constraints (e.g., linking `products` → `category_translation`) and verification queries against `information_schema.table_constraints` |
| `04_joins.sql` | Multi-table joins connecting orders → customers → order items → products → categories |
| `05_aggregations_ctes_window_functions.sql` | Aggregations (revenue by payment type, product performance), CTEs (customers with 3+ orders, revenue by category), and window functions (`ROW_NUMBER`, `RANK`, `DENSE_RANK`, `SUM() OVER()`, `AVG() OVER()`) |
| `06_data_analysis_questions.sql` | Business-driven queries — top 10 categories by revenue, states with the most orders, most-used payment method, average order value, and more |

**Example — window function used to rank sellers by revenue:**
```sql
SELECT
    seller_id,
    SUM(price) AS total_revenue,
    RANK() OVER (ORDER BY SUM(price) DESC) AS seller_rank
FROM order_items
GROUP BY seller_id;
```

**Example — CTE identifying repeat customers:**
```sql
WITH customer_orders AS (
    SELECT customer_id, COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id, total_orders
FROM customer_orders
WHERE total_orders > 3
ORDER BY total_orders DESC;
```

---

## Step 2 — Python: Data Cleaning & KPI Analysis

**Notebook:** `notebooks/01_eda_kpis.ipynb`

- Loaded and merged all 9 tables with `pandas`
- Fixed timestamp columns stored as US-locale text strings (`M/D/YYYY H:MM:SS AM/PM`) — converted with `pd.to_datetime()`
- Handled missing values (e.g., undelivered orders with no delivery date)
- Computed exploratory KPIs: delivery time distributions, revenue trends, payment behavior, review score patterns
- Exported clean, structured KPI tables used as the foundation for both the Power BI dashboard and the ML feature set

---

## Step 3 — Power BI Dashboard

An interactive dashboard summarizing delivery performance, revenue trends, and customer behavior — built with **Power Query** (data cleaning/locale fixes) and **DAX** (calculated columns + measures).

![Power BI Dashboard](assets/screenshots/DashBoard.png)

**Dashboard highlights:**
- **Total Orders / Total Revenue** KPI cards
- **Revenue by Order Month** — trend line showing growth over the platform's lifetime
- **Orders by Day of Week** — operational pattern for staffing insight
- **Region by Total Revenue** — geographic sales distribution
- **Orders by Product Size Category** — logistics breakdown (Light/Medium/Heavy/Very Heavy)
- **Orders by Delivery Status** — On Time / Late / Not Delivered split

### DAX reference
Every calculated column and measure used in this dashboard — organized by table, with dependency notes — is documented in full: **[`powerbi/olist_powerbi_dax_reference.md`](./powerbi/olist_powerbi_dax_reference.md)**

**Full inventory of what was built:**

![DAX Inventory Checklist](assets/screenshots/AnalysisStructure.png)

Includes columns like `Delivery Status`, `Delivery Delay (Days)`, `Order Month`, `Review Sentiment`, `Region`, `Product Size Category`, and measures like `Total Orders`, `Average Delivery Time`, `Cancellation Rate`, and `Late Delivery %`.

---

## Step 4 — Machine Learning: Late Delivery Prediction

**Notebook:** `notebooks/02_model_training.ipynb`

### Objective
Predict, **at the time of purchase**, whether an order will arrive after its estimated delivery date — using only information available before shipping (no data leakage from delivery-time fields).

### Feature engineering
- Time-based: purchase month, day of week, hour
- Logistics: estimated delivery window, whether customer/seller are in different states (distance proxy)
- Order details: price, freight value, product weight/dimensions
- Payment: type, number of installments
- Categorical encoding via one-hot encoding (`pd.get_dummies`)

### Modeling approach — baseline first, then upgrade
| Step | Model | Purpose |
|---|---|---|
| 1 | **Logistic Regression** (`class_weight='balanced'`) | Baseline — simple, interpretable, sanity check |
| 2 | **XGBoost** (`scale_pos_weight` tuned for class imbalance) | Main model — captures non-linear feature interactions |

### Results — baseline vs. main model

![Model Comparison](assets/screenshots/CompairModels.png)

| Metric | Logistic Regression | XGBoost | Improvement |
|---|---:|---:|---:|
| Precision (Late) | 0.13 | **0.20** | +54% |
| Recall (Late) | 0.62 | **0.67** | +8% |
| F1-score (Late) | 0.22 | **0.31** | +41% |
| Accuracy | 0.65 | **0.77** | +18% |
| **ROC-AUC** | 0.680 | **0.794** | +17% |

XGBoost outperformed the baseline on every single metric, confirming the added model complexity was justified by real performance gains — not chosen arbitrarily.

### Explainability with SHAP
Beyond raw accuracy, **SHAP (SHapley Additive exPlanations)** was used to explain *individual* predictions — critical for a business-facing tool, since "the model says it's risky" is far less useful than "the model says it's risky **because** the estimated delivery window is unusually tight."

![SHAP Waterfall Explanation](assets/screenshots/2_singlePrediction.png)

Red bars push a prediction toward "Late," blue bars push it toward "On Time" — giving full transparency into what's driving each individual risk score, not just a black-box probability.

---

## Step 5 — Deployment: Streamlit App

The trained model was deployed as a fully interactive web app — not just a Jupyter notebook — so the prediction tool can actually be used by someone outside the data team.

### 🔮 Single Prediction
A form-based interface to score one order at a time, with a live risk gauge and instant feedback:

![Single Prediction](assets/screenshots/1_SinglePrediction.png)

### 📁 Batch Prediction
Upload a CSV of multiple orders and get late-delivery probabilities for all of them at once, with color-coded risk and a downloadable results file:

![Batch Prediction](assets/screenshots/BatchPrediction.png)

**App features:**
- Adjustable **decision threshold** slider (live precision/recall tradeoff control)
- Per-prediction **SHAP waterfall explanation**
- Global feature importance view
- Batch CSV upload/download
- Custom dark theme (blue background, orange accents) built entirely with CSS inside `app.py`
- `@st.cache_resource` used so the model and SHAP explainer load once, not on every interaction

---

## 🧠 Skills Applied

| Category | Skills |
|---|---|
| **Database & SQL** | PostgreSQL, DBeaver (ERD & data modeling), `CREATE TABLE`, foreign keys, joins, CTEs, window functions (`ROW_NUMBER`, `RANK`, `DENSE_RANK`), aggregations, data-quality auditing (null/type checks) |
| **Python / Data Wrangling** | pandas (merging, cleaning, datetime handling), handling missing data, locale-aware date parsing |
| **Business Intelligence** | Power Query (data transformation, locale fixes), DAX (calculated columns vs. measures, row context vs. filter context), dashboard design |
| **Machine Learning** | scikit-learn, XGBoost, train/test splitting with stratification, handling class imbalance (`class_weight`, `scale_pos_weight`), model evaluation (precision/recall/F1/ROC-AUC), avoiding data leakage |
| **Explainable AI** | SHAP (TreeExplainer, waterfall & summary plots) |
| **Deployment** | Streamlit, `joblib` model serialization, custom CSS theming, caching strategies |
| **Software Practice** | Git/GitHub version control, `.gitignore`, project structuring, reproducible environments (`requirements.txt`) |

---

## 🧗 Challenges & Solutions

| Challenge | Solution |
|---|---|
| **Timestamps stored as US-locale text** (`7/24/2018 8:41:37 PM`) broke `DATEDIFF` in Power BI and `pd.to_datetime()` behaved inconsistently | Used Power Query's **"Change Type → Using Locale → English (United States)"** for all date columns, and `pd.to_datetime()` in Python, before any date arithmetic |
| **DAX column vs. measure confusion** — a formula referencing `orders[order_purchase_timestamp]` directly worked as a column (row context) but threw *"a single value... cannot be determined"* as a measure (filter context) | Learned to distinguish row-context (columns) from filter-context (measures) explicitly, and verified every formula was created in the correct table and mode before debugging further |
| **Severe class imbalance** — only ~8% of orders were late, making raw accuracy a misleading metric (a model predicting "on time" for everything would still score ~92%) | Used `class_weight='balanced'` (Logistic Regression) and `scale_pos_weight` (XGBoost), and evaluated with **precision, recall, F1, and ROC-AUC** instead of accuracy alone |
| **Power BI's Map/Filled Map visual blocked by tenant policy** (`MapVisualNotEnabled` error, common on work/school Microsoft accounts) | Replaced the geographic map with a sorted **bar chart** (`Region` / `customer_state` → `Total Revenue`) — a reliable, portfolio-safe alternative with no external dependency |
| **Data leakage risk in the ML model** — using delivery-time fields (`order_delivered_customer_date`) as features would let the model "cheat" using information that doesn't exist yet at prediction time | Strictly restricted the feature set to information known **at the time of purchase only** |
| **Project file organization** across notebooks, model artifacts, and the Streamlit app led to repeated `FileNotFoundError` issues from mismatched relative paths and inconsistent folder names | Standardized on a clean, consistently-named folder structure (see [Project Structure](#-project-structure)) and used explicit, verified paths in both the notebook and the app |

---

## 🚀 How to Run This Project

### 1. Clone the repository
```bash
git clone https://github.com/YOUR-USERNAME/olist-ecommerce-analysis.git
cd olist-ecommerce-analysis
```

### 2. Install dependencies
```bash
pip install -r requirements.txt --break-system-packages
```

### 3. Add the dataset
Download the CSVs from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place them in `data/`.

### 4. (Optional) Recreate the database
Run the scripts in `sql/` in order (`01` → `06`) against a PostgreSQL instance — e.g., via DBeaver — to rebuild the relational schema and reproduce the SQL analysis.

### 5. Run the notebooks
```bash
jupyter notebook notebooks/01_eda_kpis.ipynb
jupyter notebook notebooks/02_model_training.ipynb
```
Running `02_model_training.ipynb` in full regenerates `models/xgb_model.joblib` and `models/model_columns.joblib`.

### 6. Launch the Streamlit app
```bash
cd app
streamlit run app.py
```

### 7. Explore the Power BI dashboard
Open `powerbi/powerbi_dashboard.pbix` in Power BI Desktop, or view the static export at `powerbi/olist_dashboard.pdf`.

---

## 🛠 Tech Stack

**Database:** PostgreSQL, DBeaver
**Languages:** SQL, Python, DAX
**Python libraries:** pandas, numpy, scikit-learn, XGBoost, SHAP, Streamlit, Plotly, matplotlib
**BI Tool:** Power BI (Power Query, DAX)
**Version Control:** Git, GitHub

---

## 👤 Author

**[Mariam Tarek]**
📧 [mariam.tarek8122005@gmail.com]
🔗 [LinkedIn](https://www.linkedin.com/in/mariam-tarek-a2261b321/)

---

*This project was built as a three-part series — SQL/Database Design → Python & Power BI Analysis → Machine Learning & Deployment — demonstrating a complete, end-to-end data workflow from raw data to a production-style interactive tool.*
