FROM 7.3-apache-stretch
LABEL maintainer="marcos.fr.rocha@gmail.com"
ENV GLPI_VERSION 9.3
ENV LAST_RELEASE 9.3.0

ENV PATH="/opt/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"

RUN apt update && apt install tzdata -y \
	&&  echo "America/Sao_Paulo" > /etc/timezone \
	&& dpkg-reconfigure -f noninteractive tzdata \
	&&  apt  install -y \
	php7.3 \
	php7.3-xml \
	php7.3-opcache \
	php-apcu \
	php7.3-bcmath \
	php7.3-imap \
	php-cas \
	php7.3-soap \
	php7.3-cli \
	php7.3-common \
	php7.3-snmp \
	php7.3-xmlrpc \
	php7.3-gd \
	php7.3-ldap \
        php-cas \
        php7.3-intl \
        php7.3-zip \
        php7.3-bz2 \
	libapache2-mod-php7.3 \
	php7.3-curl \
	php7.3-mbstring \
	php7.3-mysql \
	php-dev \
	php-pear \
	apache2 \
	unzip \
	curl \
	snmp \
	nano \
	wget \ 
	cron && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* 

RUN printf '<VirtualHost *:80>\n\
	DocumentRoot /var/www/html/glpi\n\
	<Directory /var/www/html/glpi>\n\
	AllowOverride All \n\
	Order Allow,Deny\n\
	Allow from all \n\
	</Directory> \n\
	ErrorLog /var/log/apache2/error-glpi.log\n\
	LogLevel warn \n\
	CustomLog /var/log/apache2/access-glpi.log combined \n\
</VirtualHost> '\
>> /etc/apache2/conf-available/glpi.conf 

RUN printf '<Directory /var/www/html/glpi>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride None\n\
        Require all granted\n\
</Directory>  '\
>> /etc/apache2/conf-available/glpi2.conf

RUN	a2enconf glpi.conf \
	&& a2enconf glpi2.conf \
	&& echo "*/5 * * * * /usr/bin/php /var/www/html/glpi/front/cron.php &>/dev/null"  > /var/spool/cron/crontabs/root \
	&& echo ' \n#!/bin/bash \n/etc/init.d/apache2 start \n/bin/bash' > /usr/bin/glpi \
	&& chmod +x /usr/bin/glpi

## Definindo a porta de acesso ao serviço
EXPOSE 80


## Definindo o scrit para executar no boot do container
CMD /usr/bin/glpi
 
CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["apachectl"]
