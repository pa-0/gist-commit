### Grouping results and removing unwanted ones

Here we want to scrape product name, price and rating from ebay product pages:

```python
url = 'https://www.ebay.com/itm/Sony-PlayStation-4-PS4-Pro-1TB-4K-Console-Black/203084236670' 

wanted_list = ['Sony PlayStation 4 PS4 Pro 1TB 4K Console - Black', 'US $349.99', '4.8'] 

scraper.build(url, wanted_list)
```
The items which we wanted have been on multiple sections of the page and the scraper tries to catch them all. So it may retrieve some extra information compared to what we have in mind.
Let's run it on a different page:
```python
scraper.get_result_exact('https://www.ebay.com/itm/Acer-Predator-Helios-300-15-6-144Hz-FHD-Laptop-i7-9750H-16GB-512GB-GTX-1660-Ti/114183725523') 
```
The result:
```python
[
    "Acer Predator Helios 300 15.6'' 144Hz FHD Laptop i7-9750H 16GB 512GB GTX 1660 Ti",
    'ACER Predator Helios 300 i7-9750H 15.6" 144Hz FHD GTX 1660Ti 16GB 512GB SSD⚡RGB',
    'US $1,229.49',
    '5.0'
]
```
As we can see we have one extra item here. We can run the `get_result_exact` or `get_result_similar` method with `grouped=True` parameter. It will group all results per its scraping rule:

```python
scraper.get_result_exact('https://www.ebay.com/itm/Acer-Predator-Helios-300-15-6-144Hz-FHD-Laptop-i7-9750H-16GB-512GB-GTX-1660-Ti/114183725523', grouped=True) 
```
 
Output:
```python
{
    'rule_sks3': ["Acer Predator Helios 300 15.6'' 144Hz FHD Laptop i7-9750H 16GB 512GB GTX 1660 Ti"],
    'rule_d4n5': ['ACER Predator Helios 300 i7-9750H 15.6" 144Hz FHD GTX 1660Ti 16GB 512GB SSD⚡RGB'],
    'rule_fmrm': ['ACER Predator Helios 300 i7-9750H 15.6" 144Hz FHD GTX 1660Ti 16GB 512GB SSD⚡RGB'],
    'rule_2ydq': ['US $1,229.49'],
    'rule_buhw': ['5.0'],
    'rule_vpfp': ['5.0']
}
```
 
Now we can use `keep_rules` or `remove_rules` methods to prune unwanted rules:
 
```python
scraper.keep_rules(['rule_sks3', 'rule_2ydq', 'rule_buhw'])
 
scraper.get_result_exact('https://www.ebay.com/itm/Acer-Predator-Helios-300-15-6-144Hz-FHD-Laptop-i7-9750H-16GB-512GB-GTX-1660-Ti/114183725523') 
```

And now the result only contains the ones which we want:
```python
[
    "Acer Predator Helios 300 15.6'' 144Hz FHD Laptop i7-9750H 16GB 512GB GTX 1660 Ti",
    'US $1,229.49',
    '5.0'
]
 ```
 
 
 ### Building a scraper to work with multiple websites with incremental learning
 
 Suppose we want to make a price scraper to work with multiple websites. Here we consider ebay.com, walmart.com and etsy.com.
 We create some sample data for each website and then feed it to the scraper. By using `update=True` parameter when calling the `build` method, all previously learned rules will be kept and new rules will be added to them:
 
 ```python
 from autoscraper import AutoScraper

data = [
    # some Ebay examples
    ('https://www.ebay.com/itm/Sony-PlayStation-4-PS4-Pro-1TB-4K-Console-Black/193632846009', ['US $349.99']),
    ('https://www.ebay.com/itm/Acer-Predator-Helios-300-15-6-FHD-Gaming-Laptop-i7-10750H-16GB-512GB-RTX-2060/303669272117', ['US $1,369.00']),
    ('https://www.ebay.com/itm/8-TAC-FORCE-SPRING-ASSISTED-FOLDING-STILETTO-TACTICAL-KNIFE-Blade-Pocket-Open/331625445801', ['US $8.95']),
    
    #some Walmart examples
    ('https://www.walmart.com/ip/8mm-Classic-Sterling-Silver-Plain-Wedding-Band-Ring/113651182', ['US $8.95']),
    ('https://www.walmart.com/ip/Apple-iPhone-11-64GB-Red-Fully-Unlocked-A-Grade-Refurbished/806414606', ['$659.99']),

    #some Etsy examples
    ('https://www.etsy.com/listing/805075149/starstruck-silk-face-mask-black-silk', ['$12.50+']),
    ('https://www.etsy.com/listing/851553172/apple-macbook-pro-i9-32gb-500gb-radeon', ['$1,500.00']),
]

scraper = AutoScraper()
for url, wanted_list in data:
    scraper.build(url=url, wanted_list=wanted_list, update=True)
```

Now hopefully the scraper has learned to scrape all 3 websites.
Let's check some new pages:

```python
>>> scraper.get_result_exact('https://www.ebay.com/itm/PUMA-Mens-Turino-Sneakers/274324387149')

['US $24.99', "PUMA Men's Turino Sneakers  | eBay"]


>>> scraper.get_result_exact('https://www.walmart.com/ip/Pack-of-8-Gerber-1st-Foods-Baby-Food-Peach-2-2-oz-Tubs/267133209')

['$8.71', '(Pack of 8) Gerber 1st Foods Baby Food, Peach, 2-2 oz Tubs - Walmart.com']


>>> scraper.get_result_exact('https://www.etsy.com/listing/863615551/matte-black-smart-wireless-bluetooth')

['$60.00']
```

Almost done! But's there's some extra info, let's fix it:
```python
>>> scraper.get_result_exact('https://www.walmart.com/ip/Pack-of-8-Gerber-1st-Foods-Baby-Food-Peach-2-2-oz-Tubs/267133209', grouped=True)

 {'rule_cqhs': [],
 'rule_h4sy': [],
 'rule_jqtb': [],
 'rule_r9qd': ['$8.71'],
 'rule_6lt7': ['$8.71'],
 'rule_2nrk': ['$8.71'],
 'rule_wy9j': ['$8.71'],
 'rule_v395': [],
 'rule_4ej6': ['(Pack of 8) Gerber 1st Foods Baby Food, Peach, 2-2 oz Tubs - Walmart.com']}


>>> scraper.remove_rules(['rule_4ej6'])
>>> scraper.get_result_exact('https://www.ebay.com/itm/PUMA-Mens-Turino-Sneakers/274324387149')

['US $24.99']


>>> scraper.get_result_exact('https://www.walmart.com/ip/Pack-of-8-Gerber-1st-Foods-Baby-Food-Peach-2-2-oz-Tubs/267133209')

['$8.71']


>>> scraper.get_result_exact('https://www.etsy.com/listing/863615551/matte-black-smart-wireless-bluetooth')

['$60.00']
```
Now we have a scraper which works with Ebay, Walmart and Etsy!


 ### Fuzzy matching for html tag attributes
 
 Some websites use different tag values for different pages (like different styles for the same element). In these cases you can adjust `attr_fuzz_ratio` parameter when getting the results. See [this issue](https://github.com/alirezamika/autoscraper/issues/31#issuecomment-709393010) for a sample usage.
 
 
### Using regular expressions

You can use regular expressions for wanted items:
```python
wanted_list = [re.compile('Lorem ipsum.+est laborum')]
```