FROM openresty/openresty:1.27.1.2-4-alpine-fat

ENV LAPIS_VERSION=1.16.0

RUN apk add openssl-dev git
RUN apk --no-cache add findutils
RUN apk --no-cache add coreutils
RUN opm get spacewander/luafilesystem
RUN luarocks install luasec
RUN luarocks install busted
RUN luarocks install lapis ${LAPIS_VERSION}
RUN luarocks install moonscript

WORKDIR /srv/lapis

CMD lapis server $ENVIRONMENT
