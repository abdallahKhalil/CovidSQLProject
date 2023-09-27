-- Looking at the percentage of death in the united state
SELECT location, date, total_cases,total_deaths, 
(CONVERT(DECIMAL(15,3),total_deaths)/CONVERT(DECIMAL(15,3),total_cases))*100 AS deathPercentage
FROM covidDeaths
WHERE location LIKE '%state%'
ORDER BY 1, 2

--Looking at the total cases vs population in a spacific country / orderd by cases

SELECT location, date, total_cases,population, 
(CONVERT(DECIMAL(15,3),total_cases)/CONVERT(DECIMAL(15,3),population))*100 AS infectionPercentage
FROM covidDeaths
WHERE location LIKE '%leb%'
ORDER BY 1, 5 DESC

--Looking at the country with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS MaxCases, 
MAX((CONVERT(DECIMAL(15,3),total_cases)/CONVERT(DECIMAL(15,3),population)))*100 AS MaxInfectionPercentage
FROM covidDeaths
GROUP BY location, population
ORDER BY MaxInfectionPercentage DESC

--Showing Countries with highest death count

SELECT location, MAX(CAST(total_deaths AS int)) AS MaxDeaths
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MaxDeaths DESC

--Showing Continante with highest death count

SELECT continent, MAX(CAST(total_deaths AS int)) AS MaxDeathsInContinante
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MaxDeathsInContinante DESC

--Global Numbers

SELECT SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS INT)) AS totalDeaths, 
	(SUM(CAST(new_deaths AS INT)) / SUM(new_cases))*100 AS deathPercentage
FROM covidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

--Covid Vaccination

SELECT *
FROM covidVaccinations

--JOining the tow table

SELECT *
FROM covidDeaths dea
JOIN covidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--Looking at Total population VS vaccination / their precentage 

SELECT SUM(CAST(dea.population AS BIGINT)) AS totalPopulation, 
	SUM(CAST(vac.total_vaccinations AS BIGINT)) AS totalVaccinated,
	SUM(CAST(vac.total_vaccinations AS BIGINT)) / SUM(dea.population) * 100 AS totalPercentageVaccinated
FROM covidDeaths dea
JOIN covidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--Summing total amount of people vacinted by each country

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingVaccinationSum
FROM covidDeaths dea
JOIN covidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE max vaccinated

WITH popVsVac (continent, location, date, population, vaccination, rollingVaccinationSum)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingVaccinationSum
FROM covidDeaths dea
JOIN covidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT location, MAX(population) AS maxPopulation, MAX(vaccination) AS maxVaccination, 
	MAX(rollingVaccinationSum) AS maxVaccinationSum, MAX((rollingVaccinationSum/population)*100) AS maxVaccinePerPopulation 
FROM popVsVac
GROUP BY location

--Create a view fro later

CREATE VIEW percentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingVaccinationSum
FROM covidDeaths dea
JOIN covidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM percentPopulationVaccinated
