SHELL := /bin/bash
TSP := npx tsp
PORT ?= 8091

.PHONY: deps openapi build-docs serve-docs clean docs serve clean-docs

deps:
	npm i -D @typespec/compiler @typespec/http @typespec/openapi3 @redocly/cli

openapi: deps
	$(TSP) compile api/main.tsp --emit @typespec/openapi3 --output-dir dist/openapi
	@echo "Adding x-tagGroups to OpenAPI..."
	@node scripts/add-tag-groups.js

build-docs: openapi
	mkdir -p dist/redoc
	OPENAPI_DIR=dist/openapi/@typespec/openapi3; \
	FILES=$$(ls $$OPENAPI_DIR/*.yaml); \
	COUNT=$$(echo $$FILES | wc -w); \
	if [ $$COUNT -eq 1 ]; then \
		npx redocly build-docs $$FILES --output dist/redoc/index.html; \
	else \
		npx redocly join $$FILES --without-x-tag-groups -o dist/openapi/openapi.yaml && \
		node scripts/add-tag-groups.js dist/openapi/openapi.yaml && \
		npx redocly build-docs dist/openapi/openapi.yaml --output dist/redoc/index.html; \
	fi

serve-docs: build-docs
	python3 -m http.server $(PORT) -d dist/redoc || python3 -m http.server 8092 -d dist/redoc

clean:
	rm -rf dist tsp-output

# 文档站点构建目标
DOCS_DIR := docs
DOCS_PORT ?= $(PORT)

# 构建完整文档站点
docs: build-docs
	@echo "Building documentation site..."
	@mkdir -p $(DOCS_DIR)/api $(DOCS_DIR)/guides $(DOCS_DIR)/references $(DOCS_DIR)/styles
	@# 复制 API 文档
	@if [ -f dist/redoc/index.html ]; then cp dist/redoc/index.html $(DOCS_DIR)/api/index.html; fi
	@if [ -f dist/openapi/openapi.yaml ]; then cp dist/openapi/openapi.yaml $(DOCS_DIR)/api/openapi.yaml; fi
	@# 生成文档主页和内容
	@node scripts/build-docs.js
	@echo "Documentation site built successfully!"

# 启动文档服务
serve: docs
	@echo "Starting documentation server on port $(DOCS_PORT)..."
	@echo "Visit: http://localhost:$(DOCS_PORT)"
	@python3 -m http.server $(DOCS_PORT) -d $(DOCS_DIR) || python -m http.server $(DOCS_PORT) -d $(DOCS_DIR)

# 清理文档（仅删除生成的 HTML，保留 Markdown 源文件）
clean-docs:
	@rm -rf $(DOCS_DIR)
