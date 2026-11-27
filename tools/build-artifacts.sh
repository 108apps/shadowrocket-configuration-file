#!/usr/bin/env bash

# Останавливаем скрипт при ошибке команды, в том числе внутри конвейера, или при обращении к незаданной переменной.
set -euo pipefail

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

# Временная папка создаётся позже. trap удалит её при выходе, в том числе после ошибки.
temp_dir=
trap 'if [[ -n $temp_dir ]]; then rm -rf "$temp_dir"; fi' EXIT

# Проверяем зависимости до запуска сборки, чтобы не ждать её зря.
for cmd in git gh rsync realpath; do
  command -v "$cmd" >/dev/null || die "Required command not found: $cmd"
done
gh auth status --hostname github.com >/dev/null 2>&1 || die "Run 'gh auth login' first."

echo "Starting Shadowrocket artifact build..."

# Относительные пути считаются от корня проекта.
# realpath раскрывает символическую ссылку на скрипт, а git rev-parse находит корень репозитория.
cd "$(git -C "$(dirname "$(realpath "$0")")" rev-parse --show-toplevel)"
branch_ref=$(git symbolic-ref --quiet HEAD) || die "Check out a branch first: HEAD is detached."
branch=${branch_ref#refs/heads/}
local_sha=$(git rev-parse HEAD)
remote=$(git remote get-url origin)

# Для gh нужен адрес вида владелец/репозиторий. Убираем из адреса origin префикс SSH или HTTPS, а затем суффикс .git.
case "$remote" in
  git@github.com:*) repo=${remote#git@github.com:} ;;
  https://github.com/*) repo=${remote#https://github.com/} ;;
  ssh://git@github.com/*) repo=${remote#ssh://git@github.com/} ;;
  *) die "Unsupported GitHub origin: $remote" ;;
esac
repo=${repo%.git}

directories=(conf modules rules scripts)

require_original_checkout() {
  if [[ $(git symbolic-ref --quiet HEAD) != "$branch_ref" || $(git rev-parse HEAD) != "$local_sha" ]]; then
    die "The local branch or HEAD changed during the build."
  fi

  # Git может считать рабочую копию чистой даже во время незавершённой операции.
  local state state_path
  for state in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-apply rebase-merge sequencer; do
    state_path=$(git rev-parse --git-path "$state")
    [[ ! -e $state_path ]] || die "Finish the Git operation in progress before building artifacts ($state)."
  done
}

require_clean_worktree() {
  local status
  status=$(git status --porcelain --untracked-files=all --ignore-submodules=none)
  [[ -z $status ]] || die "The working tree must be clean. Commit or stash local changes and untracked files first."
}

require_original_checkout
require_clean_worktree

# Сравниваем с веткой на сервере: локальная ссылка origin/<ветка> может быть устаревшей.
# ls-remote может вернуть и другие ссылки, оканчивающиеся таким же путём.
if ! remote_sha=$(git ls-remote --exit-code origin "$branch_ref" |
  awk -F '\t' -v ref="$branch_ref" '$2 == ref { print $1 }') || [[ -z $remote_sha ]]; then
  die "Could not verify origin/$branch on the server."
fi
[[ $local_sha == "$remote_sha" ]] || die "Local HEAD ($local_sha) differs from origin/$branch ($remote_sha)."

# GitHub собирает версию текущей ветки, которая уже отправлена в origin.
run_url=$(gh workflow run build-artifacts.yml --repo "$repo" --ref "$branch")

# Из ссылки вида …/actions/runs/123 извлекаем номер 123. Bash сохраняет совпадение из скобок в BASH_REMATCH[1].
[[ $run_url =~ /actions/runs/([0-9]+)/?$ ]] || die "GitHub did not return a run URL: $run_url"
run_id=${BASH_REMATCH[1]}
echo "$run_url"

# Ветка на сервере могла измениться между проверкой SHA и запуском сборки.
# GitHub фиксирует коммит запуска сразу при создании, поэтому проверяем его до ожидания сборки.
run_sha=$(gh run view "$run_id" --repo "$repo" --json headSha --jq .headSha)
[[ $run_sha == "$local_sha" ]] || die "GitHub is building $run_sha, but the expected commit was $local_sha."

# Ждём именно этот запуск. Флаг --exit-status остановит скрипт, если сборка завершится неудачно.
gh run watch "$run_id" --repo "$repo" --exit-status

# gh распакует архив во временную папку.
temp_dir=$(mktemp -d)
gh run download "$run_id" --repo "$repo" --name shadowrocket-files --dir "$temp_dir"

# До копирования проверяем наличие всех четырёх папок, чтобы неполный архив не обновил проект частично.
for directory in "${directories[@]}"; do
  [[ -d "$temp_dir/$directory" ]] || die "Missing artifact directory: $directory"
done

# Сборка может занять несколько минут. Перед копированием повторно проверяем рабочую копию.
require_original_checkout
require_clean_worktree

for directory in "${directories[@]}"; do
  # Слеш в конце пути означает «содержимое папки». Сравниваем файлы по содержимому.
  # Без --delete локальные файлы, которых нет в архиве, сохраняются. Это сделано намеренно и отличается от
  # build-and-publish.yml: если сборка удалит файл, CI закоммитит удаление, а этот скрипт оставит файл на месте.
  rsync -r --checksum "$temp_dir/$directory/" "$directory/"
done

require_original_checkout
git add -A -- "${directories[@]}"
if git diff --cached --quiet -- "${directories[@]}"; then
  echo "Artifacts are unchanged."
else
  git commit -m "Manual: обновление сгенерированных файлов [skip ci]"
fi
