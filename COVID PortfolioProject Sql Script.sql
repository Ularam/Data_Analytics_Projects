--SELECT * FROM CovidDeaths 
--SELECT * FROM CovidVaccinations order by 3,4

--SELECT Location, date, total_cases, new_cases,total_deaths, population
--	from PortfolioProject.dbo.CovidDeaths 


--looking at total cases vs total deaths
  --SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 
	 -- as DeathPercentage
	 -- from PortfolioProject..CovidDeaths 
	 -- where location like '%Nigeria%'

--Looking at the total cases vs the population
--Shows what percentage of population got covid
  --SELECT Location, date, total_cases, population, (total_cases/population)*100 
	 -- as DeathPercentage
	 -- from PortfolioProject..CovidDeaths 
	 -- where location like '%Nigeria%'


--Looking at countries with highest infection rates
--SELECT Location,  population,  MAX(total_cases)
--	   as HighestInfectedCount,MAX((total_cases/population)*100) 
--	  as InfectedPercentage
--	  from PortfolioProject..CovidDeaths 
--	  --where Location like '%Nigeria%'
--	  Group By location, population
--	  order by InfectedPercentage desc

--Showing countries with highest death rates
--Select Location, Max(cast(Total_deaths as int)) as TotalDeathRate
--From PortfolioProject..CovidDeaths
--where continent is not null
--group by Location
--order by TotalDeathRate desc

--breaking down by continent
--Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
--where continent is  null
--group by location
--order by TotalDeathCount desc

 --showing the continents with the highest deathCOunt
  --Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
  --from PortfolioProject..CovidDeaths
  --where continent='Asia'
  --group by continent
  --order by TotalDeathCount desc

--Global Numbers
Select date, Sum(new_cases)TotalNewCasesINaDay,
Sum(cast(new_deaths as int) )as TotalNewDeaths,
 sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by DeathPercentage desc


--looking at Total population vs vaccinations


--using CTE
--with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, TotalVaccination )
--as
--(select dea.continent, dea.location, dea.date, 
--dea.population, vac.new_vaccinations,
--sum(cast(vac.new_vaccinations as int))  
--over (Partition by dea.location order by dea.location, dea.date) 
--as TotalVaccination
----(TotalVaccination/population) *100

--from PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVaccinations vac
--on dea.location = vac.location
--and dea.date = vac.date
--where dea.continent is not null 
-- )

--Select *, (TotalVaccination/Population)*100 as PercentageOfPeopleVaccinated
--from PopvsVac order by 1,2


--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccination numeric)

insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))  
over (Partition by dea.location order by dea.location, dea.date) 
as TotalVaccination
--(TotalVaccination/population) *100

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

Select *, (TotalVaccination/Population)*100 as PercentageOfPeopleVaccinated
from #PercentPopulationVaccinated order by 1,2

--creating a view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))  
over (Partition by dea.location order by dea.location, dea.date) 
as TotalVaccination
--(TotalVaccination/population) *100

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

Select * from PercentPopulationVaccinated
