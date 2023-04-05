# Covid-Data-Explorataion_SQL

This code provides a series of SQL queries for exploring COVID-19 data. The code uses PostgreSQL 15 server and pgAdmin 4. The SQL queries use a variety of SQL skills such as joins, common table expressions (CTEs), temporary tables, window functions, aggregate functions, creating views, converting data types, select, from, where, and group by clauses.

The SQL queries retrieve data from two tables named coviddeath and covidvaccin that contain data related to COVID-19 cases, deaths, and vaccinations by country, date, and continent.

The SQL queries retrieve data related to total cases vs. total deaths, total cases vs. population, countries with the highest infection rate compared to population, continents with the highest death count per population, countries with the highest death count per population, and continents with the highest death count per population.

The SQL queries also calculate and show the percentage of the population that has received at least one COVID-19 vaccine by country, date, and continent. The SQL queries use a CTE and a temporary table to perform calculations on the partition. Finally, the code creates a view to store data for later visualizations.
