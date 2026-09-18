# Olist E-Commerce Analysis — Power BI DAX Reference

A complete reference of all calculated columns and measures used in this project, organized by table. Paste order matters within each table — some columns/measures reference others created earlier (noted where relevant).

**Prerequisite:** All date/time columns in `orders` (`order_purchase_timestamp`, `order_approved_at`, `order_delivered_carrier_date`, `order_delivered_customer_date`, `order_estimated_delivery_date`) must be converted to **Date/Time** type in Power Query using **Change Type → Using Locale → English (United States)** before creating any DAX below. Kaggle's Olist CSVs store these as US-format text strings (`M/D/YYYY H:MM:SS AM/PM`), and DAX date functions will fail or return wrong results otherwise.

---

## Table: `orders`

### Calculated Columns

```dax
Delivery Time (Days) = 
DATEDIFF(
    orders[order_purchase_timestamp],
    orders[order_delivered_customer_date],
    DAY
)
```

```dax
Delivery Delay (Days) = 
DATEDIFF(
    orders[order_estimated_delivery_date],
    orders[order_delivered_customer_date],
    DAY
)
```

```dax
Delivery Status = 
IF(
    ISBLANK(orders[order_delivered_customer_date]),
    "Not Delivered",
    IF(
        orders[Delivery Delay (Days)] > 0,
        "Late",
        "On Time / Early"
    )
)
```
> Depends on `Delivery Delay (Days)` — create that column first.

```dax
Approval Time (Hours) = 
DATEDIFF(
    orders[order_purchase_timestamp],
    orders[order_approved_at],
    HOUR
)
```

```dax
Is Late Delivery = 
IF(
    NOT ISBLANK(orders[order_delivered_customer_date]) &&
    orders[order_delivered_customer_date] > orders[order_estimated_delivery_date],
    1, 0
)
```

```dax
Order Month = 
FORMAT(orders[order_purchase_timestamp], "YYYY-MM")
```

```dax
Order Day of Week = 
FORMAT(orders[order_purchase_timestamp], "dddd")
```

```dax
Day Number = 
WEEKDAY(orders[order_purchase_timestamp], 2)
```
> Used as the **Sort by Column** for `Order Day of Week` (Column tools → Sort by Column) so charts order Monday → Sunday instead of alphabetically.

### Measures

```dax
Total Orders = 
DISTINCTCOUNT(orders[order_id])
```

```dax
Average Delivery Time = 
AVERAGEX(
    FILTER(
        orders,
        NOT ISBLANK(orders[order_delivered_customer_date]) &&
        NOT ISBLANK(orders[order_purchase_timestamp])
    ),
    DATEDIFF(
        orders[order_purchase_timestamp],
        orders[order_delivered_customer_date],
        DAY
    )
)
```

```dax
Cancellation Rate = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(orders[order_id]),
        orders[order_status] = "canceled"
    ),
    [Total Orders],
    0
)
```

```dax
Total Late Deliveries = 
SUM(orders[Is Late Delivery])
```

```dax
Late Delivery % = 
DIVIDE([Total Late Deliveries], [Total Orders], 0)
```

---

## Table: `order_items`

### Calculated Columns

```dax
Total Item Cost = 
order_items[price] + order_items[freight_value]
```

```dax
Freight Ratio = 
DIVIDE(
    order_items[freight_value],
    order_items[Total Item Cost],
    0
)
```
> Depends on `Total Item Cost` — create that column first.

### Measures

```dax
Total Revenue = 
SUM(order_items[price])
```

```dax
Average Order Value = 
AVERAGEX(
    VALUES(order_items[order_id]),
    CALCULATE(SUM(order_items[price]))
)
```

---

## Table: `order_payments`

### Calculated Columns

```dax
Payment Method Group = 
SWITCH(
    order_payments[payment_type],
    "credit_card", "Card",
    "debit_card", "Card",
    "boleto", "Bank Slip",
    "voucher", "Voucher",
    "Other"
)
```

```dax
Installments Bucket = 
SWITCH(
    TRUE(),
    order_payments[payment_installments] = 1, "1 (Full Payment)",
    order_payments[payment_installments] <= 3, "2-3",
    order_payments[payment_installments] <= 6, "4-6",
    order_payments[payment_installments] <= 12, "7-12",
    "13+"
)
```

---

## Table: `order_reviews`

### Calculated Columns

```dax
Review Sentiment = 
SWITCH(
    TRUE(),
    order_reviews[review_score] >= 4, "Positive",
    order_reviews[review_score] = 3, "Neutral",
    order_reviews[review_score] <= 2, "Negative",
    "Unknown"
)
```

---

## Table: `customers`

### Calculated Columns

```dax
Region = 
SWITCH(
    customers[customer_state],
    "SP", "Southeast", "RJ", "Southeast", "MG", "Southeast", "ES", "Southeast",
    "PR", "South", "SC", "South", "RS", "South",
    "BA", "Northeast", "PE", "Northeast", "CE", "Northeast", "MA", "Northeast",
    "PB", "Northeast", "RN", "Northeast", "AL", "Northeast", "SE", "Northeast", "PI", "Northeast",
    "GO", "Central-West", "MT", "Central-West", "MS", "Central-West", "DF", "Central-West",
    "AM", "North", "PA", "North", "RO", "North", "AC", "North", "AP", "North", "RR", "North", "TO", "North",
    "Other"
)
```

---

## Table: `products`

### Calculated Columns

```dax
Product Size Category = 
SWITCH(
    TRUE(),
    products[product_weight_g] <= 500, "Light",
    products[product_weight_g] <= 2000, "Medium",
    products[product_weight_g] <= 10000, "Heavy",
    "Very Heavy"
)
```

```dax
Category Display = 
IF(
    ISBLANK(products[product_category_name]),
    "Uncategorized",
    SUBSTITUTE(products[product_category_name], "_", " ")
)
```

---

## Inventory Checklist

| Table | Columns | Measures |
|---|---|---|
| `orders` | Delivery Time (Days), Delivery Delay (Days), Delivery Status, Approval Time (Hours), Is Late Delivery, Order Month, Order Day of Week, Day Number | Total Orders, Average Delivery Time, Cancellation Rate, Total Late Deliveries, Late Delivery % |
| `order_items` | Total Item Cost, Freight Ratio | Total Revenue, Average Order Value |
| `order_payments` | Payment Method Group, Installments Bucket | — |
| `order_reviews` | Review Sentiment | — |
| `customers` | Region | — |
| `products` | Product Size Category, Category Display | — |

---

## Suggested Chart Pairings

| # | Chart | Axis / Legend | Values |
|---|---|---|---|
| 1 | Line | `orders[Order Month]` | `Total Revenue` (order_items) |
| 2 | Clustered Column | `orders[Order Day of Week]` (sort by `Day Number`) | `Total Orders` (orders) |
| 3 | Donut | `orders[Delivery Status]` | `Total Orders` (orders) |
| 4 | Card | — | `Total Late Deliveries`, `Late Delivery %` (orders) |
| 5 | Pie | `order_payments[Payment Method Group]` | `Total Revenue` / `Total Orders` |
| 6 | Clustered Column | `order_payments[Installments Bucket]` | `Total Orders` (orders) |
| 7 | Bar (map alternative) | `customers[Region]` or `customers[customer_state]` | `Total Revenue` (order_items) |
| 8 | Column | `products[Product Size Category]` | `Total Orders` (orders) |
| 9 | Bar, Top N = 10 | `products[Category Display]` | `Total Revenue` (order_items) |
| 10 | Stacked Bar | `orders[Order Month]` + `order_reviews[Review Sentiment]` | `Total Orders` (orders) |
| 11 | Cards row | — | `Total Revenue`, `Average Order Value`, `Average Delivery Time`, `Cancellation Rate` |

**Note on chart #7:** Power BI's built-in Map/Filled Map visuals can be blocked by tenant/organization policy (`MapVisualNotEnabled` error) on work/school accounts. The bar chart version using `customer_state` or `Region` avoids this dependency entirely and is the safer, portfolio-ready choice.
