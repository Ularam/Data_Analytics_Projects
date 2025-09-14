SELECT location, date, total_cases, new_cases, total_deaths, population FROM CovidDeaths WHERE continent is not null ORDER BY 1,2

--Ratio of Deaths to Cases in Nigeria (%)
SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage FROM CovidDeaths WHERE location ='Nigeria' ORDER BY 1,2

--Ratio of Total cases to Population in Nigeria (%)
SELECT location, date, population, total_cases,  (total_cases/population)* 100 as Cases_VS_Population FROM CovidDeaths 
	WHERE location ='Nigeria' 
	ORDER BY 1,2

--COUNTRY WITH  HIGHEST INFECTION RATES COMPARED TO POPULATION
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as  PopulationInfectedPercent 
FROM CovidDeaths 
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestInfectionCount DESC

--COUNTRIES WITH HIGHEST MORTALITY RATE PER POPULATION
SELECT Location, population,  MAX(CAST(total_deaths As INT)) as HighestDeathCount, MAX((total_deaths/population))*100 as DeathPercentage
FROM CovidDeaths  
WHERE continent is not null 
GROUP BY location, population
ORDER BY HighestDeathCount DESC

--COUNTRIES WITH THE HIGHEST MORTALITY RATE BY CONTINENTS
SELECT location,   MAX(CAST(total_deaths As INT)) as HighestDeathCount FROM CovidDeaths
WHERE continent is  null 
GROUP BY location
ORDER BY HighestDeathCount DESC

--Global Numbers NEW CASES & NEW DEATHS
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as INT)) as Total_Deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage FROM CovidDeaths
WHERE continent	IS NOT NULL
GROUP BY date
ORDER BY 1,2

--COVID VACCINATIONS
--TOTAL POPULATION VS TOTAL VACCINATIONS
--USING CTEs,
WITH PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT CovidDeaths.continent, CovidDeaths.location,CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(cast(CovidVaccinations.new_vaccinations as int)) 
OVER (PARTITION BY CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) AS  RollingPeopleVaccinated
FROM CovidDeaths
JOIN CovidVaccinations ON CovidDeaths.location = CovidVaccinations.location
AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL

)

Select *, (RollingPeopleVaccinated/Population)* 100 FROM PopVsVac order by 2,3

--using temp_tables
DROP TABLE IF EXISTS #PercentOfPeopleVaccinated
CREATE TABLE #PercentOfPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentOfPeopleVaccinated
SELECT CovidDeaths.continent, CovidDeaths.location,CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(cast(CovidVaccinations.new_vaccinations as int)) 
OVER (PARTITION BY CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) AS  RollingPeopleVaccinated
FROM CovidDeaths
JOIN CovidVaccinations ON CovidDeaths.location = CovidVaccinations.location
AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL

--CREATING VIEWS
CREATE VIEW PercentPopulationVaccinated AS
SELECT CovidDeaths.continent, CovidDeaths.location,CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(cast(CovidVaccinations.new_vaccinations as int)) 
OVER (PARTITION BY CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) AS  RollingPeopleVaccinated
FROM CovidDeaths
JOIN CovidVaccinations ON CovidDeaths.location = CovidVaccinations.location
AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL
