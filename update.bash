#!/usr/bin/env bash

cd $(dirname $0)

function die() {
  echo "${*}" >&2
  exit 1
}
function checkutil() {
  which "${1}" &>/dev/null
}

if [[ -d "${PWD}/.git" ]]; then
  checkutil git || die "Не удалось найти утилиту 'git' (она нужна для скачивания обновлений)"

  OLD_COMMIT=$(git rev-parse @)
  git pull -q || exit 1
  NEW_COMMIT=$(git rev-parse @)

  if ! [[ "${OLD_COMMIT}" == "${NEW_COMMIT}" ]]; then
    BUILD=1 RECREATE=1 bash start.bash
  fi
else
  echo "Кажется, Вы установили данное ПО не по инструкции (скачав git-репозиторий), а из архива"
  echo "Работоспособность обновления при данном способе не гарантируется, но, всё же, попробуем обновить"

  bash install.bash
fi
