import time
from selenium import webdriver
import os
from selenium.webdriver.common.keys import Keys
from pyvirtualdisplay import Display

display = Display(visible=0, size=(800, 800))
display.start()

chrome_options = webdriver.ChromeOptions()
# below trick saved my life
chrome_options.add_argument('--no-sandbox')

# set the folder where you want to save your file
prefs = {'download.default_directory' : os.getcwd()}
chrome_options.add_experimental_option('prefs', prefs)

# Optional argument, if not specified will search path.
driver = webdriver.Chrome('/usr/local/bin/chromedriver',chrome_options=chrome_options)
chrome_options=chrome_options

# Scraping steps
driver.get("http://pypi.python.org/pypi/selenium")
time.sleep(3)
driver.find_element_by_css_selector("#introduction table tbody tr:nth-child(3) td:nth-child(2) a").click()
time.sleep(3)
print(' [*] Finished!')
driver.quit()
