

Select *
From Portfolio..CovidDeaths$
order by 3,4

Select *
From Portfolio..CovidVaccinations$
order by 3,4

-- Select Data we will use for exploration
Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths$
order by 1,2

--Total Cases vs Total Deaths in the United States
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths$
Where location = 'United States'
order by 1,2

--Total Cases vs the Population in the United States
Select location, date, population, total_cases, (total_cases/population)*100 as PercentInfected
From Portfolio..CovidDeaths$
Where location = 'United States'
order by 1,2

--Countries with highest infection rate compared to population
Select location, population, Max(total_cases)as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths$
group by location, population
order by 4 desc

--Countries with the highest death rate by population
Select location, population, max(cast(total_deaths as int))as DeathCount, (max(cast(total_deaths as int)))/population*100 as DeathRate
From Portfolio..CovidDeaths$
Where continent is not null
group by location, population
order by DeathRate desc

--Continents with the highest death rate by population
Select location, population, max(cast(total_deaths as int))as DeathCount, (max(cast(total_deaths as int)))/population*100 as DeathRate
From Portfolio..CovidDeaths$
Where continent is null
and location not like '%income'
and location <> 'International'
and location <> 'World'
group by location, population
order by DeathRate desc


--Death rate by Income Level across the world
Select location, population, max(cast(total_deaths as int))as DeathCount, (max(cast(total_deaths as int)))/population*100 as DeathRate
From Portfolio..CovidDeaths$
Where location like '%income'
group by location, population
order by DeathRate desc


--Each country's percent of people infected who died
Select location, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentageOfInfected
From Portfolio..CovidDeaths$
Where continent is not null
group by location
order by 1

--Global rolling total death numbers by day
Select date, sum(total_cases) as TotalCases, sum(cast(total_deaths as int)) as TotalDeaths, (sum(cast(total_deaths as int))/sum(total_cases))*100 as DeathPercentageOfInfected
From Portfolio..CovidDeaths$
Where continent is not null
group by date
order by 1

--Global death numbers per day
Select date, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as PercentNewInfectedDead
From Portfolio..CovidDeaths$
Where continent is not null
group by date
order by 1

--Global Numbers
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From Portfolio..CovidDeaths$
Where continent is not null
order by 1,2



--Join Covid Deaths and Covid Vaccination Tables
Select *
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date


--Total Poulation vs Total Vaccinations Possible
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as PossibleVaccinations
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE, How many vaccines did each country have and how much of their population could be vaccinated if all vaccines were administered

With PopvsVac (Continent, Location, Date, Population, NewVaccines, TotalVaccinesOnHand)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as VaccinationsPossible
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (TotalVaccinesOnHand/Population)*100 as PercentCouldBeVaccinated
From PopvsVac


--Using CTE 
With TestvsPop (Continent, Location, Date, Population, NewTests, TotalTests)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_tests, 
sum(cast(vac.new_tests as int)) OVER (Partition by dea.location order by dea.location, dea.date) as TestsAdministered
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (TotalTests/Population)*100 as PercentTested
From TestvsPop


--Creating views to store data for later visualization
Create view DeathPercentageOfInfected as
Select date, sum(total_cases) as TotalCases, sum(cast(total_deaths as int)) as TotalDeaths, (sum(cast(total_deaths as int))/sum(total_cases))*100 as DeathPercentageOfInfected
From Portfolio..CovidDeaths$
Where continent is not null
group by date

Create view DeathRatebyIncomeLevel as
Select location, population, max(cast(total_deaths as int))as DeathCount, (max(cast(total_deaths as int)))/population*100 as DeathRate
From Portfolio..CovidDeaths$
Where location like '%income'
group by location, population


Create view ContinentDeathRate as
Select location, population, max(cast(total_deaths as int))as DeathCount, (max(cast(total_deaths as int)))/population*100 as DeathRate
From Portfolio..CovidDeaths$
Where continent is null
and location not like '%income'
and location <> 'International'
and location <> 'World'
group by location, population