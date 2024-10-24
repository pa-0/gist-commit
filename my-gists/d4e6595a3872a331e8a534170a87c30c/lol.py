import requests
from datetime import datetime

url = "http://api.avalonbay.com/json/reply/ApartmentSearch?communityCode=CA100&min=2900&max=5600&_=1426745186577"
resp = requests.get(url)

# CSV Plan:
# DATE,Beds,Unit,SqFt,Price
now = datetime.today().isoformat()

# fopen, check for file blah blah 
# print 'Date,Beds,Unit,SqFt,Price'

def print_csv_line(date, beds, unit, sqft, price):
    print "{},{},{},{},{}".format(date, beds, unit, sqft, price)

json = resp.json()
availables = json['results']['availableFloorPlanTypes']
for fp_types in availables:
    #print "Floor Plan: {}".format(fp_types['floorPlanTypeCode'])
    beds = fp_types['floorPlanTypeCode'][0]
    units = fp_types['availableFloorPlans']
    for unit in units:
        u = unit['finishPackages']
        for a in unit['finishPackages'][0]['apartments']:
            #print "Unit #: {}  __ SqFt: {} __ Price: ${}".format(
                #a['apartmentNumber'],
                #a['apartmentSize'],
                #a['pricing']['amenitizedRent'])
            print_csv_line(now, beds,
                a['apartmentNumber'],
                a['apartmentSize'],
                a['pricing']['amenitizedRent'])
