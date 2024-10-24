from splinter import Browser
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup as bs
import pandas as pd
import requests
import os
import time


def init_browser():
 
    executable_path = {'executable_path': 'chromedriver.exe'}
    return Browser('chrome', **executable_path, headless=False)
   
def scrape_info():

    browser =init_browser()
    url = 'https://mars.nasa.gov/news/'
    browser.visit(url)
    time.sleep(1)
    html = browser.html
    soup = bs(html, 'html.parser')

    news = soup.find_all('div', class_='list_text',limit=1)

    for new in news:
    # scrape the article date 
        date = new.find('div', class_='list_date').text
        
    # scrape the article title
        title = new.find('div', class_='content_title').text
       
    # scrape the article preview
        article = new.find('div', class_='article_teaser_body').text
        
        #print
        #allnews=(date,title,article)
   


    #SECOND ONE
    url = 'https://www.jpl.nasa.gov/spaceimages/?search=&category=Mars'
    browser.visit(url)
    time.sleep(3)
    html = browser.html
    soup = bs(html, 'html.parser')
    
    img = soup.find('a', class_='fancybox')
    browser.click_link_by_id('full_image')

    soup.find('a', class_='button')
    browser.click_link_by_partial_text('more info')

    html = browser.html
    soup = bs(html, 'html.parser')
    time.sleep(3)
# Scrape the URL
    featured_image_url2 = soup.find('img', class_='main_image')['src']
    featured_image_url = f'https://www.jpl.nasa.gov' + featured_image_url2
    #featured_image_url="https://www.jpl.nasa.gov/spaceimages/images/largesize/PIA19952_hires.jpg"

#ThIRD ONE 


    res=requests.get ('https://twitter.com/'+ 'MarsWxReport')
    bs1=bs(res.content,'lxml')
    content = bs1.find('div',{'class':'content'})
    all_tweets = bs1.find_all('div',{'class':'tweet'})
    message =content.find('div',{'class':'js-tweet-text-container'}).text


#FOURTH ONE 

    url = 'https://space-facts.com/mars/'
    response = requests.get(url)
    soup = bs(response.text, 'html.parser')
    factsresults = soup.find('table',id="tablepress-p-mars-no-2")
    facttable=str(factsresults)
    factstable=pd.read_html(facttable)
    facts_df=factstable[0]
    facts_df.columns=["","value"]
    marsfactstable=facts_df.to_html(index=False, border=None)


 #5TH ONE 
    
    url='https://astrogeology.usgs.gov/search/results?q=hemisphere+enhanced&k1=target&v1=Mars'
    browser.visit(url)

    Hemisphere_imgurl=[]

    
    url='https://astrogeology.usgs.gov/search/results?q=hemisphere+enhanced&k1=target&v1=Mars'
    browser.visit(url)
    
    time.sleep(5)
    browser_html=browser.html
    browser_soup=bs(browser_html, 'html.parser')
   
    results=browser_soup.find_all('div',class_='item')
    baseurl='http://astropedia.astrogeology.usgs.gov/download/Mars/Viking/'
    for result in results:
        
        img_thumb = result.find('a', class_ = 'product-item').find('img', class_ = 'thumb')
        img_str = str(img_thumb)                        # convert each element tag to string
        img_split = img_str.split('_', 1)               # drop first part of string
        img_tif = img_split[1].split('_thumb.png"/>')   # drop last part of string
        image_url = baseurl + img_tif[0] + '/full.jpg'   # add img location to base_url
        # Find title
        title = result.find('div', class_ = 'description')\
            .find('a', class_ = 'product-item').find('h3').text

        Hemispheredict={
            'title':title,
            'image_url':image_url

        }
        Hemisphere_imgurl.append(Hemispheredict)

    #dictioary for data
    mars_data = {
        "date": date,
        "title":title,
        "article":article,
        "featured_image_url":featured_image_url,
        "message":message,
        "marsfactstable":marsfactstable,
        "Hemisphere_imgurl":Hemisphere_imgurl
        


    }  



    browser.quit()
    return mars_data
