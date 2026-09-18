import streamlit as st
import pandas as pd
import numpy as np
import joblib
import shap
import matplotlib.pyplot as plt
import plotly.graph_objects as go


# ----------------------------------------------------------------
# PAGE CONFIG
# ----------------------------------------------------------------
st.set_page_config(
    page_title="Olist Late Delivery Predictor",
    page_icon="📦",
    layout="wide",
    initial_sidebar_state="expanded"
)


# ----------------------------------------------------------------
# CUSTOM CSS
# ----------------------------------------------------------------
st.markdown("""
    <style>

        .main {
            background-color: #0a1929;
        }

        .metric-card {
            background-color: #10243d;
            padding: 20px;
            border-radius: 12px;
            border: 1px solid #1e3a5f;
        }

        .risk-high {
            color: #ff4b4b;
            font-weight: 700;
            font-size: 28px;
        }

        .risk-medium {
            color: #ffa726;
            font-weight: 700;
            font-size: 28px;
        }

        .risk-low {
            color: #00c853;
            font-weight: 700;
            font-size: 28px;
        }

        h1, h2, h3 {
            font-family: 'Segoe UI', sans-serif;
            color: #e8f1fb;
        }

        /* Tabs */
        .stTabs [data-baseweb="tab-list"] {
            gap: 8px;
        }

        .stTabs [data-baseweb="tab"] {
            background-color: #10243d;
            border-radius: 8px 8px 0 0;
            padding: 10px 20px;
            color: #cfe3f7;
        }

        .stTabs [aria-selected="true"] {
            background-color: #1565c0 !important;
            color: white !important;
        }

        /* Buttons */
        .stButton > button,
        .stDownloadButton > button,
        button[kind="primary"],
        button[kind="secondary"],
        div[data-testid="stBaseButton-primary"] button,
        div[data-testid="stBaseButton-secondary"] button {

            background-color: #ff8c00 !important;
            color: white !important;
            border: none !important;
            border-radius: 8px !important;
            font-weight: 600 !important;
            transition: background-color 0.2s ease-in-out;
        }

        .stButton > button:hover,
        .stDownloadButton > button:hover,
        button[kind="primary"]:hover,
        button[kind="secondary"]:hover {

            background-color: #e67600 !important;
            color: white !important;
        }

        .stButton > button:active,
        .stDownloadButton > button:active,
        button[kind="primary"]:active,
        button[kind="secondary"]:active {

            background-color: #cc6a00 !important;
        }

        /* Sliders */
        .stSlider [role="slider"] {
            background-color: #1565c0;
        }

        div[data-baseweb="slider"] > div > div {
            background: #1565c0 !important;
        }

        /* Sidebar */
        section[data-testid="stSidebar"] {
            background-color: #0d1f33;
        }

        /* Inputs */
        div[data-baseweb="select"] > div,
        .stNumberInput input,
        .stDateInput input {

            background-color: #10243d !important;
            color: #e8f1fb !important;
        }

    </style>
""", unsafe_allow_html=True)


# ----------------------------------------------------------------
# LOAD MODEL
# ----------------------------------------------------------------
@st.cache_resource
def load_model_and_columns():

    model = joblib.load(
        r"C:\Users\USER\Desktop\Olist\models\xgb_model.joblib"
    )

    model_columns = joblib.load(
        r"C:\Users\USER\Desktop\Olist\models\model_columns.joblib"
    )

    return model, model_columns


# ----------------------------------------------------------------
# LOAD SHAP EXPLAINER
# ----------------------------------------------------------------
@st.cache_resource
def load_explainer(_model):

    return shap.TreeExplainer(_model)


# ----------------------------------------------------------------
# INITIALIZE MODEL
# ----------------------------------------------------------------
try:

    model, model_columns = load_model_and_columns()
    explainer = load_explainer(model)

    MODEL_LOADED = True

except FileNotFoundError:

    MODEL_LOADED = False


# ----------------------------------------------------------------
# CONSTANTS
# ----------------------------------------------------------------
BRAZIL_STATES = [
    "SP", "RJ", "MG", "ES", "PR", "SC", "RS", "BA", "PE", "CE",
    "MA", "PB", "RN", "AL", "SE", "PI", "GO", "MT", "MS", "DF",
    "AM", "PA", "RO", "AC", "AP", "RR", "TO"
]

PAYMENT_TYPES = [
    "credit_card",
    "boleto",
    "voucher",
    "debit_card"
]


# ----------------------------------------------------------------
# BUILD MODEL INPUT
# ----------------------------------------------------------------
def build_input_row(raw: dict, columns: list) -> pd.DataFrame:

    row = pd.DataFrame(
        np.zeros((1, len(columns))),
        columns=columns
    )

    numeric_fields = [
        "price",
        "freight_value",
        "product_weight_g",
        "product_length_cm",
        "product_height_cm",
        "product_width_cm",
        "payment_installments",
        "purchase_month",
        "purchase_dayofweek",
        "purchase_hour",
        "estimated_delivery_days",
        "different_state"
    ]

    for field in numeric_fields:

        if field in row.columns:
            row.at[0, field] = raw[field]

    # Payment type
    payment_col = f"payment_type_{raw['payment_type']}"

    if payment_col in row.columns:
        row.at[0, payment_col] = 1

    # Customer state
    customer_col = f"customer_state_{raw['customer_state']}"

    if customer_col in row.columns:
        row.at[0, customer_col] = 1

    # Seller state
    seller_col = f"seller_state_{raw['seller_state']}"

    if seller_col in row.columns:
        row.at[0, seller_col] = 1

    return row


# ----------------------------------------------------------------
# RISK GAUGE
# ----------------------------------------------------------------
def risk_gauge(probability: float) -> go.Figure:

    fig = go.Figure(
        go.Indicator(

            mode="gauge+number",

            value=probability * 100,

            number={
                "suffix": "%",
                "font": {
                    "size": 40
                }
            },

            title={
                "text": "Late Delivery Risk",
                "font": {
                    "size": 20
                }
            },

            gauge={

                "axis": {
                    "range": [0, 100]
                },

                "bar": {
                    "color": "#1c1f26"
                },

                "steps": [

                    {
                        "range": [0, 30],
                        "color": "#00c853"
                    },

                    {
                        "range": [30, 60],
                        "color": "#ffa726"
                    },

                    {
                        "range": [60, 100],
                        "color": "#ff4b4b"
                    }

                ],

                "threshold": {

                    "line": {
                        "color": "white",
                        "width": 4
                    },

                    "thickness": 0.8,

                    "value": probability * 100
                }
            }
        )
    )

    fig.update_layout(

        height=320,

        margin=dict(
            l=20,
            r=20,
            t=60,
            b=20
        ),

        paper_bgcolor="rgba(0,0,0,0)",

        font={
            "color": "white"
        }
    )

    return fig


# ----------------------------------------------------------------
# SIDEBAR
# ----------------------------------------------------------------
with st.sidebar:

    st.title("📦 Olist Delivery AI")

    st.divider()

    st.subheader("⚙️ Decision Threshold")

    threshold = st.slider(

        "Probability cutoff for flagging an order as 'Late'",

        min_value=0.05,
        max_value=0.95,
        value=0.50,
        step=0.05,

        help=(
            "Lower = catches more late orders but more false alarms. "
            "Higher = fewer false alarms but misses more late orders."
        )
    )

    st.divider()

    st.markdown(
        "**Model:** XGBoost Classifier"
    )

    st.markdown(
        "**Target:** Probability an order arrives after "
        "its estimated delivery date"
    )

    st.markdown(
        "**Dataset:** Brazilian E-Commerce (Olist), ~100K orders"
    )

    if not MODEL_LOADED:

        st.error(
            "Model files not found. Place `xgb_model.joblib` "
            "and `model_columns.joblib` in the same folder as this app."
        )


# ----------------------------------------------------------------
# HEADER
# ----------------------------------------------------------------
st.title(
    "📦 Late Delivery Risk Predictor"
)

st.markdown(
    "Predict the probability that an order will arrive **after** "
    "its estimated delivery date — before it even ships."
)

st.divider()


if not MODEL_LOADED:
    st.stop()


# ----------------------------------------------------------------
# TABS
# ----------------------------------------------------------------
tab_predict, tab_batch = st.tabs(
    [
        "🔮 Single Prediction",
        "📁 Batch Prediction"
    ]
)


# ==================================================================
# TAB 1 — SINGLE PREDICTION
# ==================================================================
with tab_predict:

    st.subheader("Order Details")

    col1, col2, col3 = st.columns(3)


    # --------------------------------------------------------------
    # ORDER VALUE
    # --------------------------------------------------------------
    with col1:

        st.markdown("**💰 Order Value**")

        price = st.number_input(
            "Product price (BRL)",
            min_value=0.0,
            value=120.0,
            step=5.0
        )

        freight_value = st.number_input(
            "Freight value (BRL)",
            min_value=0.0,
            value=20.0,
            step=1.0
        )

        payment_type = st.selectbox(
            "Payment type",
            PAYMENT_TYPES
        )

        payment_installments = st.slider(
            "Installments",
            1,
            24,
            1
        )


    # --------------------------------------------------------------
    # PRODUCT DIMENSIONS
    # --------------------------------------------------------------
    with col2:

        st.markdown("**📦 Product Dimensions**")

        product_weight_g = st.number_input(
            "Weight (g)",
            min_value=0,
            value=800,
            step=50
        )

        product_length_cm = st.number_input(
            "Length (cm)",
            min_value=0,
            value=20,
            step=1
        )

        product_height_cm = st.number_input(
            "Height (cm)",
            min_value=0,
            value=10,
            step=1
        )

        product_width_cm = st.number_input(
            "Width (cm)",
            min_value=0,
            value=15,
            step=1
        )


    # --------------------------------------------------------------
    # LOGISTICS
    # --------------------------------------------------------------
    with col3:

        st.markdown("**📍 Logistics**")

        customer_state = st.selectbox(
            "Customer state",
            BRAZIL_STATES,
            index=0
        )

        seller_state = st.selectbox(
            "Seller state",
            BRAZIL_STATES,
            index=1
        )

        estimated_delivery_days = st.slider(
            "Estimated delivery window (days)",
            1,
            60,
            15
        )

        purchase_date = st.date_input(
            "Purchase date"
        )

        purchase_hour = st.slider(
            "Purchase hour",
            0,
            23,
            14
        )


    # --------------------------------------------------------------
    # PREDICT BUTTON
    # --------------------------------------------------------------
    predict_btn = st.button(
        "🔍 Predict Delivery Risk",
        type="primary",
        use_container_width=True
    )


    # --------------------------------------------------------------
    # PREDICTION
    # --------------------------------------------------------------
    if predict_btn:

        raw_input = {

            "price": price,

            "freight_value": freight_value,

            "product_weight_g": product_weight_g,

            "product_length_cm": product_length_cm,

            "product_height_cm": product_height_cm,

            "product_width_cm": product_width_cm,

            "payment_installments": payment_installments,

            "payment_type": payment_type,

            "purchase_month": purchase_date.month,

            "purchase_dayofweek": purchase_date.weekday(),

            "purchase_hour": purchase_hour,

            "estimated_delivery_days": estimated_delivery_days,

            "different_state": int(
                customer_state != seller_state
            ),

            "customer_state": customer_state,

            "seller_state": seller_state
        }


        input_row = build_input_row(
            raw_input,
            model_columns
        )


        probability = model.predict_proba(
            input_row
        )[0, 1]


        prediction = int(
            probability >= threshold
        )


        st.divider()


        res_col1, res_col2 = st.columns(
            [1, 1]
        )


        # ----------------------------------------------------------
        # RISK GAUGE
        # ----------------------------------------------------------
        with res_col1:

            st.plotly_chart(
                risk_gauge(probability),
                use_container_width=True
            )


        # ----------------------------------------------------------
        # RESULT
        # ----------------------------------------------------------
        with res_col2:

            st.markdown("### Result")


            if probability >= 0.6:

                st.markdown(
                    f"""
                    <p class="risk-high">
                        🔴 HIGH RISK — {probability:.1%}
                    </p>
                    """,
                    unsafe_allow_html=True
                )

                st.warning(
                    "This order has a high probability of arriving late. "
                    "Consider prioritizing it or flagging it for proactive "
                    "customer communication."
                )


            elif probability >= 0.3:

                st.markdown(
                    f"""
                    <p class="risk-medium">
                        🟠 MEDIUM RISK — {probability:.1%}
                    </p>
                    """,
                    unsafe_allow_html=True
                )

                st.info(
                    "Moderate risk of delay. Worth monitoring."
                )


            else:

                st.markdown(
                    f"""
                    <p class="risk-low">
                        🟢 LOW RISK — {probability:.1%}
                    </p>
                    """,
                    unsafe_allow_html=True
                )

                st.success(
                    "This order is likely to arrive on time."
                )


            st.metric(
                "Predicted class at current threshold",
                "LATE" if prediction == 1 else "ON TIME",
                delta=f"Threshold: {threshold:.2f}"
            )


        # ----------------------------------------------------------
        # SHAP EXPLANATION
        # ----------------------------------------------------------
        st.divider()

        st.markdown(
            "### 🧠 Why did the model predict this?"
        )

        st.caption(
            "Red bars push the prediction toward 'Late'. "
            "Blue bars push the prediction toward 'On Time'."
        )


        shap_values_single = explainer.shap_values(
            input_row
        )

        expected_value = explainer.expected_value


        fig, ax = plt.subplots(
            figsize=(9, 5)
        )


        shap.plots._waterfall.waterfall_legacy(

            expected_value,

            shap_values_single[0],

            feature_names=model_columns,

            max_display=10,

            show=False
        )


        st.pyplot(
            fig,
            use_container_width=True
        )


# ==================================================================
# TAB 2 — BATCH PREDICTION
# ==================================================================
with tab_batch:

    st.subheader(
        "Batch Prediction from CSV"
    )

    st.caption(
        "Upload a CSV with the same raw columns used in training "
        "(price, freight_value, product_weight_g, customer_state, etc.)"
    )


    # --------------------------------------------------------------
    # CSV UPLOAD
    # --------------------------------------------------------------
    uploaded_file = st.file_uploader(
        "Upload CSV",
        type=["csv"]
    )


    if uploaded_file is not None:

        batch_df = pd.read_csv(
            uploaded_file
        )


        st.write(
            "Preview:",
            batch_df.head()
        )


        # ----------------------------------------------------------
        # BATCH PREDICTION
        # ----------------------------------------------------------
        if st.button(
            "Run Batch Prediction",
            type="primary"
        ):


            batch_encoded = pd.get_dummies(
                batch_df
            )


            batch_encoded = batch_encoded.reindex(
                columns=model_columns,
                fill_value=0
            )


            probs = model.predict_proba(
                batch_encoded
            )[:, 1]


            batch_df["late_probability"] = probs


            batch_df["prediction"] = np.where(
                probs >= threshold,
                "LATE",
                "ON TIME"
            )


            st.success(
                f"Predicted {len(batch_df)} orders."
            )


            st.dataframe(
                batch_df.style.background_gradient(
                    subset=["late_probability"],
                    cmap="RdYlGn_r"
                ),
                use_container_width=True
            )


            # ------------------------------------------------------
            # DOWNLOAD RESULTS
            # ------------------------------------------------------
            csv_out = batch_df.to_csv(
                index=False
            ).encode("utf-8")


            st.download_button(

                "⬇️ Download Results as CSV",

                data=csv_out,

                file_name="late_delivery_predictions.csv",

                mime="text/csv"
            )