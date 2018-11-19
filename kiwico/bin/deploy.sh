#!/bin/bash

# ---------------------------------------------------------------------------------------------------------------------
# KIWICO MAGECLOUDKIT DEPLOY SCRIPT
#
# This script can be used to deploy a Docker image built by CircleCI to the KiwiCo ECS Clusters.
# ---------------------------------------------------------------------------------------------------------------------

set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DEFAULT_ENVIRONMENT="production"

# Check that the value of the given arg is not empty. If it is, exit with an error.
function assert_not_empty {
  local readonly arg_name="$1"
  local readonly arg_value="$2"
  local readonly reason="$3"

  if [[ -z "$arg_value" ]]; then
    log_error "The value for '$arg_name' cannot be empty. $reason"
    exit 1
  fi
}

# Log the given message at the given level. All logs are written to stderr with a timestamp.
function log {
  local readonly level="$1"
  local readonly message="$2"
  local readonly timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local readonly script_name="$(basename "$0")"
  >&2 echo -e "${timestamp} [${level}] [$script_name] ${message}"
}

# Log the given message at INFO level. All logs are written to stderr with a timestamp.
function log_info {
  local readonly message="$1"
  log "INFO" "$message"
}

# Log the given message at ERROR level. All logs are written to stderr with a timestamp.
function log_error {
  local readonly message="$1"
  log "ERROR" "$message"
}

function print_usage {
  echo
  echo "Usage: deploy.sh [options]"
  echo
  echo "This script can be used to deploy a Docker image built by CircleCI to the ECS clusters."
  echo
  echo "Note: The build must of successfully passed in order to the deploy to work."
  echo
  echo "Options:"
  echo
  echo -e "  --build-id\t\tThe CircleCI Build ID to use. Required."
  echo -e "  --environment\t\tThe MageCloudKit Environment. Optional. Defaults to production."
  echo
  echo "Example:"
  echo
  echo "  deploy.sh --build-id 166"
  echo "  deploy.sh --build-id 166 --environment production"
}

function deploy_ecs_service {
  local readonly ecs_cluster="$1"
  local readonly ecs_service="$2"
  local readonly build_id="$3"
  local readonly timeout="360"

  log_info "Deploying ECS service: $ecs_cluster/$ecs_service with Build ID: $build_id"

  $SCRIPT_DIR/ecs-deploy.sh -c "$ecs_cluster" -n "$ecs_service" -to "$build_id" -i ignore -t "$timeout"
}

function deploy {
  local build_id
  local environment
  local app_cluster="$DEFAULT_ENVIRONMENT-app"
  local admin_cluster="$DEFAULT_ENVIRONMENT-admin"
  local web_service="web-service"
  local admin_service="admin-service"

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --build-id)
        assert_not_empty "$key" "$2"
        build_id="$2"
        shift
        ;;
      --environment)
        assert_not_empty "$key" "$2"
        environment="$2"
        shift
        ;;
      --help)
        print_usage
        exit
        ;;
      *)
        log_error "Unrecognized argument: $key"
        print_usage
        exit 1
        ;;
    esac

    shift
  done

  if [[ -z "$build_id" ]]; then
    log_error "You must specify the --build-id parameter when running this script. You can find the Build IDs on CircleCI."
    exit 1
  fi

  log_info "Starting deployment to Amazon ECS"

  deploy_ecs_service "$admin_cluster" "$admin_service" "$build_id"
  deploy_ecs_service "$app_cluster" "$web_service" "$build_id"

  log_info "Deployment completed successfully!"
}

deploy "$@"
