#!/usr/bin/env bash

# — флаг -e останавливает сборку при ошибке команды,
# — флаг -u помогает заметить обращение к переменной, которой ещё не задали значение.
set -eu

# Замер времени сборки. Значение можно переопределить при запуске.
if [[ -z ${BUILD_TIMING:-} ]]; then
  BUILD_TIMING=true
fi

# Относительные пути к source/ и conf/ считаются от корня проекта.
cd "$(dirname "$0")/.."

# macOS workaround @begin
# если доступен Homebrew, ставим каталог GNU sed первым в PATH для генераторов профилей.
if [[ $(uname -s) == Darwin ]] && command -v brew >/dev/null; then
  export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
fi

# Проверяем, поддерживает ли sed параметр --version. Сам вывод нам не нужен,
# поэтому скрываем и обычный вывод, и ошибки. При сбое подсказываем, как установить GNU sed.
if ! sed --version >/dev/null 2>&1; then
  echo "Нужен GNU sed. На macOS установите его командой 'brew install gnu-sed'" >&2
  exit 1
fi
# macOS workaround @end

# Для загрузки списка доменов нужен curl, для обработки строк — awk.
# Команда command -v проверяет каждую утилиту. Если её нет, сообщаем имя и завершаем сборку.
for tool in curl awk; do
  command -v "$tool" >/dev/null || { echo "Отсутствует $tool" >&2; exit 1; }
done

# Создаём папку для готовых профилей. С ключом -p команда сработает и для существующей папки.
mkdir -p conf

now_ms() {
  local nanoseconds
  nanoseconds=$(date +%s%N 2>/dev/null) || return 1
  [[ $nanoseconds =~ ^[0-9]+$ ]] || return 1
  echo "$((10#$nanoseconds / 1000000))"
}

build_profile() {
  local start_ms='' end_ms
  if [[ $BUILD_TIMING == true ]]; then
    start_ms=$(now_ms) || start_ms=''
  fi
  bash -e "tools/profiles/$1.sh"
  if [[ -n $start_ms ]] && end_ms=$(now_ms); then
    printf '  Время сборки: %d ms\n' "$((end_ms - start_ms))"
  fi
  echo
}

# --- Генерация конфигов ---
echo "Создаем sr_ru_basic.conf с заменой update-url в копии general"
build_profile sr_ru_basic

echo "Создаем sr_ru_whitelist.conf с заменой update-url в копии general"
build_profile sr_ru_whitelist

echo "Создаем sr_ru_keen.conf с заменой update-url в копии general"
build_profile sr_ru_keen

echo "Создаем sr_nonru_basic.conf с заменой update-url"
build_profile sr_nonru_basic

echo "Создаем sr_ru_mini.conf с заменой update-url и проксированием портов и telegram"
build_profile sr_ru_mini

echo "Создаем sr_ru_extended.conf без update-url и с пустыми строками после [Rule]"
build_profile sr_ru_extended

echo "Создаем sr_ru_geo.conf"
build_profile sr_ru_geo
