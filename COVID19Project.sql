/* 
COVID-19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Selecting data for this project
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Showing the Death Rate in Indonesia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%indonesia%'
and continent is not null
Order by 1,2

--Showing the Infection Rate globally
Select location, date, total_cases, population, (total_cases/population)*100 as infection_rate
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Showing Countries with Highest Infection Rate
Select location, population, max(total_cases) as HighestInfection, max((total_cases/population))*100 as PopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
Order by PopulationInfected desc

--Showing Countries with Highest Deaths
Select location, max(cast (total_deaths as int)) as HighestDeath
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by HighestDeath desc

--Showing Continent with Highest Deaths
Select continent, max(cast (total_deaths as int)) as HighestDeath
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by HighestDeath desc

--Showing global numbers of death percentage of COVID-19 
Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Showing global numbers of death percentage of COVID-19
Select sum(new_cases) as TotalCases, sum(convert(int, new_deaths)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Joining from other dataset
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date

--Showing Total Vaccinated People in every country 
Select dea.continent, dea.location, dea.date, dea.population, CONVERT(bigint, vac.new_vaccinations) as NewVaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Using CTE to show percentage of vaccinated people within the population
With VaccinatedPopulation (Continent, Location, Date, population, NewVaccinations, TotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, CONVERT(bigint, vac.new_vaccinations) as NewVaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)
Select *, (TotalVaccinations/population)*100 as PeopleVaccinatedPercentage
From VaccinatedPopulation 

--Using TEMP TABLE to show percentage of vaccinated people within the population
DROP table if exists #TotalPopulationVaccinated
Create Table #TotalPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
TotalVaccinations numeric
)

insert into #TotalPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, CONVERT(bigint, vac.new_vaccinations) as NewVaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *, (TotalVaccinations/population)*100 as PeopleVaccinatedPercentage
From #TotalPopulationVaccinated


--Creating View for data visualization later on
Create view VaccinatedPopulation as
Select dea.continent, dea.location, dea.date, dea.population, CONVERT(bigint, vac.new_vaccinations) as NewVaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null