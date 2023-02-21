-- Data for this project was obtained from https://ourworldindata.org/covid-deaths on Feb 16, 2023

-- I split that spreadsheet into two, one with Covid19 Deaths information, and one with Covid19 Vaccination information

-- I added 'Where continent is not null' to basically all the queries because 
-- I ran into issue with how there were extra columns with some data already added together by continent
-- I would have seperated that info into its own spreadsheet if this wasnt a project piece and was planning on using it more than once



-- Making sure I have the right table and selecting the columns I want

Select continent, Location, date, total_cases, new_cases, total_deaths, population
From Covid19Project..CovidDeaths
Order by 1,2



-- Showing Total Cases vs Total Deaths, and calculating Death Percentage from those two numbers
-- Shows Likelihood of dying if you contract covid in a country or your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid19Project..CovidDeaths
Where continent is not null
--and Location like 'United States'
Order by 1,2



-- Showing Total Cases per Population
-- Also showing what percentage of population has Covid

Select Location, Date, Population, Total_Cases, 
	(total_cases/population)*100 as 'Percent of Population Infected'
From Covid19Project..CovidDeaths
Where continent is not null
and Location like 'United States'
Order by date



-- Showing Countries with Highest Infection Rate compared to the total Population

Select Location, Population, MAX(total_cases) as 'Highest Infection Count', 
	MAX(total_cases/population)*100 as 'Percent of Population Infected'
From Covid19Project..CovidDeaths
Where continent is not null
Group by location, population
Order by 'Percent of Population Infected' desc



-- Showing Countries with Highest Death Count per Population

Select continent, Location, MAX(cast(total_deaths as int)) as 'Total Death Count'
From Covid19Project..CovidDeaths
Where continent is not null
Group by continent, location
Order by 'Total Death Count' desc



-- Showing Continent with Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as 'Total Death Count'
From Covid19Project..CovidDeaths
Where continent is not null
Group by continent
Order by 'Total Death Count' desc



-- GLOBAL NUMBERS



-- Showing Percentage of new Total Cases and new Total Deaths per Day in the entire world

Select date, sum(new_cases) as 'Total Cases', sum(cast(new_deaths as int)) as 'Total Deaths', 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death Percentage'
From Covid19Project..CovidDeaths
Where continent is not null
Group by date
Order by 1,2



-- Showing new Total Cases and new Total Deaths, and what percentage that is for the for the whole world

Select  sum(new_cases) as 'Total Cases', sum(cast(new_deaths as int)) as 'Total Deaths', 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death Percentage'
From Covid19Project..CovidDeaths
Where continent is not null
Order by 1,2



-- JOINING TABLES



-- Showing Total Population vs New Vaccinations, with a running total of people vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



-- Using CTE, showing the previous query, but also including what that running total is as a percentage of the country

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--and dea.location like '%states%'
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
From PopvsVac



-- Temp Table
-- Same information as last query in a different format

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Where dea.location like 'United States'
Order by 1,2

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



