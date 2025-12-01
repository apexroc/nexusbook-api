# 文档系统使用指南

## 目录结构

本项目采用**源文件和生成文件分离**的方式组织文档：

```
项目根目录/
├── docs-src/                       # Markdown 源文件（可编辑）
│   ├── README.md                   # 本文件
│   ├── guides/                     # 开发指南源文件
│   │   ├── getting-started.md
│   │   ├── authentication.md
│   │   ├── document-model.md
│   │   ├── data-operations.md
│   │   ├── webhooks.md
│   │   ├── best-practices.md
│   │   └── examples.md
│   └── references/                 # 参考文档源文件
│       ├── error-codes.md
│       ├── field-types.md
│       ├── i18n.md
│       └── changelog.md
│
├── docs/                           # 生成的 HTML 文件（自动生成，不要手动编辑）
│   ├── index.html                  # 文档站点主页
│   ├── api/                        # OpenAPI 文档
│   │   ├── index.html              # Redoc 生成的 API 文档
│   │   └── openapi.yaml            # OpenAPI 规范文件
│   ├── guides/                     # 开发指南 HTML
│   ├── references/                 # 参考文档 HTML
│   └── styles/                     # 样式文件
│       └── main.css
│
└── scripts/
    └── build-docs.js               # 文档构建脚本
```

## 快速开始

使用 `make serve` 命令一键启动文档服务器：

```bash
make serve
```

默认访问地址：http://localhost:8091

如果端口被占用，可以指定其他端口：

```bash
PORT=9000 make serve
```

## 文档结构

```
docs/
├── index.html                      # 文档站点主页
├── api/                            # OpenAPI 文档
│   ├── index.html                  # Redoc 生成的 API 文档
│   └── openapi.yaml                # OpenAPI 规范文件
├── guides/                         # 开发指南
│   ├── getting-started.html        # 快速开始
│   ├── authentication.html         # 认证授权指南
│   ├── document-model.html         # 文档模型详解
│   ├── data-operations.html        # 数据操作指南
│   ├── webhooks.html               # Webhook 使用指南
│   ├── best-practices.html         # 最佳实践
│   └── examples.html               # 完整示例
├── references/                     # 参考文档
│   ├── error-codes.html            # 错误码参考
│   ├── field-types.html            # 字段类型参考
│   ├── i18n.html                   # 国际化说明
│   └── changelog.html              # 变更日志
└── styles/                         # 样式文件
    └── main.css                    # 统一样式
```

## 可用命令

| 命令 | 说明 |
|------|------|
| `make deps` | 安装依赖 |
| `make openapi` | 生成 OpenAPI 规范 |
| `make build-docs` | 生成 Redoc 文档 |
| `make docs` | 构建完整文档站点 |
| `make serve` | 启动文档服务器 |
| `make clean-docs` | 清理文档目录 |

## 更新文档

### 编辑 Markdown 文档

1. **在 `docs-src/` 目录下编辑 Markdown 文件**
   ```bash
   # 编辑开发指南
   vim docs-src/guides/getting-started.md
   
   # 编辑参考文档
   vim docs-src/references/error-codes.md
   ```

2. **运行 `make docs` 重新生成 HTML**
   ```bash
   make docs
   ```

3. **运行 `make serve` 预览更改**
   ```bash
   make serve
   # 访问 http://localhost:8091
   ```

### 重要提示

⚠️ **不要直接编辑 `docs/` 目录下的 HTML 文件**！
- `docs/` 目录的内容是由构建脚本自动生成的
- 所有修改应该在 `docs-src/` 目录中进行
- 每次运行 `make docs` 时，`docs/` 目录中的 HTML 文件会被重新生成

### 文件组织原则

- **docs-src/guides/**：开发指南的 Markdown 源文件
- **docs-src/references/**：参考文档的 Markdown 源文件
- **docs/guides/**：自动生成的开发指南 HTML
- **docs/references/**：自动生成的参考文档 HTML
- **docs/api/**：从 TypeSpec 生成的 OpenAPI 文档
- **docs/styles/**：样式文件（可直接编辑）

## 文档内容

### 开发指南

- **快速开始**：帮助新用户快速上手
- **认证授权指南**：OAuth2 和 OIDC 认证详解
- **文档模型详解**：核心概念和数据结构
- **数据操作指南**：数据行 CRUD 操作
- **Webhook 使用指南**：事件通知和集成
- **最佳实践**：性能优化和安全建议
- **完整示例**：实际应用场景

### 参考文档

- **错误码参考**：所有错误码和处理建议
- **字段类型参考**：25+ 种字段类型详解
- **国际化说明**：多语言消息系统
- **变更日志**：版本历史和迁移指南

## 特性

✅ **一键启动**：`make serve` 启动本地文档服务
✅ **OpenAPI 文档**：完整的 API 参考文档
✅ **完整开发指南**：7 个系统化指南文档
✅ **参考文档**：错误码、字段类型等快速参考
✅ **响应式设计**：支持桌面和移动设备
✅ **深色模式**：自动适配系统主题

## 技术栈

- **API 定义**：TypeSpec 1.6.0
- **OpenAPI 生成**：@typespec/openapi3
- **文档生成**：Redocly CLI
- **Markdown 转换**：marked.js
- **样式**：原生 CSS（支持 CSS 变量和深色模式）
- **Web 服务器**：Python http.server

## 部署

文档站点是纯静态页面，可以部署到任何静态托管服务：

- GitHub Pages
- Netlify
- Vercel
- Cloudflare Pages
- 或任何支持静态文件的 Web 服务器

## 维护

- 文档源文件位于 `docs/guides/` 和 `docs/references/`
- 修改后运行 `make docs` 重新生成
- 样式文件位于 `docs/styles/main.css`
- 构建脚本位于 `scripts/build-docs.js`

## 问题反馈

如果遇到问题或有改进建议，请在 GitHub Issues 中反馈。
