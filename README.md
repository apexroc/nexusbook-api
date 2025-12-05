# NexusBook API

<div align="center">

**一个功能强大的开源文档管理和数据协作平台 API**

使用 TypeSpec 定义并生成 OpenAPI 3.0 规范

[![TypeSpec](https://img.shields.io/badge/TypeSpec-1.6.0-blue)](https://typespec.io/)
[![OpenAPI](https://img.shields.io/badge/OpenAPI-3.0-green)](https://www.openapis.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[快速开始](DOCS.md) • [完整文档](docs-src/) • [API 参考](#api-文档) • [贡献指南](docs-src/CONTRIBUTING.md)

</div>

---

## 🎯 概览

NexusBook API 是一个功能完整的文档管理和数据协作平台，提供：

- **统一的文档抽象** - 支持订货单、产品、库存、项目等多种业务类型
- **强大的数据管理** - 25+ 种字段类型，支持公式、查找、汇总等计算字段
- **灵活的视图系统** - 表格、看板、日历、图表等 8 种视图类型
- **完整的协作功能** - 评论、修订、审批、变更请求等
- **事件驱动通知** - Webhook 支持 20+ 种事件类型，自动推送变更通知
- **标准的认证授权** - OAuth2 & OIDC 兼容

## 🚀 快速开始

### 前置要求

- Node.js 16+
- Make

### 安装与使用

```bash
# 1. 安装依赖
make deps

# 2. 生成 OpenAPI 文档
make openapi

# 3. 构建完整文档站点
make docs

# 4. 启动文档服务器（浏览器访问 http://localhost:8091）
make serve
```

### API 文档

本地查看完整 API 文档：

```bash
make serve
```

然后在浏览器中访问 `http://localhost:8091`

### 快速示例

#### 1. 获取访问令牌

```bash
curl -X POST https://auth.nexusbook.com/token \
  -d 'grant_type=client_credentials' \
  -d 'client_id=YOUR_CLIENT_ID' \
  -d 'client_secret=YOUR_CLIENT_SECRET' \
  -d 'scope=doc:read data:read'
```

#### 2. 获取文档数据

```bash
curl -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  'https://open.nexusbook.com/api/v1/doc/product/123?include=metadata,views,data'
```

#### 3. 创建数据行

```bash
curl -X POST 'https://open.nexusbook.com/api/v1/doc/product/123/data?apply=true' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "id": "row-1",
    "values": [
      {"fieldId": "name", "value": {"text": "新产品"}},
      {"fieldId": "price", "value": {"number": 99.99}}
    ]
  }'
```

## 📚 文档

### 🌐 在线文档

访问完整的在线文档：**[NexusBook API 文档](https://nexusbook.github.io/nexusbook-api/)**

> 文档由 GitHub Actions 自动构建并部署到 GitHub Pages。

### 📝 文档内容

完整的文档请查看：

- **[📖 完整文档站点](docs-src/)** - 包含所有开发指南和参考文档
  - [快速开始](docs-src/guides/getting-started.md)
  - [认证授权指南](docs-src/guides/authentication.md)
  - [文档模型详解](docs-src/guides/document-model.md)
  - [数据操作指南](docs-src/guides/data-operations.md)
  - [Webhook 使用指南](docs-src/guides/webhooks.md)
  - [架构设计](docs-src/guides/architecture.md)
  - [开发指南](docs-src/guides/development.md)
  - [最佳实践](docs-src/guides/best-practices.md)
  - [完整示例](docs-src/guides/examples.md)

- **[🔍 API 参考手册](docs-src/references/api-reference.md)** - 完整的 API 端点参考
- **[📋 错误码参考](docs-src/references/error-codes.md)** - 所有错误码说明
- **[🏷️ 字段类型参考](docs-src/references/field-types.md)** - 25+ 种字段类型
- **[🌍 国际化说明](docs-src/references/i18n.md)** - 多语言消息系统
- **[📡 GitHub Pages 部署](docs-src/GITHUB_PAGES.md)** - 文档部署配置

## 🏗️ 项目结构

```
api/                  # TypeSpec API 定义
├── main.tsp         # 顶层入口
├── shared/          # 共享基础模块
├── auth/            # 认证模块
└── document/        # 文档模块

docs-src/            # 文档源文件（Markdown）
├── guides/          # 开发指南
├── references/      # 参考文档
└── styles/          # 样式文件

docs/                # 生成的文档站点（不提交到 Git）
```

## 🔧 开发命令

```bash
# 开发相关
make deps          # 安装依赖
make openapi       # 生成 OpenAPI 规范
make docs          # 构建完整文档站点（本地开发）
make serve         # 启动文档服务器

# GitHub Pages 部署
npm run build-for-github  # 为 GitHub Pages 构建文档（带 /nexusbook-api/ 路径前缀）

# 清理
make clean         # 清理生成的文件
make clean-docs    # 清理文档
```

### 📦 构建说明

**本地开发**：使用 `make docs` 或 `npm run build-docs`，生成的链接使用根路径 `/`

**GitHub Pages 部署**：使用 `npm run build-for-github`，生成的链接使用子路径 `/nexusbook-api/`

> 构建脚本通过环境变量 `BASE_PATH` 自动处理路径前缀，确保文档在不同部署环境下链接正确。

详细的开发指南请查看 [开发指南](docs-src/guides/development.md)。

## 📄 许可证

MIT License

## 🤝 贡献

欢迎贡献代码、报告问题或提出建议！详细的贡献指南请查看 [贡献指南](docs-src/CONTRIBUTING.md)。

---

<div align="center">

**[⬆ 回到顶部](#nexusbook-api)**

Made with ❤️ using TypeSpec

</div>
