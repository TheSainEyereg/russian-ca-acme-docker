# Docker container for obtaining Russian certificates via ACME

## Why?
**TL;DR:** Cuz I was borded.

Ironically, `Russian Trusted CA` isn't trusted by anyone (except for Russian Linux distributions and the Yandex browser), so there's no point in using it. My goal was to test ACME and create a secure environment for obtaining Russian certificates (if you ever need them), so that you wouldn't have to install `Russian Trusted CA` on your host system

## How do I use it?

### Pre-built image

Via docker CLI:

```bash
# replace `admin@example.com` with your email
ACME_EMAIL=admin@example.com docker run -d \
    --name acme-nuc \
    --restart unless-stopped \
    -v /var/www/html:/var/www/html \
    -v ./certs:/.acme.sh \
    ghcr.io/thesaineyereg/russian-ca-acme-docker
```

Via docker-compose:

```bash
cat <<EOF > docker-compose.yml
services:
  acme-nuc:
    image: ghcr.io/thesaineyereg/russian-ca-acme-docker:latest
    container_name: acme-nuc
    restart: unless-stopped
    volumes:
      - /var/www/html:/var/www/html
      - ./certs:/.acme.sh
    environment:
      - ACME_EMAIL
EOF

# replace `admin@example.com` with your email
echo "ACME_EMAIL=admin@example.com" > .env

docker compose up -d
```

### Building from source
1. Clone this repo
2. Run `docker compose build`
3. Create `.env` with your email in `ACME_EMAIL`
4. Run `docker compose up -d`

## How do I obtain certificates?
```bash
docker exec acme-nuc acme.sh \
    --issue \
    --domain example.com \
    --webroot /var/www/html \
    --keylength 2048 \
    --force \
    --always-force-new-domain-key
```
You'll figure out the rest by yourself