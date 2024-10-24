rm srv1.xlsx -ErrorAction Ignore

[xml](gc .\srv1.mbsa) | % secscan | 
    Export-Excel srv1.xlsx -AutoSize -TableName table -Show

# Read the new spreadsheet
# Import-Excel .\srv1.xlsx

# read, export to csv
# Import-Excel .\srv1.xlsx | Export-Csv -NotType srv1.csv