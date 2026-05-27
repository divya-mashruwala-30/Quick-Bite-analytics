# QuickBite Express Crisis Recovery Analytics

## Project Overview

QuickBite Express is a Bengaluru-based online food delivery startup that faced a major crisis in June 2025. The crisis was triggered by a viral food-safety incident involving partner restaurants and a week-long delivery outage during the monsoon season. This led to customer backlash, reduced daily orders, falling customer satisfaction, restaurant partner risk, and higher recovery pressure for the business.

This project analyses QuickBite's order, delivery, customer, restaurant, and sentiment data to support a crisis recovery strategy. The work includes SQL-based ad-hoc analysis, data cleaning and preprocessing, feature engineering, star-schema data modelling, and a three-page Power BI dashboard for business stakeholders.

The goal is to help management answer three key questions:

1. What was the business impact of the crisis?
2. Which operational issues made the crisis worse?
3. Which customers and campaigns should QuickBite prioritise for recovery?

---

## Business Problem

QuickBite's management needed detailed insights across six recovery areas:

- **Customer Segments:** Identify recoverable customers and customers needing new strategies.
- **Order Patterns:** Compare order behaviour across pre-crisis and crisis phases.
- **Delivery Performance:** Assess delivery delays, cancellations, and SLA compliance.
- **Campaign Opportunities:** Recommend targeted trust and loyalty recovery initiatives.
- **Restaurant Partnerships:** Identify restaurant and delivery partner performance issues.
- **Feedback & Sentiment:** Monitor ratings, reviews, and sentiment to guide recovery.

---

## Project Files

| File | Description |
|---|---|
| `RPC_18_Problem_Statement.pdf` | Business case, stakeholder expectations, and challenge brief. |
| `quick-bite_analytics_report.docx` | SQL ad-hoc analysis report with 15 business questions and result tables. |
| `quickbite_BI_view.pbix` | Power BI dashboard with three report pages. |
| `README_QuickBite_Crisis_Recovery.md` | Project documentation and explanation. |

---

## Tools and Technologies

- **PostgreSQL / pgAdmin:** SQL analysis and ad-hoc business queries.
- **Power BI:** Dashboard design, data modelling, DAX measures, and stakeholder reporting.
- **DAX:** Feature engineering, calculated columns, customer segmentation, and KPI measures.
- **Star Schema Modelling:** Fact and dimension tables connected for efficient reporting.

---

## Dataset and Data Model

The project uses a food-delivery analytics data model with fact and dimension tables.

### Main Fact Tables

| Table | Purpose |
|---|---|
| `fact_orders` | Order-level data including customer, restaurant, delivery partner, revenue, month, and cancellation status. |
| `fact_delivery_performance` | Delivery SLA data including actual delivery time, expected delivery time, and delivery distance. |
| `fact_ratings` | Customer ratings, review text, review timestamp, and sentiment score. |
| `fact_order_items` | Item-level order details including quantity, unit price, item discount, and line total. |

### Main Dimension Tables

| Table | Purpose |
|---|---|
| `dim_customer` | Customer location, signup details, and acquisition channel. |
| `dim_restaurant` | Restaurant name, city, cuisine type, partner type, prep time, and active status. |
| `dim_delivery_partner` / `dim_delivery_partner_clean` | Delivery partner details, vehicle type, employment type, rating, and active status. |
| `dim_menu_item` | Menu item name, category, vegetarian flag, and price. |

### Data Model Approach

A star-schema style model was used, with fact tables connected to relevant dimension tables. `fact_orders` acts as the central transactional table for most analysis, connected to customer, restaurant, delivery partner, ratings, and delivery performance data.

Key relationship examples:

```text
fact_orders[customer_id]           → dim_customer[customer_id]
fact_orders[restaurant_id]         → dim_restaurant[restaurant_id]
fact_orders[delivery_partner_id]   → dim_delivery_partner_clean[delivery_partner_id]
fact_orders[order_id]              → fact_delivery_performance[order_id]
fact_orders[order_id]              → fact_ratings[order_id]
fact_orders[order_id]              → fact_order_items[order_id]
fact_order_items[menu_item_id]     → dim_menu_item[menu_item_id]
```

A missing delivery-partner issue was identified during modelling: several order rows had blank `delivery_partner_id` values. These were handled by assigning an `Unknown Partner` category instead of deleting valid order records.

---

## Analysis Periods

The project compares two major phases:

| Phase | Months |
|---|---|
| Pre-Crisis | January to May 2025 |
| Crisis | June to September 2025 |

Feature engineering was performed to create phase-level fields such as `Crisis Phase`, `Month Name`, `Delivery Delay Mins`, `Delay Bucket`, and `Sentiment Bucket`.

---

## SQL Ad-Hoc Analysis

The SQL report answers 15 business questions. These questions cover demand, revenue, cancellation, delivery, customer recovery, restaurant performance, and sentiment.

### 1. Monthly Orders: Pre-Crisis vs Crisis

Pre-crisis orders were **113,806**, contributing **76.29%** of total orders. Crisis-period orders dropped to **35,360**, contributing only **23.71%**.

**Insight:** The crisis created a major demand shock and customer disengagement after June 2025.

### 2. Top 5 Cities by Order Decline

The highest percentage order declines were concentrated in:

| City | Percentage Drop |
|---|---:|
| Chennai | 69.98% |
| Kolkata | 69.19% |
| Bengaluru | 69.17% |
| Hyderabad | 68.92% |
| Ahmedabad | 68.83% |

**Insight:** Recovery campaigns should be prioritised city-wise, especially in cities with the sharpest demand decline.

### 3. Top 10 High-Volume Restaurants by Decline

Restaurants with at least 50 pre-crisis orders were analysed. Several high-volume restaurants experienced order declines above 80%, with Royal Curry Mahal showing a 94% decline.

**Insight:** Previously valuable restaurant partners require retention support, visibility recovery, and operational review.

### 4. Cancellation Rate Trend

Cancellation rates increased sharply during the crisis. Ahmedabad showed the highest cancellation-rate increase at **6.95 percentage points**, followed by Mumbai, Chennai, Kolkata, and Hyderabad.

**Insight:** Cancellation pressure worsened in major markets, indicating operational and trust-related failure points.

### 5. Average Delivery Delay

Average delivery delay increased from approximately **2.02 minutes** pre-crisis to **17.60 minutes** during the crisis.

**Insight:** Delivery reliability deteriorated significantly during the crisis period.

### 6. SLA Compliance Rate

SLA compliance dropped from **43.60%** pre-crisis to **12.20%** during the crisis.

**Insight:** QuickBite failed to meet promised delivery times during the crisis, which likely contributed to cancellations and trust loss.

### 7. Average Customer Rating by Month

Ratings were above 4 before the crisis but dropped sharply after June. September had the lowest rating at **3.07**.

**Insight:** Customer satisfaction and trust weakened after the crisis began.

### 8. Revenue Loss Estimate

Revenue declined from **37.62 million** pre-crisis to **10.94 million** during the crisis.

**Insight:** The crisis caused a major financial impact due to lower order volume and customer disengagement.

### 9. Loyal Customer Churn and High-Rating Churn

There were **58 loyal pre-crisis customers**, **49 churned loyal customers**, and **26 high-rating churned customers**.

**Insight:** Some customers who were previously loyal and satisfied stopped ordering during the crisis, making them strong trust-repair candidates.

### 10. Top 5% Customers by Pre-Crisis Spend

The top 5% of customers were identified using pre-crisis spending. These customers represent QuickBite's highest-value recovery segment.

**Insight:** High spenders should be targeted separately from general churned users.

### 11. High-Value Customer Order-Frequency Drop

Out of **4,342** high-value customers, **3,648** placed zero orders during the crisis.

**Insight:** Around 84% of high-value customers stopped ordering, creating a major revenue recovery opportunity.

### 12. Delivery Delay vs Cancellation Rate

Cancellation rates increased as delivery delay increased:

| Delay Bucket | Cancellation Rate |
|---|---:|
| On-time | 6.47% |
| Delay 0–10 min | 6.91% |
| Delay 10–20 min | 8.21% |
| Delay 20+ min | 11.07% |

**Insight:** Longer delays are directly associated with higher cancellation risk.

### 13. Severe 20+ Minute Delay Contributors

Bengaluru contributed the largest share of 20+ minute delays, with **4,101 severe-delay orders** and **24.78%** of all 20+ minute delays.

**Insight:** Severe SLA breaches are concentrated in specific cities, partners, and restaurants.

### 14. Worst Delivery and Cancellation Cities During Crisis

Ahmedabad had the highest cancellation rate during the crisis at **13.03%**, with average delivery time around **60.22 minutes**.

**Insight:** Some cities need urgent operational recovery before marketing recovery can succeed.

### 15. Sentiment Bucket Analysis

Review sentiment was distributed as follows:

| Sentiment Bucket | Reviews | Share |
|---|---:|---:|
| Very Positive | 35,888 | 52% |
| Negative | 16,409 | 24% |
| Positive | 13,810 | 20% |
| Neutral | 2,735 | 4% |

**Insight:** Customer trust is damaged but not fully lost because positive and very positive reviews still represent a meaningful share.

---

## Power BI Dashboard

The Power BI report contains three pages:

1. **Crisis Impact Overview**
2. **Operations & SLA Recovery**
3. **Customer Recovery & Campaign Strategy**

The dashboard follows a business storytelling flow:

```text
Impact → Operational Cause → Recovery Action
```

---

## Dashboard Page 1: Crisis Impact Overview

### Purpose

This page explains the overall business impact of the crisis.

### Key Visuals

- KPI cards for orders, revenue, cancellation rate, average rating, and SLA compliance.
- Orders by crisis phase.
- Monthly order trend.
- Revenue by crisis phase.
- Average rating by month.
- Top cities by order decline.

### Main Message

Orders, revenue, and customer ratings declined after June 2025. Recovery should begin in cities where order drop and trust loss were most severe.

---

## Dashboard Page 2: Operations & SLA Recovery

### Purpose

This page explains the operational drivers behind the crisis impact.

### Key Visuals

- KPI cards for average delivery delay, SLA compliance, cancellation rate, 20+ minute delay orders, and 20+ minute delay share.
- SLA compliance by crisis phase.
- Cancellation rate by delay bucket.
- Top cities by severe delays.
- Top delivery partners by severe delays.
- Restaurant delay overview table.

### Main Message

Operational failure played a major role in the crisis. Severe delivery delays and weak SLA compliance increased cancellation risk, especially in specific cities, delivery partners, and restaurant groups.

---

## Dashboard Page 3: Customer Recovery & Campaign Strategy

### Purpose

This page turns the analysis into customer recovery actions.

### Key KPI Cards

| KPI | Value | Meaning |
|---|---:|---|
| Loyal Pre-Crisis Customers | 58 | Customers with 5+ pre-crisis orders. |
| Churned Loyal Customers | 49 | Loyal customers with zero crisis orders. |
| High-Rating Churned Customers | 26 | Churned loyal customers with average rating above 4.5. |
| Top 5% High-Value Customers | 4,342 | Customers in the top 5% by pre-crisis spend. |
| High-Value Customers Lost | 3,648 | Top-spending customers with zero crisis orders. |

### Key Visuals

- Loyal Customer Recovery Funnel.
- High-Value Customer Drop-Off donut chart.
- Customer Sentiment Distribution donut chart.
- Priority Customer Recovery List.
- Campaign Opportunity by Action Type.

### Campaign Logic

Campaign actions are assigned using rule-based segmentation:

| Campaign Action | Rule | Recommended Action |
|---|---|---|
| Priority Win-Back | Top 5% pre-crisis spend and zero crisis orders. | Personalised voucher, free delivery, apology, and trust assurance. |
| Trust Repair Campaign | Loyal pre-crisis customer, zero crisis orders, and average rating above 4.5. | Food-safety communication, apology, and confidence-building message. |
| Loyalty Booster | Loyal customer whose crisis orders are lower than pre-crisis orders. | Loyalty points, streak rewards, or personalised offers. |
| Service Recovery Survey | Average rating below 3. | Feedback survey, complaint resolution, and targeted service recovery. |

### Main Message

QuickBite should not target all churned customers equally. The strongest recovery opportunity lies in high-value customers, loyal churned customers, and previously satisfied customers who stopped ordering during the crisis.

---

## Key DAX Features

The Power BI report uses DAX for calculated columns, measures, and segmentation.

### Important Calculated Columns

| Column | Purpose |
|---|---|
| `Crisis Phase` | Classifies months into Pre-Crisis and Crisis. |
| `Month Name` | Converts month numbers into readable month labels. |
| `Delivery Delay Mins` | Calculates actual delivery time minus expected delivery time. |
| `Delay Bucket` | Groups delivery delay into On-time, 0–10, 10–20, and 20+ minute buckets. |
| `Sentiment Bucket` | Converts sentiment scores into Negative, Neutral, Positive, and Very Positive. |

### Important Measures

| Measure | Purpose |
|---|---|
| `Total Orders` | Counts unique orders. |
| `Total Revenue` | Sums revenue using order amount. |
| `Cancellation Rate` | Calculates cancelled orders as a share of total orders. |
| `SLA Compliance Rate` | Measures share of orders delivered within expected time. |
| `20+ Min Delay Orders` | Counts severe delivery delay orders. |
| `Top 5% High-Value Customers` | Identifies high-spend customers using the 95th percentile. |
| `High-Value Customers Lost` | Counts high-value customers with zero crisis orders. |
| `Recovery Target Customers` | Counts unique customers by campaign action. |

---

## Key Business Insights

1. **Demand dropped sharply after the crisis.**  Pre-crisis orders contributed more than three-fourths of total orders, while crisis-period orders fell to less than one-fourth.

2. **Revenue loss was significant.** Revenue fell from 37.62 million pre-crisis to 10.94 million during the crisis.

3. **Delivery operations worsened.** Average delivery delay increased to 17.60 minutes during the crisis, and SLA compliance dropped to 12.20%.

4. **Longer delays increased cancellations.** Orders delayed by more than 20 minutes had the highest cancellation rate.

5. **High-value customers are the main recovery opportunity.** Out of 4,342 top-spending customers, 3,648 stopped ordering during the crisis.

6. **Customer trust is damaged but recoverable.** Negative sentiment exists, but very positive and positive review shares show that QuickBite still has a recoverable customer base.

---

## Recommendations

### 1. Prioritise High-Value Win-Back

Focus on high-value customers who placed zero orders during the crisis. Use personalised offers, apology messaging, free delivery, and trust-assurance communication.

### 2. Repair Trust for Previously Satisfied Customers

Target loyal churned customers with high historical ratings. These customers were satisfied before the crisis and are more likely to return if trust concerns are addressed.

### 3. Fix Severe Delivery Delay Markets

Prioritise cities and partners with high 20+ minute delay contribution. Improve delivery partner capacity, routing, SLA monitoring, and restaurant handoff processes.

### 4. Use Sentiment for Ongoing Recovery Monitoring

Track negative sentiment and ratings continuously to identify whether recovery initiatives are working.

### 5. Strengthen Restaurant and Delivery Partner Governance

Review restaurants and delivery partners associated with severe delays. Combine food-safety verification with operational performance monitoring.

---

## How to Use the Dashboard

1. Open `quickbite_BI_view.pbix` in Power BI Desktop.
2. Review the pages in order:
   - **Crisis Impact Overview** to understand business damage.
   - **Operations & SLA Recovery** to identify operational causes.
   - **Customer Recovery & Campaign Strategy** to decide recovery actions.
3. Use slicers such as campaign action and acquisition channel for targeted exploration.
4. Use the Priority Customer Recovery List to identify customers for campaign execution.

---

## Project Outcome

This project delivers a complete crisis recovery analytics solution for QuickBite Express. It combines SQL-based business investigation with a Power BI dashboard that communicates clear insights to leadership. The analysis shows that QuickBite's recovery should focus on high-value customer win-back, trust repair, SLA improvement, and targeted city-level operational fixes.

---

## Author Notes

This project was built as a business analytics case study using SQL and Power BI. It demonstrates data cleaning, preprocessing, feature engineering, star-schema modelling, dashboard design, customer segmentation, and business recommendation development.
