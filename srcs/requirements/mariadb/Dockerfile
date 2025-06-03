# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: marvin <marvin@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/02 17:27:35 by marvin            #+#    #+#              #
#    Updated: 2025/06/02 17:27:35 by marvin           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:11-slim

LABEL maintainer = "hhecquet@student.42perpignan.fr"

RUN = apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint

COPY tools/init.sh /docker-entrypoint/init.sh
RUN chmod +x /docker-entrypoint/init.sh

VOLUME ["/var/lib/mysql"]

EXPOSE 3306

ENTRYPOINT ["/docker-entrypoint/init.sh"]
CMD ["mysqld", "--bind-address=0.0.0.0"]