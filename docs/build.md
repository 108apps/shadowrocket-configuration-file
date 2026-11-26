# Сборка Shadowrocket

## Проверка workflow GitHub Actions

Установите `actionlint` командой `brew install actionlint` и запустите `actionlint` из корня репозитория.

## Локальная сборка `conf/`

`./tools/build-shadowrocket-conf.sh`

Скрипты `tools/profiles/sr_*.sh` запускаются последовательно, используют шаблон `source/General.txt` из рабочей копии и перезаписывают одноимённые профили в `conf/`.

## Полная сборка через GitHub Actions

`./tools/preview-artifacts.sh`

Скрипт через `gh` запускает `build-artifacts.yml` для текущей ветки в `origin`. Перед запуском закоммитьте и отправьте изменения, которые хотите проверить, и учтите [источники доменных списков](#источники-доменных-списков).

После сборки скрипт копирует файлы из артефакта `shadowrocket-files` в `conf/`, `modules/`, `rules/` и `scripts/` и выводит `git status --short` и `git diff`.

Если в этих папках есть незакоммиченные изменения или неотслеживаемые файлы, скрипт остановится до запуска сборки.

## Источники доменных списков

Исходный репозиторий для этих списков — `misha-tgshv/shadowrocket-configuration-file`.

- При локальной сборке и в CI генератор `sr_ru_mini.conf` скачивает `source/community.list` из ветки `main` исходного репозитория.
- Для `domains_community.list` и `domain_ips.list` CI скачивает соответственно `source/community.list` и `source/domains.list` из той же ветки. Предпросмотр в форке использует эти версии списков даже после отправки изменений в ветку форка.

## Списки, которые сохраняются при сборке

Скрипты сборки сохраняют следующие файлы.

- `rules/domains_discord.list`
- `rules/domains_youtube.list`
- `rules/voice_ports.list`

## Известные проблемы

См. [известные проблемы сборки](build-issues.md).
