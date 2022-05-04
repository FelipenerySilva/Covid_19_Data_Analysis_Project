/*
Portfolio Project:
Covid 19 Data Exploration and Visualization on Tableau 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views and Converting Data types

*/


Select *
From CovidProjectPortfolio..['CovidDeaths-data$']
ORDER BY 3,4

--Select *
--From CovidProjectPortfolio..['CovidVaccinations-data$']
--ORDER BY 3,4


-- Selecting the Data we are going to working with

SELECT	Location, Date, total_cases, new_cases, total_deaths, population
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
WHERE	continent is not NULL
ORDER BY 1, 2


-- The Total Cases vs Total Deaths ( Mortality rate)
-- It shows the likelyhood of dying if a person contract covid in Australia 

SELECT	Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
WHERE	Location = 'Australia'and continent is not null 
ORDER BY 1, 2


-- Looking at Australian Population Infection Rate (Total Cases vs the Population)

SELECT	 Location, date, Population, total_cases, (total_cases/population)*100 as PopulationInfectionRate
FROM	 CovidProjectPortfolio..['CovidDeaths-data$']
WHERE	 Location = 'Australia'and continent is not null
ORDER BY 1, 2


--Looking at Countries with the Highest Infection Rate compared to Population

SELECT	Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectionRate
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
--WHERE Location = 'Australia'
GROUP BY Location, population
ORDER BY PopulationInfectionRate desc


-- Check Highest Infections rates by date and location

SELECT	Location, date, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectionRate
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
--WHERE Location = 'Australia'
GROUP BY Location, population, date
ORDER BY PopulationInfectionRate desc


-- Countries with the Highest Death count per Population 

SELECT	Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
--WHERE Location = 'Australia'
WHERE	continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

 
 -- EXPLORING THE COVID DATA BY CONTINENT 

 -- Continents with the Highest Death count per population

 SELECT	continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
--WHERE Location = 'Australia'
WHERE	continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS 

SELECT	SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
WHERE	continent is not null 
--GROUP BY date
ORDER BY 1, 2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingVaccinatedPeople
FROM	CovidProjectPortfolio..['CovidDeaths-data$'] dea
Join CovidProjectPortfolio..['CovidVaccinations-data$'] vac
	On dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2, 3


--Using CTE to perform calculation on partition by refered to previous query

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingVaccinatedPeople)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date) as RollingVaccinatedPeople
FROM	CovidProjectPortfolio..['CovidDeaths-data$'] dea
Join CovidProjectPortfolio..['CovidVaccinations-data$'] vac
	On dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null
)
SELECT	*, (RollingVaccinatedPeople/Population)*100 
FROM	PopvsVac


-- Using Temp TABLE to perform calculation on partition by refered to previous query

DROP table if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent	nvarchar(255),
Location	nvarchar(255),
Date		Datetime,
Population	numeric,
New_Vaccinations	numeric,
RollingVaccinatedPeople	numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingVaccinatedPeople
FROM	CovidProjectPortfolio..['CovidDeaths-data$'] dea
Join CovidProjectPortfolio..['CovidVaccinations-data$'] vac
	On dea.location = vac.location
	and dea.date = vac.date 
--WHERE dea.continent is not null

SELECT	*, (RollingVaccinatedPeople/Population)*100
FROM	#PercentPopulationVaccinated


-- Creating View to store data for later visualization in Tableau


CREATE VIEW RateofPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingVaccinatedPeople
FROM	CovidProjectPortfolio..['CovidDeaths-data$'] dea
Join CovidProjectPortfolio..['CovidVaccinations-data$'] vac
	On dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null

SELECT *
FROM RateofPopulationVaccinated


CREATE VIEW GlobalNumbers
as
SELECT	SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
WHERE	continent is not null 
--GROUP BY date
--ORDER BY 1, 2


CREATE VIEW DeathbyContinent as
SELECT	continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
--WHERE Location = 'Australia'
WHERE	continent is not null
GROUP BY continent 
--ORDER BY TotalDeathCount desc


CREATE VIEW HighestInfectionsRate 
as
SELECT	Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectionRate
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
--WHERE Location = 'Australia'
WHERE continent is not null
GROUP BY Location, population
--ORDER BY PopulationInfectionRate desc



CREATE VIEW TopdeathsbyCountry as
SELECT	Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
--WHERE Location = 'Australia'
WHERE	continent is not null
GROUP BY Location
--ORDER BY TotalDeathCount desc


CREATE VIEW AustraliaInfectionRate
as
SELECT	 Location, date, Population, total_cases, (total_cases/population)*100 as PopulationInfectionRate
FROM	 CovidProjectPortfolio..['CovidDeaths-data$']
WHERE	 Location = 'Australia'and continent is not null
--ORDER BY 1, 2

CREATE VIEW AustraliaDeathRate 
as
SELECT	Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM	CovidProjectPortfolio..['CovidDeaths-data$']
WHERE	Location = 'Australia'and continent is not null 
--ORDER BY 1, 2
