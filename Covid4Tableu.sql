/* 
Covid 19 Data queries for the Tableau Project visualization

*/

-- 1. The total number of covid cases, Total Deaths and the world covid death rate  

SELECT SUM(new_cases) as total_cases
	, SUM(cast(new_deaths as int)) as total_deaths
	, round(SUM(cast(new_deaths as int))/SUM(New_Cases)*100,2)  as DeathPercentage
FROM CovidProjectPortfolio..['CovidDeaths-data$']
WHERE continent is not null 
ORDER BY 1,2

Select Distinct continent
From CovidProjectPortfolio..['CovidDeaths-data$']


-- Just to double check the numbers based off the Covid data provided
-- numbers are extremely close so we will keep them 
-- The following includes "International"  Location


--Select SUM(new_cases) as total_cases
--, SUM(cast(new_deaths as int)) as total_deaths
--, round(SUM(cast(new_deaths as int))/SUM(New_Cases)*100, 2) as DeathPercentage
--From CovidProjectPortfolio..['CovidDeaths-data$']
--where location = 'World'
--order by 1,2


-- 2. The total death number by continent  

-- Here I cleaned the data and exclude locations equals to Upper middle income, High income, Lower middle income, Low income, World, European Union and International as they are not inluded in the above queries and I want to stay consistent
-- European Union is part of Europe

SELECT continent, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM CovidProjectPortfolio..['CovidDeaths-data$']
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc


-- 3. The percentage of infected population, the highest numbers of infections by location

SELECT Location
	, Population
	, MAX(total_cases) as HighestInfectionCount
	,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidProjectPortfolio..['CovidDeaths-data$']
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- 4. The percentage of infected population, the highest numbers of infections by Date and location 


SELECT Location
	,Population
	,date
	, MAX(total_cases) as HighestInfectionCount
	, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidProjectPortfolio..['CovidDeaths-data$']
WHERE continent is not null
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc


-- 5. Percentage of population vaccinated by date, country and continent


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProjectPortfolio..['CovidDeaths-data$'] dea
Join CovidProjectPortfolio..['CovidVaccinations-data$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


