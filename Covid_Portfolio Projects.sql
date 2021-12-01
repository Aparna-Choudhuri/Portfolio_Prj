--View the Data
SELECT * FROM Portfolio_Project.dbo.Covid_Deaths$
ORDER BY 3,4

--View the new case, total cases, population as per location
SELECT Location, date, total_cases,new_cases,total_deaths,population
FROM Portfolio_Project.dbo.Covid_Deaths$
ORDER BY 1,2

--Looking at the total cases vs total deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM Portfolio_Project.dbo.Covid_Deaths$
WHERE location like '%india%'
ORDER BY 1,2

--Looking at the total cases vs the population
SELECT Location, date, total_cases,population, (total_cases/ population)* 100 AS Percentage
FROM Portfolio_Project.dbo.Covid_Deaths$
WHERE location like '%india%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location ,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/ population))* 100 AS InfectedPercentage
FROM Portfolio_Project.dbo.Covid_Deaths$
--WHERE location like '%india%'
GROUP BY  Location, population
ORDER BY InfectedPercentage DESC

--Showing the countries with the highest death count per population
SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project.dbo.Covid_Deaths$
 WHERE continent IS NOT NULL
GROUP BY  Location
ORDER BY TotalDeathCount DESC

--Let's break things down by continent
SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project.dbo.Covid_Deaths$
WHERE continent IS NOT NULL
GROUP BY  continent
ORDER BY TotalDeathCount DESC

SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project.dbo.Covid_Deaths$
 WHERE continent IS NULL
 GROUP BY  Location
ORDER BY TotalDeathCount DESC

 --Global Numbers
SELECT date,SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/ SUM(new_cases) * 100 AS DeathPercentage   --total_cases,total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM Portfolio_Project.dbo.Covid_Deaths$
--WHERE location like '%india%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/ SUM(new_cases) * 100 AS DeathPercentage   --total_cases,total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM Portfolio_Project.dbo.Covid_Deaths$
--WHERE location like '%india%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccinations
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project.dbo.Covid_Deaths$ dea
Join Portfolio_Project.dbo.Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project.dbo.Covid_Deaths$ dea
Join Portfolio_Project.dbo.Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to Store Data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project.dbo.Covid_Deaths$ dea
Join Portfolio_Project.dbo.Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

