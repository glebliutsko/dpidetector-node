#!/usr/bin/env bash

BUILD="${BUILD:+--build}"
RECREATE="${RECREATE:+--force-recreate}"

function die() {
  echo "${*}" >&2
  exit 1
}
function checkutil() {
  which "${1}" &>/dev/null
}

checkutil docker || die "Не получается найти утилиту 'docker' (без неё невозможно запустить данное ПО)"

if [[ -f /usr/libexec/docker/cli-plugins/docker-compose ]]; then
  # [[ -f /usr/libexec/docker/cli-plugins/docker-buildx ]]
  # TODO: ^ разобраться: с одной стороны есть много инсталляций, где всё собирается и обновляется без него,
  # а с другой - в чате техподдержки было несколько сообщений о фейле сборки без него 🤷
  docker compose up "${BUILD}" --detach "${RECREATE}"
else
  checkutil docker-compose || die "Не получается найти ни плагин compose для docker, ни утилиту 'docker-compose'" \
    "(без хотя бы одного из них невозможно запустить данное ПО)"
  docker-compose up "${BUILD}" --detach "${RECREATE}"
fi

