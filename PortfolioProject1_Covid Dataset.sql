--1.

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases)) * 100.0 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location
/*
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(New_Cases))*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
where location = 'World'
order by 1,2
*/

--2.

SELECT location, SUM(new_deaths) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent is null 
and location not in ('World', 'European Union', 'Low income','Lower middle income','Upper middle income','High income')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Just a double check based off the data provided
/*
SELECT continent, SUM(new_deaths) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC
*/

--3.

SELECT location, population, MAX(CAST(total_cases AS INT)) AS HighestInfectionCount, (MAX(CAST(total_cases AS INT)) / population) * 100.0 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--4. 

SELECT location, population, date, MAX(CAST(total_cases AS INT)) AS HighestInfectionCount, (MAX(CAST(total_cases AS INT)) / population) * 100.0 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC