#  Retail sales data -----> Data cleaning


import pandas as pd #type:ignore
df = pd.read_csv("retail_sales_synthetic.csv")
print(df)
print(df.head())
print(df.shape)
print(df.info())
print(df.describe())

# find missing values 
print(df.isnull().sum())

print(df.duplicated().sum())
df = df.drop_duplicates()
print(df.duplicated().sum())

# Handling null values 
df["sales_amount"] = df["sales_amount"].fillna(df["sales_amount"].median())
df = df.dropna(subset=["customer_id"])
print(df.isnull().sum())

print(df.dtypes)
df["date"] = pd.to_datetime(df["date"])
print(df.dtypes)

df["customer_id"] = df["customer_id"].astype("str")
print(df.dtypes)

print(df.head())
df["months"] = df["date"].dt.month_name()
print(df['months'])

df["year"] = df["date"].dt.year
print(df['year'])


month_order = ["January","February", "March", "April", "May", "June", 
                            "July", "August", "September", "October", "November", "December"]

df["months"] = pd.Categorical(df["months"], categories=month_order, ordered=True)

# monthly sales aggregate 
monthly_sales = df.groupby("months")["sales_amount"].sum().reset_index()
print(monthly_sales)

# which category generates the most revenue
category_sales = df.groupby("category")["sales_amount"].sum().reset_index()
print(category_sales)

# Electronics generates the most revenue 


# How much did each product category generate in each month?
sales_pivot = pd.pivot_table(
    df,
    values="sales_amount",
    index="months",
    columns="category",
    aggfunc="sum",
    fill_value=0,
    margins=True,
    margins_name="Total")

print(sales_pivot)

# Visualization 
# Monthly sales trend 
import matplotlib.pyplot as plt #type:ignore


# plt.title("Monthly Sales Trend")
# plt.xlabel("Month")
# plt.ylabel("Sales Amount")
# plt.show()

# product performance 

product_sales = (
    df.groupby
    (["product_id", "product_name"])
    ["sales_amount"]
    .sum()
    .sort_values(ascending=False)
)

print(product_sales)

# calculate quantity 
print(df.columns)
product_qty = df.groupby(["product_id","product_name"])["quantity_sold"].sum().sort_values(ascending=False)
print(product_qty)

print(pd.merge(
    product_sales,
    product_qty,
    on= "product_name",
    how= "left"
))

# revenue leaders is office chair 
# unit volume leaders is waterbottles 

# customer analysis 

# •	total spending 
# •	number of transactions 
# •	quantity purchased 
# calculating metrics at once


customer_summary = df.groupby(['customer_id']).agg(
    total_spend = ("sales_amount","sum"),
    total_orders = ("date","count"),
    total_quantity=("quantity_sold", "sum")
)

print(customer_summary)
print(customer_summary.describe)


spend_threshold = customer_summary["total_spend"].median()
order_threshold = customer_summary["total_orders"].median()

customer_summary["segment"] = "Low Value"

customer_summary.loc[
    (customer_summary["total_spend"] >= spend_threshold) &
    (customer_summary["total_orders"] >= order_threshold),
    "segment"
] = "High Value"

customer_summary.loc[
    (customer_summary["total_spend"] >= spend_threshold) &
    (customer_summary["total_orders"] < order_threshold),
    "segment"
] = "Big Spenders"

customer_summary.loc[
    (customer_summary["total_spend"] < spend_threshold) &
    (customer_summary["total_orders"] >= order_threshold),
    "segment"
] = "Frequent Buyers"

print(customer_summary)

# High Value	High spending + frequent purchases
# Big Spenders	High spending but fewer purchases
# Frequent Buyers	Frequent purchases but lower spending
# Low Value	Lower spending + fewer purchases

segment_counts = customer_summary["segment"].value_counts()

segment_counts.plot(kind="bar")

plt.title("Customer Segments")
plt.xlabel("Customer Segment")
plt.ylabel("Number of Customers")
plt.tight_layout()
plt.show()


# •	Increase inventory planning before peak months. 
# •	Build targeted campaigns for high-value customers. 
# •	Use cross-selling to increase spending among frequent buyers. 
# •	Review underperforming products for pricing or promotion opportunities. 

# Recommendation 1 — Focus on high-value customers
# Create loyalty campaigns for customers with high spending and frequent purchases.
# Recommendation 2 — Optimize inventory
# Use monthly/category trends to prepare inventory for periods of increased demand.
# Recommendation 3 — Improve low-value customer conversion
# Target frequent buyers with bundles or cross-selling offers.
# Recommendation 4 — Review product performance
# Investigate products with:
# •	low revenue 
# •	low quantity 
# •	declining demand 



