SELECT * 
FROM CovidData.dbo.CovidDeaths
ORDER BY 3,4

SELECT *
FROM CovidData.dbo.CovidVaccinations
ORDER BY 3,4


-- SELECT Data that is going to be used
-- shows likelihood (percentage) if Covid is contracted  grouped by country

SELECT location, date, total_cases, new_cases, total_deaths, population, (total_Deaths/total_cases) * 100 as DeathPercentage
FROM CovidData.dbo.CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1,2



-- Total Cases vs Population
-- shows % of population contracted covid

SELECT location, date, total_cases, new_cases, total_deaths, population, (total_cases/population) * 100 as CasePercentage
FROM CovidData.dbo.CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1,2



-- Countries with Highest Infection Rate compared to Population
-- ORDER BY highest to lowest

SELECT location,population, MAX(total_cases) as HighestInfectionCount, 
				MAX((total_cases/population)) * 100 as PercentPopulationInfected

FROM CovidData.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidData.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc


-- Filtering by Continent Total Death Count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidData.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc




----- GLOBAL NUMBERS -----


-- SUM of new_cases, new_deaths

SELECT date, SUM(new_cases) as TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths,
		SUM(cast(new_deaths as int)) / SUM(new_cases) as TotalDeathPercentage
FROM CovidData.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Total Death Percentage
SELECT SUM(new_cases) as TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths,
		SUM(cast(new_deaths as int)) / SUM(new_cases) as TotalDeathPercentage
FROM CovidData.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2




------ COVID VACCINATIONS ------

SELECT *
FROM CovidData.dbo.CovidVaccinations


-- Total Population vs Vaccinations
-- JOIN CovidDeaths and CovidVaccinations tables

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER(PARTITION BY dea.location 
				ORDER BY dea.location, dea.date) as RollingVaccinationCount


FROM CovidData.dbo.CovidDeaths dea
JOIN CovidData.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Use CTE

WITH PopulationVsVaccination (Continent, Location, Date, Population, new_vaccinations, RollingVaccinationCount)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER(PARTITION BY dea.location 
				ORDER BY dea.location, dea.date) as RollingVaccinationCount


FROM CovidData.dbo.CovidDeaths dea
JOIN CovidData.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingVaccinationCount / Population) * 100 as PercentageVaccinated
FROM PopulationVsVaccination



--- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER(PARTITION BY dea.location 
				ORDER BY dea.location, dea.date) as RollingVaccinationCount


FROM CovidData.dbo.CovidDeaths dea
JOIN CovidData.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingVaccinationCount / Population) * 100 as PercentageVaccinated
FROM #PercentPopulationVaccinated




-- CREATE VIEW
-- Store Date for Visualization

CREATE VIEW PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER(PARTITION BY dea.location 
				ORDER BY dea.location, dea.date) as RollingVaccinationCount


FROM CovidData.dbo.CovidDeaths dea
JOIN CovidData.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
