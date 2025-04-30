
docker build --no-cache -t "springboot-dev-container" .

docker image ls
#docker rmi -f springboot-dev-container

docker run  --name my-springboot-dev -it --entrypoint /bin/bash springboot-dev-container 

docker ps

docker exec -it my-springboot-dev /bin/bash

docker rm -f my-springboot-dev
docker rmi -f springboot-dev-container
docker image prune -f