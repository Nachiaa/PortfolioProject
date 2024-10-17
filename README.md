COVID-19 Data Exploration Project
Overview
This project explores and analyzes COVID-19 data, focusing on cases, deaths, and vaccinations worldwide. Using SQL, I delve into the impact of the pandemic across different countries and continents. The analysis provides insights into mortality and infection rates and tracks vaccination progress over time.

Data Source
The data used in this project is sourced from the COVID-19 Open Data Project, which includes data on cases, deaths, and vaccinations by country and region. This information is regularly updated to reflect the latest global statistics.

Project Objectives
Analyze COVID-19 Cases and Deaths: Calculate infection and mortality rates by location to understand the pandemic's impact.
Population Analysis: Determine what percentage of each country's population has been affected by COVID-19.
Vaccination Analysis: Track vaccination trends, calculating the percentage of the population vaccinated over time using CTEs, temp tables, and views.

Skills Demonstrated
SQL Joins and Aggregate Functions
Common Table Expressions (CTEs)
Temporary Tables
Window Functions
Creating and Querying Views
Data Type Conversions
Project Structure
The SQL code is organized into sections, each targeting a specific aspect of the analysis.

1. Basic Data Exploration
These queries extract core information from the data, providing a foundation for the rest of the analysis.
Example:
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY location, date;

2. Statistical Calculations
These queries calculate key statistics, including:
Death Percentage: Likelihood of dying from COVID-19 per location.
Infection Rate: Percentage of the population infected with COVID-19.


SELECT location, date, total_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL 
ORDER BY location, date;

3. Advanced Analysis
This section explores countries with the highest infection and death rates, as well as overall trends by continent.
Example:
SELECT location, population, 
       MAX(total_cases) AS HighestInfectionCount, 
       MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

5. Global Analysis
Aggregates cases, deaths, and death percentages across all data to analyze global trends.
Example:
SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS int)) AS total_deaths, 
       SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

7. Vaccination Analysis with Joins and Window Functions
Combines COVID-19 case data with vaccination data to analyze the progress of vaccination by location.
Example:
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
                                                     ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY location, date;

9. Using CTEs and Temporary Tables
This section uses CTEs and temporary tables to calculate cumulative vaccination numbers and determine the percentage of the population vaccinated over time.
Example:
WITH PopvsVac AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
                                                         ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL 
)
SELECT *, 
       (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PopvsVac;

10. Creating and Using Views
This section involves creating views to store cumulative vaccination data, making it easy to access for future analysis and visualization.
Example:
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
                                                     ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

Insights and Findings
Mortality and Infection Rates: Understanding the likelihood of death due to COVID-19 by country provides insights into where the virus has been most deadly.
Vaccination Progress: Tracking vaccination percentages over time offers a view of the global vaccination rollout and how it aligns with population size.

How to Use This Project
Clone or download this repository.
Import the CovidDeaths and CovidVaccinations datasets into your SQL database.
Run each section of the SQL code to perform the analysis or customize the queries as needed.

Future Work
Data Visualizations: Add visualizations using tools like Tableau or Power BI to enhance the analysis.
Automated Updates: Use a scheduled process to update the dataset regularly with the latest COVID-19 statistics.
Additional Metrics: Include analyses on variables like testing rates and healthcare capacity for a more comprehensive view.

License
This project is open-source and available under the MIT License.
