-- Total Cases vs Total Deaths (death rate) by Country
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases) *100, 2) AS death_percentage
FROM COVIDProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Percent of population with COVID by date
SELECT location, date, population, total_cases, ROUND((total_cases/population) *100, 2) AS percent_infected
FROM COVIDProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Percent of population with COVID ranked by country
SELECT location, population, MAX(total_cases) AS total_cases, ROUND((MAX(total_cases/population) *100), 2) AS percent_infected
FROM COVIDProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Highest death count per population ranked by country
SELECT location, population, MAX(cast(total_deaths as int)) AS total_deaths, ROUND((MAX(total_deaths/population) *100), 2) AS percent_population_deaths
FROM COVIDProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Highest death count per population ranked by continent
SELECT location, population, MAX(cast(total_deaths as int)) AS total_deaths, ROUND((MAX(total_deaths/population) *100), 2) AS percent_population_deaths
FROM COVIDProject..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location, population
ORDER BY total_deaths DESC

-- Comparing death rate by income
SELECT location, population, MAX(cast(total_deaths as int)) AS total_deaths, ROUND((MAX(total_deaths/population) *100), 2) AS percent_population_deaths
FROM COVIDProject..CovidDeaths
WHERE location LIKE '%income%'
GROUP BY location, population
ORDER BY total_deaths DESC



-- GLOBAL NUMBERS

--Daily total numbers
SELECT date, SUM(total_cases) as total_cases, SUM(cast(total_deaths AS int)) as total_deaths, (SUM(cast(total_deaths AS int))/SUM(total_cases) *100) AS death_percentage
FROM COVIDProject..CovidDeaths
where continent is not null
GROUP BY date
ORDER BY 1

--Daily new numbers
SELECT 
	date, 
	SUM(new_cases) as new_cases, 
	SUM(cast(total_deaths AS int)) as new_deaths, 
	(SUM(cast(total_deaths AS int))/SUM(total_cases) *100) AS death_percentage
FROM COVIDProject..CovidDeaths
where continent is not null
GROUP BY date
ORDER BY 1



-- Total Population vs Vaccinations
-- USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, people_fully_vaccinated, rolling_vaccinations)
AS (SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_people_vaccinated_smoothed AS new_vaccinations,
  vac.people_fully_vaccinated,
  SUM(CAST(vac.new_people_vaccinated_smoothed AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT
  *,
  (rolling_vaccinations / population * 100) AS percent_with_atleast_1,
  (people_fully_vaccinated / population * 100) AS percent_fully_vaccinated
FROM PopVsVac
ORDER BY location, date


-- Total Population vs Vaccinations
-- USE Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
	continent NVARCHAR(255),
	location NVARCHAR(255),
	date DATETIME,
	population NUMERIC,
	new_vaccinations NUMERIC,
	people_fully_vaccinated NUMERIC,
	people_vaccinated NUMERIC,
	rolling_vaccinations NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_people_vaccinated_smoothed AS new_vaccinations,
  vac.people_fully_vaccinated,
  vac.people_vaccinated,
  SUM(CAST(vac.new_people_vaccinated_smoothed AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT 
	*, 
	(people_vaccinated/population * 100)
FROM #PercentPopulationVaccinated
WHERE location = 'United States'
ORDER BY location, date;


-- Creating View to Store For Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_people_vaccinated_smoothed AS new_vaccinations,
  vac.people_fully_vaccinated,
  vac.people_vaccinated,
  SUM(CAST(vac.new_people_vaccinated_smoothed AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;