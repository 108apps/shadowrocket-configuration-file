# Генераторы запускаются в одинаковом окружении Linux на macOS и Linux.
FROM ubuntu:24.04

# Обновляем список пакетов перед установкой.
# dnsutils предоставляет команду dig,
# ca-certificates нужен для проверки HTTPS,
# tzdata содержит часовые пояса для дат.
# noninteractive отключает вопросы установщика, например о выборе часового пояса.
# Удаляем списки пакетов в том же слое, чтобы уменьшить размер образа.
RUN apt-get -o Acquire::Retries=3 update \
    && DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
        bash ca-certificates curl dnsutils gawk grep jq python3 sed tzdata \
    && rm -rf /var/lib/apt/lists/*

# Здесь начнётся выполнение ./build-local.sh. Скрипт на хосте подключает сюда репозиторий.
WORKDIR /workspace
