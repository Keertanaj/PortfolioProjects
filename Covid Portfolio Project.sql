select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- select *
-- from PortfolioProject..CovidVaccinations
-- order by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid  in your country
SELECT Location, date, total_cases, total_deaths, (1.0*total_deaths/total_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (1.0*total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at Countries with Higest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(1.0*total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--Breaking things down by continent
--Showing continents with highest death count per population
Select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 1.0*SUM(new_deaths)/1.0*SUM(new_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
order by 1,2

--Looking at Total Population vs.  Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location  Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not NULL 
    and vac.new_vaccinations is not NULL
order by 2,3

--USE CTE
With PopvsVac(Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location )-- Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not NULL 
    and vac.new_vaccinations is not NULL
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Table
Create Table #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not NULL 

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later vizualizations
Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location  Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not NULL 

Select * 
from PercentPopulationVaccinated