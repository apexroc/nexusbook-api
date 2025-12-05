# NexusBook API 文档结构说明

## 📚 文档组织

NexusBook API 文档采用清晰的层级结构，通过侧边栏导航方便快速定位内容。

### 🗂️ 文档分组

文档分为 5 个主要分组：

#### 1. 开始使用 (Getting Started)

适合初次使用的开发者，包含基础概念和快速入门。

- **概览** - 项目介绍、核心功能、技术栈
- **快速开始** - 5 分钟快速上手指南
- **认证授权** - OAuth2、OIDC、JWT 完整指南

#### 2. 核心概念 (Core Concepts)

深入理解 NexusBook 的设计理念和数据模型。

- **文档模型** - 统一文档抽象、字段定义、元数据
- **数据操作** - CRUD 操作、批量更新、变更请求
- **Webhook 事件** - 事件类型、订阅管理、安全验证

#### 3. API 参考 (API Reference)

完整的 API 接口文档和数据结构参考。

- **API 端点** - OpenAPI 交互式文档（Redocly 生成）
- **字段类型** - 25+ 种字段类型详细说明
- **错误码** - 完整的错误码列表和处理建议

#### 4. 开发指南 (Development Guide)

开发环境搭建、最佳实践和实战示例。

- **开发环境** - 项目结构、构建流程、本地开发
- **架构设计** - 系统架构、设计原则、技术选型
- **最佳实践** - 性能优化、安全建议、错误处理
- **完整示例** - 实际场景的代码示例和解决方案

#### 5. 其他资源 (Additional Resources)

国际化、更新日志、贡献指南等辅助资料。

- **国际化** - 多语言消息系统、i18n 配置
- **更新日志** - 版本更新记录
- **贡献指南** - 如何参与项目开发
- **问题排查** - 常见问题和解决方案

---

## 📂 文件结构

```
docs-src/                        # 文档源文件目录
├── index.md                     # 文档首页
├── README.md                    # 项目概览
├── CONTRIBUTING.md              # 贡献指南
├── TROUBLESHOOTING.md           # 问题排查
├── GITHUB_PAGES.md              # GitHub Pages 配置
├── guides/                      # 开发指南
│   ├── getting-started.md       # 快速开始
│   ├── authentication.md        # 认证授权
│   ├── document-model.md        # 文档模型
│   ├── data-operations.md       # 数据操作
│   ├── webhooks.md              # Webhook
│   ├── development.md           # 开发环境
│   ├── architecture.md          # 架构设计
│   ├── best-practices.md        # 最佳实践
│   └── examples.md              # 完整示例
├── references/                  # 参考文档
│   ├── api-reference.md         # API 参考
│   ├── field-types.md           # 字段类型
│   ├── error-codes.md           # 错误码
│   ├── i18n.md                  # 国际化
│   └── changelog.md             # 更新日志
└── styles/                      # 样式文件
    └── main.css                 # 主样式

sidebars.yaml                    # 侧边栏配置（已废弃）
redocly.yaml                     # Redocly 配置（包含 sidebars）
```

---

## 🎨 侧边栏配置

侧边栏配置定义在 `redocly.yaml` 的 `sidebars.main` 部分：

```yaml
sidebars:
  main:
    - group: 开始使用
      expanded: true
      pages:
        - label: 概览
          page: index.md
        # ... 其他页面
    
    - group: 核心概念
      expanded: true
      pages:
        - label: 文档模型
          page: guides/document-model.md
        # ... 其他页面
```

### 配置说明

- **group**: 分组名称
- **expanded**: 是否默认展开（`true` 或 `false`）
- **pages**: 该分组下的页面列表
  - **label**: 显示在侧边栏的标签
  - **page**: Markdown 文件的相对路径

### 展开策略

- **开始使用** - 默认展开（`expanded: true`）
- **核心概念** - 默认展开（`expanded: true`）
- **API 参考** - 默认展开（`expanded: true`）
- **开发指南** - 默认折叠（`expanded: false`）
- **其他资源** - 默认折叠（`expanded: false`）

---

## 🔧 构建与预览

### 生成文档

```bash
# 生成 OpenAPI 文档
make openapi

# 生成 Redoc API 文档
make build-docs

# 构建完整文档站点
make docs

# 启动文档服务器
make serve
```

### 预览文档

```bash
# 启动本地服务器（端口 8091）
make serve

# 浏览器访问
open http://localhost:8091
```

---

## 🌐 在线文档

文档自动部署到 GitHub Pages：

- **文档地址**: https://nexusbook.github.io/nexusbook-api/
- **构建触发**: 每次推送到 `main` 分支
- **构建工具**: GitHub Actions + Redocly

---

## 📝 文档编写指南

### Markdown 规范

1. **标题层级**
   - 使用 `#` 到 `####` 四级标题
   - 一个文件只有一个一级标题

2. **代码块**
   - 使用语法高亮：` ```bash `, ` ```javascript `, ` ```json `
   - 提供完整的可运行示例

3. **链接**
   - 内部链接使用相对路径：`[快速开始](guides/getting-started.md)`
   - 外部链接使用完整 URL：`[GitHub](https://github.com/...)`

4. **图表**
   - 支持 Mermaid 图表：` ```mermaid `
   - 建议使用简洁的流程图和架构图

### 内容更新流程

1. 修改 `docs-src/` 下的 Markdown 文件
2. 运行 `make docs` 重新生成文档
3. 运行 `make serve` 本地预览
4. 提交并推送到 GitHub（自动部署）

---

## 🎯 快速导航

| 我想... | 查看文档 |
|---------|----------|
| 快速上手 | [快速开始](docs-src/guides/getting-started.md) |
| 了解认证 | [认证授权](docs-src/guides/authentication.md) |
| 理解数据模型 | [文档模型](docs-src/guides/document-model.md) |
| 查看 API 接口 | [API 参考](dist/redoc/index.html) |
| 处理错误 | [错误码](docs-src/references/error-codes.md) |
| 查看示例 | [完整示例](docs-src/guides/examples.md) |
| 参与贡献 | [贡献指南](docs-src/CONTRIBUTING.md) |

---

<div align="center">

**文档持续更新中** | Made with ❤️ using TypeSpec & Redocly

</div>
