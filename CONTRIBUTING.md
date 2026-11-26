# CONTRIBUTING.md

## Валидация ./github/*.yml локально на машине

Установка: `brew install actionlint`

Валидация: `actionlint`

# Локальная сборка conf/

Команда `./build-shadowrocket-conf.sh` собирает все профили в `conf/`.

Генераторы профилей находятся в `source/build-scripts/sr_*.sh` и используют общий шаблон `source/General.txt`.<br>
Они запускаются последовательно, поскольку используют общий временный файл.

### Особенности проекта

#1<br>
Для профиля `sr_ru_mini.conf` скрипт скачивает `source/community.list` из ветки `main` исходного репозитория.

#2<br>
Следующие файлы не перезаписываются скриптами сборки:

- `rules/domains_discord.list`
- `rules/domains_youtube.list`
- `rules/voice_ports.list`

