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
  echo "Нужен GNU sed. На macOS установите его командой brew install gnu-sed." >&2
  exit 1
fi

mkdir -p conf
build_profile() {
  local profile=$1
  echo "Сборка ${profile}.conf"
  bash -e "source/build-scripts/${profile}.sh"
}

# --- Генерация конфигов ---
# Создаем sr_ru_basic.conf с заменой update-url в копии general
build_profile sr_ru_basic

# Создаем sr_ru_whitelist.conf с заменой update-url в копии general
build_profile sr_ru_whitelist

# Создаем sr_ru_keen.conf с заменой update-url в копии general
build_profile sr_ru_keen

# Создаем sr_nonru_basic.conf с заменой update-url
build_profile sr_nonru_basic

# Создаем sr_ru_mini.conf с заменой update-url и проксированием портов и telegram
build_profile sr_ru_mini

# Создаем sr_ru_extended.conf без update-url и с пустыми строками после [Rule]
build_profile sr_ru_extended

# Создаем sr_ru_geo.conf
build_profile sr_ru_geo
