

--SELECT *
FROM CovidProject..['coviddeath']
ORDER BY 3,4

--SELECT *
FROM CovidProject..['covidvaccination']
ORDER BY 3,4

--SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..['coviddeath']
ORDER BY 1,2

---- Total cases vs Total deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM CovidProject..['coviddeath']
WHERE location = 'India'
ORDER BY 1,2

-- Total cases vs Population
-- Shows what percent of population got infected daily.
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidProject..['coviddeath']
WHERE location = 'India'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
	PercentPopulationInfected
FROM CovidProject..['coviddeath']
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Highest death count per country
-- WITH Continents
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..['coviddeath']
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Highest death count per country
-- WITHOUT Continents
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..['coviddeath']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT 

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..['coviddeath']
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..['coviddeath']
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPercentage
FROM CovidProject..['coviddeath']
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- ALL OVER WORLD
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPercentage
FROM CovidProject..['coviddeath']
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Covid Vaccination
-- Looking at Total Population Vs Vaccination  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations 
--	(total_vaccinations/population)*100 
FROM CovidProject..['coviddeath'] as dea
JOIN CovidProject..['covidvaccination'] as vac
	ON dea.location =vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE 

WITH POPvsVAC (continent, location, date, popuplation, new_vaccinations, total_vaccinations)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations 
FROM CovidProject..['coviddeath'] as dea
JOIN CovidProject..['covidvaccination'] as vac
	ON dea.location =vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (total_vaccinations/popuplation)*100
FROM POPvsVAC

-- TEMP TABLE

DROP TABLE IF EXISTS #PopulationPercentVaccinated
CREATE TABLE #PopulationPercentVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
total_vaccinations NUMERIC
)

INSERT INTO #PopulationPercentVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations 
FROM CovidProject..['coviddeath'] as dea
JOIN CovidProject..['covidvaccination'] as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (total_vaccinations/Population)*100
FROM #PopulationPercentVaccinated


-- CREATE VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PopulationPercentVaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations 
FROM CovidProject..['coviddeath'] as dea
JOIN CovidProject..['covidvaccination'] as vac
	ON dea.location =vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PopulationPercentVaccinated