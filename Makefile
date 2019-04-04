HAS_DEP := $(shell command -v dep;)
DEP_VERSION := v0.5.1
GIT_TAG := $(shell git describe --tags --always)
GIT_COMMIT := $(shell git rev-parse --short HEAD)
LDFLAGS := "-X main.GitTag=${GIT_TAG} -X main.GitCommit=${GIT_COMMIT}"
DIST := $(CURDIR)/dist
DOCKER_USER := $(shell printenv DOCKER_USER)
DOCKER_PASSWORD := $(shell printenv DOCKER_PASSWORD)
TRAVIS := $(shell printenv TRAVIS)
TAG := v0.0.1

all: bootstrap build docker push

dev: build mac docker 

prod: bootstrap build mac docker push

mac: fmt vet 
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -ldflags $(LDFLAGS) -o $(GOPATH)/bin/cain $(GOPATH)/src/github.com/prem0132/cain/cmd/cain.go

fmt:
	go fmt ./pkg/... ./cmd/...

vet:
	go vet ./pkg/... ./cmd/...

# Build cain binary
build: fmt vet
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags $(LDFLAGS) -o bin/cain $(GOPATH)/src/github.com/prem0132/cain/cmd/cain.go

# Build hecuba docker image
docker:
	cp bin/hecuba hecuba
	docker build -t premhashmap/hecuba:$(TAG) .
	rm hecuba


# Push will only happen in travis ci
push:
	sudo docker login -u $(USERNAME) -p $(PASSWORD)
	docker push premhashmap/hecuba:$(TAG)


bootstrap:
ifndef HAS_DEP
	wget -q -O $(GOPATH)/bin/dep https://github.com/golang/dep/releases/download/$(DEP_VERSION)/dep-linux-amd64
	chmod +x $(GOPATH)/bin/dep
endif
	dep ensure

dist:
	mkdir -p $(DIST)
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags $(LDFLAGS) -o hecuba hecuba.go
	tar -zcvf $(DIST)/hecuba-linux-$(GIT_TAG).tgz hecuba
	rm hecuba
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -ldflags $(LDFLAGS) -o hecuba hecuba.go
	tar -zcvf $(DIST)/hecuba-macos-$(GIT_TAG).tgz hecuba
	rm hecuba
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -ldflags $(LDFLAGS) -o hecuba.exe hecuba.go
	tar -zcvf $(DIST)/hecuba-windows-$(GIT_TAG).tgz hecuba.exe
	rm hecuba.exe


