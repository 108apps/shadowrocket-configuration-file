# CONTRIBUTING.md

Перед подготовкой pull request желательно ознакомиться с данным документом.

## Локальная сборка

Выполните команду `./build-local.sh`

При каждой сборке **перезаписываются** файлы в папках `./conf`, `./modules`, `./rules` и `./scripts`.<br>
В git изменения не фиксируется.

Этапы сборки запускаются последовательно, т.к. используются общие временные файлы.

Для выборочной сборки выполните:<br>
`./build-local.sh conf`<br>
`./build-local.sh modules`<br>
`./build-local.sh rules`<br>
`./build-local.sh scripts`<br>

При запуске `./build-local.sh conf` используется общий шаблон `./source/General.txt`

Если на macOS ошибка выполнения `./build-local.sh`, установите недостающие компоненты `brew install gnu-sed grep gawk jq`.

### Сборка в Docker

С запущенным Docker выполните `./build-local.sh --docker` для полной сборки или, например, `./build-local.sh --docker scripts modules` для выборочной.

## Особенности сборки

### #1
Скачиваются файлы `source/community.list` и `source/domains.list` из ветки `main` оригинального репозитория.

| Название файла          | Где присутствует хардкод                                                                                                | Что аффектит                  |
|-------------------------|-------------------------------------------------------------------------------------------------------------------------|-------------------------------|
| `source/community.list` | [domains_community.sh](source/build-scripts/domains_community.sh) и [sr_ru_mini.sh](source/build-scripts/sr_ru_mini.sh) | `./build-local.sh rules conf` |
| `source/domains.list`   | [domain_ips.sh](source/build-scripts/domain_ips.sh)                                                                     | `./build-local.sh rules`      |

### #2

Следующие файлы не перезаписываются скриптами сборки:

- `rules/domains_discord.list`
- `rules/domains_youtube.list`
- `rules/voice_ports.list`
