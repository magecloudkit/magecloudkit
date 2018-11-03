#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
BUILD_ID=165

$DIR/ecs-deploy.sh -c production-admin -n admin-service -to ${BUILD_ID} -i ignore -t 360
$DIR/ecs-deploy.sh -c production-app -n web-service -to ${BUILD_ID} -i ignore -t 360

# TODO - something for Jenkins
