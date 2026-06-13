#!/usr/bin/env bash
# Source this file to add the `rep` helper to your current shell:
#   source ./rep.sh

rep() {
  case "$1" in
    build)
      docker compose build
      ;;
    run)
      docker compose up
      ;;
    *)
      printf 'Usage: rep {build|run}\n' >&2
      return 2
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  rep "$@"
fi
