SELECT *
FROM PortfolioProject..CovidDeaths

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND  continent IS NOT NULL
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--Shows likelihhod of dying if you contract covid in your country
SELECT location, date, total_cases,  total_deaths, ( total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%STATES%' AND continent IS NOT NULL
ORDER BY 1,2



--LOOKING AT TOTAL CASES VS POPULATION
--Shows what percentage of population got Covid
SELECT location, date, total_cases,  population, ( total_cases/population)*100 AS GotCovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%STATES%' AND  continent IS NOT NULL
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATECOMPARED TO POPULATION
SELECT location,population, MAX(total_cases) AS MaxInfected, MAX(( total_cases/population))*100 AS PercentageInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentageInfected desc


--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT per POPULATION
SELECT location, MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%india%'
GROUP BY location
ORDER BY TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%india%'
GROUP BY continent
ORDER BY TotalDeathCount desc



--GLOBAL NUMBERS
SELECT  date, SUM(new_cases) AS SumNewCases, SUM(CAST( new_deaths as int) )  AS SumNewDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--TOTAL DEATHS
SELECT  SUM(new_cases) AS SumNewCases, SUM(CAST( new_deaths as int) )  AS SumNewDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--LOOKING AT THE TOTAL POPULATION vs TOTAL VACCINATION
--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, Total_vac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as Total_vac
 FROM PortfolioProject..CovidDeaths AS dea
 JOIN PortfolioProject..CovidVaccinations as vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *,(Total_vac/population)*100 AS PercentageVac
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
Total_vac numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as Total_vac
 FROM PortfolioProject..CovidDeaths AS dea
 JOIN PortfolioProject..CovidVaccinations as vac
  ON dea.location = vac.location
  and dea.date = vac.date

SELECT *,(Total_vac/population)*100 AS PercentageVac
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as Total_vac
 FROM PortfolioProject..CovidDeaths AS dea
 JOIN PortfolioProject..CovidVaccinations as vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated