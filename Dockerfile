FROM --platform=$BUILDPLATFORM golang:1.26 as builder

WORKDIR /go/src/github.com/sstarcher/helm-exporter
COPY . /go/src/github.com/sstarcher/helm-exporter
RUN go mod download

ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -o /go/bin/helm-exporter /go/src/github.com/sstarcher/helm-exporter/main.go

FROM alpine:3.24
RUN apk --update add ca-certificates
RUN apk update && apk upgrade openssl zlib busybox
RUN addgroup -S helm-exporter && adduser -S -G helm-exporter helm-exporter
USER helm-exporter
COPY --from=builder /go/bin/helm-exporter /usr/local/bin/helm-exporter

ENTRYPOINT ["helm-exporter"]
