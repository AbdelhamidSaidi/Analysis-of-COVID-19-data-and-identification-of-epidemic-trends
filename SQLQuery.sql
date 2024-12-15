Select *
from PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--from PortfolioProject1..CovidVaccines
--order by 3,4

--Select the data we will use 

Select Location, Date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
order by 1,2

--looking at the total cases vs total deaths to determine the likely to die if u got covid in a certain country

Select Location, Date, total_cases, total_deaths, (CAST((total_deaths) AS DECIMAL)/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where location like 'United States'
and continent is not null
order by 1,2

--looking at the total cases vs the population to know how many of of the population got infected

Select Location, Date, population, total_cases, (CAST((total_cases) AS DECIMAL)/population)*100 as InfectionPercentage
from PortfolioProject1..CovidDeaths
--where location like 'United States'
order by 1,2

-- looking at the countries with the highest infection rate 
Select Location, population, MAX(total_cases) as HighestInfectionCount, (CAST((Max(total_cases)) AS DECIMAL)/population)*100 as HighestCasePercentage
from PortfolioProject1..CovidDeaths
Group by Location, population
order by HighestCasePercentage desc

-- looking for the countries with the highest death counts per population
Select Location, population, MAX(total_deaths) as HighestDeathCount
from PortfolioProject1..CovidDeaths
Where continent is not null
Group by location, population
order by HighestDeathCount desc

-- Death by continent
Select continent, max(total_deaths) as HighestDeathCount
from PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
order by HighestDeathCount desc

-- showing the continents with the highest death counts

Select continent, MAX(total_deaths) as HighestDeathCount
from PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
order by HighestDeathCount desc


-- Global Numbers

Select  Sum(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths/1.0)/Sum(new_cases/1.0)*100 as Death_Percentage
from PortfolioProject1..CovidDeaths
where continent is not null
--group by Date
order by 1,2


-- looking at the total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
with population_vs_vaccination(continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date ) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)
select*,(RollingPeopleVaccinated/population)*100 as Vaccination_percentage
from population_vs_vaccination

-- Temp Table

Drop table if exists #Percent_Population_Vaccinated
Create Table  #Percent_Population_Vaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select*,(RollingPeopleVaccinated/population)*100 as Vaccination_percentage
from #Percent_Population_Vaccinated


--Create a view to store data for later visualisations

Create View Percent_Population_Vaccinated_View as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date ) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
