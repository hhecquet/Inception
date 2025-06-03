# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: hhecquet <hhecquet@student.42perpignan.    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/03 08:56:01 by hhecquet          #+#    #+#              #
#    Updated: 2025/06/03 08:57:14 by hhecquet         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:11-slim

LABEL maintainer="hhecquet@student.42perpignan.fr"

RUN apt-get update && \
    apt-get install -y \
      php7.4-fpm \
      php7.4-mysql \
      php7.4-cli \
      curl \
      unzip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

RUN curl -o /tmp/latest.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/latest.tar.gz --strip-components=1 -C /var/www/html && \
    rm /tmp/latest.tar.gz

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

COPY tools/wp-setup.sh /docker-entrypoint/wp-setup.sh
RUN chmod +x /docker-entrypoint/wp-setup.sh

RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

ENTRYPOINT ["/docker-entrypoint/wp-setup.sh"]
CMD ["php-fpm7.4", "-F"]