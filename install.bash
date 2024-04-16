#!/usr/bin/env bash

REPO_URL="https://github.com/DPIdetector/dpidetector-node"

function die() {
  echo "${*}" >&2
  exit 1
}
function checkutil() {
  which "${1}" &>/dev/null
}
function co() {
  git clone "${REPO_URL}" "${1}"
}

TMP=${TMP:-${TMPDIR:-${TEMP:-/tmp}}}

touch "${TMP}/test.file.test" || die "Нет доступа на запись в директорию для временных файлов (${TMP})"
rm "${TMP}/test.file.test"

checkutil git || die "Не удалось найти утилиту 'git'"

if [[ -f "install.bash" && -f "start.bash" && -f "update.bash" && -f "compose.yml" ]]; then
  url="$([[ -d "${PWD}/.git" ]] && git config --local remote.origin.url)"
  # NOTE: Похоже, нас вызвали из директории уже скачанного проекта
  bkp="${TMP}/dpidetector.bkp"
  mkdir -p "${bkp}"
  rm -r "${bkp}/*"
  mv * "${bkp}/"
  if [[ -d "${bkp}/.git" && ( "${url}" == "${REPO_URL}" || "${url}" == "git@"* ) ]]; then
    cp -a "${bkp}/.git" "${PWD}"
    git reset --hard
    git pull
  else
    co "${PWD}"
  fi
  if [[ -f "${bkp}/user.conf" ]]; then
    cp "${bkp}/user.conf" "${PWD}"
  fi
else # NOTE: Похоже, нас вызвали для первоначальной установки
  CO_DIR="${REPO_URL##*/}"
  co "${CO_DIR}"
  cd "${CO_DIR}"
fi

if ! [[ -f "${PWD}/user.conf" ]]; then
  echo "Скачайте из панели управления конфигурационный файл для данного узла" \
   "и поместите его в рабочую директорию (${PWD})." \
   "После чего нажмите Enter"
  read
fi
BUILD=1 RECREATE=1 bash start.bash
