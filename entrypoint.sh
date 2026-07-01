#!/bin/bash
set -e

if [ ! -f "/.acme.sh/acme.sh" ]; then
    ACME_EMAIL="${ACME_EMAIL:-admin@example.com}"

    echo "==> Первоначальная установка acme.sh..."
    cd /opt/acme.sh
    ./acme.sh --install \
        --no-cron \
        --home /.acme.sh

    echo "==> Установка НУЦ как CA по-умолчанию..."
    ./acme.sh --set-default-ca --server https://nuc-acme.voskhod.ru/acme/api/v1/directory
    echo "==> Регистрация почты в НУЦ (${ACME_EMAIL})..."
    ./acme.sh --register-account --email "${ACME_EMAIL}" --accountkeylength 2048
    echo "==> acme.sh установлен."
else
    echo "==> acme.sh уже установлен в /.acme.sh"
fi

echo "==> Запуск cron для автообновления сертификатов..."

exec "$@"
