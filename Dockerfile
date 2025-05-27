FROM ubuntu:16.04

# Set the locale to avoid the 'ascii' codec error
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    zip \
    unzip \
    git \
    apache2 \
    openssh-server \
    supervisor \
    libapache2-mod-php7.0 \
    locales

# Add the repository for PHP 7.0.33
RUN add-apt-repository ppa:ondrej/php && apt-get update && apt-get install -y \
    php7.0 \
    php7.0-cli \
    php7.0-fpm \
    php7.0-mysql \
    php7.0-xml \
    php7.0-mbstring \
    php7.0-curl \
    php7.0-zip \
    php7.0-gd \
    php7.0-intl

# Enable Apache mods
RUN a2enmod php7.0
RUN a2enmod rewrite
RUN a2enmod proxy      # Enable mod_proxy
RUN a2enmod proxy_http # Enable mod_proxy_http
RUN a2enmod headers    # Enable mod_headers

# Copy the custom Apache config file
COPY ./apache-site.conf /etc/apache2/sites-available/000-default.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir /var/run/sshd
RUN echo 'root:rootpassword' | chpasswd

ARG SSH_USER=user
ARG SSH_PASS=userpassword
RUN useradd -m -s /bin/bash $SSH_USER && echo "$SSH_USER:$SSH_PASS" | chpasswd
RUN mkdir -p /home/$SSH_USER/.ssh && chown $SSH_USER:$SSH_USER /home/$SSH_USER/.ssh

RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/run

# Set the working directory
WORKDIR /var/www/html

# Expose the Apache port
EXPOSE 80
EXPOSE 22

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]