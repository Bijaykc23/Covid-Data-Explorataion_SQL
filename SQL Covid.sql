/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types, Select,
From, Where, Group BY
*/
-- Have used PostgreSQL 15 server and pgAdmin 4

Select * 
from coviddeath
where continent is not null
order by 3,4


--Select Data that we are going to be using
Select location,date,total_cases,new_cases,total_deaths,population
from coviddeath
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
--shows the likelihood of dying if you are in contact with Covid in your country
Select location,date,total_cases,total_deaths,Round((total_deaths::decimal/total_cases::decimal)*100,2) as DeathPercentage
from coviddeath
where location like '%States%' and continent is not null 
order by 1,2

--Loking at Total case vs Population
--shows what percentage of population got Covid
Select location,date,Population,total_cases,Round((total_cases::decimal/population::decimal)*100,2) as Percentpopulationinfected
from coviddeath
where location like '%States%' and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population
Select location, Population, Max(total_cases)as HighestInfectionCount,
Max((total_cases::decimal/population::decimal))*100 as Percentpopulationinfected
from coviddeath
where population is not null and total_cases is not null and continent is not null
group by location, Population
order by Percentpopulationinfected desc

--showing continents with highest death count per population
Select location, max(total_deaths) as TotalDeathCount
from coviddeath
where continent is  null 
group by location
order by TotalDeathCount desc

--showing countries with highest death count per population
Select location, max(total_deaths) as TotalDeathCount
from coviddeath
where total_deaths is not null and continent is not null 
group by location
order by TotalDeathCount desc

--Showing the continents with the highest death count per population
Select continent, max(total_deaths) as TotalDeathCount
from coviddeath
where continent is not null 
group by continent
order by TotalDeathCount desc


--Global number
Select date,sum(new_cases)as total_cases,sum(new_deaths)as total_deaths,sum(new_deaths::decimal)/sum(new_cases::decimal)*100 as death_Percent
from coviddeath
where continent is not null and new_cases is not null
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(new_vaccinations) Over(partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
from coviddeath dea
Join covidvaccin vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
with popvVac (Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(new_vaccinations) Over(partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeath dea
Join covidvaccin vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
Select*,(RollingPeopleVaccinated::decimal/population::decimal)*100
from popvvac


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS PercentpopulationVaccinated;
CREATE TEMP TABLE IF NOT EXISTS PercentpopulationVaccinated (
    Continent TEXT,
    Location TEXT,
    Date DATE,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeoplevaccinated NUMERIC
);

-- Insert values into temp table
INSERT INTO PercentpopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeoplevaccinated
FROM coviddeath dea
JOIN covidvaccin vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Select from temp table and calculate percent vaccinated
SELECT *, (RollingPeoplevaccinated::DECIMAL / Population::DECIMAL) * 100 AS PercentPopulationVaccinated
FROM PercentpopulationVaccinated;


--Creating view to store data for later visualizations
Create View PercentpopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeoplevaccinated
FROM coviddeath dea
JOIN covidvaccin vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--Creating view to store data for later visualizations
Create View DeathPercentage as
Select location,date,total_cases,total_deaths,Round((total_deaths::decimal/total_cases::decimal)*100,2) as DeathPercentage
from coviddeath
where location like '%States%' and continent is not null 
order by 1,2

--Creating view to store data for later visualizations
Create View DeathCountContinent as
Select location,date,total_cases,total_deaths,Round((total_deaths::decimal/total_cases::decimal)*100,2) as DeathPercentage
from coviddeath
where location like '%States%' and continent is not null 
order by 1,2


--Creating view to store data for later visualizations
Create View DeathCountContry as
Select location, max(total_deaths) as TotalDeathCount
from coviddeath
where total_deaths is not null and continent is not null 
group by location
order by TotalDeathCount desc
