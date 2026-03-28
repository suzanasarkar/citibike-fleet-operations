# 🚲 NYC Citi Bike Fleet Operations — Operational Risk Mitigation Analysis

**Solo Project | Business Analytics | MSBA, University of Washington Tacoma**

An end-to-end data analytics system that transforms Citi Bike's Fleet Operations from reactive complaint response to proactive, data-driven resource deployment.

---

## 📌 Project Overview

Citi Bike's Fleet Operations Management oversees the largest bike-share network in North America — thousands of bikes across hundreds of NYC docking stations. The core problem: operations ran reactively. Rebalancing trucks responded to complaints *after* shortages occurred. Maintenance crews defaulted to the busiest Manhattan stations while problems clustered elsewhere.

This project builds the full analytical infrastructure to fix that:

- **Azure SQL database** storing 99,930 October 2025 trip records
- **Microsoft Forms + PowerApps** integration for real-time field incident reporting
- **Tableau Asset Utilization Dashboard** — 30-second operational health check
- **Tableau Operational Risk Storyboard** — 7-page progressive investigation
- **Station Risk Index** — composite KPI combining fleet imbalance, peak volume stress, and maintenance issues to rank stations by intervention priority

---

## 🗂️ Repository Structure

```
citibike-fleet-operations/
│
├── README.md
│
├── sql/
│   └── SQLQuery_5.sql          # Schema creation, data cleaning, dimension tables, seed data
│
├── docs/
│   ├── technical-report.docx   # Full system documentation: ER diagram, schema, use cases, access guide
│   └── analysis-report.docx    # Individual analytical write-up: findings, KPIs, recommendations, limitations
│
├── tableau/
│   └── CitiBike_Dashboard.twbx # Packaged Tableau workbook (dashboard + storyboard)
│
└── demo/
    └── walkthrough.mp4         # Full product walkthrough video
```

---

## 🛠️ Tech Stack

| Layer | Tool |
|---|---|
| Database | Azure SQL (cloud-hosted) |
| Data Ingestion | Microsoft Forms → Power Automate → Excel → Azure SQL |
| Visualization | Tableau Public |
| Schema Design | Star schema (fact + dimension tables) |
| Language | T-SQL |

---

## 🗄️ Database Design

**Fact Table**
- `CitiBikeRides` — raw trip records (99,930 rows, October 2025)
- `CitiBikeRides_clean` — cleaned version filtering nulls and zero/negative duration trips

**Dimension Tables**
- `dim_station` — unique stations with coordinates (derived from start + end station union)
- `DateDim` — date dimension with weekday, weekend, holiday flags

**Operational Table**
- `StationForm` — real-time incident reports (issue type, description, status, reporter)
  - Issue types: Docking Issue, Bike Availability, Maintenance Needed, Payment/Kiosk Issue, Signage, Other
  - Statuses: Open, In Progress, Resolved

---

## 📊 Tableau Dashboards

**Live links (Tableau Public):**
- [Asset Utilization Dashboard](https://public.tableau.com/views/NYCCitibikeFleetOperationsAnOperationalRiskMitigationAnalysis/AssetUtilizationDashboard)
- [Fleet Rebalancing Storyboard](https://public.tableau.com/views/NYCCitibikeFleetOperationsAnOperationalRiskMitigationAnalysis/CitiBikeFleetRebalancingAStoryboardforOperationalRiskMitigation)

### Asset Utilization Dashboard
Single-screen operational command center. Key metrics at a glance:
- **99,930** total trips | **84** net displaced bikes | **70%** e-bike utilization
- **42%** of all trips occur in just 4 peak hours (7–9 AM, 5–7 PM)
- Geographic heatmaps, top start/end station bar charts, hourly demand profile
- Station Bike Dominance Map (electric vs. classic preference by location)

### Operational Risk Storyboard (7 pages)
Progressive investigation designed for root-cause analysis:

| Page | Focus |
|---|---|
| 1 | Demand Concentration — highest-volume nodes |
| 2 | Net Bike Flow — fleet imbalance (diverging bar + hotspots map) |
| 3 | Asset Allocation — e-bike vs. classic utilization patterns |
| 4 | Peak Hour Demand — temporal surge patterns |
| 5 | Peak Hour Rebalancing — directional flow maps (7–9 AM and 4–6 PM) |
| 6 | Customer Friction — maintenance issue clustering |
| 7 | Converging Risks — Station Risk Index rankings |

---

## 🔑 Key Findings

1. **Fleet imbalance is localized, not systemic** — 84 net displaced bikes (<0.1% of rides), but Financial District stations face chronic morning shortages
2. **42% of operational stress compresses into 4 hours daily** — requires time-specific rebalancing schedules
3. **Electric bikes dominate at 70% utilization** — yet popular routes still require classic bike supply
4. **Maintenance problems cluster outside Manhattan's busiest zones** — reactive crew deployment misses true hotspots
5. **Station Risk Index** identifies Clinton St & Grand St and Hanson Pl & Ashland Pl as highest-priority intervention locations (scores 14–15)

---

## ⚠️ Limitations

- Single-month scope (October 2025) — seasonal variation not captured
- Risk Index weights are analyst-defined — should be calibrated with operations team
- Maintenance data relies on voluntary user reports — likely undercounts actual issues
- Financial impact (lost revenue, truck operating costs) not quantifiable from available data

---

## 🔭 Next Steps

- Expand to multi-month historical data for seasonal modeling
- Build automated alerting when Station Risk Index exceeds threshold
- Deploy mobile-optimized dashboard for field crews
- Develop predictive demand models using historical patterns

---

*Suzana Sarkar | MSBA, Milgard School of Business, University of Washington Tacoma*
