# GitHub Pages 部署故障排查

## 问题 1: Jekyll 处理错误

### 错误信息

```
github-pages 232 | Error: No such file or directory @ dir_chdir0 - /github/workspace/docs
```

### 原因分析

GitHub Pages 默认使用 Jekyll 静态站点生成器处理文件。即使我们创建了 `.nojekyll` 文件，如果该文件不在正确的位置或构建过程中丢失，GitHub Pages 仍然会尝试用 Jekyll 处理 `docs` 目录。

错误日志显示：
- Jekyll 正在尝试处理文件
- 找不到 `/github/workspace/docs` 目录
- 这意味着 `.nojekyll` 文件没有生效

### 解决方案

#### 1. 确保 `.nojekyll` 文件存在

**位置 1**: 源文件目录
```
docs-src/.nojekyll
```

**位置 2**: 构建输出目录
```
docs/.nojekyll
```

#### 2. 验证构建脚本

确保 `scripts/build-docs.js` 正确复制了 `.nojekyll` 文件：

```javascript
// 复制 .nojekyll 文件（GitHub Pages 需要）
const nojekyllSource = path.join(DOCS_SRC_DIR, '.nojekyll');
const nojekyllTarget = path.join(DOCS_DIR, '.nojekyll');
if (await fs.pathExists(nojekyllSource)) {
  await fs.copy(nojekyllSource, nojekyllTarget);
  console.log('✓ 复制 .nojekyll 文件');
}
```

#### 3. GitHub Actions 工作流验证

在 `.github/workflows/deploy-docs.yml` 中添加验证步骤：

```yaml
- name: Verify .nojekyll file
  run: |
    if [ ! -f docs/.nojekyll ]; then
      echo "Creating .nojekyll file"
      touch docs/.nojekyll
    fi
    echo "Contents of docs directory:"
    ls -la docs/
```

这个步骤会：
- 检查 `.nojekyll` 文件是否存在
- 如果不存在，创建它
- 列出 `docs` 目录内容，便于调试

### 验证修复

#### 本地验证

```bash
# 清理旧文件
make clean-docs

# 重新构建
make docs

# 检查文件
ls -la docs/.nojekyll

# 应该看到：
# -rw-r--r-- 1 user group 0 Dec 2 00:00 docs/.nojekyll
```

#### GitHub Actions 验证

1. 推送代码后，访问 Actions 页面
   ```
   https://github.com/apexroc/nexusbook-api/actions
   ```

2. 查看最新的工作流运行

3. 展开 "Verify .nojekyll file" 步骤

4. 应该看到：
   ```
   Contents of docs directory:
   total XX
   drwxr-xr-x  8 runner docker  256 Dec  2 00:00 .
   drwxr-xr-x 23 runner docker  736 Dec  2 00:00 ..
   -rw-r--r--  1 runner docker    0 Dec  2 00:00 .nojekyll
   ...
   ```

---

## 问题 2: 样式文件丢失

### 错误表现

- 页面显示但没有样式
- 网页看起来只有纯文本

### 原因分析

Jekyll 可能会忽略以下划线开头的目录（如 `_site`），或者样式文件路径不正确。

### 解决方案

1. **确保样式文件被复制**
   
   检查 `docs/styles/main.css` 是否存在：
   ```bash
   ls -la docs/styles/main.css
   ```

2. **验证 HTML 中的引用**
   
   检查生成的 HTML 文件中样式引用是否正确：
   ```html
   <link rel="stylesheet" href="styles/main.css">
   <!-- 或 -->
   <link rel="stylesheet" href="../styles/main.css">
   ```

3. **浏览器开发者工具检查**
   
   - 按 F12 打开开发者工具
   - 查看 Console 是否有 404 错误
   - 检查 Network 标签，查看 CSS 文件是否加载成功

---

## 问题 3: 404 错误

### 错误表现

访问 `https://username.github.io/repository-name/` 显示 404

### 可能原因

1. GitHub Pages 未启用
2. 部署尚未完成
3. 仓库名称或用户名错误
4. 工作流构建失败

### 解决方案

#### 1. 检查 Pages 设置

访问：`https://github.com/username/repository-name/settings/pages`

确认：
- Source 设置为 "GitHub Actions"
- 显示 "Your site is live at ..." 消息

#### 2. 检查工作流状态

访问：`https://github.com/username/repository-name/actions`

确认：
- 最新的工作流运行成功（绿色 ✓）
- 两个任务都完成：`build` 和 `deploy`

#### 3. 等待几分钟

首次部署或更新后，GitHub Pages 需要几分钟才能生效。

#### 4. 验证 URL

确保访问的 URL 正确：
```
https://username.github.io/repository-name/
```

对于本项目：
```
https://apexroc.github.io/nexusbook-api/
```

---

## 问题 4: Mermaid 图表不显示

### 错误表现

文档中的流程图、架构图等 Mermaid 图表不显示

### 原因分析

Mermaid 需要 JavaScript 支持，可能是：
1. Mermaid 库未加载
2. 代码块格式不正确
3. JavaScript 被禁用

### 解决方案

1. **确认 Mermaid 库已引入**
   
   检查生成的 HTML 是否包含：
   ```html
   <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
   <script>
     mermaid.initialize({ startOnLoad: true, theme: 'default' });
   </script>
   ```

2. **验证代码块格式**
   
   Markdown 中应该使用：
   ````markdown
   ```mermaid
   graph TD
       A[开始] --> B[结束]
   ```
   ````

3. **检查浏览器控制台**
   
   查看是否有 JavaScript 错误

---

## 问题 5: 权限错误

### 错误信息

```
Error: Resource not accessible by integration
```

### 原因分析

GitHub Actions 没有足够的权限部署到 Pages。

### 解决方案

1. **检查工作流权限配置**
   
   `.github/workflows/deploy-docs.yml` 应包含：
   ```yaml
   permissions:
     contents: read
     pages: write
     id-token: write
   ```

2. **检查仓库设置**
   
   在 Settings > Actions > General 中：
   - Workflow permissions: 选择 "Read and write permissions"
   - 或确保 "Allow GitHub Actions to create and approve pull requests" 已勾选

---

## 调试技巧

### 1. 查看完整的 Actions 日志

```
https://github.com/apexroc/nexusbook-api/actions
```

点击失败的工作流 > 展开每个步骤 > 查看详细日志

### 2. 本地完整测试

```bash
# 完整的构建流程
make clean
make deps
make openapi
make build-docs
make docs

# 检查生成的文件
ls -la docs/
cat docs/.nojekyll
ls -la docs/styles/
ls -la docs/api/
```

### 3. 使用检查脚本

```bash
bash scripts/check-github-pages.sh
```

这会自动检查所有配置和执行本地构建测试。

### 4. 启用调试日志

在 GitHub Actions 中，可以启用调试模式：
1. 进入仓库 Settings > Secrets and variables > Actions
2. 添加一个新的 secret：
   - Name: `ACTIONS_STEP_DEBUG`
   - Value: `true`

---

## 常用命令

```bash
# 本地构建和预览
make docs && make serve

# 清理并重新构建
make clean-docs && make docs

# 运行配置检查
bash scripts/check-github-pages.sh

# 查看 Git 状态
git status

# 查看最近的提交
git log --oneline -5

# 强制推送（谨慎使用）
git push -f origin main
```

---

## 快速参考

| 问题 | 快速解决 |
|------|----------|
| Jekyll 错误 | 确保 `docs/.nojekyll` 存在 |
| 样式丢失 | 检查 `docs/styles/main.css` |
| 404 错误 | 启用 GitHub Pages，等待部署 |
| Mermaid 不显示 | 检查 Mermaid 库引用 |
| 权限错误 | 配置工作流权限 |

---

## 获取帮助

如果问题仍未解决：

1. 查看 [GitHub Pages 文档](https://docs.github.com/en/pages)
2. 查看 [GitHub Actions 文档](https://docs.github.com/en/actions)
3. 在仓库中创建 Issue
4. 参考 `GITHUB_PAGES_CHECKLIST.md`
