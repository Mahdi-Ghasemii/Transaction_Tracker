!/bin/bash

docker container rm back_container --force

docker image rm db_proj_back --force

docker build . -t db_proj_back

docker container run --name back_container --network my_network -p 4000:4000 db_proj_back
