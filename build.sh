#!/usr/bin/env bash

# — флаг -e останавливает сборку при ошибке команды,
# — флаг -u помогает заметить обращение к переменной, которой ещё не задали значение.
set -eu

# Принимаем только один аргумент со значением conf.
if [[ $# -ne 1 || ${1:-} != conf ]]; then
  # Пишем подсказку в поток ошибок (>&2). Код 2 означает ошибку в аргументах запуска.
  echo "Использование: ./build.sh conf" >&2
  exit 2
fi

# $0 — путь к скрипту. Переходим в его каталог, чтобы найти source/ и conf/
# даже при запуске из другой папки.
cd "$(dirname "$0")"

# macOS workaround @begin
# если доступен Homebrew, ставим каталог GNU sed первым в PATH, чтобы build-scripts нашли его раньше системного sed.
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

build_profile() {
  local profile=$1
  echo "Сборка ${profile}.conf"
  # Запускаем скрипт с именем профиля в отдельном Bash.
  # Передаём -e и ему, чтобы ошибка в генераторе прервала сборку.
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
