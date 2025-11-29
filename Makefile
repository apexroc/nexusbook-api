SHELL := /bin/bash
TSP := npx tsp

.PHONY: deps openapi preview-api preview-auth preview-redoc-api preview-redoc-auth build-redoc-api build-redoc-auth redoc-deps serve-redoc-api serve-redoc-auth clean

deps:
	npm i -D @typespec/compiler @typespec/http @typespec/openapi3

openapi: deps
	$(TSP) compile api/main.api.tsp --emit @typespec/openapi3 --output-dir dist/api
	$(TSP) compile api/main.auth.tsp --emit @typespec/openapi3 --output-dir dist/auth

preview-api: deps
	$(TSP) preview api/main.api.tsp

preview-auth: deps
	$(TSP) preview api/main.auth.tsp

clean:
	rm -rf dist tsp-output

redoc-deps:
	npm i -D @redocly/cli

build-redoc-api: openapi redoc-deps
	npx redocly build-docs dist/api/@typespec/openapi3/openapi.yaml --output dist/redoc/api.html

build-redoc-auth: openapi redoc-deps
	npx redocly build-docs dist/auth/@typespec/openapi3/openapi.yaml --output dist/redoc/auth.html

serve-redoc-api: build-redoc-api
	python3 -m http.server 8088 -d dist/redoc

serve-redoc-auth: build-redoc-auth
	python3 -m http.server 8089 -d dist/redoc
