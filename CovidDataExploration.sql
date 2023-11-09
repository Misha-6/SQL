SELECT * 
FROM CovidDeaths

SELECT * 
FROM CovidVaccinations

SELECT location, date, total_cases, New_cases, total_deaths, population  
FROM CovidDeaths
ORDER BY 1,2

-- Total cases vs Total deaths.

SELECT location, date, total_cases, New_cases, total_deaths, population , (total_deaths / total_cases)*100   AS deathPercentage
FROM CovidDeaths
WHERE location  like  'Canada'
ORDER BY 1,2

-- Tatal cases vs population

SELECT location, date, total_cases, population , (total_cases / population)*100   AS AffectedPopulation
FROM CovidDeaths
WHERE location  like  'Canada'
ORDER BY 1,2

--Looking at countries highest Infection rate compared to population

SELECT location, Max(total_cases) as highestInfectionCount , population , max((total_cases / population))*100   AS AffectedPopulation
FROM CovidDeaths
-- WHERE location  like  'Canada'
GROUP by Location , population
ORDER BY AffectedPopulation desc

-- countries with highest death count

SELECT location, Max(cast(total_deaths as int)) as HighestdeathCount
FROM CovidDeaths
-- WHERE location  like  'Canada'
WHERE continent is not Null
GROUP BY Location 
ORDER BY  HighestdeathCount DESC

---- showing the continent with the highest death count per population

SELECT Location, Max(cast(total_deaths as int)) as HighestdeathCount
FROM CovidDeaths
-- WHERE location  like  'Canada'
WHERE continent is Null
GROUP BY Location 
ORDER BY  HighestdeathCount DESC

SELECT SUM(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths
--WHERE location  like  'Canada'
WHERE Continent is not null 
--GROUP BY Date
ORDER BY 1,2

SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location , dea.date) as RollingCount
FROM CovidDeaths Dea
join CovidVaccinations Vac
ON Dea.date = Vac.date
AND Dea.location = Vac.location
WHERE Dea.continent is not null
order by 2 ,3

-- USE CTE

WITH PopvsVac ( Continent , Location, date , population ,new_vaccinations, RollingCount)
as
(
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location , dea.date) as RollingCount
FROM CovidDeaths Dea
join CovidVaccinations Vac
ON Dea.date = Vac.date
AND Dea.location = Vac.location
WHERE Dea.continent is not null
)
SELECT * , ( RollingCount / population )  * 100 as TotalVaccinationPercentage
FROM PopvsVac

--Temp Table 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent VarChar(50) 
, Location VarChar(50),
  date datetime ,
  population Numeric,
  new_vaccinations Numeric, 
  RollingCount Numeric)
 
Insert Into #PercentPopulationVaccinated
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location , dea.date) as RollingCount
FROM CovidDeaths Dea
join CovidVaccinations Vac
ON Dea.date = Vac.date
AND Dea.location = Vac.location

SELECT * , ( RollingCount / population )  * 100 as TotalVaccinationPercentage
FROM #PercentPopulationVaccinated 

CREATE VIEW PercentPopulationVaccinated
AS SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location , dea.date) as RollingCount
FROM CovidDeaths Dea
join CovidVaccinations Vac
ON Dea.date = Vac.date
AND Dea.location = Vac.location
WHERE dea.continent is not Null

SELECT * 
FROM PercentPopulationVaccinated 