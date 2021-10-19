DROP TABLE COVID_Vaccinations
CREATE TABLE COVID_Vaccinations (
	iso_code VARCHAR,	
	continent VARCHAR,	
	location VARCHAR,	
	date date,
	new_tests decimal,	
	total_tests decimal,	
	total_tests_per_thousand decimal,	
	new_tests_per_thousand decimal,	
	new_tests_smoothed decimal,	
	new_tests_smoothed_per_thousand decimal,	
	positive_rate decimal,
	tests_per_case decimal,
	tests_units VARCHAR,	
	total_vaccinations decimal,	
	people_vaccinated decimal,	
	people_fully_vaccinated decimal,	
	total_boosters decimal,	
	new_vaccinations decimal,	
	new_vaccinations_smoothed decimal,	
	total_vaccinations_per_hundred decimal,	
	people_vaccinated_per_hundred decimal,	
	people_fully_vaccinated_per_hundred decimal,	
	total_boosters_per_hundred decimal,	
	new_vaccinations_smoothed_per_million decimal,	
	stringency_index decimal,
	population_density decimal,	
	median_age decimal,
	aged_65_older decimal,	
	aged_70_older decimal,	
	gdp_per_capita decimal,	
	extreme_poverty  decimal,	
	cardiovasc_death_rate decimal,
	diabetes_prevalence decimal,
	female_smokers decimal,	
	male_smokers decimal,	
	handwashing_facilities decimal,	
	hospital_beds_per_thousand decimal,	
	life_expectancy decimal,	
	human_development_index decimal,	
	excess_mortality_cumulative_absolute decimal,	
	excess_mortality_cumulative decimal,	
	excess_mortality decimal,	
	excess_mortality_cumulative_per_million decimal
);
DROP TABLE COVID_death
CREATE TABLE COVID_death(
	iso_code VARCHAR,	
	continent VARCHAR,	
	location VARCHAR,	
	date date,
	population bigint,	
	total_cases	decimal,
	new_cases int,	
	new_cases_smoothed decimal,	
	total_deaths int,	
	new_deaths int,	
	new_deaths_smoothed	decimal,
	total_cases_per_million decimal,	
	new_cases_per_million decimal,	
	new_cases_smoothed_per_million	decimal,
	total_deaths_per_million decimal,	
	new_deaths_per_million decimal,	
	new_deaths_smoothed_per_million decimal,	
	reproduction_rate decimal,	
	icu_patients int,	
	icu_patients_per_million decimal,	
	hosp_patients int,	
	hosp_patients_per_million decimal,	
	weekly_icu_admissions decimal,	
	weekly_icu_admissions_per_million decimal,	
	weekly_hosp_admissions decimal,	
	weekly_hosp_admissions_per_million decimal
);
--viewing each table
SELECT * 
FROM COVID_death

SELECT *
FROM covid_vaccinations

--select data 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid_death
ORDER BY 1,2

--total cases vs total deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_death
WHERE Location ='United States'
and continent is not null
ORDER BY 1,2

--total cases vs population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as infection_percentage
FROM covid_death
WHERE Location ='United States'
ORDER BY 1,2

--countries with highest infection percentage
SELECT Location, population, MAX(total_cases) as highest_infection_count, (MAX(total_cases/population))*100 as infection_percentage
FROM covid_death
GROUP BY location, population 
ORDER BY infection_percentage DESC

-- highest death count per population 
SELECT Location, MAX(total_deaths) as total_death_count
FROM covid_death
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC

-- grouping by continent with the highest death count
SELECT continent, MAX(total_deaths) as total_death_count
FROM covid_death
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC

--Global Numbers
Select SUM(new_cases) as total_cases, 
SUM(new_deaths) as total_deaths, 
SUM(new_deaths)/SUM(New_Cases)*100 as death_percentage
From covid_death
WHERE continent is not null 
ORDER BY 1,2

--COVID VACCINATIONS

--Joining the tables to find total pop vs vaccinations and using a CTE
WITH pop_vs_vac(continent, location, date, population, new_vaccinations, rolling_vaccintation_count)
as
(
SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccination_count
FROM covid_death as dea
JOIN covid_vaccinations as vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (pop_vs_vac.rolling_vaccintation_count/population)*100
FROM pop_vs_vac


-- Creating a views to store data for visualizations
CREATE VIEW percentage_pop_vaccinated as
SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccination_count
FROM covid_death as dea
JOIN covid_vaccinations as vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT* 
FROM percentage_pop_vaccinated

CREATE VIEW continent_death_count as
SELECT continent, MAX(total_deaths) as total_death_count
FROM covid_death
WHERE continent is not null
GROUP BY continent
--ORDER BY total_death_count DESC

CREATE VIEW country_infection_percentage as
SELECT Location, population, MAX(total_cases) as highest_infection_count, (MAX(total_cases/population))*100 as infection_percentage
FROM covid_death
GROUP BY location, population 
--ORDER BY infection_percentage DESC