FROM mysql:8.0.45-oraclelinux9

LABEL "Project"="vprofile"
LABEL "Author"="Sadam"

ENV MYSQL_ROOT_PASSWORD=admin123
ENV MYSQL_DATABASE=accounts

ADD db_backup.sql docker-entrypoint-initdb.d/db_backup.sql
EXPOSE 3306