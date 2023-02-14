FROM golang:1.20.0-bullseye

WORKDIR /workspace

COPY go.mod go.sum Makefile ./

RUN apt update \
    && apt install -y make \
    && make install-deps-dev
