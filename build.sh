#!/bin/bash
PROJECT="$1"
USER="goodjob"
TAG="$USER/$PROJECT:$TRAVIS_BRANCH"
DOCKERFILE="Dockerfile"

[ -z "$PROJECT" ] && echo "Usage : $0 project_name" && exit 1

# Build docker
function docker_build {
  df=$1
  tag=$2
  docker build -t $tag -f $df .
}

# Push docker
function push_docker {
  if [ -z "$DOCKER_USER" ] || [ -z "$DOCKER_PASSWORD" ]; then
    echo "DOCKER_USER and DOCKER_PASSWORD not found, Failed"
    exit 12
  fi
  tag=$1
  echo "fake@goodjob.fr" | docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
  docker push $tag
}

# Deploy docker
function deploy_docker {
  tag=$1
  branch=$2
  curl --insecure "https://githook.gj.kr0.fr?tag=$tag&branch=$branch&key=$DEPLOY_KEY"
}

# Step 0
docker info

# Step 1
docker_build $DOCKERFILE $TAG
[ $? -ne 0 ] && echo "Docker build Failed" && exit 2

# Step 2
## TODO
## TESTS

# Step 3
push_docker $TAG
[ $? -ne 0 ] && echo "Docker push Failed" && exit 3

# Step 4
deploy_docker $TAG $TRAVIS_BRANCH
[ $? -ne 0 ] && echo "Docker deploy Failed" && exit 4
