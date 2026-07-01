# Docker container for obtaining Russian certificates via ACME

## Why?
**TL;DR:** Cuz I was borded.

Ironically, `Russian Trusted CA` isn't trusted by anyone (except for Russian Linux distributions and the Yandex browser), so there's no point in using it. My goal was to test ACME and create a secure environment for obtaining Russian certificates (if you ever need them), so that you wouldn't have to install `Russian Trusted CA` on your host system

## How do I use it?
1. Clone this repo
2. Run `docker compose build`
3. Copy `.env.example` to `.env` and enter your email in `ACME_EMAIL`
4. Run `docker compose up -d`

## How do I obtain certificates?
```bash
docker compose exec acme-nuc acme.sh \
    --issue \
    --domain example.com \
    --webroot /var/www/html \
    --keylength 2048 \
    --force \
    --always-force-new-domain-key
```
You'll figure out the rest by yourself