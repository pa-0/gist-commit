import praw
from icrawler.builtin import GoogleImageCrawler
import openai
import cv2
from os import listdir
from os.path import isfile, join
import os
import json
import glob
import ntpath
import requests
from pymongo import MongoClient

client = MongoClient(
   )
db = client["baqpa2"]
collection = db["products"]



apiKey = ''
openai.api_key = apiKey


def create_folder_if_not_exists(dir_path):
    if not os.path.exists(dir_path):
        os.mkdir(dir_path)
        print("Directory ", dir_path, " Created ")
    return dir_path


class PostProcessing:
    def __init__(self, name, kkId):
        self.name = name
        self.kkId = kkId

    def run(self):
        self.unique()
        self.extract_files()
        self.delete_folders()
        self.upload_file()
        self.image_arr = []
        self.add_to_mongodb()

    def add_to_mongodb(self):
        cursor = collection.update({"kkId": self.kkId},
                                   {'$push': {'images': {'$each': self.image_arr}}})

    def upload_file(self):
        kkId = self.kkId
        path = overall_dir.format(kkId)
        onlyfiles = glob.glob(path + '/*')
        for file in onlyfiles:
            fileName = ntpath.basename(file)
            url = "".format(kkId, fileName)
            url_to_add = "".format(kkId, fileName)
            headers = {
                "Accept": "*/*",
                "AccessKey": ""
            }

            response = requests.request("PUT", url, data=open(file, 'rb'), headers=headers)
            print(response.text)
            self.image_arr.append(url_to_add)

    def unique(self):
        dir_name = self.kkId
        

        directory_contents = glob.glob(overall_dir.format(dir_name) + '/*')

        for counter in range(0, len(directory_contents) - 1):
            files = glob.glob(directory_contents[counter] + '/*')
            for counter2 in range(counter + 1, len(directory_contents)):
                files2 = glob.glob(directory_contents[counter2] + '/*')
                for file in files:
                    for file2 in files2:
                        if open(file, "rb").read() == open(file2, "rb").read():
                            os.remove(file2)

    def extract_files(self):
        dir_name = self.kkId
        directory_contents = glob.glob(overall_dir.format(dir_name) + '/*')
        for item in directory_contents:
            if not os.path.isdir(item):
                os.remove(item)
        imagenum = 0
        for item in directory_contents:
            files = glob.glob(item + '/*')
            for file in files:
                os.rename(file, overall_dir.format(dir_name) + '/image{}.jpg'.format(imagenum))
                imagenum += 1

    def delete_folders(self):
        dir_name = self.kkId
        directory_contents = glob.glob(overall_dir.format(dir_name) + '/*')
        for item in directory_contents:
            if os.path.isdir(item):
                os.rmdir(item)


class ImageRetrieval:
    def __init__(self, name, kkId, item):
        self.name = name
        self.kkId = kkId
        self.item = item

    def run_all(self):
        category = self.category_classification(self.item)
        storage = self.category_storage(self.item)
        print(storage)
        if category == "Technology" or category == "Household object":
            self.category_hand_desk(self.item)
        self.scrape_web(storage, category)
        # self.scrape_reddit(self.input_processing())

    def input_processing(self):
        name2 = self.name.split()
        if name2[0].lower() == "the":
            reddit_name = str(name2[1:3]).lower()
        else:
            reddit_name = str(name2[0:2]).lower()
        return (reddit_name)

    def scrape_reddit(self, to_search):
        onebag = reddit.subreddit("onebag")
        for submission in onebag.search(to_search):
            if submission.is_self == False:
                print(submission.url, submission.title)

    @staticmethod
    def general_openai_call(engine, prompt, temp, max_tokens, top_p=1, frequency_penalty=0, presence_penalty=0, stop="\n"):
        response = openai.Completion.create(
            engine=engine,
            prompt=prompt,
            temperature=temp,
            max_tokens=max_tokens,
            top_p=top_p,
            frequency_penalty=frequency_penalty,
            presence_penalty=presence_penalty,
            stop=[stop]
        )
        return response["choices"][0]["text"]

    def category_classification(self, item):
        response = ImageRetrieval.general_openai_call(
            "curie",
            "I am a highly intelligent question answering bot. If you ask me a question that is rooted in truth, I will give you the answer. If you ask me a question that is nonsense, trickery, or has no clear answer, I will respond with \"Unknown\". I will classify the product into the following categories: Technology, Furniture, Fashion, Sports, Household object\n\nQ: Which category does an Iphone belong to? \nA: Technology\n\nQ: Which category does a sofa belong to? \nA: Furniture\n\nQ: Which category does a watch belong to? \nA: Fashion\n\nQ: Which category does a water bottle belong to? \nA: Household object\n\nQ: Which category does a Backpack belong to? \nA: Fashion\n\nQ: Which category does a book belong to? \nA: Household object\n\nQ: Which category does a knife belong to?\nA: Household object\n\nQ: Which category does a cup belong to?\nA: Household object\n\nQ: Which category do {} belong to?\n".format(item),
            temp=0, max_tokens=100)
        print(response)
        return response[3:]


    def category_storage(self, item):
        response = ImageRetrieval.general_openai_call(
            "curie",
            "The following is a list of products and a classification of them, into either 'Storage' or 'Non-storage'. \n\nBackpack: Storage\nLaptop: Non-storage\nWatch: Non-storage\nPencil Case: Storage\nCupboard: Storage\nWall: Non-storage\nMonitor: Non-storage\nKnife: Non-storage\nDrawer: Storage\nWallet: Non-storage\nGuitar case: Storage\nCalculator: Non-storage\n{}:".format(item),
            temp=0, max_tokens=6),
        return response


    def category_hand_desk(self):
        response = ImageRetrieval.general_openai_call(
            "curie",
            prompt="The following is a list of products and the categories they fall into\n\nLaptop: Desk\nPhone: Hand\nKnife: Hand\nBottle: Desk\nBook: Desk\nMonitor: Desk\nWatch: Hand\nPen: Hand\nCalculator: Desk\nTv: Desk\nCup: Desk\nGlass: Desk \nHeadphones: Hand\nPencil Case: Desk\n",
            temp=0.09, max_tokens=321)
        # from my perspective using this member variables is OK but I actually would rather return it as in the example above
        # especially with calculations this could lead to misunderstandings
        self.hand_desk = response
        return self.hand_desk

    def detect_person(self, theImage):
        print(theImage)
        hog = cv2.HOGDescriptor()
        hog.setSVMDetector(cv2.HOGDescriptor_getDefaultPeopleDetector())
        image = cv2.imread(theImage)
        if image.shape[1] < 400:  # if image width < 400
            (height, width) = image.shape[:2]
            ratio = width / float(width)  # find the width to height ratio
            image = cv2.resize(image, (400, width * ratio))  # resize the image according to the width to height ratio
        img_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

        (regions, weights) = hog.detectMultiScale(img_gray,
                                                  winStride=(5, 5),
                                                  padding=(2, 2),
                                                  scale=2.65)
        person = 0
        for i, (x, y, w, h) in enumerate(regions):
            print(weights[i])
            cv2.rectangle(image, (x, y),
                          (x + w, y + h),
                          (0, 0, 255), 2)
            person += 1
        return (person)

    def scrape_web(self, storage, category):
        images = 0
        dir_name = self.kkId
        google_Crawler = GoogleImageCrawler(
            storage={'root_dir': r'/' + create_folder_if_not_exists(overall_dir.format(dir_name) + '/plain')})
        google_Crawler.crawl(keyword=self.name.lower() + " plain white background", max_num=2)

        if category == "Fashion":
            google_Crawler = GoogleImageCrawler(
                storage={'root_dir': r'/' + create_folder_if_not_exists(overall_dir.format(dir_name) + '/worn')})
            google_Crawler.crawl(keyword=self.name.lower() + "on person worn", max_num=5)
            mypath = overall_dir.format(dir_name) + '/worn'
            print(mypath)
            onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]
            onlyfiles = glob.glob(mypath + '/*')
            print("glob glob", onlyfiles)
            images_gotten = 0
            selected = []
            for img in onlyfiles:
                try:
                    # file_name = '/Users/dhruvroongta/Downloads/{}/worn/{}'.format(dir_name,img)
                    file_name = img
                    if images_gotten >= 2:
                        pass
                    elif self.detect_person(file_name) >= 1:
                        images_gotten += 1
                        selected.append(file_name)
                    else:
                        pass
                except Exception as e:
                    print(e)
            print(len(selected))
            if len(selected) < 2:
                for counter in range(0, 2 - len(selected)):
                    selected.append(onlyfiles[counter])
            for img in onlyfiles:
                if img not in selected:
                    os.remove(img)
            images += 2

        if category == "Furniture" or category == "Sports":
            google_Crawler = GoogleImageCrawler(
                storage={'root_dir': r'/' + overall_dir.format(dir_name) + '/use'})
            google_Crawler.crawl(keyword=self.name.lower() + "in use", max_num=2)
            images += 2

        if category == "Technology" or category == "Household object":
            if self.hand_desk == "Hand":
                google_Crawler = GoogleImageCrawler(
                    storage={'root_dir': r'/' + overall_dir.format(dir_name) + '/hand'})
                google_Crawler.crawl(keyword=self.name.lower() + "in hand", max_num=2)
                images += 2
            else:
                google_Crawler = GoogleImageCrawler(
                    storage={'root_dir': r'/' + overall_dir.format(dir_name) + '/desk'})
                google_Crawler.crawl(keyword=self.name.lower() + "on desk", max_num=2)
                images += 2
            google_Crawler = GoogleImageCrawler(
                storage={'root_dir': r'/' + overall_dir.format(dir_name) + '/use'})
            google_Crawler.crawl(keyword=self.name.lower() + "in use", max_num=1)
            images += 1

        if storage == "Storage":
            print("looking for storage")
            google_Crawler = GoogleImageCrawler(
                storage={'root_dir': r'/' + create_folder_if_not_exists(overall_dir.format(dir_name) + '/inside')})
            google_Crawler.crawl(keyword=self.name.lower() + "open inside", max_num=2)
            images += 2


class PreProcessing:
    def __init__(self, file):
        self.file = file

    def run(self):
        with open(self.file, encoding='utf-8') as f:
            obj = json.load(f)
            counter = 0

            for sub in obj:
                counter += 1
                print("At backpack:", counter)
                try:  # added because there's a null object
                    kkId = sub["kkId"]
                    name = sub["brand"] + sub["productName"]
                    item = sub["type"]
                    # create folder in os
                    dir_path = overall_dir.format(kkId)
                    create_folder_if_not_exists(dir_path)

                    image_extractor = ImageRetrieval(name, kkId, item)
                    image_extractor.run_all()
                    post_processor = PostProcessing(name, kkId)
                    post_processor.run()
                except Exception as e:
                    print(e)


overall_dir = ''
to_run = PreProcessing("")
to_run.run()