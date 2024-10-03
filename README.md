# Covid-19_SQL_Data_exploration

Link to the dataset https://ourworldindata.org/covid-deaths

Analysis was carried out in PostgreSQL (pgAdmin 4)

First I split the dataset into two tables in Excel: 
- coviddeaths - contains data on COVID-19 deaths by country and time
- covidvaccination - contains data on COVID-19 vaccinations

I then conducted a study analyzing key metrics, such as: 
- mortality rate
- vaccination rate
- infection rate
- total number of deaths, infected and vaccinated
- impact of population density and GDP on the spread of the virus

I did this with an eye to practice basic SQL queries and window functions.

Based on the data obtained, I created a rather simple visualization in Jupyter Notebook (using pandas, matplotlib, seaborn) with the idea to reflect the dynamics of change in metrics in different countries over certain periods of time.

