FROM ubuntu:latest

MAINTAINER rendiya <ligerrendy@gmail.com>
#RUN apt -y update && upgrade
# Install apache, PHP 7, and su && limentary programs. openssh-server, curl, and lynx-cur are for debugging the container.
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
    apache2 \
    php7.0 \
    php7.0-cli \
    libapache2-mod-php7.0 \
    php7.0-gd \
    php7.0-curl \
    php7.0-json \
    php7.0-mbstring \
    php7.0-mysql \
    php7.0-xml \
    php7.0-xsl \
    php7.0-zip

RUN apt-get update && apt-get install -y software-properties-common
# Enable apache mods.
RUN a2enmod php7.0
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.0/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.0/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

RUN apt-get update && apt-get install -y openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:laripagi' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Copy this repo into place.
# VOLUME ["/var/www", "/etc/apache2/sites-enabled"]

RUN apt-get install -y supervisor # Installing supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

# Update the default apache site with the config we created.
ADD apache.conf /etc/apache2/sites-enabled/000-default.conf
RUN mkdir /var/www/explorer
ADD /KodExplorer /var/www/explorer
RUN chmod -Rf 777 /var/www/*
RUN export LC_ALL=C
#RUN apt-get install python-pip python-dev build-essential -y

RUN mkdir /var/www/public
RUN cp /var/www/html/index.html /var/www/public/index.html

RUN apt-get clean

# Expose apache.
EXPOSE 80
EXPOSE 22
EXPOSE 8000

# By default start up apache in the foreground, override with /bin/bash for interative.
# CMD  /usr/sbin/sshd -D ; /usr/sbin/apache2ctl -D FOREGROUND
# ENTRYPOINT /usr/sbin/sshd -D && /usr/sbin/apache2ctl start
ENTRYPOINT ["/usr/bin/supervisord"]
# CMD ["/usr/sbin/sshd", "-D","/usr/sbin/apache2ctl","-D","FOREGROUND"]
