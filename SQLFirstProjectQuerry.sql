Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%ndia%'
order by 1, 2

-- Looking at the Total Cases vs Population
-- Shows what percentage of the population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as CovidCasesPercentage
From PortfolioProject..CovidDeaths
--Where location like '%hailand%'
order by 1, 2

-- Looking at countries with highest infection rate compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

-- Showing the countries with the highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

-- Global numbers
Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%ndia%'
where continent is not null
-- Group by date
order by 1, 2

-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
, (RollingPeopleVaccinated / population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Using CTE
With PopvsVac (Continent, location, date, population, New_Vaccinatios, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--, (RollingPeopleVaccinated / population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Using temp tables
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--, (RollingPeopleVaccinated / population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualisations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--, (RollingPeopleVaccinated / population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated
