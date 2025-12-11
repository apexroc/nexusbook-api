# API 参考手册

完整的 NexusBook API 端点参考文档。

## 基本信息

| 项目 | 说明 |
|------|------|
| **API 基址** | `https://open.nexusbook.app/api/v1` |
| **认证域名** | `https://auth.nexusbook.app` |
| **API 规范** | OpenAPI 3.0 |
| **架构风格** | RESTful |

## 统一响应格式

所有 API 返回统一的 `ApiResponse<T>` 结构：

```typescript
{
  success: boolean,           // 是否成功
  code?: ErrorCode,          // 错误码（失败时）
  message?: Record<string, string>,  // 多语言消息（灵活的语言代码映射）
  payload?: T | null         // 实际数据载荷
}
```

### 多语言消息说明

`message` 字段使用 ISO 639-1 语言代码作为键，支持任意语言扩展。常用语言代码：
- `zh`: 中文
- `en`: English
- `ja`: 日本語
- `ko`: 한국어
- `es`: Español
- `fr`: Français
- `de`: Deutsch
- `pt`: Português
- `ru`: Русский
- `ar`: العربية

**示例：**

```json
{
  "success": false,
  "code": "DOC_NOT_FOUND",
  "message": {
    "zh": "文档不存在",
    "en": "Document not found",
    "ja": "ドキュメントが見つかりません"
  },
  "payload": null
}
```

## 核心端点

### 1. 聚合查询

```http
GET /api/v1/doc/{doc-type}/{doc-id}?include=metadata,views,data,comments,revisions,settings
```

一次性获取文档所需的多种数据，支持按需加载。

**查询参数：**
- `include` - 包含的数据部分（逗号分隔）
  - `metadata` - 字段定义
  - `views` - 视图列表
  - `data` - 数据行
  - `comments` - 评论
  - `revisions` - 修订历史
  - `settings` - 设置
- `viewId` - 指定视图 ID
- `page`, `pageSize` - 分页参数
- `commentsLimit`, `revisionsLimit` - 限制数量

**示例：**

```bash
# 获取产品文档的元数据、视图和数据
curl -H 'Authorization: Bearer TOKEN' \
  'https://open.nexusbook.app/api/v1/doc/product/123?include=metadata,views,data'
```

### 2. 文档属性

管理文档级元信息（订单时间、门店、金额、数量等）。

```http
# 获取文档属性
GET /api/v1/doc/{doc-type}/{doc-id}/properties

# 创建文档属性
POST /api/v1/doc/{doc-type}/{doc-id}/properties

# 完全替换文档属性
PUT /api/v1/doc/{doc-type}/{doc-id}/properties

# 部分更新文档属性
PATCH /api/v1/doc/{doc-type}/{doc-id}/properties?merge=true&version=1

# 删除文档属性
DELETE /api/v1/doc/{doc-type}/{doc-id}/properties

# 获取属性历史
GET /api/v1/doc/{doc-type}/{doc-id}/properties/history
```

**示例：**

```bash
# 获取订货单属性
curl -H 'Authorization: Bearer TOKEN' \
  'https://open.nexusbook.app/api/v1/doc/purchase/p001/properties'

# 更新订货单属性
curl -X PATCH 'https://open.nexusbook.app/api/v1/doc/purchase/p001/properties?merge=true' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "orderDate": "2024-12-01",
    "storeName": "北京旗舰店",
    "totalAmount": 12345.67
  }'
```

### 3. 元数据

管理字段定义、类型和验证配置。

```http
# 获取元数据
GET /api/v1/doc/{doc-type}/{doc-id}/metadata

# 更新元数据
PUT /api/v1/doc/{doc-type}/{doc-id}/metadata
```

**示例：**

```bash
# 获取产品表的字段定义
curl -H 'Authorization: Bearer TOKEN' \
  'https://open.nexusbook.app/api/v1/doc/product/123/metadata'
```

### 4. 视图

视图管理端点，支持 8 种视图类型（Table, Gallery, Kanban, Calendar, Chart, Form, Map, Timeline）。

```http
# 获取视图列表
GET /api/v1/doc/{doc-type}/{doc-id}/views

# 创建视图
POST /api/v1/doc/{doc-type}/{doc-id}/views

# 获取单个视图
GET /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}

# 更新视图
PUT /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}

# 删除视图
DELETE /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}

# 设置默认视图
POST /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}/default
```

**示例：**

```bash
# 创建看板视图
curl -X POST 'https://open.nexusbook.app/api/v1/doc/project/456/views' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "项目看板",
    "type": "kanban",
    "config": {
      "groupByField": "status",
      "displayFields": ["name", "assignee", "dueDate"]
    }
  }'
```

# 数据

数据行的 CRUD 操作，支持简单查询和结构化查询。

```http
# 列表查询（简单）
GET /api/v1/doc/{doc-type}/{doc-id}/data?page=1&pageSize=20&sort=name:asc

# 结构化查询
POST /api/v1/doc/{doc-type}/{doc-id}/data/query

# 创建数据行（所有写操作需携带 requestId）
POST /api/v1/doc/{doc-type}/{doc-id}/data?requestId={request-id}

# 批量更新（target/value）
POST /api/v1/doc/{doc-type}/{doc-id}/data/bulk?requestId={request-id}

# 获取单行
GET /api/v1/doc/{doc-type}/{doc-id}/data/{row-id}

# 更新数据行
PUT /api/v1/doc/{doc-type}/{doc-id}/data/{row-id}?requestId={request-id}

# 删除数据行
DELETE /api/v1/doc/{doc-type}/{doc-id}/data/{row-id}?requestId={request-id}
```


**说明：** 所有写操作统一通过 `requestId` 进入变更请求工作流，`apply` 参数已废弃。

**示例 - 简单查询：**

```bash
# 获取产品列表，按名称升序排序
curl -H 'Authorization: Bearer TOKEN' \
  'https://open.nexusbook.app/api/v1/doc/product/123/data?page=1&pageSize=20&sort=name:asc'
```

**示例 - 结构化查询：**

```bash
# 查询价格在 50-200 之间且状态为 active 的产品
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/data/query' \
  -H 'Authorization: Bearer TOKEN' \
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

**示例 - 创建数据行：**

```bash
# 直接创建产品
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/data?apply=true' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "id": "row-1",
    "values": [
      {"fieldId": "name", "value": {"text": "新产品"}},
      {"fieldId": "price", "value": {"number": 99.99}},
      {"fieldId": "status", "value": {"selectOption": {"id": "active"}}}
    ]
  }'
```

### 6. 评论（统一接口）

支持在文档、字段、行、单元格等任何位置进行评论。

```http
# 列表（支持按位置过滤）
GET /api/v1/doc/{doc-type}/{doc-id}/comments?scope=document|field|row|cell&fieldId=&rowId=

# 创建评论
POST /api/v1/doc/{doc-type}/{doc-id}/comments

# 获取单个评论
GET /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}

# 更新评论
PUT /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}

# 删除评论
DELETE /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}

# 置顶评论
POST /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}/pin

# 取消置顶
POST /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}/unpin

# 标记为已解决
POST /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}/resolve

# 取消已解决
POST /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}/unresolve

# 添加表情反应
POST /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}/reactions?emoji=👍

# 删除表情反应
DELETE /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}/reactions/{emoji}
```

**评论位置定位：**

```typescript
CommentTarget {
  scope: "document" | "field" | "row" | "cell",
  fieldId?: string,  // scope 为 field 或 cell 时
  rowId?: string     // scope 为 row 或 cell 时
}
```

**示例：**

```bash
# 文档级评论
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/comments' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "target": {"scope": "document"},
    "content": "这个产品目录需要更新"
  }'

# 单元格评论
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/comments' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "target": {
      "scope": "cell",
      "rowId": "row-123",
      "fieldId": "price"
    },
    "content": "这个价格看起来不对，请核实"
  }'
```

### 8. 实时协同（Realtime）

- 获取连接信息：`GET /realtime/doc/{docType}/{docId}/connect`（返回 `wsUrl/wsHost/wsPath/port/protocols/sseUrl` 与 `token`）
- 在线用户：`GET /realtime/doc/{docType}/{docId}/users`
- 锁定/解锁/锁列表：`POST /lock`、`DELETE /unlock/{lockId}`、`GET /locks`
- Yjs 快照：`GET/POST /snapshot`、`GET /snapshots`
- 更新（后备）：`POST /apply-update`、`POST /awareness`
- 事件历史：`GET /events`
- 断开所有会话：`POST /disconnect-all`
- 消息结构：`GET /realtime/messages/schema`
- SSE 流：`GET /realtime/doc/{docType}/{docId}/events/stream`（`text/event-stream`）

**握手示例（WebSocket）**
```json
{
  "kind": "auth",
  "seq": 1,
  "payload": { "token": "Bearer {ACCESS_TOKEN}" }
}
```


完整的版本控制和变更追踪。

```http
# 获取修订列表
GET /api/v1/doc/{doc-type}/{doc-id}/revisions

# 获取单个修订
GET /api/v1/doc/{doc-type}/{doc-id}/revisions/{rev-id}

# 获取修订的变更操作
GET /api/v1/doc/{doc-type}/{doc-id}/revisions/{rev-id}/operations

# 对比两个修订
GET /api/v1/doc/{doc-type}/{doc-id}/revisions/{rev-id}/diff?base={base-rev-id}

# 获取特定目标的历史
GET /api/v1/doc/{doc-type}/{doc-id}/revisions/history?targetKind=row&rowId={row-id}

# 回滚到指定修订
POST /api/v1/doc/{doc-type}/{doc-id}/revisions/{rev-id}/revert

# 获取修订关联的请求
GET /api/v1/doc/{doc-type}/{doc-id}/revisions/{rev-id}/request

# 导出修订数据
GET /api/v1/doc/{doc-type}/{doc-id}/revisions/{rev-id}/export?format=json
```

**修订变更操作：**

```typescript
ChangeOperation {
  id: string,
  type: "row-create" | "row-update" | "row-delete" 
      | "field-create" | "field-update" | "field-delete"
      | "metadata-update" | "settings-update",
  target: {
    kind: "row" | "field" | "metadata" | "settings",
    rowId?: string,
    fieldId?: string
  },
  oldValue?: unknown,  // 更新和删除时
  newValue?: unknown,  // 创建和更新时
  operator?: string,
  timestamp?: string,
  note?: string
}
```

**示例：**

```bash
# 查看修订详情
curl -H 'Authorization: Bearer TOKEN' \
  'https://open.nexusbook.app/api/v1/doc/product/123/revisions/rev-456'

# 对比两个修订的差异
curl -H 'Authorization: Bearer TOKEN' \
  'https://open.nexusbook.app/api/v1/doc/product/123/revisions/rev-456/diff?base=rev-455'

# 回滚到指定版本
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/revisions/rev-455/revert' \
  -H 'Authorization: Bearer TOKEN'
```

### 8. 变更请求

类似 Git Pull Request 的变更管理机制。

```http
# 获取请求列表
GET /api/v1/doc/{doc-type}/{doc-id}/requests

# 创建请求
POST /api/v1/doc/{doc-type}/{doc-id}/requests

# 获取单个请求
GET /api/v1/doc/{doc-type}/{doc-id}/requests/{req-id}

# 合并请求
POST /api/v1/doc/{doc-type}/{doc-id}/requests/{req-id}/merge

# 关闭请求
POST /api/v1/doc/{doc-type}/{doc-id}/requests/{req-id}/close

# 重新打开请求
POST /api/v1/doc/{doc-type}/{doc-id}/requests/{req-id}/reopen

# 获取冲突
GET /api/v1/doc/{doc-type}/{doc-id}/requests/{req-id}/conflicts
```

**示例：**

```bash
# 创建变更请求
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/requests' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "title": "更新产品价格",
    "description": "年度价格调整",
    "changes": [
      {
        "type": "row-update",
        "target": {"kind": "row", "rowId": "row-123"},
        "newValue": {
          "values": [{"fieldId": "price", "value": {"number": 119.99}}]
        }
      }
    ]
  }'

# 合并请求
curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/requests/req-789/merge' \
  -H 'Authorization: Bearer TOKEN'
```

### 9. 审批

多层级、多人审批流程。

```http
# 获取审批配置
GET /api/v1/doc/{doc-type}/{doc-id}/approval

# 启动审批流程
POST /api/v1/doc/{doc-type}/{doc-id}/approval/start

# 获取审批实例
GET /api/v1/doc/{doc-type}/{doc-id}/approval/{instance-id}

# 提交审批决策
POST /api/v1/doc/{doc-type}/{doc-id}/approval/{instance-id}/decision?result=approved|rejected
```

**示例：**

```bash
# 启动审批流程
curl -X POST 'https://open.nexusbook.app/api/v1/doc/purchase/p001/approval/start' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "requestId": "req-789",
    "flowId": "purchase-approval-flow"
  }'

# 审批通过
curl -X POST 'https://open.nexusbook.app/api/v1/doc/purchase/p001/approval/appr-123/decision?result=approved' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "comment": "订单已审核通过",
    "signature": "张三"
  }'
```

### 10. 设置

文档和类型级别的配置。

```http
# 文档级设置
GET /api/v1/doc/{doc-type}/{doc-id}/settings
PUT /api/v1/doc/{doc-type}/{doc-id}/settings

# 类型级设置
GET /api/v1/doc/{doc-type}/setting
PUT /api/v1/doc/{doc-type}/setting
```

**示例：**

```bash
# 更新文档设置
curl -X PUT 'https://open.nexusbook.app/api/v1/doc/product/123/settings' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "permissions": {
      "allowComment": true,
      "requireApproval": false
    },
    "notifications": {
      "emailOnChange": true
    }
  }'
```

### 11. 认证

OAuth2 和 OIDC 标准认证端点。

```http
# 授权端点
GET /auth/authorize

# 令牌颁发
POST /auth/token

# 用户信息
GET /auth/userinfo

# OIDC 发现
GET /auth/.well-known/openid-configuration

# 公钥集合
GET /auth/jwks.json
```

详细的认证流程请查看 [认证授权指南](../guides/authentication.md)。

### 12. Webhooks

事件驱动的通知机制。

```http
# Webhook 管理
GET    /api/v1/webhooks
POST   /api/v1/webhooks
GET    /api/v1/webhooks/{webhook-id}
PUT    /api/v1/webhooks/{webhook-id}
DELETE /api/v1/webhooks/{webhook-id}

# Webhook 操作
POST   /api/v1/webhooks/{webhook-id}/pause
POST   /api/v1/webhooks/{webhook-id}/resume
POST   /api/v1/webhooks/{webhook-id}/test
POST   /api/v1/webhooks/{webhook-id}/regenerate-secret

# 投递管理
GET    /api/v1/webhooks/{webhook-id}/deliveries
GET    /api/v1/webhooks/{webhook-id}/deliveries/{delivery-id}
POST   /api/v1/webhooks/{webhook-id}/deliveries/{delivery-id}/redeliver

# 统计信息
GET    /api/v1/webhooks/{webhook-id}/stats
```

详细的 Webhook 使用方法请查看 [Webhook 使用指南](../guides/webhooks.md)。

## 查询与过滤

### 过滤操作符

```typescript
FilterOp = 
  | "eq"           // 等于
  | "ne"           // 不等于
  | "in"           // 包含于
  | "range"        // 区间
  | "contains"     // 包含
  | "is_empty"     // 为空
  | "is_not_empty" // 不为空
```

### 过滤组合

```typescript
FilterGroup {
  logic: "and" | "or",
  conditions: Filter[],
  groups: FilterGroup[]  // 支持嵌套
}
```

### 排序

```typescript
Sort {
  field: string,
  direction: "asc" | "desc"
}
```

### 分组与聚合

```typescript
GroupBy {
  fields: string[],
  aggregations: Aggregation[]
}

Aggregation {
  kind: "count" | "sum" | "avg" | "min" | "max",
  field: string
}
```

## 错误码

查看 [错误码参考](./error-codes.md) 获取完整的错误码列表和说明。

## 字段类型

查看 [字段类型参考](./field-types.md) 获取所有支持的字段类型和值类型映射。

## 下一步

- 查看 [快速开始指南](../guides/getting-started.md) 开始使用 API
- 查看 [数据操作指南](../guides/data-operations.md) 学习高级查询
- 查看 [最佳实践](../guides/best-practices.md) 了解使用建议
