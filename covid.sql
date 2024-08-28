SELECT * 
FROM coviddeaths
ORDER BY 3, 4;

SELECT * 
FROM covidvaccination
ORDER BY 3, 4;


SELECT * 
FROM coviddeaths
WHERE location = 'Russia'
ORDER BY 3, 4;

/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--1

SELECT *
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Select Data that we are going to be starting with
--2

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, ROUND((CAST(total_deaths AS decimal)  / NULLIF(CAST(total_cases AS decimal), 0)) * 100, 5)  AS death_percentage
FROM coviddeaths
WHERE location = 'Russia' 
AND continent IS NOT NULL 
ORDER BY 1,2

SELECT Location, /*total_cases, total_deaths,*/ ROUND(MAX(CAST(total_deaths AS decimal)  / NULLIF(CAST(total_cases AS decimal), 0)) * 100, 5)  AS highest_death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY 1 --,2, total_deaths, total_cases
ORDER BY 2 DESC

SELECT Location, date, total_cases, total_deaths
FROM coviddeaths
WHERE location = 'Russia' 
AND continent IS NOT NULL AND total_cases = 0
ORDER BY 2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases, ROUND((CAST(total_cases AS decimal)  / NULLIF(CAST(population AS decimal), 0)) * 100, 5) AS PercentPopulationInfected
FROM CovidDeaths
WHERE location = 'Russia' 
ORDER BY 4 DESC



-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(CAST(total_cases AS decimal)) AS HighestInfectionCount,  MAX(ROUND((CAST(total_cases AS decimal)  / NULLIF(CAST(population AS decimal), 0)) * 100, 5)) AS PercentPopulationInfected
FROM coviddeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

SELECT Location, Population, MAX(CAST(total_cases AS decimal)) AS HighestInfectionCount,  MAX(ROUND((CAST(total_deaths AS decimal)  / NULLIF(CAST(total_cases AS decimal), 0)) * 100, 5)) AS PercentInfPopulationDead
FROM coviddeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentInfPopulationDead DESC


-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM coviddeaths
--Where location like '%states%'
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Max deaths in a day for each country 

SELECT location, MAX(CAST(new_deaths AS int)) AS MaxDeathsInADay
FROM coviddeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
GROUP BY Location
ORDER BY 2 DESC

--Day with the most deaths

SELECT Location, date, new_deaths AS max_deaths
FROM coviddeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL AND new_deaths = (SELECT MAX(CAST(new_deaths AS int)) 
																			FROM coviddeaths 
																			WHERE continent IS NOT NULL AND total_cases IS NOT NULL 
																			GROUP BY Location 
																			ORDER BY 1 DESC 
																			LIMIT 1)


--Day with the most deaths	in Russia

SELECT Location, date, new_deaths AS max_deaths
FROM coviddeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL AND new_deaths = (SELECT MAX(cast(new_deaths AS int)) 
																			FROM coviddeaths 
																			WHERE continent IS NOT NULL AND total_cases IS NOT NULL AND location = 'Russia'
																			GROUP BY Location 
																			ORDER BY 1 DESC 
																			LIMIT 1)



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM coviddeaths
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

-- Mortal rate by countries

SELECT location, SUM(new_cases) AS total_country_cases, SUM(CAST(new_deaths AS int)) AS total_country_deaths, ROUND(SUM(CAST(new_deaths AS decimal))/NULLIF(SUM(new_cases), 0)*100, 5) AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL  
GROUP BY location
HAVING ROUND(SUM(CAST(new_deaths AS decimal))/NULLIF(SUM(new_cases), 0)*100, 5) IS NOT NULL
ORDER BY 4 DESC

-- The biggest mortal rate by countries

SELECT location, SUM(new_cases) AS total_country_cases, SUM(CAST(new_deaths AS int)) AS total_country_deaths, ROUND(SUM(CAST(new_deaths AS decimal))/NULLIF(SUM(new_cases), 0)*100, 5) AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL  
GROUP BY location
HAVING ROUND(SUM(CAST(new_deaths AS decimal))/NULLIF(SUM(new_cases), 0)*100, 5) IS NOT NULL
ORDER BY 4 DESC
LIMIT 1

-- Mortal rate by continents

SELECT continent, SUM(new_cases) AS total_country_cases, SUM(CAST(new_deaths AS int)) AS total_country_deaths, ROUND(SUM(CAST(new_deaths AS decimal))/NULLIF(SUM(new_cases), 0)*100, 5) AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL  
GROUP BY continent
HAVING ROUND(SUM(CAST(new_deaths AS decimal))/NULLIF(SUM(new_cases), 0)*100, 5) IS NOT NULL
ORDER BY 4 DESC

-- The biggest rate by continents

SELECT continent, SUM(new_cases) AS total_country_cases, SUM(CAST(new_deaths AS int)) AS total_country_deaths, ROUND(SUM(CAST(new_deaths AS decimal))/NULLIF(SUM(new_cases), 0)*100, 5) AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL  
GROUP BY continent
HAVING ROUND(SUM(CAST(new_deaths AS decimal))/NULLIF(SUM(new_cases), 0)*100, 5) IS NOT NULL
ORDER BY 4 DESC

-- Mortal rate in Russia

SELECT location, SUM(new_cases) AS total_country_cases, SUM(CAST(new_deaths AS int)) AS total_country_deaths, ROUND(SUM(CAST(new_deaths AS decimal))/NULLIF(SUM(new_cases), 0)*100, 5) AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL AND location = 'Russia'
Group By location



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	 SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	 --ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5) AS rate
FROM coviddeaths dea 
	 INNER JOIN covidvaccination vac 
	 ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location = 'Russia'
ORDER BY 2,3 DESC



-- Using CTE (Common table expressions) to perform Calculation on Partition By in previous query
-- Percentage of vaccinated people around the world



WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM coviddeaths dea
	INNER JOIN covidvaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)

SELECT *, ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5) AS Percentage_of_vaccinated_people
From PopvsVac
WHERE ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5) IS NOT NULL --AND location = 'Russia'
ORDER BY ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5) DESC



-- Percentage of vaccinated people around the world from biggest to lowest



WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM coviddeaths dea
	INNER JOIN covidvaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)

SELECT location, MAX(ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5)) AS Percentage_of_vaccinated_people
From PopvsVac
WHERE ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5) IS NOT NULL --AND location = 'Russia'
GROUP BY location 
ORDER BY 2 DESC



-- Biggest country by vaccinated people



WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM coviddeaths dea
	INNER JOIN covidvaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)



SELECT location, RollingPeopleVaccinated AS Percentage_of_vaccinated_people
From PopvsVac
WHERE RollingPeopleVaccinated IS NOT NULL AND RollingPeopleVaccinated = (SELECT MAX(CAST(RollingPeopleVaccinated AS decimal)) 
																			FROM PopvsVac 
																			WHERE RollingPeopleVaccinated IS NOT NULL
																			GROUP BY Location 
																			ORDER BY 1 DESC 
																			LIMIT 1)
GROUP BY location, RollingPeopleVaccinated



--



WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated,
	ROW_NUMBER() OVER(PARTITION BY dea.location ORDER BY dea.date DESC) AS Number
FROM coviddeaths dea
	INNER JOIN covidvaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)

SELECT location, RollingPeopleVaccinated AS MAXIM	
From PopvsVac
WHERE RollingPeopleVaccinated IS NOT NULL AND RollingPeopleVaccinated <> 0 AND Number = 1
GROUP BY location, RollingPeopleVaccinated 
ORDER BY 2 DESC



-- Percentage of vaccinated people in Russia



WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
	INNER JOIN covidvaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT location, date, population, ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5) AS Percentage_of_vaccinated_people
FROM PopvsVac
WHERE ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5) IS NOT NULL AND location = 'Russia' 
ORDER BY ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5) DESC



-- Using Temp Table to perform Calculation on Partition By in previous query



DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TABLE PercentPopulationVaccinated
(
	continent VARCHAR(255),
	location VARCHAR(255),
	date DATE,
	population DECIMAL,
	new_vaccinations DECIMAL,
	RollingPeopleVaccinated DECIMAL
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM coviddeaths dea
	INNER JOIN covidvaccination vac
	ON dea.location = vac.location AND dea.date = vac.date;
	

SELECT location, date, population, ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5) AS Percentage_of_vaccinated_people
FROM PercentPopulationVaccinated
WHERE ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5) IS NOT NULL AND location = 'Russia' 
ORDER BY ROUND(CAST(RollingPeopleVaccinated AS decimal)/CAST(population AS decimal)*100, 5) DESC



-- Creating View to store data for later visualizations

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM coviddeaths dea
	INNER JOIN covidvaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 