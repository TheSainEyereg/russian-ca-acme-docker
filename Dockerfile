FROM alpine:latest AS builder

RUN apk add --no-cache \
    build-base \
    linux-headers \
    wget \
    tar \
    && rm -rf /var/cache/apk/*

RUN wget -q -O /tmp/7z-src.tar.gz https://github.com/ip7z/7zip/archive/refs/tags/26.02.tar.gz \
    && tar -xzf /tmp/7z-src.tar.gz -C /tmp \
    && cd /tmp/7zip-26.02/CPP/7zip/Bundles/Alone2 \
    && make -j$(nproc) -f makefile.gcc \
        CXXFLAGS_EXTRA="-static-libstdc++ -static-libgcc" \
        LDFLAGS_STATIC_2="-static -static-libstdc++ -static-libgcc" \
    && cp _o/7zz /usr/local/bin/7zz \
    && chmod +x /usr/local/bin/7zz \
    && file /usr/local/bin/7zz


FROM alpine:latest

COPY --from=builder /usr/local/bin/7zz /usr/local/bin/7zz

RUN apk add --no-cache \
    bash \
    curl \
    wget \
    ca-certificates \
    cronie \
    openssl \
    idn2-utils \
    && rm -rf /var/cache/apk/*

# Скачивание корневого сертификата Минцифры
RUN wget -q -O /usr/local/share/ca-certificates/russian_trusted_root_ca_pem.crt https://gu-st.ru/content/lending/russian_trusted_root_ca_pem.crt

# Скачивание выпускающих сертификатов Минцифры
RUN wget -q -O /tmp/russian_trusted_sub_ca_pem.zip https://gu-st.ru/content/lending/russian_trusted_sub_ca_pem.zip \
    && 7zz x /tmp/russian_trusted_sub_ca_pem.zip -o/usr/local/share/ca-certificates/ -y > /dev/null \
    && rm /usr/local/share/ca-certificates/russian_trusted_sub_ca_gost*.crt

# Обновление хранилища доверенных сертификатов
RUN update-ca-certificates 2>/dev/null || true

# Скачивание кастомного acme.sh с портала НУЦ
RUN wget -q -O /tmp/acme_client_fix.rar https://nuc.voskhod.ru/api/instructions/9/get-document/ \
    && 7zz x /tmp/acme_client_fix.rar -o/opt/acme.sh/ -y > /dev/null \
    && chmod +x /opt/acme.sh/acme.sh

RUN mkdir -p /var/www/html /certs /.acme.sh

ENV LE_WORKING_DIR="/.acme.sh"
ENV PATH="/.acme.sh:${PATH}"

RUN echo "0 3 * * * root /.acme.sh/acme.sh --cron --home /.acme.sh >> /var/log/acme-cron.log 2>&1" \
    > /etc/cron.d/acme \
    && chmod 0644 /etc/cron.d/acme

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["crond", "-n", "-s"]
