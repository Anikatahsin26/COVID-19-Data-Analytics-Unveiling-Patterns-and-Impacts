Select *
from [Covid Project]..CovidDeaths
order by 3,4

Select *
from [Covid Project]..CovidVaccinations
order by 3,4

-- select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from [Covid Project]..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths.
Alter table dbo.CovidDeaths
Alter Column total_cases float

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Covid Project]..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total cases vs population

Select location, date,population, total_cases, (total_cases/population)*100 as CasePercentage
from [Covid Project]..CovidDeaths
order by 1,2


--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from [Covid Project]..CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc


--Showing the countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Covid Project]..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Covid Project]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Covid Project]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS


SELECT
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)
    END AS DeathPercentage
FROM [Covid Project]..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;



--JOINING DEATH AND VACCINATIONS DATASET

Select*
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3




--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, total_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
select*, (total_vaccinations/population)*100
from PopvsVac




--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent IS NOT NULL

select*, (total_vaccinations/population)*100 as VaccinationPercent
from #PercentPopulationVaccinated




--CREATING VIEW TO STORE DATA FOR VISUALIZATION



CREATE VIEW Percent_population_vaccinated AS 
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM
    [Covid Project]..CovidDeaths dea
JOIN
    [Covid Project]..CovidVaccinations vac
ON
    dea.location = vac.location
    AND dea.date = vac.date;


SELECT *
FROM Percent_population_vaccinated;