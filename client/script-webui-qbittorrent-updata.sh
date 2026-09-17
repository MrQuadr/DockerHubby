#!/usr/bin/env bash
set -euo pipefail
source network/.env

REPO="VueTorrent/VueTorrent"
VERSION_FILE="version.txt"
ASSET_PATTERN="vuetorrent.zip"

# 1. Текущая версия
current_version=$(cat "$PATH_CONFIG/qbittorrent/vuetorrent/$VERSION_FILE" 2>/dev/null || echo "0.0.0")
current_version="${current_version#v}"   # срезаем "v" если есть

# 2. Последний релиз с GitHub API
release_json=$(curl -sSL "https://api.github.com/repos/${REPO}/releases/latest")
latest_version=$(echo "$release_json" | jq -r '.tag_name')
latest_version="${latest_version#v}"

echo "Текущая: $current_version | Последняя: $latest_version"

# 3. Сравнение версий (семвер через sort -V)
if [ "$current_version" = "$latest_version" ]; then
    echo "Уже актуальная версия."
    exit 0
fi

newest=$(printf '%s\n%s\n' "$current_version" "$latest_version" | sort -V | tail -n1)
if [ "$newest" = "$current_version" ]; then
    echo "Локальная версия новее или равна — обновление не требуется."
    exit 0
fi

echo "Найдена новая версия: $latest_version. Скачиваю..."

# 4. Находим нужный asset и скачиваем
download_url=$(echo "$release_json" \
    | jq -r --arg pat "$ASSET_PATTERN" '.assets[] | select(.name | contains($pat)) | .browser_download_url')

if [ -z "$download_url" ]; then
    echo "Подходящий файл релиза не найден." >&2
    exit 1
fi

filename=$(basename "$download_url")
curl -sSL -o "$filename" "$download_url"
echo "Скачано: $filename"

rm -rf "$PATH_CONFIG/qbittorrent/vuetorrent"

unzip $ASSET_PATTERN -d "$PATH_CONFIG/qbittorrent"