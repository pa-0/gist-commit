locations_ten_or_more = all_items_df.groupby(['Location']).filter(lambda g: g.Location.value_counts() >= 10) \
.loc[:,['Location','Description', 'Price', 'Title', 'Url']]

#checking the number of locations with less than 10 items
len_of_locs = len(locations_ten_or_more.groupby("Location").size())
print(f'There are {len_of_locs} cities with 10 items or more.')
print('\n')

#checking the locations with the most items in this subset
print('Locations with the most amount of items in this subset:')
print(locations_ten_or_more.groupby(['Location']).size().sort_values(ascending=False).head(11))
print('\n')

#sorting locations by largest total selling price  
print('Locations with highest total selling price:')
print(locations_ten_or_more.groupby(['Location']).agg(['sum']).loc[:,'Price'].sort_values('sum', ascending=False).head(10))
print('\n')

#sorting locations by largest average selling price totals 
print('Locations with highest average selling price:')
print(locations_ten_or_more.groupby(['Location']).mean().sort_values(by='Price',ascending=False).head(11))