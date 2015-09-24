FROM bytekast/docker-lamp-precise

####### CONFIG ENVIRONMENT VARIABLES #######

ENV APP_MYSQL_DB ...
ENV APP_MYSQL_USER ...
ENV APP_MYSQL_PASS ...
ENV APP_MYSQL_TEST_DATA data/...

ENV GIT_REPO_URL https://user:password@...
ENV GIT_BRANCH ...

############################################

# Configure /app folder with app
RUN git clone -b ${GIT_BRANCH} ${GIT_REPO_URL} /app
RUN rm -fr /var/www && ln -s /app/public_html /var/www

# Create required folders by the app
RUN mkdir -p /app/public_html/bd/home/reports/saved_reports
RUN mkdir -p /app/public_html/bd/home/reports/status
RUN mkdir -p /app/public_html/bd/log
RUN mkdir -p /app/public_html/bd/app/tmp/logs

RUN chmod 777 /app/public_html/bd/home/reports/saved_reports
RUN chmod 777 /app/public_html/bd/home/reports/status
RUN chmod 777 /app/public_html/bd/log
RUN chmod 777 /app/public_html/bd/app/tmp/logs

RUN ln -s /usr/bin/php /usr/bin/php-cli

# Add MySQL User/Data
ADD config_busdec_mysql.sh /config_busdec_mysql.sh
RUN chmod 755 /config_busdec_mysql.sh

RUN mkdir -p /app/data
ADD data/wwwbusi_www.sql /app/data/wwwbusi_www.sql

ENV AUTHORIZED_KEYS **None**
ENV MYSQL_PASS password # admin user pssword

EXPOSE 80 3306 22
CMD /config_busdec_mysql.sh && /run.sh