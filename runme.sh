#/bin/sh
# Runs postgres in background
# Kill: docker kill $(cat ./.docker.id)
# Shell: docker exec -it $(cat .docker.id) /bin/bash
# See also http://blog.baudson.de/blog/stop-and-remove-all-docker-containers-and-images

PROCEED=${1:-"no"}

DIR=`dirname $0`
#PID_DIR=
ENV_FILE=$DIR/docker.env
MOUNTS="-v /run/postgresql/:/run/postgresql/"

if [ -z $XDG_DATA_HOME ]; then
  XDG_DATA_HOME=$HOME/.local/.share
fi

if [ -z $PID_DIR ]; then
  PID_DIR=$XDG_DATA_HOME/protgres-runme
fi

function join_by { local IFS="$1"; shift; echo "$*"; }

function Die() {
    echo "Dead: $1"
    exit -1
}

source $ENV_FILE
TAG=${TAG:-"$DB_NAME/postgres"}

EXTRA_ENV=()

if [ -z $DB_USER ]; then
    EXTRA_ENV+=("--env DB_USER=$USER")
fi

PREFIX=()
if [ ! -z "$DB_PASS" ]; then
    PREFIX+=("PGPASSWORD=$DB_PASS")
fi

PARAMS=("-d $DB_NAME")
#PARAMS+=("-h localhost")
if ! [[ -z $DB_USER  ||  "x$DB_USER" == "x$USER" ]]; then
    PARAMS+=("-U $DB_USER")
fi

PREFIX=`join_by " " ${PREFIX[@]}`
PARAMS=`join_by " " ${PARAMS[@]}`
EXTRA_ENV=`join_by " " ${EXTRA_ENV[@]}`

mkdir -p $PID_DIR
DOCKER_ID_FILE=$PID_DIR/$DB_NAME.id

if [ "x$PROCEED" != "x-y" ]; then
    echo "This will start docker with postgres in background (-y to bypass the question)"
    read -p "Continue (y/n)?" PROCEED
    case "$PROCEED" in 
      y|Y ) echo "yes" && PROCEED="yes";;
      n|N ) echo "no" && PROCEED="no";;
      * ) echo "invalid" && exit -1;
    esac
else
   PROCEED="yes"
fi

if [[ "$(docker images -q $TAG 2> /dev/null)" == "" ]]; then
    echo "Try: docker build --no-cache  --tag=$TAG ./"
    Die "Docker is not built yet"
fi


if [ $PROCEED = "yes" ]; then
    echo Starting posgres container in background
    if [ ! -f $DOCKER_ID_FILE ]; then
	echo "Starting new as docker id file not found: $DOCKER_ID_FILE"
	docker run --env-file=$ENV_FILE $EXTRA_ENV $MOUNTS -it -p 5432:5432 -d $TAG > $DOCKER_ID_FILE || Die "Try starting docker like that:"$'\n'"#   systemctl start docker"
	DOCKER_ID=`cat $DOCKER_ID_FILE`
    else
	DOCKER_ID=`cat $DOCKER_ID_FILE`
	echo "Startind old docker container: $DOCKER_ID"
	docker start $DOCKER_ID || Die "Could not connect to the docker, is it up? Probably you could remove pid file and try again, like that:"$'\n'"#   rm $DOCKER_ID_FILE && ./runme.sh -y"
    fi
    echo "Here is your docker: $DOCKER_ID"
    echo Try:$PREFIX psql $PARAMS
    echo '	Bash: docker exec -it $(cat '$DOCKER_ID_FILE') /bin/bash'
    echo '	Kill: docker kill $(cat '"$DOCKER_ID_FILE"''

    echo "	Restore:$PREFIX pg_restore --clean --no-acl --no-owner --no-subscriptions $PARAMS latest.dump"
fi
