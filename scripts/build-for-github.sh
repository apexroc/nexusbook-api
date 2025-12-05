#!/bin/bash

# GitHub Pages 部署构建脚本
# 设置 BASE_PATH 为 /nexusbook-api/

echo "🚀 构建用于 GitHub Pages 的文档..."

# 设置环境变量
export BASE_PATH="/nexusbook-api/"

# 构建 OpenAPI 和 Redoc
# 1) 生成 OpenAPI（TypeSpec -> OpenAPI3）
npx tsp compile api --emit @typespec/openapi3 --output-dir dist/openapi

# 2) 添加 x-tagGroups
node scripts/add-tag-groups.js dist/openapi/openapi.yaml

# 3) 构建 Redoc 单页文档
mkdir -p docs/api
npx @redocly/cli build-docs dist/openapi/openapi.yaml --output docs/api/index.html

# 4) 构建站点（带 BASE_PATH）
npm run build-docs

echo "✅ 构建完成！文档已针对 GitHub Pages 进行优化"
echo "📦 部署路径: https://apexroc.github.io/nexusbook-api/"
