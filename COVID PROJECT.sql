SELECT *
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--From CovidVaccinations
--ORDER BY 3,4

--Select Data to use for the project 

SELECT location, date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--This shows the likelihood of getting covid in your country

SELECT location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
FROM CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2

-- Looking at Total cases vs Population
-- Shows the number of population that has Covid 

SELECT location, date,total_cases,population,(total_cases/population)*100 as PercentagePopulationInfected 
FROM CovidDeaths
--WHERE location like '%state%'
WHERE location like '%state%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population 

SELECT location,MAX (total_cases)as HighestInfectionCount,MAX((total_deaths/total_cases))*100 as PercentagePopulationInfected
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location,population
ORDER BY PercentagePopulationInfected Desc 

--Looking at countries with highest Death Count
SELECT location,MAX (CAST(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount Desc 


-- Breaking it up by Continent 

SELECT location,MAX (CAST(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount Desc 

--Showing Continent with highest DeathCount per Population 

SELECT location,MAX (CAST(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount Desc 

--Global Numbers 

SELECT date,SUM(new_cases)as Total_Cases, SUM(CAST(new_deaths as int)) as Total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date 
ORDER BY 1,2

--For overall 
SELECT SUM(new_cases)as Total_Cases, SUM(CAST(new_deaths as int)) as Total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM CovidDeaths
WHERE continent is NOT NULL
-ORDER BY 1,2


--Looking at Total Population Vs Total Vaccinated 

SELECT Dea.continent,Dea.location,Dea.date,Dea.population, Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (partition by Dea.location Order by Dea.location,Dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
   ON Dea.location = Vac.location 
   AND Dea.date = Vac.date
   WHERE Dea.continent is NOT NULL
ORDER BY 2,3

-- USE CTE
With PopVsVac(continent,location,date,population,RollingPeopleVaccinated,new_vaccinations)
as
(
SELECT Dea.continent,Dea.location,Dea.date,Dea.population, Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (partition by Dea.location Order by Dea.location,Dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
   ON Dea.location = Vac.location 
   AND Dea.date = Vac.date
   WHERE Dea.continent is NOT NULL
--ORDER BY 2,3
 )
 SELECT *,(RollingPeopleVaccinated/population)*100
 FROM PopVsVac

 --TEMP Table 

 CREATE Table #PercentagePopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentagePopulationVaccinated
 SELECT Dea.continent,Dea.location,Dea.date,Dea.population, Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (partition by Dea.location Order by Dea.location,Dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
   ON Dea.location = Vac.location 
  AND Dea.date = Vac.date
  WHERE Dea.continent is NOT NULL


 SELECT *,(RollingPeopleVaccinated/population)*100
 FROM #PercentagePopulationVaccinated


 --CREATING VIEW to store data for later visualization

 CREATE View PercentagePopulationVaccinated as
 SELECT Dea.continent,Dea.location,Dea.date,Dea.population, Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (partition by Dea.location Order by Dea.location,Dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
   ON Dea.location = Vac.location 
  AND Dea.date = Vac.date
  WHERE Dea.continent is NOT NULL


Select *
From PercentagePopulationVaccinated 
