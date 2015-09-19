docker-busdec-template
=================

Configuration
-------------

Copy a mysqldump of the test database in the `data` folder. It should be a `.sql` file.

Modify the following variables in the Dockerfile:

ENV APP_MYSQL_DB 
ENV APP_MYSQL_USER 
ENV APP_MYSQL_PASS 
ENV APP_MYSQL_TEST_DATA 
ENV GIT_REPO_URL 
ENV GIT_BRANCH

Building
--------
docker build -t bytekast/docker-busdec .


Running
-------
docker run -d -p 2222:22 -p 80:80 -p 3306:3306 -e AUTHORIZED_KEYS="`cat ~/.ssh/id_rsa.pub`" bytekast/docker-busdec


SSH
---
ssh -p 2222 root@${CONTAINER_IP}