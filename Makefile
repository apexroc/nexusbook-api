SHELL := /bin/bash
TSP := npx tsp
PORT ?= 8091

.PHONY: deps openapi build-docs serve-docs clean

deps:
	npm i -D @typespec/compiler @typespec/http @typespec/openapi3 @redocly/cli

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

clean:
	rm -rf dist tsp-output

serve-docs: build-docs
