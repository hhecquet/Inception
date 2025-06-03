# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: hhecquet <hhecquet@student.42perpignan.    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/04/30 09:54:11 by hhecquet          #+#    #+#              #
#    Updated: 2025/05/29 10:19:59 by hhecquet         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

.SILENT:

all: 

up:
	docker compose up -d --build

down:
	docker compose down

clean:
	docker stop $(shell docker ps -qa); docker rm $(shell docker ps -qa); docker rmi -f $(shell docker images -qa); docker volume rm $(shell docker volume ls -q); docker network rm $(shell docker network ls -q) 2>/dev/null

fclean: clean

re: fclean all

.PHONY: all clean fclean re