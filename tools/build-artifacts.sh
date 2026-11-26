#!/usr/bin/env bash

# Останавливаем скрипт при ошибке команды, в том числе внутри конвейера, или при обращении к незаданной переменной.
set -euo pipefail

echo "Starting Shadowrocket artifact build..."

# Относительные пути считаются от корня проекта, в котором лежит скрипт.
cd "$(dirname "$0")/.."
branch_ref=$(git symbolic-ref HEAD)
branch=${branch_ref#refs/heads/}
local_sha=$(git rev-parse HEAD)
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

require_original_checkout() {
  if [[ $(git symbolic-ref --quiet HEAD) != "$branch_ref" || $(git rev-parse HEAD) != "$local_sha" ]]; then
    echo "The local branch or HEAD changed during the build." >&2
    exit 1
  fi

  # Git может считать рабочую копию чистой даже во время незавершённой операции.
  local state state_path
  for state in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-apply rebase-merge sequencer; do
    state_path=$(git rev-parse --git-path "$state")
    if [[ -e $state_path ]]; then
      echo "Finish the Git operation in progress before building artifacts ($state)." >&2
      exit 1
    fi
  done
}

require_clean_worktree() {
  local status
  status=$(git status --porcelain --untracked-files=all --ignore-submodules=none)
  if [[ -n $status ]]; then
    echo "The working tree must be clean. Commit or stash local changes and untracked files first." >&2
    exit 1
  fi
}

require_original_checkout
require_clean_worktree

# Сравниваем с веткой на сервере: локальная ссылка origin/<ветка> может быть устаревшей.
# ls-remote может вернуть и другие ссылки, оканчивающиеся таким же путём.
if ! remote_sha=$(git ls-remote --exit-code origin "$branch_ref" |
  awk -F '\t' -v ref="$branch_ref" '$2 == ref { print $1 }') || [[ -z $remote_sha ]]; then
  echo "Could not verify origin/$branch on the server." >&2
  exit 1
fi
if [[ $local_sha != "$remote_sha" ]]; then
  echo "Local HEAD ($local_sha) differs from origin/$branch ($remote_sha)." >&2
  exit 1
fi

# GitHub собирает версию текущей ветки, которая уже отправлена в origin.
run_url=$(gh workflow run build-artifacts.yml --repo "$repo" --ref "$branch")

# Из ссылки вида …/actions/runs/123 извлекаем номер 123. Bash сохраняет совпадение из скобок в BASH_REMATCH[1].
if [[ ! $run_url =~ /actions/runs/([0-9]+)/?$ ]]; then
  echo "GitHub did not return a run URL: $run_url" >&2
  exit 1
fi
run_id=${BASH_REMATCH[1]}
echo "$run_url"

# Ждём именно этот запуск. Флаг --exit-status остановит скрипт, если сборка завершится неудачно.
gh run watch "$run_id" --repo "$repo" --exit-status

# Ветка на сервере могла измениться между проверкой SHA и запуском сборки.
run_sha=$(gh run view "$run_id" --repo "$repo" --json headSha --jq .headSha)
if [[ $run_sha != "$local_sha" ]]; then
  echo "GitHub built $run_sha, but the expected commit was $local_sha." >&2
  exit 1
fi

# gh распакует архив во временную папку. trap удалит её при выходе, в том числе после ошибки.
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT
gh run download "$run_id" --repo "$repo" --name shadowrocket-files --dir "$temp_dir"

# До копирования проверяем наличие всех четырёх папок, чтобы неполный архив не обновил проект частично.
for directory in "${directories[@]}"; do
  [[ -d "$temp_dir/$directory" ]] || { echo "Missing artifact directory: $directory" >&2; exit 1; }
done

# Сборка может занять несколько минут. Перед копированием повторно проверяем рабочую копию.
require_original_checkout
require_clean_worktree

for directory in "${directories[@]}"; do
  # Слеш в конце пути означает «содержимое папки». Сравниваем файлы по содержимому и сохраняем локальные файлы, которых нет в архиве.
  rsync -r --checksum "$temp_dir/$directory/" "$directory/"
done

require_original_checkout
git add -- "${directories[@]}"
artifact_changes=$(git diff --cached --name-only -- "${directories[@]}")
if [[ -n $artifact_changes ]]; then
  git commit --only -m "build: update Shadowrocket artifacts" -- "${directories[@]}"
else
  echo "Artifacts are unchanged."
fi
