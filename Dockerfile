FROM --platform=$BUILDPLATFORM golang:1.25-alpine AS build

ARG VERSION=2.1.18
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
RUN apk add --no-cache ca-certificates
WORKDIR /src
ADD https://github.com/DNSCrypt/dnscrypt-proxy/archive/refs/tags/${VERSION}.tar.gz /tmp/src.tar.gz
RUN tar -xzf /tmp/src.tar.gz --strip-components=1
WORKDIR /src/dnscrypt-proxy
ENV CGO_ENABLED=0
RUN case "${TARGETARCH}${TARGETVARIANT}" in \
      armv7) export GOARM=7 ;; \
      armv6) export GOARM=6 ;; \
    esac \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
       go build -trimpath -ldflags="-s -w" -o /out/dnscrypt-proxy .

COPY ./dnscrypt-proxy.toml /tmp/dnscrypt-proxy.toml

RUN mkdir -p /opt/dnscrypt-proxy \
	&& cp /out/dnscrypt-proxy /opt/dnscrypt-proxy/dnscrypt-proxy \
    && chmod +x /opt/dnscrypt-proxy/dnscrypt-proxy \
    && cp /tmp/dnscrypt-proxy.toml /opt/dnscrypt-proxy/dnscrypt-proxy.toml


FROM scratch

#RUN addgroup -S dnscrypt && adduser -S -D -H -G dnscrypt dnscrypt \
#    && apk add --no-cache ca-certificates

#COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /opt/dnscrypt-proxy /opt/dnscrypt-proxy

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/opt/dnscrypt-proxy/dnscrypt-proxy"]
CMD ["-config", "/opt/dnscrypt-proxy/dnscrypt-proxy.toml"]
