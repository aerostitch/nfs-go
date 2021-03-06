DC=docker-compose -f resources/docker-compose.yml
GOFILES_NOVENDOR=$(shell find . -type f -name '*.go' -not -path "./vendor/*")

default: go-dep go-lint test

build:
	@echo "building nothing"

dev:
	@echo "deploy dev something"

stg:
	@echo "deploy staging something"

prd:
	@echo "deploy prd something"

slack_success:
	$(DC) run --rm success

slack_failure:
	$(DC) run --rm failure

# for local builds
go-dep:
	@go get github.com/Masterminds/glide \
		&& go install github.com/Masterminds/glide
	@if [ -f "glide.yaml" ] ; then \
		glide install --strip-vendor; \
	else \
		go get -v ./...; \
	fi

go-fmt:
	@[ $$(gofmt -l $(GOFILES_NOVENDOR) | wc -l) -gt 0 ] && echo "Code differs from gofmt's style" && exit 1 || true

go-lint: go-fmt
	@go get github.com/golang/lint/golint; \
	if [ -f "glide.yaml" ] ; then \
		golint $(GO_EXTRAFLAGS) -set_exit_status $$(glide novendor); \
	else \
		golint $(GO_EXTRAFLAGS) -set_exit_status ./...; \
	fi
	@if [ -f "glide.yaml" ] ; then \
		go vet -v $$(glide novendor); \
	else \
		go vet -v ./...; \
	fi

test:
	@if [ -f "glide.yaml" ] ; then \
		go test $$(glide novendor); \
	else \
		go test $(GO_EXTRAFLAGS) -v ./...; \
	fi

go-build: go-dep go-lint test
	go clean -v
	go build -v $(GOFLAGS)
