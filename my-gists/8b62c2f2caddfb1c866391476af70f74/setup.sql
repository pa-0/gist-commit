ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
CREATE USER 'root'@'%' IDENTIFIED BY 'password';

CREATE USER 'username'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
CREATE USER 'username'@'%' IDENTIFIED BY 'password';

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'username'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'username'@'%';

DROP USER 'username'@localhost;
DROP USER 'username'@%;

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'username'@'localhost';

USE mysql;
SELECT user, host, plugin FROM user;

SHOW VARIABLES LIKE '%auth%';

SET GLOBAL validate_password.policy=LOW;
ALTER USER 'username'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';

