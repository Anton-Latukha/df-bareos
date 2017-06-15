###
### Bareos (community fork of Bacula)
### with WebUI with Apache
### Using PostgreSQL
###
### Contribute DB separation, if you can make it.
### Entrypoint populates creates DB
### Supervisor control cannot be used, because Bareos uses old SysV Init scripts that fork
### Any improvements appreciated

FROM debian:latest
MAINTAINER anton.latukha+docker@gmail.com

ENV DEBIAN_FRONTEND noninteractive
RUN apt update
RUN apt install -y apt-utils wget

# Install on Debian
# define parameter for BareOS setup
#

# Look at http://download.bareos.org/bareos/release/latest/ for available builds
ENV DIST=Debian_8.0

ENV DATABASE=postgresql
# or DATABASE=mysql

# Bareos repository URL
ENV BareosURL=http://download.bareos.org/bareos/release/latest/$DIST/

# add the Bareos repository
RUN printf "deb $BareosURL /\n" > /etc/apt/sources.list.d/bareos.list

# add Bareos repository key
RUN wget -q "$BareosURL"/Release.key -O- | apt-key add -
 
# install Bareos packages
RUN apt update

# --no-install-recommends
RUN apt install -y \
      bareos-common \
      bareos-bconsole \
      bareos-director \
      bareos-storage \
      bareos-database-common \
      bareos-database-"$DATABASE" \
      bareos-database-tools \
      bareos-webui \
      bareos-filedaemon \
      postgresql \
      postgresql-contrib
#      supervisor # supervisor cannot be used, because Bareos uses old SysV Init scripts that fork
      
# deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main

# ENV POSTGRES_PASSWORD=mysecretpasswor is not suitable, because we need to access variable after build.

# RUN POSTGRES_PASSWORD=mysecretpassword

EXPOSE 5432 9101 9102 9103

# TODO: figure-out how to hack Bareos services procedures to tun in supervisord
#RUN mkdir -p /var/log/supervisor
#COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres

# docker build . -t bareos-postgres
# docker run --name bareos-postgres -d bareos-postgres --init
