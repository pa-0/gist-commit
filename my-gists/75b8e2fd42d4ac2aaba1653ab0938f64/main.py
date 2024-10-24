from bs4 import BeautifulSoup
import requests
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

#Fetch a website URL and store it to webpage
webpage = requests.get("https://content.codecademy.com/courses/beautifulsoup/cacao/index.html")

#Take the webpage variable and fetch the content using BeautifulSoup
soup = BeautifulSoup(webpage.content, "html.parser")

#Store the whole text in HTML that have the class "Rating" and "CocoaPercent"
rating_column = soup.find_all(attrs={"class": "Rating"})
cocoa_percent_tags = soup.find_all(attrs={"class": "CocoaPercent"})

#Make a empty lists for Rating and CocoaPercent
ratings = []
cocoa_percents = []

#Loop for inserting each table data to list
for x in rating_column[1:] :
  ratings.append(float(x.get_text()))

for td in cocoa_percent_tags[1:] :
  percent = float(td.get_text().strip('%'))
  cocoa_percents.append(percent)

#Combining both ratings and cocoa_percents list to a dictionary
data = {"Company": company, "Rating": ratings, "CocoaPercentage": cocoa_percents}

#Make a new Data Frame from data dictionary
df = pd.DataFrame.from_dict(data)

#Find the fits using polyfit
z = np.polyfit(df.CocoaPercentage, df.Rating, 1)

#Make the line polynomial function using poly1d
line_function = np.poly1d(z)

#Plotting the data
plt.scatter(df.CocoaPercentage, df.Rating)
plt.title('Cocoa Percentage & Ratings Correlation')
plt.xlabel('Cocoa Percentage (%)')
plt.ylabel('Ratings')
plt.plot(df.CocoaPercentage, line_function(df.CocoaPercentage), "r--")
plt.show()