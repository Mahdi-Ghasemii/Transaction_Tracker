# !/bin/bash

# docker image rm db_proj_front --force

docker container rm front_container --force

docker build . -t db_proj_front

docker container run -p 3000:3000 --name front_container --network my_network db_proj_front
