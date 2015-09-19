#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"
else
    echo "=> Using an existing volume of MySQL"
fi

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

echo "=> Adding app users and data to MySQL"
mysql -uroot -e "CREATE USER '${APP_MYSQL_USER}'@'%' IDENTIFIED BY '${APP_MYSQL_PASS}'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${APP_MYSQL_USER}'@'%' WITH GRANT OPTION"

echo "=> Loading Sample Data"
mysql -uroot < /app/${APP_MYSQL_TEST_DATA}

echo "=> Insert Test Referrers"
mysql -uroot ${APP_MYSQL_DB} -e "INSERT INTO referrers VALUES (LAST_INSERT_ID(),'192.168.59.103', NULL,50,NOW(),NOW())" 
mysql -uroot ${APP_MYSQL_DB} -e "INSERT INTO referrers VALUES (LAST_INSERT_ID(),'*localhost*', NULL,50,NOW(),NOW())" 
mysql -uroot ${APP_MYSQL_DB} -e "INSERT INTO referrers VALUES (LAST_INSERT_ID(),'*bytekast.com*', NULL,50,NOW(),NOW())" 
mysql -uroot ${APP_MYSQL_DB} -e "INSERT INTO referrers VALUES (LAST_INSERT_ID(),'*bd.local*', NULL,50,NOW(),NOW())" 

echo "=> Insert Test User: test@bytekast.com / password"
mysql -uroot ${APP_MYSQL_DB} -e "INSERT INTO users VALUES (LAST_INSERT_ID(),'01bbd2e040c52958685756692ec4f2e9','test@bytekast.com','ae10bd66ab60684106c8337385d7fabc',NULL,'32814','',NULL,NOW(),NOW(),50,NULL,2,'5c7a3b81a677c639c76989610183c0e0','yes',NULL);"

mysqladmin -uroot shutdown