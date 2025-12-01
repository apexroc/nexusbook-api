#!/bin/bash

# GitHub Pages 配置检查脚本

echo "======================================"
echo "  GitHub Pages 配置检查"
echo "======================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 存在"
        return 0
    else
        echo -e "${RED}✗${NC} $1 不存在"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 目录存在"
        return 0
    else
        echo -e "${RED}✗${NC} $1 目录不存在"
        return 1
    fi
}

# 1. 检查关键文件
echo "1. 检查关键配置文件"
echo "-----------------------------------"
check_file ".github/workflows/deploy-docs.yml"
check_file "docs-src/.nojekyll"
check_file "scripts/build-docs.js"
check_file "Makefile"
check_file ".gitignore"
echo ""

# 2. 检查文档目录结构
echo "2. 检查文档目录结构"
echo "-----------------------------------"
check_dir "docs-src"
check_dir "docs-src/guides"
check_dir "docs-src/references"
check_dir "docs-src/styles"
check_file "docs-src/styles/main.css"
echo ""

# 3. 检查文档源文件
echo "3. 检查文档源文件"
echo "-----------------------------------"
GUIDE_FILES=(
    "docs-src/guides/getting-started.md"
    "docs-src/guides/authentication.md"
    "docs-src/guides/document-model.md"
    "docs-src/guides/data-operations.md"
    "docs-src/guides/webhooks.md"
)

for file in "${GUIDE_FILES[@]}"; do
    check_file "$file"
done
echo ""

# 4. 检查 Git 状态
echo "4. 检查 Git 状态"
echo "-----------------------------------"
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Git 仓库已初始化"
    
    # 检查远程仓库
    REMOTE=$(git remote get-url origin 2>/dev/null)
    if [ -n "$REMOTE" ]; then
        echo -e "${GREEN}✓${NC} 远程仓库: $REMOTE"
    else
        echo -e "${RED}✗${NC} 未配置远程仓库"
    fi
    
    # 检查当前分支
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo -e "${GREEN}✓${NC} 当前分支: $BRANCH"
    
    # 检查是否有未提交的更改
    if git diff-index --quiet HEAD --; then
        echo -e "${GREEN}✓${NC} 工作目录干净，无未提交更改"
    else
        echo -e "${YELLOW}⚠${NC} 有未提交的更改"
    fi
else
    echo -e "${RED}✗${NC} 不是 Git 仓库"
fi
echo ""

# 5. 测试本地构建
echo "5. 测试本地构建"
echo "-----------------------------------"
echo -e "${YELLOW}正在测试文档构建...${NC}"

if make docs > /tmp/make-docs.log 2>&1; then
    echo -e "${GREEN}✓${NC} 文档构建成功"
    
    # 检查生成的文件
    if [ -f "docs/index.html" ]; then
        echo -e "${GREEN}✓${NC} docs/index.html 已生成"
    fi
    
    if [ -f "docs/.nojekyll" ]; then
        echo -e "${GREEN}✓${NC} docs/.nojekyll 已生成"
    fi
    
    if [ -d "docs/styles" ]; then
        echo -e "${GREEN}✓${NC} docs/styles 目录已生成"
    fi
else
    echo -e "${RED}✗${NC} 文档构建失败"
    echo "查看日志: /tmp/make-docs.log"
fi
echo ""

# 6. 检查依赖
echo "6. 检查 Node.js 依赖"
echo "-----------------------------------"
if [ -f "package.json" ]; then
    echo -e "${GREEN}✓${NC} package.json 存在"
    
    # 检查关键依赖
    DEPS=("marked" "fs-extra" "@typespec/compiler" "@redocly/cli")
    for dep in "${DEPS[@]}"; do
        if grep -q "\"$dep\"" package.json; then
            echo -e "${GREEN}✓${NC} $dep 已配置"
        else
            echo -e "${RED}✗${NC} $dep 未配置"
        fi
    done
else
    echo -e "${RED}✗${NC} package.json 不存在"
fi
echo ""

# 7. 生成报告
echo "======================================"
echo "  检查完成"
echo "======================================"
echo ""
echo "下一步操作："
echo "1. 访问 GitHub 仓库设置页面"
echo "   https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/settings/pages"
echo ""
echo "2. 在 'Build and deployment' 部分"
echo "   - Source: 选择 'GitHub Actions'"
echo "   - 点击 Save"
echo ""
echo "3. 等待 GitHub Actions 自动部署（2-5分钟）"
echo ""
echo "4. 访问文档网站："
echo "   https://$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/\//.github.io\//')/"
echo ""
echo "详细说明请查看: GITHUB_PAGES_CHECKLIST.md"
echo ""
