# Сборка Shadowrocket

## Проверка workflow GitHub Actions

Установите `actionlint` командой `brew install actionlint` и запустите `actionlint` из корня репозитория.

## Локальная сборка `conf/`

`./tools/build-shadowrocket-conf.sh`

Скрипты `tools/profiles/sr_*.sh` запускаются последовательно, используют шаблон `source/General.txt` из рабочей копии и перезаписывают одноимённые профили в `conf/`.

## Полная сборка через GitHub Actions

`./tools/build-artifacts.sh`

Для запуска `build-artifacts.yml` используйте версию GitHub CLI, в которой `gh workflow run` возвращает URL запуска. [Справка GitHub CLI](https://cli.github.com/manual/gh_workflow_run).

Перед запуском проверьте состояние репозитория.

- Завершите текущие операции Git, например слияние или `rebase`.
- Убедитесь, что в индексе и рабочей копии нет изменений и неотслеживаемых файлов. Файлы, которые Git игнорирует, допустимы.
- Убедитесь, что SHA локального `HEAD` совпадает с SHA текущей ветки на сервере `origin`.

После сборки скрипт проверяет её SHA и копирует файлы из артефакта `shadowrocket-files` в `conf/`, `modules/`, `rules/` и `scripts/`. Если файлы изменились, скрипт коммитит только артефакты. Коммит остаётся локальным.

Учитывайте [источники доменных списков](#источники-доменных-списков).

## Источники доменных списков

Исходный репозиторий для этих списков — `misha-tgshv/shadowrocket-configuration-file`.

- При локальной сборке и в CI генератор `sr_ru_mini.conf` скачивает `source/community.list` из ветки `main` исходного репозитория.
- Для `domains_community.list` и `domain_ips.list` CI скачивает соответственно `source/community.list` и `source/domains.list` из той же ветки. Сборка в форке использует эти версии списков даже после отправки изменений в ветку форка.

## Списки, которые сохраняются при сборке

Скрипты сборки сохраняют следующие файлы.

- `rules/domains_discord.list`
- `rules/domains_youtube.list`
- `rules/voice_ports.list`

## Известные проблемы

См. [известные проблемы сборки](build-issues.md).
