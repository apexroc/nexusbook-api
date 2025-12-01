# 文档贡献指南

感谢您对 NexusBook API 文档的贡献！

## 📁 目录结构说明

本项目采用**源文件和生成文件分离**的架构：

```
├── docs-src/          # ✅ 源文件目录（提交到 Git）
│   ├── guides/        # 开发指南 Markdown 源文件
│   └── references/    # 参考文档 Markdown 源文件
│
├── docs/              # ❌ 生成目录（不提交到 Git，已加入 .gitignore）
│   ├── guides/        # 自动生成的 HTML
│   ├── references/    # 自动生成的 HTML
│   ├── api/           # 自动生成的 OpenAPI 文档
│   └── styles/        # 样式文件
│
└── scripts/
    └── build-docs.js  # 文档构建脚本
```

## ✏️ 如何编辑文档

### 1. 编辑 Markdown 源文件

**只编辑 `docs-src/` 目录下的文件**：

```bash
# 编辑开发指南
vim docs-src/guides/getting-started.md

# 编辑参考文档
vim docs-src/references/error-codes.md
```

### 2. 重新生成文档

```bash
make docs
```

这个命令会：
- 编译 TypeSpec 生成 OpenAPI 规范
- 使用 Redocly 生成 API 文档
- 将 Markdown 转换为 HTML
- 生成文档站点主页

### 3. 本地预览

```bash
make serve
```

访问 http://localhost:8091 查看生成的文档。

## 📝 添加新文档

### 添加新的开发指南

1. 在 `docs-src/guides/` 创建新的 Markdown 文件：
   ```bash
   touch docs-src/guides/new-guide.md
   ```

2. 编辑 `scripts/build-docs.js`，添加配置：
   ```javascript
   const guides = [
     // ...现有文档
     { file: 'new-guide', title: '新指南标题' }
   ];
   ```

3. 重新生成文档：
   ```bash
   make docs
   ```

4. 在主页添加链接（可选）：
   编辑 `scripts/build-docs.js` 中的 `generateHomePage()` 函数。

### 添加新的参考文档

步骤同上，但是在 `references` 数组中添加配置。

## 🎨 修改样式

样式文件位于 `docs/styles/main.css`，可以直接编辑。

主要使用 CSS 变量定义主题：
```css
:root {
  --primary-color: #1976d2;
  --text-primary: #212121;
  /* ... */
}
```

支持深色模式：
```css
@media (prefers-color-scheme: dark) {
  :root {
    --text-primary: #e0e0e0;
    /* ... */
  }
}
```

## ⚙️ 修改样式

如果需要修改文档站点的样式：

1. **编辑样式文件** - `docs-src/styles/main.css`
2. **重新构建** - `make docs`
3. **预览效果** - `make serve`

⚠️ **重要**：
- ✅ 只编辑 `docs-src/styles/main.css`（源文件）
- ❌ 不要直接修改 `docs/styles/main.css`（生成文件）
- 构建脚本会自动复制样式文件到 `docs/styles/`

## ⚠️ 重要注意事项

### ✅ 应该做的

- ✅ 只编辑 `docs-src/` 目录下的 Markdown 文件
- ✅ 修改后运行 `make docs` 重新生成
- ✅ 提交 `docs-src/` 目录的更改到 Git
- ✅ 在本地预览验证后再提交

### ❌ 不应该做的

- ❌ 不要直接编辑 `docs/` 目录下的 HTML 文件
- ❌ 不要提交 `docs/` 目录到 Git（已加入 .gitignore）
- ❌ 不要修改自动生成的文件（会被覆盖）

## 📋 Markdown 编写规范

### 标题层级

```markdown
# 一级标题（页面标题，只用一次）

## 二级标题（主要章节）

### 三级标题（子章节）

#### 四级标题（详细说明）
```

### 代码块

使用三个反引号标记代码块，并指定语言：

````markdown
```bash
make docs
```

```javascript
const api = require('./api');
```

```json
{
  "key": "value"
}
```
````

### 链接

- **内部链接**（指向其他文档）：
  ```markdown
  [认证授权指南](authentication.html)
  [API 参考](../api/index.html)
  ```

- **外部链接**：
  ```markdown
  [GitHub](https://github.com/NexusBook/nexusbook-api)
  ```

### 表格

```markdown
| 列1 | 列2 | 列3 |
|-----|-----|-----|
| 值1 | 值2 | 值3 |
```

### 提示框

使用 emoji 和粗体文字突出重要信息：

```markdown
✅ **推荐做法**：使用批量操作

❌ **不推荐**：循环调用单个 API

⚠️ **警告**：注意版本兼容性

💡 **提示**：可以使用快捷命令
```

## 🔧 本地开发工具

### 推荐的 Markdown 编辑器

- **VS Code** + Markdown Preview Enhanced 插件
- **Typora**
- **MacDown**（macOS）
- **MarkText**

### 实时预览工作流

1. 开启文档服务器：
   ```bash
   make serve
   ```

2. 编辑 Markdown 文件

3. 重新生成（在另一个终端）：
   ```bash
   make docs
   ```

4. 刷新浏览器查看更改

## 📤 提交流程

1. **编辑文档**（只修改 `docs-src/` 下的文件）

2. **本地测试**
   ```bash
   make docs
   make serve
   # 验证更改
   ```

3. **提交更改**
   ```bash
   git add docs-src/
   git add scripts/build-docs.js  # 如果修改了构建脚本
   git add docs/styles/main.css    # 如果修改了样式
   git commit -m "docs: 更新快速开始指南"
   ```

4. **推送**
   ```bash
   git push
   ```

## 🤝 贡献建议

- 保持文档简洁明了
- 提供实际可运行的代码示例
- 添加必要的截图或图表
- 使用中英文双语（如适用）
- 保持格式一致性
- 及时更新过时的信息

## 📞 获取帮助

如有问题，请：
- 查看 [docs-src/README.md](README.md)
- 提交 GitHub Issue
- 在 Discussions 中讨论

感谢您的贡献！🎉
