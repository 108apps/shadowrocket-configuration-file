# Локальная сборка

Команда `./build-local.sh conf` собирает все профили в `conf/`.

Генераторы профилей находятся в `source/build-scripts/sr_*.sh` и используют общий шаблон `source/General.txt`.
Они запускаются последовательно, поскольку используют общий временный файл.

PR compatibility workaround:<br>
Для профиля `sr_ru_mini.conf` скрипт скачивает `source/community.list` из ветки `main` исходного репозитория.

Следующие файлы не перезаписываются скриптами сборки:

- `rules/domains_discord.list`
- `rules/domains_youtube.list`
- `rules/voice_ports.list`
