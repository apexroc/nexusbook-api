# OpenAPI 文档增强说明

## 概述

为了让 OpenAPI 文档的启动页面更加清晰和专业，我们对文档结构进行了全面优化。

## 主要改进

### 1. 📋 增强的文档描述

在 `api/main.tsp` 中大幅扩充了文档说明，现在包含：

- **核心特性介绍**（4大类）
  - 📋 灵活的文档模型
  - 🤝 实时协作
  - 🔗 供应链数据协同
  - 🔌 扩展能力

- **API 架构说明**
  - 文档管理命名空间
  - 供应链协同命名空间
  - 租户管理命名空间
  - 扩展功能模块

- **快速开始指南**
  - 认证方式说明
  - 基础调用示例
  - 供应链协同示例

- **核心概念**
  - 文档包（Document Package）
  - 并发控制机制
  - 错误处理规范
  - 分页和查询

- **相关资源链接**
  - 完整文档站点
  - 快速开始指南
  - Catalog-OrderBook 数据协同参考
  - 认证授权指南
  - 字段类型参考
  - 错误码参考
  - GitHub 仓库
  - 社区支持

### 2. 🔧 自动化增强脚本

创建了 `scripts/enhance-openapi.js` 脚本，在 TypeSpec 编译后自动为 OpenAPI 文件添加：

#### Info 元信息
```yaml
info:
  title: NexusBook OpenAPI
  version: 1.0.0
  description: ...  # 从 TypeSpec 继承
  termsOfService: https://nexusbook.app/terms
  contact:
    name: NexusBook API Support
    url: https://docs.nexusbook.app/support
    email: api@nexusbook.app
  license:
    name: Apache 2.0
    url: https://www.apache.org/licenses/LICENSE-2.0.html
```

#### External Docs
```yaml
externalDocs:
  description: 完整的 API 文档和开发指南
  url: https://docs.nexusbook.app
```

#### x-tagGroups 分组
```yaml
x-tagGroups:
  - name: 🚀 快速开始
    tags: [OAuth, Authentication, API Keys]
  - name: 👥 租户管理
    tags: [Users, Organizations, Workspaces, Invitations, Join Requests]
  - name: 📄 文档管理
    tags: [Metadata, Views, Data, Revisions, Comments, Approvals, Requests, Settings]
  - name: 🔗 供应链协同
    tags: [Catalog, OrderBook, Connection, Connector]
  - name: 🔌 扩展功能
    tags: [Webhooks, I18n, Preferences]
  - name: 💳 计费管理
    tags: [Billing, Plans, Subscriptions, Invoices, Payments, Usage]
  - name: 📊 审计日志
    tags: [Audit]
  - name: 🔐 OAuth & OIDC
    tags: [OAuth Clients, OIDC Providers - Public, OIDC Providers - Admin, OAuth Login, OAuth Extensions]
```

### 3. 🔄 更新构建流程

修改了 `Makefile`，将增强脚本集成到构建流程中：

```makefile
openapi: deps
	$(TSP) compile api/main.tsp --emit @typespec/openapi3 --output-dir tsp-output
	@echo "✅ OpenAPI 规范已生成"
	@echo "Enhancing OpenAPI files..."
	@node scripts/enhance-openapi.js
	@echo "✅ OpenAPI 文件增强完成"
```

## 用户体验改进

### 文档首页展示

当用户打开 API 文档时，现在会看到：

1. **清晰的标题和版本信息**
   - NexusBook OpenAPI v1.0.0
   - Apache 2.0 开源协议

2. **完整的产品介绍**
   - 核心特性说明
   - 使用场景示例
   - 技术架构概览

3. **快速导航**
   - 按功能模块分组的 API
   - Emoji 图标增强可读性
   - 清晰的层级结构

4. **便捷的外部链接**
   - 联系支持: api@nexusbook.app
   - 完整文档: https://docs.nexusbook.app
   - 服务条款: https://nexusbook.app/terms

### API 分组组织

通过 x-tagGroups，API 端点按功能分为 8 大类：

- 🚀 快速开始 - 认证和密钥管理
- 👥 租户管理 - 用户、组织、工作区
- 📄 文档管理 - 元数据、视图、数据操作
- 🔗 供应链协同 - Catalog、OrderBook、Connection
- 🔌 扩展功能 - Webhooks、国际化
- 💳 计费管理 - 订阅、账单、支付
- �� 审计日志 - 审计记录查询
- 🔐 OAuth & OIDC - 认证授权详细配置

## 技术细节

### 为什么不在 TypeSpec 中定义？

TypeSpec 的 `@service` 装饰器只支持 `title` 参数，不支持 `contact`、`license`、`termsOfService` 等扩展字段。因此我们采用了后处理的方式，在编译后通过脚本增强 OpenAPI 文件。

### 脚本运行时机

```
TypeSpec 编译 → 生成基础 OpenAPI → 运行增强脚本 → 最终 OpenAPI 文件 → Redocly 生成文档
```

### 文件路径

- 输入: `tsp-output/@typespec/openapi3/openapi.NexusBook.Api.yaml`
- 输入: `tsp-output/@typespec/openapi3/openapi.NexusBook.Auth.yaml`
- 脚本会直接修改这两个文件，添加元信息和分组

## 使用方式

### 构建文档

```bash
# 生成 OpenAPI 规范（自动运行增强脚本）
make openapi

# 构建完整文档站点
make docs

# 本地预览
make serve
```

### 查看效果

启动服务后访问:
- 主页: http://localhost:8091/
- API 文档: http://localhost:8091/api.html

## 未来改进

### 可选项

1. **自定义 Redocly 主题**
   - 可以在 `redocly.yaml` 中调整颜色、字体等

2. **添加更多示例**
   - 在 TypeSpec 的接口注释中添加更多代码示例

3. **多语言支持**
   - 考虑为 OpenAPI description 提供英文版本

4. **版本管理**
   - 建立 API 版本管理机制
   - 为不同版本生成独立文档

## 总结

通过这次优化，OpenAPI 文档从一个简单的端点列表升级为了一个完整的、专业的 API 参考文档，能够：

- ✅ 快速引导新用户了解产品能力
- ✅ 清晰展示 API 架构和组织结构
- ✅ 提供必要的联系方式和外部资源链接
- ✅ 通过分组和图标提升文档的可读性
- ✅ 保持与 TypeSpec 定义的同步性

---

**创建时间**: 2024-12-14
**版本**: v0.1.8
