# Clark County Federal Spending Analysis

A Python data pipeline that pulls every federal contract performed in Clark County, Nevada during fiscal year 2025 from the [USAspending.gov](https://www.usaspending.gov) API, loads it into a PostgreSQL database, and analyzes it with SQL to answer a simple question: **where does federal contract money in Clark County actually go?**

## Key Findings

- **$22.2 billion** in federal contracts was spent in Clark County in FY2025, across **17,132 contracts** awarded to **1,141 companies**.
- **Spending is highly concentrated:** the top 10 companies (less than 1% of all recipients) received **87.2%** of all contract dollars.
- **Most of the money goes to national security.** The two largest contracts, about **$13.5 billion combined**, fund the management and operation of the Nevada National Security Site (formerly the Nevada Test Site). Other top contracts cover Nellis Air Force Base aircraft maintenance, military test range support, and federal detention services in Las Vegas.
- **The Department of Energy is the biggest spender** at **$14.4 billion**, followed by the Department of Defense at **$5.9 billion**.
- **The "average" contract is misleading.** The mean contract was **$1.3 million**, but the median was only **$26,935**. A handful of multi-billion-dollar contracts pull the average far above what a typical contract looks like.
- **One company dominates by volume:** Fleet Vehicle Source Inc. holds **13,166 contracts (77% of all contracts)** but received only about **$390 million (under 2% of the money)**, most likely individual vehicle purchases.

## Tools Used

- **Python**: the data pipeline
  - `requests` for calling the USAspending REST API (JSON over POST requests)
  - `psycopg` for connecting to PostgreSQL and loading data with parameterized queries
- **PostgreSQL**: storing and querying the data
- **pgAdmin 4**: database management and writing SQL
- **SQL**: aggregation (`GROUP BY`, `SUM`, `AVG`, `COUNT DISTINCT`), subqueries, percentiles (`PERCENTILE_CONT`), and formatting (`TO_CHAR`)
- **Git / GitHub**: version control, with credentials kept out of the repo through `.gitignore`
- **Fedora Linux, VS Code and Python virtual environments**: development setup

## How It Works

1. **Fetch:** `fetch_awards.py` sends POST requests to the USAspending `spending_by_award` endpoint, filtered to contracts (award types A–D) performed in Clark County, NV during FY2025 (October 1, 2024 – September 30, 2025).
2. **Paginate:** the API returns 100 results per page, so the script loops through pages until the API reports there are no more (`hasNext`).
3. **Load:** results are inserted into a PostgreSQL table with `executemany` and parameterized queries. `ON CONFLICT DO NOTHING` on the primary key makes the script safe to rerun without creating duplicates.
4. **Analyze:** `queries.sql` answers the questions behind the findings above.

## Data Challenge: The 10,000-Record Cap

The first full run loaded **exactly 10,000 rows**, and real data rarely lands on a perfectly round number. The smallest contract in the table was also $26,935, which suggested the smaller contracts had been cut off.

To investigate, I wrote `check_count.py`, which queries the API's `spending_by_award_count` endpoint with the same filters. It reported **17,132 contracts**, which confirmed that the search endpoint caps results at 10,000 and that **about 42% of the data was missing.**

**The fix:** I split the request into the four fiscal quarters, each under the cap (1,945 / 9,443 / 4,608 / 4,903), and wrapped the paging loop in an outer loop over the quarters. Some contracts appear in more than one quarter, and the primary key with `ON CONFLICT DO NOTHING` removes those overlaps automatically. The final table holds **17,132 unique contracts**, matching the API's count exactly.

The fix changed the results: Fleet Vehicle Source's contract count went from 8,321 to 13,166, and several companies with only small contracts appeared that had been invisible before.

## How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/pgansterpg-cloud/clark_county_spending.git
   cd clark_county_spending
   ```
2. Create and activate a virtual environment, then install dependencies:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
3. Copy `config.example.py` to `config.py` and fill in your PostgreSQL connection details.
4. Create a PostgreSQL database, then run `schema.sql` to create the `contracts` table.
5. Run the pipeline:
   ```bash
   python fetch_awards.py
   ```
6. Run the queries in `queries.sql` to reproduce the analysis.

## Project Files

| File | Purpose |
|---|---|
| `fetch_awards.py` | Fetches FY2025 contracts by quarter from the USAspending API and loads them into PostgreSQL |
| `check_count.py` | Checks the true number of matching contracts, used to verify the data is complete |
| `schema.sql` | Creates the `contracts` table |
| `queries.sql` | Analysis queries behind the key findings |
| `config.example.py` | Template for database connection settings (the real `config.py` is excluded from Git) |
| `requirements.txt` | Python dependencies |

## Notes and Limitations

- Results reflect contracts whose **place of performance** is Clark County, not where the contractor is headquartered.
- Award amounts are the totals reported by USAspending for each contract. Contracts that were active in FY2025 can include money obligated in earlier years.
- Figures reflect the data available from USAspending at the time it was collected.

## Possible Next Steps

- Add more fiscal years to compare spending trends over time
- Break spending down by industry (NAICS codes) or by month
- Build a dashboard to visualize the findings
