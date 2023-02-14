SOURCE_FILES ?= $(shell find . -type d \( -name dist -o -name .git \) -prune -o -type f -name '*.go' -print)

GIT_REVISION ?= $(shell git rev-parse --short HEAD)
GIT_TAG ?= $(shell git describe --tags --abbrev=0 | sed -e s/v//g)

OUTPUT ?= dist/devcontainer-go

GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
GOPATH ?= $(shell go env GOPATH)
GOBUILD ?= GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go build
GOLANGCI_LINT_VERSION ?= latest

LDFLAGS ?= '-s -w \
	-X "github.com/ks6088ts-labs/devcontainer-go/internal.Revision=$(GIT_REVISION)" \
	-X "github.com/ks6088ts-labs/devcontainer-go/internal.Version=$(GIT_TAG)" \
'

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

.PHONY: install-deps-dev
install-deps-dev: ## install dependencies for development
	@which golangci-lint || curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(GOPATH)/bin $(GOLANGCI_LINT_VERSION)
	@which cobra-cli || go install github.com/spf13/cobra-cli@latest
	go install -v golang.org/x/tools/gopls@latest

.PHONY: format
format: ## format codes
	gofmt -s -w $(SOURCE_FILES)

.PHONY: lint
lint: ## lint
	golangci-lint run -v

.PHONY: test
test: ## run tests
	go test -cover -v ./...

.PHONY: build
build: ## build applications
	$(GOBUILD) -ldflags=$(LDFLAGS) -o $(OUTPUT) .

.PHONY: ci-test
ci-test: install-deps-dev lint build test ## run CI test
