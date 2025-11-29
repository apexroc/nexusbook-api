SHELL := /bin/bash
TSP := npx tsp
PORT ?= 8091

.PHONY: deps openapi build-docs serve-docs generate-go serve-go clean

deps:
	npm i -D @typespec/compiler @typespec/http @typespec/openapi3 @redocly/cli
	go mod tidy || true
	go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@latest

openapi: deps
	$(TSP) compile api/main.tsp --emit @typespec/openapi3 --output-dir dist/openapi

build-docs: openapi
	mkdir -p dist/redoc
	OPENAPI_DIR=dist/openapi/@typespec/openapi3; \
	FILES=$$(ls $$OPENAPI_DIR/*.yaml); \
	COUNT=$$(echo $$FILES | wc -w); \
	if [ $$COUNT -eq 1 ]; then \
		npx redocly build-docs $$FILES --output dist/redoc/index.html; \
	else \
		npx redocly join $$FILES -o dist/openapi/openapi.yaml && \
		npx redocly build-docs dist/openapi/openapi.yaml --output dist/redoc/index.html; \
	fi

serve-docs: build-docs
	python3 -m http.server $(PORT) -d dist/redoc || python3 -m http.server 8092 -d dist/redoc

generate-go: openapi deps
	OPENAPI_DIR=dist/openapi/@typespec/openapi3; \
	DOC_SPEC=$$(ls $$OPENAPI_DIR/openapi.NexusBook.Api.Document.yaml 2>/dev/null || true); \
	FILES=$$(ls $$OPENAPI_DIR/*.yaml); \
	TARGET=dist/openapi/openapi.yaml; \
	mkdir -p server/apigen; \
	if [ -n "$$DOC_SPEC" ]; then \
		oapi-codegen -generate types,gin -package apigen -o server/apigen/apigen.gen.go $$DOC_SPEC; \
	else \
		npx redocly join $$FILES -o $$TARGET && \
		oapi-codegen -generate types,gin -package apigen -o server/apigen/apigen.gen.go $$TARGET; \
	fi

serve-go: generate-go
	go run ./cmd/server

clean:
	rm -rf dist tsp-output

serve-docs: build-docs
