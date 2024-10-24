mysqldump -h localhost -P 3306 -u root -pPASSWORD test --no-data > mysql_dump_nodata.sql
mysql -h localhost -u root -pPASSWORD test < mysql_dump_nodata.sql