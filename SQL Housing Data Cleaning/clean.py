import pandas as pd 

df = pd.read_csv('/Users/destinjones/PortfolioProjects/SQL Housing Data Cleaning/Nashville Housing Data for Data Cleaning.csv')

df['Acreage'] = df['Acreage'].replace('', None)

df.to_csv('/Users/destinjones/PortfolioProjects/SQL Housing Data Cleaning/Nashville Housing Data for Data Cleaning.csv')