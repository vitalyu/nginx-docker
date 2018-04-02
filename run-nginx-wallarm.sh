#!/bin/bash

# ------------------------------------------------------------------
# [Vitaly Uvarov] nginx in docker
#
# 	Helpful script to manage nginx container
#
# ------------------------------------------------------------------

SCRIPT_DIR=`cd $(dirname $0)/;pwd`
CONTAINER_NAME=nginx-wallarm

case "$1" in
	#-------------------
	start)
		if docker exec ${CONTAINER_NAME} true 2>/dev/null
		then
			echo "Stopping ${CONTAINER_NAME} container"
			docker rm -f ${CONTAINER_NAME}
		fi

		echo "Running ${CONTAINER_NAME} container"
		docker run -d --restart=always \
		        --net=host \
		        --name $CONTAINER_NAME \
		        -p 80:80   \
		        -p 82:82   \
		        -p 443:443 \
		        -v "${SCRIPT_DIR}/nginx/:/etc/nginx/" \
		        vitalyu/nginx-docker:1.13.7-wallarm
        ;;
	#-------------------
        restart)
		echo "Restarting ${CONTAINER_NAME} container"
                docker restart $CONTAINER_NAME
        ;;
	#-------------------
	reload)
		echo "Reloading ${CONTAINER_NAME} container"
		# https://blog.docker.com/2015/04/tips-for-deploying-nginx-official-image-with-docker/
		docker kill -s HUP $CONTAINER_NAME
	;;
	#-------------------
        test)
		docker run -it --rm \
        		-v "${SCRIPT_DIR}/:/etc/nginx/" \
        		vitalyu/nginx-docker nginx -t
        ;;
        logs)
                docker logs -f ${CONTAINER_NAME}
        ;;
        #-------------------
        *)
		echo -e "\nUsage: $(basename $0) <command>
\nCommands:
 start \t\t Run new container
 reload \t Reload nginx
 restart \t Restart nginx container
 logs \t\t Show nginx live logs
 test \t\t Test nginx config \n"
	exit 1
	#-------------------
esac