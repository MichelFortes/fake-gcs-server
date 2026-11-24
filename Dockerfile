# Copyright 2019 Francisco Souza. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM --platform=$BUILDPLATFORM golang:1.27 AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /code
ADD go.mod go.sum ./
RUN go mod download
ADD . ./
ENV CGO_ENABLED=0
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o fake-gcs-server

FROM alpine:3.24.1
RUN apk add --no-cache mailcap
COPY --from=builder /code/fake-gcs-server /bin/fake-gcs-server
RUN /bin/fake-gcs-server -h
EXPOSE 4443
ENTRYPOINT ["/bin/fake-gcs-server", "-data", "/data"]
