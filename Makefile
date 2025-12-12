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
		npx @redocly/cli build-docs $$FILES \
			--config=redocly.yaml \
			--output dist/redoc/index.html; \
	else \
		npx redocly join $$FILES --without-x-tag-groups -o dist/openapi/openapi.yaml && \
		node scripts/add-tag-groups.js dist/openapi/openapi.yaml && \
		npx @redocly/cli build-docs dist/openapi/openapi.yaml \
			--config=redocly.yaml \
			--output dist/redoc/index.html; \
	fi
	@echo "✅ API 文档已生成"

serve-docs: build-docs
	npx http-server dist/redoc -p $(PORT) -o

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
	@npx http-server $(DOCS_DIR) -p $(DOCS_PORT) -o

# 清理文档(仅删除生成的 HTML,保留 Markdown 源文件)
clean-docs:
	@rm -rf $(DOCS_DIR)

# K3s 部署相关命令
DOCKER_REGISTRY ?= ghcr.io/apexroc
IMAGE_NAME ?= nexusbook-api-docs
VERSION ?= latest
NAMESPACE ?= nexusbook

# 构建 Docker 镜像
docker-build:
	@echo "Building Docker image..."
	docker build -t $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(VERSION) .
	@echo "✅ Docker image built: $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(VERSION)"

# 推送 Docker 镜像
docker-push:
	@echo "Pushing Docker image..."
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(VERSION)
	@echo "✅ Docker image pushed: $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(VERSION)"

# 构建并推送镜像
docker-release: docker-build docker-push

# 部署到 K3s
k3s-deploy:
	@echo "Deploying to K3s cluster..."
	@kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	@export DOCKER_REGISTRY=$(DOCKER_REGISTRY) VERSION=$(VERSION) && \
		cat deployment/k3s-deployment.yaml | envsubst | kubectl apply -f -
	@kubectl rollout status deployment/nexusbook-api-docs -n $(NAMESPACE) --timeout=5m
	@echo "✅ Deployment successful!"

# 查看 K3s 部署状态
k3s-status:
	@echo "Deployment Status:"
	@kubectl get deployment nexusbook-api-docs -n $(NAMESPACE)
	@echo ""
	@echo "Pods:"
	@kubectl get pods -n $(NAMESPACE) -l app=nexusbook-api-docs
	@echo ""
	@echo "Service:"
	@kubectl get service nexusbook-api-docs -n $(NAMESPACE)
	@echo ""
	@echo "Ingress:"
	@kubectl get ingress nexusbook-api-docs -n $(NAMESPACE)

# 查看日志
k3s-logs:
	@kubectl logs -n $(NAMESPACE) -l app=nexusbook-api-docs --tail=100 -f

# 删除 K3s 部署
k3s-delete:
	@echo "Deleting K3s deployment..."
	@kubectl delete -f deployment/k3s-deployment.yaml -n $(NAMESPACE) || true
	@echo "✅ Deployment deleted"

# 完整的发布流程: 构建镜像 -> 推送镜像 -> 部署到 K3s
release: docker-release k3s-deploy k3s-status
