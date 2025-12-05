#!/bin/bash

# 验证文档链接的正确性

echo "🔍 验证文档链接..."
echo ""

# 检查是否已构建
if [ ! -d "docs" ]; then
  echo "❌ docs 目录不存在，请先运行构建命令"
  exit 1
fi

# 检测 BASE_PATH
if grep -q 'href="/nexusbook-api/' docs/index.html; then
  BASE_PATH="/nexusbook-api/"
  echo "✓ 检测到 GitHub Pages 模式 (BASE_PATH=/nexusbook-api/)"
elif grep -q 'href="/index.html"' docs/index.html; then
  BASE_PATH="/"
  echo "✓ 检测到本地开发模式 (BASE_PATH=/)"
else
  echo "❌ 无法检测 BASE_PATH"
  exit 1
fi

echo ""
echo "📋 验证主要链接..."

# 验证主页链接
echo -n "  - 主页导航链接... "
if [ "$BASE_PATH" = "/nexusbook-api/" ]; then
  if grep -q 'href="/nexusbook-api/index.html"' docs/index.html; then
    echo "✓"
  else
    echo "❌"
  fi
else
  if grep -q 'href="/index.html"' docs/index.html; then
    echo "✓"
  else
    echo "❌"
  fi
fi

# 验证 API 文档链接
echo -n "  - API 文档链接... "
if [ "$BASE_PATH" = "/nexusbook-api/" ]; then
  if grep -q 'href="/nexusbook-api/api/index.html"' docs/index.html; then
    echo "✓"
  else
    echo "❌"
  fi
else
  if grep -q 'href="/api/index.html"' docs/index.html; then
    echo "✓"
  else
    echo "❌"
  fi
fi

# 验证开发指南链接
echo -n "  - 开发指南链接... "
if [ "$BASE_PATH" = "/nexusbook-api/" ]; then
  if grep -q 'href="/nexusbook-api/guides/getting-started.html"' docs/index.html; then
    echo "✓"
  else
    echo "❌"
  fi
else
  if grep -q 'href="/guides/getting-started.html"' docs/index.html; then
    echo "✓"
  else
    echo "❌"
  fi
fi

# 验证侧边栏链接
if [ -f "docs/guides/getting-started.html" ]; then
  echo -n "  - Sidebar logo 链接... "
  if [ "$BASE_PATH" = "/nexusbook-api/" ]; then
    if grep -q 'sidebar-logo">NexusBook API</a>' docs/guides/getting-started.html && \
       grep -q 'href="/nexusbook-api/index.html"' docs/guides/getting-started.html; then
      echo "✓"
    else
      echo "❌"
    fi
  else
    if grep -q 'sidebar-logo">NexusBook API</a>' docs/guides/getting-started.html && \
       grep -q 'href="/index.html"' docs/guides/getting-started.html; then
      echo "✓"
    else
      echo "❌"
    fi
  fi
fi

# 验证 CSS 路径
echo -n "  - CSS 相对路径... "
if grep -q 'href="styles/main.css' docs/index.html && \
   grep -q 'href="../styles/main.css' docs/guides/getting-started.html 2>/dev/null; then
  echo "✓"
else
  echo "❌"
fi

echo ""
echo "✅ 验证完成！"

if [ "$BASE_PATH" = "/nexusbook-api/" ]; then
  echo ""
  echo "📦 GitHub Pages 部署检查清单:"
  echo "  1. ✓ 已使用 npm run build-for-github 构建"
  echo "  2. □ 提交 docs/ 目录到 Git"
  echo "  3. □ 推送到 GitHub"
  echo "  4. □ 检查 GitHub Pages 设置 (Settings > Pages)"
  echo "  5. □ 访问 https://apexroc.github.io/nexusbook-api/ 验证"
fi
