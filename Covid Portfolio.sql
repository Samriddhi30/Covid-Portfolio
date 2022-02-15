Select*
from [Project Portfolio]..CovidDeaths
where continent is not null
order by 3,4

--Select*
--from [Project Portfolio]..CovidVaccinations
--order by 3,4

--Select data to be used

select location,date,total_cases,new_cases,total_deaths,population
from [Project Portfolio]..CovidDeaths
where continent is not null
order by 1,2

--Total cases vs total deaths

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpctg
from [Project Portfolio]..CovidDeaths
where continent is not null
--and location like 'India'
order by 1,2

--Total cases vs population

select location,date,total_cases,population, (total_cases/population)*100 as deathpctg
from [Project Portfolio]..CovidDeaths
where continent is not null
--and location like 'India'
order by 1,2

--Highest infection rate vs population

select location,max(total_cases) as MaxInfection,population,max ((total_cases/population))*100 as infectedpctg
from [Project Portfolio]..CovidDeaths
where continent is not null
--and location like 'India'
group by location,population
order by infectedpctg desc

--Highest number of deaths

select location, max(cast(total_deaths as int)) as Maxdeaths		--we used cast because the total_deaths is of datatype nvarchar leading to miscalculations hence we converted its data type to integer
from [Project Portfolio]..CovidDeaths
where continent is not null
--and location like 'India'
group by location
order by Maxdeaths desc

--CONTINENTWISE

--highest death percentage (continentwise)

select continent, max(cast(total_deaths as int)) as Maxdeaths		--we used cast because the total_deaths is of datatype nvarchar leading to miscalculations hence we converted its data type to integer
from [Project Portfolio]..CovidDeaths
where continent is not null
--and location like 'Asia'
group by continent
order by Maxdeaths desc


--GLOBAL CALCULATIONS

select sum(new_cases) as casescount,sum(cast(new_deaths as int)) as deathcount, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpctg
from [Project Portfolio]..CovidDeaths
where continent is not null
order by 1,2

select date, sum(new_cases) as casescount,sum(cast(new_deaths as int)) as deathcount, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpctg
from [Project Portfolio]..CovidDeaths
where continent is not null
group by date
order by deathpctg desc

--total population vs vaccinations

with popuvvacc (continent, location,population, new_vaccinations, rollingvaccinations)
as
(select dea.continent,dea.location, population,convert(int,vac.new_vaccinations) ,
sum(cast (vac.new_vaccinations as int)) over (partition by dea.location) as rollingvaccinations
from [Project Portfolio]..CovidDeaths dea
join [Project Portfolio]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)
select*,(rollingvaccinations/population)*100
from popuvvacc

-- temp table

drop table if exists percentagepopulationvaccinated
create table percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinations numeric
)
set ansi_warnings off 
go
insert into percentagepopulationvaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinations
from [Project Portfolio]..CovidDeaths dea
join [Project Portfolio]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

drop table percentagepopulationvaccinated

select *, (rollingvaccinations/population)*100
from percentagepopulationvaccinated

-- View to store data for visualizations

create view vaccinatedpercentage as 
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinations
from [Project Portfolio]..CovidDeaths dea
join [Project Portfolio]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--QUERIES FOR TABLEAU 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Project Portfolio]..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Project Portfolio]..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Project Portfolio]..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Project Portfolio]..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc



Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3


Select Location, date, population, total_cases, total_deaths
From [Project Portfolio]..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac



