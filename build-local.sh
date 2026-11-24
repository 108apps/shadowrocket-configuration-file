#!/usr/bin/env bash

# Description:
# Генераторы скачивают данные и перезаписывают результаты в conf/, rules/, modules/ и scripts/
# Изменения видны в git diff
# Если шаг вернёт ошибку, сборка остановится. Уже записанные файлы сохранятся.

# -e останавливает скрипт при ошибке шага, -u выявляет обращения к незаданным переменным.
set -eu

usage() {
  echo "Использование: ./build-local.sh [--docker] [rules|scripts|modules|conf] ..."
  echo "Без параметров выполняется полная сборка."
}

if [[ $# == 1 && ( $1 == --help || $1 == -h ) ]]; then
  usage
  exit 0
fi
docker_mode=false
if [[ ${1:-} == --docker ]]; then
  docker_mode=true
  shift
fi
if [[ $# == 0 ]]; then
  # Заполняем список аргументов всеми группами, как если бы их перечислил пользователь.
  set -- rules scripts modules conf
fi
for group in "$@"; do
  case "$group" in
    rules|scripts|modules|conf) ;;
    *) echo "Неизвестная группа: $group" >&2; usage >&2; exit 2 ;;
  esac
done

# Пробелы по краям помогают искать целые имена.
# Каждый блок ниже проверяется один раз, поэтому порядок аргументов и повторы не меняют порядок сборки.
selected=" $* "
includes() {
  [[ $selected == *" $1 "* ]]
}

# Все пути в генераторах отсчитываются от корня проекта.
cd "$(dirname "$0")"

if "$docker_mode"; then
  image=shadowrocket-configuration-file/local-build
  # Передаём Docker только рецепт образа. Исходники будут доступны при запуске.
  docker build -t "$image" - < Dockerfile

  # Монтируем проект в /workspace для записи результатов на хост с UID/GID пользователя.
  # Контейнер запускает этот же скрипт без --docker.
  # После выхода --rm удалит контейнер.
  exec docker run --rm --dns 1.1.1.1 --user "$(id -u):$(id -g)" -v "$PWD:/workspace" "$image" ./build-local.sh "$@"
fi

# Здесь хранятся даты и рабочая копия шаблона YouTube.
# Каталог удаляется при выходе.
# TODO: В пути GITHUB_ENV нельзя использовать пробелы: исходный youtube_dates.sh передаёт его без кавычек.
temp=$(mktemp -d /tmp/shadowrocket-build.XXXXXXXX)
trap 'rm -rf "$temp"' EXIT
export GITHUB_ENV="$temp/dates"

# На Mac системные sed и grep отличаются от версий на сервере сборки.
# Подставляем версии Homebrew только для этого запуска.
if [[ $(uname -s) == Darwin ]]; then
  if ! command -v brew >/dev/null; then
    echo "Для сборки на macOS нужен Homebrew. См. раздел «Локальная сборка» в README.md." >&2
    exit 1
  fi
  prefix=$(brew --prefix)
  export PATH="$prefix/opt/gnu-sed/libexec/gnubin:$prefix/opt/grep/libexec/gnubin:$prefix/bin:$PATH"
fi

# Проверяем зависимости выбранных групп до первой записи в выходные каталоги.
tools=(curl sed)
if includes rules; then
  tools+=(dig python3 gawk grep)
fi
if includes modules; then
  tools+=(jq)
fi
if includes conf; then
  tools+=(awk)
fi
for tool in "${tools[@]}"; do
  if ! command -v "$tool" >/dev/null; then
    echo "Отсутствует $tool. См. раздел «Локальная сборка» в README.md." >&2
    exit 1
  fi
done
if includes modules || includes conf; then
  if ! sed --version >/dev/null 2>&1; then
    echo "Нужен GNU sed. См. README.md." >&2
    exit 1
  fi
fi
if includes rules; then
  if ! grep -P '^ok$' <<< 'ok' >/dev/null 2>&1; then
    echo "Нужен grep с поддержкой -P. См. README.md." >&2
    exit 1
  fi
  # Генераторы вызывают awk по короткому имени, но используют функции GNU awk.
  ln -s "$(command -v gawk)" "$temp/awk"
  export PATH="$temp:$PATH"
fi

# Каждый шаг выполняется в отдельном Bash, как в GitHub Actions.
# Имя в терминале помогает найти генератор, на котором остановилась сборка.
run() {
  echo "Запуск $1"
  bash -e "source/build-scripts/$1"
}

if includes rules; then
  mkdir -p rules
  run domains_geo_detect.sh
  run domain_ips.sh
  run domains_community.sh
  run domains_antifilter.sh
  run ips_antifilter.sh
  run domains_refilter.sh
  run ips_refilter.sh
  run domains_banking.sh
  run domains_ipchecker.sh
  run custom-proxy.sh
fi

if includes scripts; then
  mkdir -p scripts
  run youtube_script.sh
fi

if includes modules; then
  mkdir -p modules
  run youtube_dates.sh

  # На GitHub даты из GITHUB_ENV автоматически доступны следующему шагу.
  # Локально читаем две строки вида ИМЯ=значение и передаём даты дочернему Bash.
  while IFS='=' read -r name value; do
    case "$name" in
      YT_SCRIPT_DATE|YT_MODULE_DATE) export "$name=$value" ;;
    esac
  done < "$GITHUB_ENV"

  # Шаблон содержит обозначения GitHub Actions. В рабочей копии заменяем их
  # ссылками на переменные Bash, чтобы даты попали в заголовок модуля.
  echo "Запуск youtube_module.sh.in"
  sed -e "s/[$][{][{] env[.]YT_SCRIPT_DATE [}][}]/\${YT_SCRIPT_DATE}/g" \
      -e "s/[$][{][{] env[.]YT_MODULE_DATE [}][}]/\${YT_MODULE_DATE}/g" \
      source/build-scripts/youtube_module.sh.in > "$temp/youtube_module.sh"
  bash -e "$temp/youtube_module.sh"

  run certificate.sh
fi

if includes conf; then
  mkdir -p conf
  run sr_ru_basic.sh
  run sr_ru_whitelist.sh
  run sr_ru_keen.sh
  run sr_nonru_basic.sh
  run sr_ru_mini.sh
  run sr_ru_extended.sh
  run sr_ru_geo.sh
fi
