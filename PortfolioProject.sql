SELECT location,date,total_cases, new_cases, total_deaths, population 
FROM coviddeaths
ORDER BY 1,2;

--looking at total cases vs total deaths 
-- shows liklihood of dying 
SELECT location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM coviddeaths
ORDER BY 1,2;

SELECT location,date,total_cases, total_deaths,CAST((total_deaths / total_cases) AS decimal(10,2)) AS DeathPercentage
FROM coviddeaths
WHERE Location LIKE '%States' 
ORDER BY 1,2;


--Total cases vs Population 
-- percentage of poulation got covid
SELECT location,date,total_cases, population ,(total_cases::float / population::float)*100  AS PopulationPercentage
FROM coviddeaths
WHERE Location LIKE '%States' 
ORDER BY 1,2;


--countries wiht highest infection rate compared to population 
SELECT location,population,Max(total_cases) AS HighestInfectionCount, CAST(MAX(total_cases::float/population::float)*100 AS float) AS PopulationPercentage
FROM coviddeaths
--WHERE Location LIKE '%States' 
GROUP BY location,population
ORDER BY 1,2;

--countries with highest death count per population
SELECT location, Max(CAST(total_deaths AS int)) AS TotalDeathCount
FROM coviddeaths
--WHERE Location LIKE '%States' 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;


--location with highest death count per population
SELECT location, Max(CAST(total_deaths AS int)) AS TotalDeathCount
FROM coviddeaths
--WHERE Location LIKE '%States' 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;


--continents with highest death counts
SELECT continent, Max(CAST(total_deaths AS int)) AS TotalDeathCount
FROM coviddeaths
--WHERE Location LIKE '%States' 
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


--global numbers 
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths ::float as int)) AS total_deaths, SUM(CAST
	(new_deaths::float AS int))/SUM(new_cases::float)*100 AS deathpercentage
FROM coviddeaths
--WHERE Location LIKE '%States' 
where continent is not null
GROUP BY date
ORDER BY 1,2;

--total count 

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST
	(new_deaths::float AS int))/SUM(new_cases::float)*100 AS deathpercentage
FROM coviddeaths
--WHERE Location LIKE '%States' 
where continent is not null
--GROUP BY date
ORDER BY 1,2;

SELECT * FROM coviddeaths;


--joining coviddeaths wiht covidvacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3; 



--total population vrs population 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM (CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location 
												  ORDER BY dea.location,dea.date) as RollingPeopleVac,
	--(RollingPeopleVac::float/population::float)*100
FROM coviddeaths dea
JOIN covidvacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


--USING CTE
WITH PopvsVacc (continent,location, date, population, new_vaccinations,RollingPeopleVac)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM (CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location 
												  ORDER BY dea.location,dea.date) as RollingPeopleVac
	--(RollingPeopleVac::float/population::float)*100
FROM coviddeaths dea
JOIN covidvacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *,(RollingPeopleVac::float/population::float)*100  
FROM popvsvacc

--temp table 

DROP TABLE IF exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent varchar(225),
location varchar(225),
date timestamp,
population numeric, 
New_vaccination numeric,
RollingPeopleVac numeric
)


INSERT into PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM (CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location 
												  ORDER BY dea.location,dea.date) as RollingPeopleVac
	--(RollingPeopleVac::float/population::float)*100
FROM coviddeaths dea
JOIN covidvacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *,(RollingPeopleVac::float/population::float)*100  
FROM  PercentPopulationVaccinated  



--creating view 

CREATE VIEW PercentPopulationVaccinated  AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM (CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location 
												  ORDER BY dea.location,dea.date) as RollingPeopleVac
	--(RollingPeopleVac::float/population::float)*100
FROM coviddeaths dea
JOIN covidvacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *  
FROM  PercentPopulationVaccinated  