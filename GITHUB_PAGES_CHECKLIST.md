# GitHub Pages 配置检查清单

## ✅ 本地配置检查

### 1. GitHub Actions 工作流文件
- [x] `.github/workflows/deploy-docs.yml` 已创建
- [x] 配置了 `pages: write` 权限
- [x] 设置了 `github-pages` 环境
- [x] 使用 `actions/upload-pages-artifact@v3`
- [x] 使用 `actions/deploy-pages@v4`

### 2. 必要文件
- [x] `docs-src/.nojekyll` 已创建（禁用 Jekyll）
- [x] `scripts/build-docs.js` 构建脚本已创建
- [x] `Makefile` 包含 `docs` 和 `serve` 命令
- [x] `.gitignore` 忽略 `docs/` 目录

### 3. 文档结构
- [x] `docs-src/` 源文件目录
- [x] `docs-src/guides/` 开发指南
- [x] `docs-src/references/` 参考文档
- [x] `docs-src/styles/main.css` 样式文件

### 4. 代码已提交
- [x] 所有文件已提交到 Git
- [x] 代码已推送到 `origin/main`

---

## 🔧 在 GitHub 上启用 Pages

### 方法 1: 通过网页界面

1. **访问仓库设置**
   ```
   https://github.com/apexroc/nexusbook-api/settings/pages
   ```

2. **配置 Source**
   - 在 "Build and deployment" 部分
   - **Source**: 选择 `GitHub Actions`
   - 点击 **Save** 保存

3. **等待部署**
   - GitHub Actions 会自动运行
   - 首次部署需要 2-5 分钟

### 方法 2: 检查 Actions 状态

访问 Actions 页面查看工作流运行状态：
```
https://github.com/apexroc/nexusbook-api/actions
```

查看是否有 "Deploy Documentation to GitHub Pages" 工作流运行。

---

## 🔍 检查部署状态

### 1. 查看 Actions 日志

在仓库的 **Actions** 标签页：
- 查看最近的工作流运行
- 确认 `build` 和 `deploy` 两个任务都成功
- 绿色 ✓ 表示成功，红色 ✗ 表示失败

### 2. 查看 Pages 状态

在 **Settings > Pages** 页面：
- 查看 "Your site is live at" 消息
- 记录文档网站 URL

### 3. 访问文档网站

部署成功后，访问：
```
https://apexroc.github.io/nexusbook-api/
```

---

## 🐛 常见问题排查

### 问题 1: 404 Not Found

**症状**: 访问网站显示 404 错误

**解决方案**:
1. 确认 `.nojekyll` 文件存在
2. 检查 GitHub Pages 设置中 Source 是否选择 "GitHub Actions"
3. 等待几分钟，部署需要时间
4. 检查 Actions 日志确认部署成功

### 问题 2: 样式丢失

**症状**: 页面显示但没有样式

**解决方案**:
1. 确认 `docs-src/styles/main.css` 存在
2. 检查构建日志中是否有 "✓ 复制样式文件"
3. 本地运行 `make docs` 测试构建
4. 检查生成的 `docs/styles/main.css` 是否存在

### 问题 3: Actions 构建失败

**症状**: GitHub Actions 显示红色 ✗

**解决方案**:
1. 点击失败的工作流查看详细日志
2. 检查 Node.js 依赖是否正确安装
3. 确认 `package.json` 包含所需依赖：
   ```json
   {
     "devDependencies": {
       "@typespec/compiler": "^1.6.0",
       "@typespec/http": "^1.6.0",
       "@typespec/openapi3": "^1.6.0",
       "@redocly/cli": "^2.12.0",
       "marked": "latest",
       "fs-extra": "latest"
     }
   }
   ```
4. 本地运行 `make docs` 确认可以成功构建

### 问题 4: 权限错误

**症状**: Actions 提示权限不足

**解决方案**:
1. 检查 `.github/workflows/deploy-docs.yml` 中的 permissions 配置
2. 确认包含：
   ```yaml
   permissions:
     contents: read
     pages: write
     id-token: write
   ```

---

## 📋 手动触发部署

如果自动部署没有运行，可以手动触发：

1. 访问 Actions 页面
   ```
   https://github.com/apexroc/nexusbook-api/actions
   ```

2. 点击左侧的 "Deploy Documentation to GitHub Pages"

3. 点击右侧的 "Run workflow" 按钮

4. 选择分支（默认 main）

5. 点击绿色的 "Run workflow" 按钮

---

## 🧪 本地测试

在推送到 GitHub 之前，先在本地测试：

```bash
# 清理旧文件
make clean-docs

# 构建文档
make docs

# 启动本地服务器
make serve

# 访问 http://localhost:8091
```

检查：
- [ ] 首页能正常访问
- [ ] 导航链接正常工作
- [ ] 样式正确显示
- [ ] API 文档可以访问
- [ ] 所有指南文档可以打开
- [ ] 参考文档可以访问

---

## 📊 验证清单

### 部署成功的标志

- [ ] GitHub Actions 工作流全部通过（绿色 ✓）
- [ ] Settings > Pages 显示 "Your site is live"
- [ ] 可以访问文档网站 URL
- [ ] 首页正常显示
- [ ] 所有链接都能正常跳转
- [ ] 样式正确加载
- [ ] API 文档（Redoc）可以访问
- [ ] Mermaid 图表正常渲染

---

## 🔗 快速链接

| 项目 | URL |
|------|-----|
| **仓库首页** | https://github.com/apexroc/nexusbook-api |
| **Actions** | https://github.com/apexroc/nexusbook-api/actions |
| **Settings** | https://github.com/apexroc/nexusbook-api/settings |
| **Pages 设置** | https://github.com/apexroc/nexusbook-api/settings/pages |
| **文档网站** | https://apexroc.github.io/nexusbook-api/ |

---

## 📞 获取帮助

如果遇到问题：

1. 查看 [GitHub Pages 文档](https://docs.github.com/en/pages)
2. 查看 [GitHub Actions 文档](https://docs.github.com/en/actions)
3. 检查本项目的 [GITHUB_PAGES.md](docs-src/GITHUB_PAGES.md)
4. 在仓库中提交 Issue

---

**当前状态**: ✅ 本地配置完成，等待在 GitHub 上启用 Pages
