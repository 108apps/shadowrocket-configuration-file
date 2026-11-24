#!/usr/bin/env bash
set -eu

usage() {
  echo "Использование: ./build-local.sh [--docker] [conf]"
}

case ${1:-} in
  -h|--help) usage; exit 0 ;;
esac

docker_mode=false
if [[ ${1:-} == --docker ]]; then
  docker_mode=true
  shift
fi
if [[ $# -gt 1 || ${1-conf} != conf ]]; then
  usage >&2
  exit 2
fi

cd "$(dirname "$0")"
if "$docker_mode"; then
  image=shadowrocket-configuration-file/local-build
  docker build -t "$image" - < Dockerfile
  exec docker run --rm --dns 1.1.1.1 --user "$(id -u):$(id -g)" -v "$PWD:/workspace" "$image" ./build-local.sh conf
fi

if [[ $(uname -s) == Darwin ]] && command -v brew >/dev/null; then
  export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
fi
for tool in curl awk; do
  command -v "$tool" >/dev/null || { echo "Отсутствует $tool" >&2; exit 1; }
done
if ! sed --version >/dev/null 2>&1; then
  echo "Нужен GNU sed. См. CONTRIBUTING.md." >&2
  exit 1
fi

mkdir -p conf
for generator in source/build-scripts/sr_*.sh; do
  echo "Запуск $generator"
  bash -e "$generator"
done
