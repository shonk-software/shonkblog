# ---------- Builder: build Hugo site ----------
FROM docker.io/hugomods/hugo:debian-dart-sass AS builder
WORKDIR /site

COPY . .

ARG HUGO_BASEURL
ENV HUGO_BASEURL=${HUGO_BASEURL}

RUN hugo \
    --gc \
    --minify \
    --baseURL="${HUGO_BASEURL}"

CMD ["sleep", "infinity"]

# ---------- Runtime: nginx to serve the static site ----------
FROM nginx:trixie

COPY --from=builder /site/public /usr/share/nginx/html

# Replace default nginx config
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/shonkblog.conf

RUN chmod -R 755 /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -qO- http://localhost:1314/ || exit 1
