sudo apt update 
sudo apt install mysql-client -y
wget https://raw.githubusercontent.com/sadamaltoubasi/vprofile-project/refs/heads/local/src/main/resources/db_backup.sql
mv db_backup.sql /tmp
mysql -h ${rds-endpoint} -P 3306 -u ${dbuser} -p${dbpass} ${dbname} < /tmp/db_backup.sql
