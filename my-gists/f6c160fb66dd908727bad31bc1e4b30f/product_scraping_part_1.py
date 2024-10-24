import pandas as pd
from selenium import webdriver
from bs4 import BeautifulSoup
import re
import requests
import time

url = 'https://books.toscrape.com/catalogue/page-1.html'
driver = webdriver.Chrome()
driver.implicitly_wait(30)
driver.get(url)
soup = BeautifulSoup(driver.page_source,'lxml')
driver.quit()