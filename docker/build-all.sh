#!/bin/bash
set -e

to_push=

cmd() {
    echo "$@"
    "$@"
}

container_test() {
    full_tag=$1
    context=$2
    test_config=$3
    
    cmd docker run --rm -v"$(pwd)/$context":/src -v/var/run/docker.sock:/var/run/docker.sock \
        gcr.io/gcp-runtimes/container-structure-test \
            test --image $full_tag --config "/src/$test_config"
}

retag() {
    tag=$1
    image=$2
    suffix=$3
    current_branch=$(echo ${GITHUB_REF:-$(git rev-parse --abbrev-ref HEAD)} | sed 's#refs/heads/##')
    echo "current_branch=$current_branch"

    case $current_branch in
        master) 
            echo "tagged master => latest"
            docker tag $tag "$image:latest$suffix" 
            to_push+=" $image:latest$suffix"
            ;;
        develop) 
            echo "tagged develop => next"
            docker tag $tag "$image:next$suffix" 
            to_push+=" $image:next$suffix"
            ;;
    esac
}

push() {
    for image in $1; do
        cmd docker push $image
    done
}

build() {
    context=$(dirname $1)
    name=$(basename $context)
    tag=$(git rev-parse HEAD | cut -c -8)
    suffix=$(test -z "$2" || echo "-$2" && echo "")
    imagename="docker.pkg.github.com/roleypoly/devops/$name"
    full_tag="${imagename}:${tag}${suffix}"

    echo ">> Building $full_tag from $context"

    DOCKER_BUILDKIT=1 docker build $context -f $1 -t $full_tag

    to_push=$full_tag
    retag $full_tag $imagename $suffix

    push "$to_push"

    test -f "${1}_test.yml" && container_test $full_tag $context $(basename "${1}_test.yml")
}

run() {
    dockerfiles=$(find . -name "Dockerfile*" ! -name "*.yml")
    for dockerfile in $dockerfiles; do
        build_tag=$(basename $dockerfile | sed "s/Dockerfile-*//g")
        build $dockerfile $build_tag
    done
}

run "$@"