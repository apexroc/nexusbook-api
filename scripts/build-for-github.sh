#!/bin/bash

# GitHub Pages 部署构建脚本
# 设置 BASE_PATH 为 /nexusbook-api/

echo "🚀 构建用于 GitHub Pages 的文档..."

# 设置环境变量
export BASE_PATH="/nexusbook-api/"

# 构建文档
npm run build-docs

echo "✅ 构建完成！文档已针对 GitHub Pages 进行优化"
echo "📦 部署路径: https://apexroc.github.io/nexusbook-api/"
