#!/usr/bin/env bash
set -eu

usage() {
  echo "Использование: ./build-local.sh [conf]"
}

case ${1:-} in
  -h|--help) usage; exit 0 ;;
esac

if [[ $# -gt 1 || ${1-conf} != conf ]]; then
  usage >&2
  exit 2
fi

cd "$(dirname "$0")"
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
