#!/bin/bash

source network/.env

DOMAIN_SUFFIX="home"
SERVICES=(qbittorrent pihole 3xui jackett)
MEDIA_SERV=(radarr sonarr lidarr downloads)

# Папки для сервисов
for svc in "${MEDIA_SERV[@]}"; do
  mkdir -p "$PATH_SERVICES/${svc}"
done
# Папки под конфиги
for svc in "${SERVICES[@]}"; do
  mkdir -p "$PATH_CONFIG/${svc}"
done

mkdir -p "$PATH_CONFIG/hysteria2"

# CA нужно установить один раз на этой машине (пропускаем, если уже сделано)
if ! mkcert -CAROOT > /dev/null 2>&1; then
  mkcert -install
fi

for svc in "${SERVICES[@]}"; do
  DIR="$PATH_CERTS/${svc}"
  mkdir -p "$DIR"
  cd "$DIR"

  echo ">>> Генерация ECDSA-сертификата для ${svc}.${DOMAIN_SUFFIX}"
  mkcert -ecdsa \
    -cert-file cert.crt \
    -key-file cert.key \
    "${svc}.${DOMAIN_SUFFIX}"

  # Конвертация в .pfx для Servarr/Jellyfin (не нужен qBittorrent — там свои .crt/.key)
  openssl pkcs12 -export -out cert.pfx \
    -inkey cert.key -in cert.crt \
    -password "pass:${PFX_PASSWORD}"

  cd - > /dev/null
done
echo ">>> Все сертификаты перевыпущены: $(date)"
