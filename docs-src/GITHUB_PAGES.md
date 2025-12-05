# GitHub Pages 部署配置

## 📦 部署概述

本项目支持部署到 GitHub Pages,文档站点会部署到子路径 `/nexusbook-api/`。

**在线访问**: https://apexroc.github.io/nexusbook-api/

## 🚀 部署步骤

### 1. 构建文档

使用专门的 GitHub Pages 构建命令:

```bash
npm run build-for-github
```

这会:
- 设置 `BASE_PATH=/nexusbook-api/`
- 生成包含正确路径前缀的静态文件到 `docs/` 目录
- 所有内部链接会自动添加 `/nexusbook-api/` 前缀

### 2. 提交并推送

```bash
git add docs/
git commit -m "docs: update GitHub Pages documentation"
git push origin main
```

### 3. GitHub Pages 设置

在 GitHub 仓库设置中:
1. 进入 Settings > Pages
2. Source 选择 `main` 分支
3. 目录选择 `/docs`
4. 保存

## 🔧 技术实现

### BASE_PATH 环境变量

构建脚本支持通过 `BASE_PATH` 环境变量控制路径前缀:

- **本地开发**: `BASE_PATH=/` (默认)
  ```bash
  npm run build-docs
  # 或
  make docs
  ```

- **GitHub Pages**: `BASE_PATH=/nexusbook-api/`
  ```bash
  npm run build-for-github
  # 或
  BASE_PATH="/nexusbook-api/" npm run build-docs
  ```

### resolvePath() 函数

在 `scripts/build-docs.js` 中,所有链接都通过 `resolvePath()` 函数生成:

```javascript
function resolvePath(relativePath) {
  if (BASE_PATH === '/') {
    return '/' + relativePath.replace(/^\//, '');
  }
  return BASE_PATH.replace(/\/$/, '') + '/' + relativePath.replace(/^\//, '');
}
```

这确保了:
- 主页链接: `/nexusbook-api/index.html`
- 导航链接: `/nexusbook-api/guides/getting-started.html`
- Sidebar链接: `/nexusbook-api/api/index.html`
- CSS等资源使用相对路径,自动适配

## 📝 注意事项

1. **不要手动编辑 `docs/` 目录**: 该目录由构建脚本自动生成
2. **使用正确的构建命令**: GitHub Pages 部署前必须使用 `npm run build-for-github`
3. **提交构建产物**: `docs/` 目录需要提交到 Git,因为 GitHub Pages 从此目录读取静态文件
4. **.nojekyll 文件**: 已自动生成,告诉 GitHub Pages 不要用 Jekyll 处理文件

## 🔍 验证部署

部署后,检查以下链接是否正常工作:

- ✅ 主页: https://apexroc.github.io/nexusbook-api/
- ✅ API文档: https://apexroc.github.io/nexusbook-api/api/index.html
- ✅ 开发指南: https://apexroc.github.io/nexusbook-api/guides/getting-started.html
- ✅ 侧边栏导航: 所有链接应该正确跳转
- ✅ CSS样式: 样式应该正常加载

## 🐛 常见问题

### 问题: 页面显示但样式丢失

**原因**: CSS 文件路径不正确

**解决**: 
- 确保使用了 `npm run build-for-github` 构建
- 检查生成的 HTML 中 CSS 路径应为相对路径 `../styles/main.css`

### 问题: 点击链接跳转到错误的页面

**原因**: 使用了错误的 BASE_PATH

**解决**: 
1. 删除 `docs/` 目录
2. 运行 `npm run build-for-github` 重新构建
3. 检查生成的 HTML 中链接应包含 `/nexusbook-api/` 前缀

### 问题: 404 错误

**原因**: GitHub Pages 配置不正确

**解决**: 
- 检查 GitHub 仓库 Settings > Pages 设置
- 确认源分支是 `main`
- 确认目录是 `/docs`
- 确认 `.nojekyll` 文件存在于 `docs/` 目录

## 📚 相关文档

- [开发指南](guides/development.md)
- [项目架构](guides/architecture.md)
- [GitHub Pages 官方文档](https://docs.github.com/en/pages)
