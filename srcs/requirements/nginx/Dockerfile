# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: marvin <marvin@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/02 16:50:25 by marvin            #+#    #+#              #
#    Updated: 2025/06/02 16:50:25 by marvin           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#* Use a small base image
FROM debian:11-slim

#* Install dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/* 
#? --no-cache chez Alpine ?

#* Create SSL directory
RUN mkdir -p /etc/nginx/ssl

#* Generate a self-signed certificate for TLS 1.3
RUN openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/CN=hhecquet.42.fr"


#* Copy nginx config file
COPY conf/nginx.conf /etc/nginx/nginx.conf

#* Expose HTTPS port
EXPOSE 443

#* Start Nginx
CMD ["nginx", "-g", "daemon off;"]
