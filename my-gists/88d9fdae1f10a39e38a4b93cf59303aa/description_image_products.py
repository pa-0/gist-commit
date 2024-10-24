# generate text using different LLM models

from langchain import PromptTemplate, LLMChain
from langchain import HuggingFaceHub
import os
import pandas as pd
from langchain.vectorstores import Chroma
from langchain.chains.question_answering import load_qa_chain

import requests
from bs4 import BeautifulSoup
from urllib.parse import quote_plus

os.environ["HUGGINGFACEHUB_API_TOKEN"] = "<YOUR HUGGINGFACEHUB KEY>"

repo_id = "tiiuae/falcon-7b-instruct"  # See https://huggingface.co/models?pipeline_tag=text-generation&sort=downloads for some other options
# repo_id = "google/flan-t5-xl"
llm = HuggingFaceHub(repo_id=repo_id, model_kwargs={"max_length": 200})


def get_item_description(item):
    # short description
    template = """
    
    Write a short description about 
     {product}?
    """

    prompt = PromptTemplate(
        input_variables=["product"],
        template=template,
    )

    llm_chain = LLMChain(prompt=prompt, llm=llm)
    product = item
    desc = llm_chain.run(product)

    final_answer = desc
    desc_con = ''
    generate_text = True
    while generate_text:
        desc_con = llm.predict(desc)
        if desc_con == desc or desc_con == '':
            generate_text = False
        else:
            desc = desc_con
            final_answer += desc_con
    return final_answer


def answer_query(query, shop_type):
    # short description
    template = """
    Act as a personal assistant at {type} shop 
    Question
         {query}?
    Answer: """

    prompt = PromptTemplate(
        input_variables=["type", "query"],
        template=template,
    )

    llm_chain = LLMChain(prompt=prompt, llm=llm)

    desc = llm_chain.run(query=query, type=shop_type)
    final_answer = desc
    desc_con = ''
    generate_text = True
    while generate_text:
        desc_con = llm.predict(desc)
        if desc_con == desc or desc_con == '':
            generate_text = False
        else:
            desc = desc_con
            final_answer += desc_con

    return final_answer


def format_description(text):
    sentences = text.split('.')
    return '\n'.join(sentences[:-1])


def process_csv_for_description():
    
    df = pd.read_csv('generated_data_2_3.csv')
    df['image_url'] = ''
    df = df.fillna('')
    for i, d in df.iterrows():
        print('Processing', i + 1)
        # if d['Description'] == '':
            # df.at[i, 'Description'] = get_item_description(d['Name'])
        if d['image_url'] == '':
            df.at[i, 'image_url'] = scrape_images(d['Name'])
        if i % 50 == 0:
            df.to_csv('generated_data_2_3.csv')
    df.to_csv('generated_data_2_3.csv')


def scrape_images(product_name):
    # Encode the product name for the URL
    encoded_product_name = quote_plus(product_name)

    # Construct the search URL
    search_url = f"https://www.google.com/search?q={encoded_product_name}&tbm=isch"

    # Send a GET request to the search URL
    response = requests.get(search_url)
    response.raise_for_status()

    # Parse the HTML response
    soup = BeautifulSoup(response.text, 'html.parser')

    # Find all image elements
    image_elements = soup.findAll(name='img')
    image_urls = []
    for img in image_elements:
        if 'src' in img.attrs and 'https' in img['src']:
            image_urls.append(img['src'])

    # Extract the image URLs from the image elements
    # image_urls = [img['src'] for img in image_elements[:2] if 'src' in img.attrs]

    return image_urls[0]



