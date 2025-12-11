# NexusBook API 文档

<div align="center">

**功能强大的文档管理和数据协作平台 API**

使用 TypeSpec 定义，生成标准 OpenAPI 3.0 规范

</div>

---

## 📚 欢迎

欢迎使用 NexusBook API 文档！NexusBook 是一个功能完整的文档管理和数据协作平台，提供强大的 RESTful API 接口。

### 🎯 核心功能

- **📄 统一的文档抽象** - 支持订货单、产品、库存、项目等多种业务类型
- **💾 强大的数据管理** - 25+ 种字段类型，支持公式、查找、汇总等计算字段
- **👁️ 灵活的视图系统** - 表格、看板、日历、图表等 8 种视图类型
- **👥 完整的协作功能** - 评论、修订、审批、变更请求等
- **🔔 事件驱动通知** - Webhook 支持 20+ 种事件类型，自动推送变更通知
- **🔐 标准的认证授权** - OAuth2 & OIDC 兼容

### 🚀 快速导航

#### 初次使用？

- [**快速开始**](guides/getting-started.md) - 5 分钟快速上手
- [**认证授权**](guides/authentication.md) - 了解如何获取访问令牌
- [**完整示例**](guides/examples.md) - 查看实际使用案例

#### 核心概念

- [**文档模型**](guides/document-model.md) - 理解 NexusBook 的文档结构
- [**数据操作**](guides/data-operations.md) - 学习数据的增删改查
- [**Webhook 事件**](guides/webhooks.md) - 集成事件通知

#### API 参考

- [**API 端点**](api/index.html) - 完整的 API 接口文档
- [**字段类型**](references/field-types.md) - 25+ 种字段类型参考
- [**错误码**](references/error-codes.md) - 错误处理指南

### 💡 快速示例

#### 获取访问令牌

```bash
curl -X POST https://auth.nexusbook.app/token \
  -d 'grant_type=client_credentials' \
  -d 'client_id=YOUR_CLIENT_ID' \
  -d 'client_secret=YOUR_CLIENT_SECRET' \
  -d 'scope=doc:read data:read'
```

#### 获取文档数据

```bash
curl -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  'https://open.nexusbook.app/api/v1/doc/product/123?include=metadata,views,data'
```

#### 创建数据行

```bash
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/data?requestId=req-1' \
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

### 🛠️ 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| **TypeSpec** | 1.6.0 | API 定义语言 |
| **OpenAPI** | 3.0 | API 规范标准 |
| **Redocly** | latest | API 文档生成 |

### 📖 文档结构

本文档站点分为以下几个部分：

1. **开始使用** - 快速入门和基础概念
2. **核心概念** - 深入理解 NexusBook 的设计理念
3. **API 参考** - 完整的 API 接口文档
4. **开发指南** - 开发环境搭建和最佳实践
5. **其他资源** - 国际化、更新日志、贡献指南等

### 🔗 相关链接

- [GitHub 仓库](https://github.com/nexusbook/nexusbook-api)
- [在线文档](https://nexusbook.github.io/nexusbook-api/)
- [问题反馈](https://github.com/nexusbook/nexusbook-api/issues)

### 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](https://github.com/nexusbook/nexusbook-api/blob/main/LICENSE)。

---

<div align="center">

**准备好开始了吗？** [立即开始 →](guides/getting-started.md)

Made with ❤️ using TypeSpec

</div>
