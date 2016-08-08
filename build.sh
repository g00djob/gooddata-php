#!/bin/bash
PROJECT="gooddata"
TAG="$PROJECT:$TRAVIS_BRANCH"
DOCKERFILE="Dockerfile"

# Build docker
function docker_build {
  df=$1
  tag=$2
  docker build -t goodjob/$tag -f $df .
}

# Push docker
function push_docker {
  tag=$1
  docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
  docker push $tag
}

# Deploy docker
function deploy_docker {
  tag=$1
  branch=$2
  curl --insecure "https://githook.gj.kr0.fr?tag=$tag&branch=$branch&key=$DEPLOY_KEY"
}

# Step 1
docker_build $DOCKERFILE $TAG
[ $? -ne 0 ] && echo "Docker build Failed" && exit 2

# Step 2
push_docker $TAG
[ $? -ne 0 ] && echo "Docker push Failed" && exit 3

# Step 3
deploy_docker $TAG $TRAVIS_BRANCH
[ $? -ne 0 ] && echo "Docker deploy Failed" && exit 4
