SELECT *
FROM coviddeaths
ORDER BY 3,4;




SELECT *
FROM covidvaccinations
ORDER BY 3,4;



-- Covid-19 Dataset Exporatory Analysis

-- Standarderize Date
SELECT `date`, STR_TO_DATE(`date`, '%d/%m/%Y'),location
FROM  coviddeaths
;


UPDATE covidvaccinations
SET `date` = STR_TO_DATE(`date`, '%d/%m/%Y');

UPDATE coviddeaths
SET `date` = STR_TO_DATE(`date`, '%d/%m/%Y');


-- Covid-19 Dataset Exporatory Analysis
SELECT location,`date`,total_cases,new_cases,total_deaths,population
FROM coviddeaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Percentage of Cases that lead to Death in US
SELECT location,`date`,total_cases,total_deaths,(total_deaths/total_cases) * 100 AS DeathPercentage
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;


-- Looking at Total Cases vs Population
-- Percentage of Population That Contracted Covid
SELECT location,`date`,total_cases,population,(total_cases/population) * 100 AS PercentOfPopulationInfected
FROM coviddeaths
ORDER BY 1,2;


-- Looking at Countris with Highest Infection Rate realtive to population
SELECT location,MAX(total_cases) AS HighestInfectionCount,population,MAX((total_cases/population)) * 100 AS PercentOfPopulationInfected
FROM coviddeaths

GROUP BY location,population
ORDER BY PercentOfPopulationInfected DESC;


-- Show Countries with Highest Death Count Per Poulation
SELECT location,MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
;



-- Continent Data

-- Accurate Continent Data 
-- Continent with Highest  Death Count realtive to population
SELECT location,MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
;

-- Continent Data (For the Sake of Drill Down)
SELECT continent,MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT  NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
;


-- Global Data 
SELECT `date`,SUM(new_cases) AS TotalCases,SUM(new_deaths) AS TotalDeaths,SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY `date`
ORDER BY 1,2 DESC;

-- Global totals
SELECT SUM(new_cases) AS TotalCases,SUM(new_deaths) AS TotalDeaths,SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 DESC;

-- Vaccination Data

-- Total Populations vs Vacctionations
SELECT dea.continent,dea.location,dea.`date`,dea.population,vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY dea.location,dea.`date`) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) *100,
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location
	AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3
;

-- CTE 

WITH PopVsVac (continent,location,`date`,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.`date`,dea.population,vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY dea.location,dea.`date`) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) *100,
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location
	AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL 

)
SELECT *, (RollingPeopleVaccinated/population) * 100 AS PercentageVaccinated
FROM PopVsVac;

-- Temp Table 
CREATE TABLE PercentagePopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
`Date` Datetime,
Population DOUBLE,
NewVaccinations DOUBLE,
RollingPeopleVaccinated DOUBLE
);

DROP TABLE IF EXISTS PercentagePopulationVaccinated;
INSERT INTO PercentagePopulationVaccinated
SELECT dea.continent,dea.location,dea.`date`,dea.population,vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY dea.location,dea.`date`) AS RollingPeopleVaccinated
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location
	AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL ;

SELECT *, (RollingPeopleVaccinated/population) * 100 AS PercentageVaccinated
FROM PercentagePopulationVaccinated;


-- Create View for Visualizations
CREATE VIEW PercentagePopulationVaccinatedD AS
SELECT dea.continent,dea.location,dea.`date`,dea.population,vac.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY dea.location,dea.`date`) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) *100,
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location = vac.location
	AND dea.`date` = vac.`date`
WHERE dea.continent IS NOT NULL ;