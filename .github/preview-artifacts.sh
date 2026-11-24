#!/usr/bin/env bash
# Останавливаем скрипт при ошибке команды, в том числе внутри конвейера, или при обращении к незаданной переменной.
set -euo pipefail

# Все пути ниже считаются от корня проекта, даже если скрипт вызвали из подпапки.
cd "$(git rev-parse --show-toplevel)"
branch=$(git symbolic-ref --short HEAD)
remote=$(git remote get-url origin)

# Для gh нужен адрес вида владелец/репозиторий. Убираем из адреса origin префикс SSH или HTTPS, а затем суффикс .git.
case "$remote" in
  git@github.com:*) repo=${remote#git@github.com:} ;;
  https://github.com/*) repo=${remote#https://github.com/} ;;
  ssh://git@github.com/*) repo=${remote#ssh://git@github.com/} ;;
  *) echo "Unsupported GitHub origin: $remote" >&2; exit 1 ;;
esac
repo=${repo%.git}

directories=(conf modules rules scripts)

# Проверяем папки, куда скопируем результат. Даже новый файл может совпасть по имени с файлом из архива.
if [[ -n $(git status --porcelain --untracked-files=all -- "${directories[@]}") ]]; then
  echo "Commit or stash local changes in the artifact directories first." >&2
  exit 1
fi

# GitHub собирает версию текущей ветки, которая уже отправлена в origin.
run_url=$(gh workflow run generate-artifacts.yml --repo "$repo" --ref "$branch")

# Из ссылки вида …/actions/runs/123 извлекаем номер 123. Bash сохраняет совпадение из скобок в BASH_REMATCH[1].
if [[ ! $run_url =~ /actions/runs/([0-9]+)/?$ ]]; then
  echo "GitHub did not return a run URL: $run_url" >&2
  exit 1
fi
run_id=${BASH_REMATCH[1]}
echo "$run_url"

# Ждём именно этот запуск. Флаг --exit-status остановит скрипт, если сборка завершится неудачно.
gh run watch "$run_id" --repo "$repo" --exit-status

# gh распакует архив во временную папку. trap удалит её при выходе, в том числе после ошибки.
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT
gh run download "$run_id" --repo "$repo" --name shadowrocket-files --dir "$temp_dir"

# До копирования проверяем наличие всех четырёх папок, чтобы неполный архив не обновил проект частично.
for directory in "${directories[@]}"; do
  [[ -d "$temp_dir/$directory" ]] || { echo "Missing artifact directory: $directory" >&2; exit 1; }
done

for directory in "${directories[@]}"; do
  # Слеш в конце пути означает «содержимое папки». Сравниваем файлы по содержимому и сохраняем локальные файлы, которых нет в архиве.
  rsync -r --checksum "$temp_dir/$directory/" "$directory/"
done

# status покажет и новые файлы, а diff — изменения в уже отслеживаемых файлах.
git status --short -- "${directories[@]}"
git diff -- "${directories[@]}"
