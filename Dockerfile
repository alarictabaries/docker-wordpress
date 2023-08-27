 # Utilisez une image de base avec Apache et PHP
FROM php:8.0-apache

# Mettez à jour les paquets et installez les extensions PHP nécessaires
RUN apt-get update && \
    apt-get install -y \
    curl \
    libmagickwand-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli zip

RUN pecl install imagick && \
    docker-php-ext-enable imagick && \	
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd && \
    docker-php-ext-install zip

RUN docker-php-ext-install exif

RUN apt-get update && \
    apt-get install -y libicu-dev && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl

# Activer le module de réécriture d'URL d'Apache
RUN a2enmod rewrite
RUN a2enmod alias

COPY data/mysql/ /etc/mysql/conf.d
COPY data/php/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# Copiez le contenu du répertoire "wordpress" local dans le répertoire du serveur web Apache
# COPY --chown=www-data:www-data data/wordpress /var/www/html
RUN curl -o /tmp/latest.tar.gz -L https://fr.wordpress.org/latest-fr_FR.tar.gz
RUN tar -xzf /tmp/latest.tar.gz -C /var/www/html --strip-components=1

RUN chown -R www-data:www-data /var/www/html

# Commande pour démarrer Apache en premier plan
CMD ["apache2ctl", "-D", "FOREGROUND"]