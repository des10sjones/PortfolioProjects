import pandas as pd

df = pd.read_csv(r"C:\Users\DestinJones\Desktop\PortfolioProjects\Covid-19 Data Exploration\CovidDeaths.csv")

pd.set_option('display.max.columns', 59)
print(df.head())


df2 = pd.read_csv(r"C:\Users\DestinJones\Desktop\PortfolioProjects\Covid-19 Data Exploration\CovidVaccinations.csv")