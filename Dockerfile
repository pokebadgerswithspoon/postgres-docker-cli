# A docker with postgres 
# Based on: https://hub.docker.com/_/postgres/
#
# Build: docker build --tag=learn21/postgres ./
# Run: docker run --name postgresdb -it -p 5432:5432 -d learn21/postgres
# Connect: psql -h localhost -U learn21
# 	note, host address my vary depending on the docker setup and -p param

FROM postgres:11.1
MAINTAINER Lauri

ENV POSTGRES_PASSWORD=ZuperZecretpass
ENV DB_USER=user
ENV DB_NAME=db
ENV DB_PASS=pass


ADD docker-entrypoint-initdb.d /docker-entrypoint-initdb.d

EXPOSE 5432:5432
