#!/bin/bash

# GitHub Pages 部署构建脚本
# 设置 BASE_PATH 为 /nexusbook-api/

set -euo pipefail

echo "🚀 构建用于 GitHub Pages 的文档..."

# 设置环境变量
export BASE_PATH="/nexusbook-api/"

# 构建 OpenAPI 和 Redoc
# 1) 生成 OpenAPI（TypeSpec -> OpenAPI3）
npx tsp compile api --emit @typespec/openapi3 --output-dir dist/openapi

# 2) 选择实际生成的 OpenAPI 路径（不同环境的 emitter 输出路径可能不同）
OPENAPI_FILE=""
for candidate in \
  "dist/openapi/openapi.yaml" \
  "dist/openapi/@typespec/openapi3/openapi.yaml" \
  "dist/openapi/@typespec/openapi3/openapi.NexusBook.Api.yaml"; do
  if [ -f "$candidate" ]; then
    OPENAPI_FILE="$candidate"
    break
  fi
done

if [ -z "$OPENAPI_FILE" ]; then
  echo "❌ 未找到 OpenAPI 输出文件，请检查 TypeSpec 编译配置"
  exit 1
fi

echo "🗂 使用 OpenAPI 文件: $OPENAPI_FILE"

# 3) 添加 x-tagGroups
node scripts/add-tag-groups.js "$OPENAPI_FILE"

# 4) 构建 Redoc 单页文档
mkdir -p docs/api
npx @redocly/cli build-docs "$OPENAPI_FILE" --output docs/api/index.html

# 5) 构建站点（带 BASE_PATH）
npm run build-docs

echo "✅ 构建完成！文档已针对 GitHub Pages 进行优化"
echo "📦 部署路径: https://apexroc.github.io/nexusbook-api/"
