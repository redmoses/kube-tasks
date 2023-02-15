FROM golang:1.19.6-alpine3.17 as builder
RUN apk --no-cache add ca-certificates
WORKDIR /app
ADD . /app
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64
RUN go mod download \
    && go build -o bin/kube-tasks cmd/kube-tasks.go

FROM alpine:3.17 as final
COPY --from=builder /app/bin/kube-tasks /usr/local/bin/kube-tasks
RUN addgroup -g 1001 -S kube-tasks \
    && adduser -u 1001 -D -S -G kube-tasks kube-tasks
USER kube-tasks
WORKDIR /home/kube-tasks
CMD ["kube-tasks"]
