SELECT * 
FROM Coviddeaths;

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Coviddeaths;

SELECT location,date,total_cases,total_deaths,(total_Deaths/total_cases)*100 as deathpercentage
FROM Coviddeaths
where location like '%states%';

SELECT location,date,total_cases,population,(total_cases/population)*100 as infactedpercentage 
FROM Coviddeaths
where location like '%states%';


SELECT location,population,Max(total_cases) as highestinfection,MAX(total_cases/population)*100 as infactedpercentage 
FROM Coviddeaths
--where location like '%states%'
GROUP BY Location, population 
Order by infactedpercentage desc


SELECT Location,Max(cast(total_deaths as int)) as Totaldeathcount
FROM Coviddeaths
--where location like '%states%'
where Location is not null
GROUP BY Location  
Order by Totaldeathcount desc


SELECT continent,Max(cast(total_deaths as int)) as Totaldeathcount
FROM Coviddeaths
--where location like '%states%'
where continent is not null
GROUP BY continent  
Order by Totaldeathcount desc

SELECT sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths,sum(cast
(new_deaths as int))/sum(new_cases)*100 as deathpercentage
FROM Coviddeaths
--where location like '%states%'
where continent is not null
--group by date 

with popvsvac (continent, location, date,population,new_vaccinationa,peoplevaccinated)
as
(
select dea.continent, dea.date, dea.location , dea.population ,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
as peoplevaccinated
from coviddeaths dea 
join vaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
)
select *,(peoplevaccinated/population)*100
from popvsvac

drop table if exists #percentpeoplevaccinated
create table #percentpeoplevaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
peoplevaccinated numeric
)
insert into #percentpeoplevaccinated
select dea.continent, dea.date, dea.location , dea.population ,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
as peoplevaccinated
from coviddeaths dea 
join vaccination vac
	on dea.location = vac.location and
	dea.date = vac.date
--where dea.continent is not null

select *,(peoplevaccinated/population)*100
from #percentpeoplevaccinated


