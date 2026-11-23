# Где вносить изменения

GitHub Actions берёт общие настройки из `source/General.txt`, добавляет правила из `.github/workflows/run.yml` и сохраняет готовые профили в `conf/`.

- **Общие настройки профилей** меняйте в `source/General.txt`.
- **Настройки одного профиля** меняйте в `.github/workflows/run.yml`.
    - Найдите нужный шаг по имени профиля, например `sr_ru_whitelist.conf`.

## Какие файлы перезаписывает сборка

При каждой сборке GitHub Actions **перезаписываются** файлы в папках `conf/`, `modules/`, `rules/` и `scripts/`.

Исключением являются три списка в `rules/`:

- `domains_discord.list`
- `domains_youtube.list`
- `voice_ports.list`

## Особенность форка

Сборка скачивает `source/community.list` и `source/domains.list` из исходного репозитория.

Чтобы использовать копии из своего форка, измените источник в `.github/workflows/run.yml`.
