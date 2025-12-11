# 快速开始

欢迎使用 NexusBook API！本指南将帮助您快速上手，完成第一个 API 调用。

## 前置要求

在开始之前，请确保您的开发环境满足以下要求：

- **Node.js**: 16+ 版本
- **Make**: 构建工具

### 检查环境

```bash
# 检查 Node.js 版本
node --version  # 应该 >= 16

# 检查 Make
make --version
```

## 安装依赖

克隆项目后，首先安装所需的依赖：

```bash
# 安装 TypeSpec、Redocly 等 npm 依赖
make deps
```

这个命令会自动：
- 安装 TypeSpec 编译器
- 安装 Redocly CLI（用于生成 API 文档）
- 安装 TypeSpec CLI
- 安装 Redocly（可选，用于本地预览 API 文档）

## 生成 OpenAPI 文档

```bash
# 从 TypeSpec 定义生成 OpenAPI 规范
make openapi
```

生成的文件位于：
- `dist/openapi/@typespec/openapi3/*.yaml` - OpenAPI 规范文件

## 构建和查看文档

```bash
# 构建完整的文档站点
make docs

# 启动文档服务（默认端口 8091）
make serve
```

打开浏览器访问：`http://localhost:8091`

## 获取访问令牌

在调用 API 之前，您需要获取访问令牌。NexusBook API 支持两种 OAuth2 认证流程：

### 方式 1：客户端凭证流程（推荐用于服务端应用）

```bash
curl -X POST https://auth.nexusbook.app/token \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=client_credentials' \
  -d 'client_id=YOUR_CLIENT_ID' \
  -d 'client_secret=YOUR_CLIENT_SECRET' \
  -d 'scope=doc:read data:read data:write'
```

**响应示例：**

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "doc:read data:read data:write"
}
```

### 方式 2：授权码流程（用于 Web 应用）

1. 引导用户到授权端点：
```
https://auth.nexusbook.app/authorize?
  response_type=code&
  client_id=YOUR_CLIENT_ID&
  redirect_uri=YOUR_REDIRECT_URI&
  scope=doc:read data:read data:write&
  state=RANDOM_STATE
```

2. 用户授权后，使用授权码换取令牌：
```bash
curl -X POST https://auth.nexusbook.app/token \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=authorization_code' \
  -d 'code=AUTHORIZATION_CODE' \
  -d 'client_id=YOUR_CLIENT_ID' \
  -d 'client_secret=YOUR_CLIENT_SECRET' \
  -d 'redirect_uri=YOUR_REDIRECT_URI'
```

### Scope 权限说明

| Scope | 说明 |
|-------|------|
| `doc:read` | 读取文档信息（属性、元数据、视图、设置） |
| `doc:write` | 创建和修改文档 |
| `data:read` | 读取数据行 |
| `data:write` | 创建、更新、删除数据行 |
| `views:manage` | 管理视图 |
| `comments:write` | 创建和管理评论 |
| `approvals:manage` | 管理审批流程 |
| `requests:manage` | 管理变更请求 |

## 第一个 API 调用

现在您已经有了访问令牌，让我们尝试第一个 API 调用！

### 示例 1：获取文档聚合数据

获取产品文档的完整信息（元数据、视图、数据行）：

```bash
curl -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  'https://open.nexusbook.app/api/v1/doc/product/123?include=metadata,views,data&page=1&pageSize=20'
```

**响应示例：**

```json
{
  "success": true,
  "payload": {
    "metadata": {
      "id": "meta-001",
      "fields": [
        {"id": "name", "name": "产品名称", "type": "text"},
        {"id": "price", "name": "价格", "type": "currency"}
      ]
    },
    "views": [
      {"id": "view-001", "name": "全部产品", "type": "table"}
    ],
    "data": {
      "items": [
        {
          "id": "row-001",
          "values": [
            {"fieldId": "name", "value": {"text": "iPhone 15"}},
            {"fieldId": "price", "value": {"number": 799.99}}
          ]
        }
      ],
      "totalItems": 100,
      "pageSize": 20
    }
  }
}
```

### 示例 2：创建数据行

向产品文档中添加新产品：

```bash
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/data?requestId=req-1' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "id": "row-new-001",
    "values": [
      {"fieldId": "name", "value": {"text": "新产品"}},
      {"fieldId": "price", "value": {"number": 99.99}},
      {"fieldId": "stock", "value": {"number": 100}}
    ]
  }'
```

**参数说明：**
- `requestId=req-1`: 所有写操作需携带 `requestId`，变更进入对应的 Request，审批后生效
- `apply` 参数已废弃：请使用 `requestId` 工作流

### 示例 3：查询数据

使用结构化查询 API 搜索产品：

```bash
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/data/query' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "filters": {
      "logic": "and",
      "conditions": [
        {"field": "status", "operator": "eq", "value": "active"},
        {"field": "price", "operator": "range", "rangeStart": 50, "rangeEnd": 200}
      ]
    },
    "sorts": [{"field": "created_at", "direction": "desc"}],
    "page": 1,
    "pageSize": 20
  }'
```

### 示例 4：批量操作（统一 BulkUpdate）

使用统一的 BulkUpdate 接口进行混合更新（数据与属性），所有写操作必须携带 `requestId`：

```bash
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/data/bulk?requestId=req-1' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '[
    {"target": {"row": "row-1", "field": "price"}, "value": 99.99},
    {"target": {"property": "amount"}, "value": 5000.00}
  ]'
```

更多说明见下文“批量更新（灵活 target/value）”。

## 批量更新（灵活 target/value）

通过统一接口实现数据与属性的混合更新：

```bash
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/data/bulk?requestId=req-1' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '[
    {"target": {"row": "row-1", "field": "price"}, "value": 99.99},
    {"target": {"property": "amount"}, "value": 5000.00}
  ]'
```

说明：客户端只需提供原始值，类型推断与校验由服务端根据 `metadata` 完成。

### 1. 如何处理认证错误？

如果收到 `401 Unauthorized` 或 `INVALID_TOKEN` 错误：

- 检查 Token 是否过期（有效期通常为 1 小时）
- 确认请求头格式：`Authorization: Bearer YOUR_ACCESS_TOKEN`
- 重新获取 Token

### 2. 如何处理权限错误？

如果收到 `403 Forbidden` 错误：

- 检查 Token 的 Scope 是否包含所需权限
- 确认您对该文档有访问权限
- 联系管理员授予权限

### 3. 如何处理 API 限流？

如果收到 `429 Too Many Requests` 错误：

- 降低请求频率
- 使用批量操作减少请求次数
- 查看响应头 `Retry-After` 了解何时可以重试

### 4. 如何调试 API 调用？

- 使用 `-v` 参数查看 curl 请求详情：`curl -v ...`
- 检查响应的 `message` 字段获取错误详情
- 查看 [错误码参考](../references/error-codes.html)

### 5. 如何进行分页？

使用 `page` 和 `pageSize` 参数：

```bash
# 获取第 2 页，每页 50 条
curl 'https://open.nexusbook.app/api/v1/doc/product/123/data?page=2&pageSize=50' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN'
```

## 下一步

恭喜！您已经完成了第一个 API 调用。接下来可以：

- 📖 阅读 [认证授权指南](authentication.html) 深入了解认证机制
- 📊 阅读 [文档模型详解](document-model.html) 理解核心概念
- 🔧 阅读 [数据操作指南](data-operations.html) 学习高级用法
- 🔔 阅读 [Webhook 使用指南](webhooks.html) 配置事件通知
- 📚 查看 [完整示例](examples.html) 了解实际应用场景

## 获取帮助

- 📚 [API 参考文档](../api/index.html)
- 🐛 [问题反馈](https://github.com/NexusBook/nexusbook-api/issues)
- 💬 [讨论区](https://github.com/NexusBook/nexusbook-api/discussions)
