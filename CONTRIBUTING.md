# Локальная сборка

Команда `./build-local.sh` собирает все профили в `conf/`. Также поддерживается `./build-local.sh conf`.
Для сборки в Docker выполните `./build-local.sh --docker`.

Генераторы профилей находятся в `source/build-scripts/sr_*.sh` и используют общий шаблон `source/General.txt`.
Они запускаются последовательно, поскольку используют общий временный файл.
Для профиля `sr_ru_mini.conf` скрипт скачивает `source/community.list` из ветки `main` исходного репозитория.

Для сборки без Docker нужны Bash, GNU sed, curl и awk. На macOS GNU sed можно установить командой `brew install gnu-sed`.

Правила, модули и файл `scripts/rewrite.youtube.response.preview.js` собираются непосредственно в `.github/workflows/run.yml`.

Следующие файлы не перезаписываются скриптами сборки:

- `rules/domains_discord.list`
- `rules/domains_youtube.list`
- `rules/voice_ports.list`
