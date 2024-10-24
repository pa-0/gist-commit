# vehicles are skewing boxplot too much; all rows at or above 1.8k appear to be motor vehicles. 
motor_vehicles = postings.loc[postings.price >= 1800.0, :]

motor_vehicles.plot.bar('name', 'price', figsize=(9,9))
plt.ylabel("Price")
plt.xlabel("Vehicle")
plt.show();