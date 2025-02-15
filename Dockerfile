FROM --platform=$BUILDPLATFORM golang:1.21-alpine as builder

# Convert TARGETPLATFORM to GOARCH format
# https://github.com/tonistiigi/xx
COPY --from=tonistiigi/xx:golang / /

ARG TARGETPLATFORM

RUN apk add --no-cache musl-dev git gcc

ADD . /src

WORKDIR /src

ENV GO111MODULE=on

RUN cd cmd/gost && go env && go build

FROM alpine:latest

# add iptables for tun/tap
RUN apk add --no-cache iptables

WORKDIR /bin/

COPY --from=builder /src/cmd/gost/gost .

# ENTRYPOINT ["/bin/gost"]
CMD ["gost", "-L=tcp://:443/tongue.thepargar.site:443", "-L=tcp://:80/tongue.thepargar.site:80"]
