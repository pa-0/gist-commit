#pipeline adjustment to export data to MongoDB
from pymongo import MongoClient
from scrapy.conf import settings

class MongoDBPipeline(object):
    def __init__(self):
        connection = MongoClient(
            settings['MONGODB_SERVER'],
            settings['MONGODB_PORT'])
        
        db = connection[settings['MONGODB_DB']]
        self.collection = db[settings['MONGODB_COLLECTION']]
        
        
    def process_item(self, item, spider):
        self.collection.insert(dict(item))
        return item
      
#settings adjustment to use Crawlera service
# Enable or disable downloader middlewares
# See https://doc.scrapy.org/en/latest/topics/downloader-middleware.html
DOWNLOADER_MIDDLEWARES = {
    'scrapy_crawlera.CrawleraMiddleware': 610,
}

#settings adjustment to export data to MongoDB
# Configure item pipelines
# See https://doc.scrapy.org/en/latest/topics/item-pipeline.html
ITEM_PIPELINES = {
    'final_project.pipelines.MongoDBPipeline': 300,
}

MONGODB_SERVER = 'localhost'
MONGODB_PORT = 27017
MONGODB_DB = 'LOCAL_USED_ITEMS'
MONGODB_COLLECTION = 'Craigslist_items'
