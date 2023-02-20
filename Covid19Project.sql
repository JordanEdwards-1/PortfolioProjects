Select * 
From Covid19Project..CovidDeaths
Order by 3,4

--Select * 
--From Covid19Project..CovidVaccinations
--Order by 3,4



-- Making sure I have the right table and selecting the columns I want

Select continent, Location, date, total_cases, new_cases, total_deaths, population
From Covid19Project..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid19Project..CovidDeaths
Where continent is not null
and Location like 'United States'
Order by 1,2

-- Looking at Total Cases ver Population
-- Shows what percentage of population has covid
Select Location, date, population, total_cases, (total_cases/population)*100 as 'Percent of Population Infected'
From Covid19Project..CovidDeaths
Where continent is not null
and Location like 'United States'
Order by date

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as 'Highest Infection Count', MAX(total_cases/population)*100 as 'Percent of Population Infected'
From Covid19Project..CovidDeaths
Where continent is not null
Group by location, population
Order by 4 desc


-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as 'Total Death Count'
From Covid19Project..CovidDeaths
Where continent is not null
Group by location
Order by 2 desc

-- Showing Continent with Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as 'Total Death Count'
From Covid19Project..CovidDeaths
Where continent is not null
Group by continent
Order by 2 desc


-- GLOBAL NUMBERS

-- Showing Percentage of new Total Cases and new Total Deaths per Day
Select date, sum(new_cases) as 'Total Cases', sum(cast(new_deaths as int)) as 'Total Deaths', sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death Percentage'
From Covid19Project..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Showing new Total Cases and new Total Deaths
Select  sum(new_cases) as 'Total Cases', sum(cast(new_deaths as int)) as 'Total Deaths', sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death Percentage'
From Covid19Project..CovidDeaths
Where continent is not null
Order by 1,2



-- Looking at Total Population vs New Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and dea.location like '%states%'
Order by 2,3



-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and dea.location like '%states%'
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
From PopvsVac




-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and dea.location like '%states%'
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3



Select *
From PercentPopulationVaccinated
Where location like '%states%'