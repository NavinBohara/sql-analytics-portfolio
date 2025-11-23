

# Orders Performance Analysis – SQL Project

## 📦 Project Overview

This project focuses on analyzing order performance using structured SQL queries.
The dataset contains detailed information about orders including pricing, quantity, discounts, shipping modes, regions, product categories, and customer segments.

The objective is to extract meaningful business insights related to revenue, profit, customer behaviour, product performance, and regional trends.

This project demonstrates practical SQL skills used in real-world data analytics roles.

---

## 📸 Orders Performance Analysis


![Orders Dashboard](thumbmail.jpg)

---

## 📊 Dataset Description

The dataset includes the following key fields:

* Order Id
* Order Date
* Ship Mode
* Segment
* Country, State, City, Region
* Category & Sub Category
* Product Id
* Cost Price
* List Price
* Quantity
* Discount Percent

From these, additional metrics like revenue, total cost, and profit were derived using SQL.

---

## 🎯 Objectives

* Clean and standardize order data
* Calculate revenue, cost, and profit per order
* Measure impact of discounts
* Analyze category and region performance
* Identify top products and cities by revenue
* Track time-based revenue trends
* Perform advanced analytics using window functions

---

## 🧠 SQL Tasks Performed

### Basic Exploration

* Display all orders and unique cities
* Filter orders by ship mode, segment, category, year, and region
* Count total number of records

### Revenue & Profit Calculation

* Calculated total sales per order
* Calculated total cost using cost price
* Derived profit per order
* Computed discount amount per order

### Business Analysis

* Total revenue with and without discounts
* Orders grouped by category and ship mode
* Highest and lowest list prices
* Top 10 products by revenue
* Top 5 cities by revenue

### Time-Based Analysis

* Monthly revenue trend
* Running total revenue over time

### Advanced Analytics

* Orders with quantity greater than category average
* Median list price per category
* Product segmentation based on total revenue

  * High Value
  * Medium Value
  * Low Value

---

## 📈 Key Insights

* Certain product categories consistently generate higher revenue
* Discounts significantly affect profit margins
* A few cities contribute most to overall revenue
* Technology products show strong performance
* Revenue trends vary month-to-month
* Some products fall into loss zones due to heavy discounting

---

## 🗂 Project Structure

```
03-orders-performance-analysis/
|
|-- orders_data.csv
|-- orders_analysis.sql
└-- README.md
```

## 🛠 Tools Used

* MySQL
* SQL Window Functions
* Aggregate Queries
* Excel for data inspection
* GitHub for version control

---

## ✅ Outcome

This project showcases the use of SQL for end-to-end data analysis including cleaning, transformation, aggregation, and insight extraction. It highlights the ability to convert raw transactional data into actionable business metrics.

---

## 👤 Credit

Project created and maintained by:

**Navin Bohara**
SQL Analytics Portfolio
GitHub: [https://github.com/NavinBohara](https://github.com/NavinBohara)




