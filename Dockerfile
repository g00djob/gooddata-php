FROM  php:7-apache

RUN   apt-get update \
      && apt-get install -y git \
      && apt-get install -y unzip \
      && apt-get clean all

RUN   php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
      && php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
      && php composer-setup.php --install-dir=/usr/bin \
      && php -r "unlink('composer-setup.php');" \
      && mv /usr/bin/composer.phar /usr/local/bin/composer
      
RUN   sed -i "s#DocumentRoot /var/www/html#DocumentRoot /var/www/html/web#g" /etc/apache2/sites-available/000-default.conf \
      && cd /etc/apache2/mods-enabled \
      && ln -s ../mods-available/rewrite.load rewrite.load

COPY  . /var/www/html

RUN   cp -p /var/www/html/app/config/parameters.yml.dist /var/www/html/app/config/parameters.yml \
      && composer install \
      && chown -R www-data /var/www/html
