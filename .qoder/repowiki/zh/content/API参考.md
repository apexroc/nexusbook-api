# API参考

<cite>
**本文档引用的文件**  
- [main.tsp](file://api/main.tsp)
- [shared/common.tsp](file://api/shared/common.tsp)
- [shared/constants.tsp](file://api/shared/constants.tsp)
- [document/aggregate/index.tsp](file://api/document/aggregate/index.tsp)
- [document/core/data.tsp](file://api/document/core/data.tsp)
- [document/core/metadata.tsp](file://api/document/core/metadata.tsp)
- [document/core/views.tsp](file://api/document/core/views.tsp)
- [redocly.yaml](file://redocly.yaml)
- [tspconfig.yaml](file://tspconfig.yaml)
- [README.md](file://README.md)
- [docs-src/references/api-reference.md](file://docs-src/references/api-reference.md)
</cite>

## 目录
1. [简介](#简介)
2. [API基础信息](#api基础信息)
3. [统一响应格式](#统一响应格式)
4. [聚合查询](#聚合查询)
5. [核心端点](#核心端点)
6. [查询与过滤](#查询与过滤)
7. [分页与游标](#分页与游标)
8. [并发控制](#并发控制)
9. [错误处理](#错误处理)
10. [客户端实现指南](#客户端实现指南)
11. [性能优化技巧](#性能优化技巧)

## 简介

NexusBook API 是一个功能完整的文档管理和数据协作平台，提供统一的文档抽象、强大的数据管理、灵活的视图系统和完整的协作功能。本API参考文档详细说明了所有RESTful API端点的HTTP方法、URL模式、请求/响应模式和认证要求。

API使用TypeSpec定义并生成OpenAPI 3.0规范，通过Redocly提供交互式文档。API支持多种功能模块，包括文档管理、认证授权、扩展功能等，为开发者提供全面的集成能力。

**Section sources**
- [main.tsp](file://api/main.tsp#L17-L134)
- [README.md](file://README.md#L19-L29)

## API基础信息

| 项目 | 说明 |
|------|------|
| **API基址** | `https://open.nexusbook.com/api/v1` |
| **认证域名** | `https://auth.nexusbook.com` |
| **API规范** | OpenAPI 3.0 |
| **架构风格** | RESTful |
| **生成工具** | TypeSpec |
| **文档工具** | Redocly |

**Section sources**
- [main.tsp](file://api/main.tsp#L96-L97)
- [README.md](file://README.md#L9-L11)

## 统一响应格式

所有API响应遵循统一的`ApiResponse<T>`结构，确保客户端能够一致地处理成功和错误情况。

```json
{
  "success": boolean,
  "code": "ERROR_CODE",
  "message": {
    "zh": "中文错误信息",
    "en": "English error message"
  },
  "payload": T | null
}
```

### 响应字段说明

- **success**: 布尔值，表示请求是否成功
- **code**: 错误码（仅在失败时存在）
- **message**: 多语言消息对象，支持任意语言扩展
- **payload**: 实际数据载荷（仅在成功时存在）

**Section sources**
- [shared/common.tsp](file://api/shared/common.tsp#L153-L177)
- [docs-src/references/api-reference.md](file://docs-src/references/api-reference.md#L14-L25)

## 聚合查询

聚合查询接口允许客户端一次性获取文档所需的多种数据，减少网络请求次数，提高性能。

### 端点信息

```http
GET /api/v1/doc/{doc-type}/{doc-id}?include=metadata,views,data,comments,revisions,settings
```

### 查询参数

- **include**: 包含的数据部分（逗号分隔）
  - `metadata`: 字段定义
  - `views`: 视图列表
  - `data`: 数据行
  - `comments`: 评论
  - `revisions`: 修订历史
  - `settings`: 设置
- **viewId**: 指定视图ID
- **page**, **pageSize**: 分页参数
- **commentsLimit**, **revisionsLimit**: 限制返回数量

### 使用示例

```bash
# 获取产品文档的元数据、视图和数据
curl -H 'Authorization: Bearer TOKEN' \
  'https://open.nexusbook.com/api/v1/doc/product/123?include=metadata,views,data'
```

**Section sources**
- [document/aggregate/index.tsp](file://api/document/aggregate/index.tsp#L92-L126)
- [docs-src/references/api-reference.md](file://docs-src/references/api-reference.md#L58-L85)

## 核心端点

### 文档属性管理

管理文档级元信息（如订单时间、门店、金额、数量等）。

```http
GET /api/v1/doc/{doc-type}/{doc-id}/properties
POST /api/v1/doc/{doc-type}/{doc-id}/properties
PUT /api/v1/doc/{doc-type}/{doc-id}/properties
PATCH /api/v1/doc/{doc-type}/{doc-id}/properties?merge=true&version=1
DELETE /api/v1/doc/{doc-type}/{doc-id}/properties
GET /api/v1/doc/{doc-type}/{doc-id}/properties/history
```

### 元数据管理

管理字段定义、类型和验证配置。

```http
GET /api/v1/doc/{doc-type}/{doc-id}/metadata
PUT /api/v1/doc/{doc-type}/{doc-id}/metadata
```

### 视图管理

支持8种视图类型：表格、相册、看板、日历、图表、表单、地图、时间线。

```http
GET /api/v1/doc/{doc-type}/{doc-id}/views
POST /api/v1/doc/{doc-type}/{doc-id}/views
GET /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}
PUT /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}
DELETE /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}
POST /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}/default
```

### 数据行管理

数据行的CRUD操作，支持简单查询和结构化查询。

```http
GET /api/v1/doc/{doc-type}/{doc-id}/data?page=1&pageSize=20&sort=name:asc
POST /api/v1/doc/{doc-type}/{doc-id}/data/query
POST /api/v1/doc/{doc-type}/{doc-id}/data?requestId={request-id}
POST /api/v1/doc/{doc-type}/{doc-id}/data/bulk?requestId={request-id}
GET /api/v1/doc/{doc-type}/{doc-id}/data/{row-id}
PUT /api/v1/doc/{doc-type}/{doc-id}/data/{row-id}?requestId={request-id}
DELETE /api/v1/doc/{doc-type}/{doc-id}/data/{row-id}?requestId={request-id}
```

### 评论管理

支持在文档、字段、行、单元格等任何位置进行评论。

```http
GET /api/v1/doc/{doc-type}/{doc-id}/comments?scope=document|field|row|cell&fieldId=&rowId=
POST /api/v1/doc/{doc-type}/{doc-id}/comments
GET /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}
PUT /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}
DELETE /api/v1/doc/{doc-type}/{doc-id}/comments/{comment-id}
```

**Section sources**
- [document/core/data.tsp](file://api/document/core/data.tsp#L326-L542)
- [document/core/metadata.tsp](file://api/document/core/metadata.tsp#L183-L210)
- [document/core/views.tsp](file://api/document/core/views.tsp#L86-L170)
- [docs-src/references/api-reference.md](file://docs-src/references/api-reference.md#L86-L302)

## 查询与过滤

### 过滤操作符

支持多种过滤操作符，满足复杂的查询需求。

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

支持嵌套的过滤组合，实现复杂的查询逻辑。

```typescript
FilterGroup {
  logic: "and" | "or",
  conditions: Filter[],
  groups: FilterGroup[]  // 支持嵌套
}
```

### 排序

支持按字段进行升序或降序排序。

```typescript
Sort {
  field: string,
  direction: "asc" | "desc"
}
```

### 分组与聚合

支持数据分组和聚合计算。

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

**Section sources**
- [shared/common.tsp](file://api/shared/common.tsp#L210-L331)
- [docs-src/references/api-reference.md](file://docs-src/references/api-reference.md#L606-L650)

## 分页与游标

### 简单分页

使用`page`和`pageSize`参数进行简单分页。

```http
GET /api/v1/doc/{doc-type}/{doc-id}/data?page=1&pageSize=20
```

### 游标分页

对于深分页场景，使用游标分页避免性能问题。

```http
GET /api/v1/doc/{doc-type}/{doc-id}/data?cursor=abc123&pageSize=20
```

### 分页响应

分页响应包含完整的分页信息。

```json
{
  "items": [...],
  "page": 1,
  "pageSize": 20,
  "total": 100
}
```

**Section sources**
- [shared/common.tsp](file://api/shared/common.tsp#L179-L203)
- [document/core/data.tsp](file://api/document/core/data.tsp#L304-L315)

## 并发控制

数据行使用版本号进行乐观锁定，防止并发修改冲突。

### 版本号机制

- 每个数据行都有一个`version`字段
- 更新时需要提供当前版本号
- 如果版本号不匹配，返回冲突错误
- 客户端需要重新获取最新数据并重试

### 更新示例

```json
{
  "id": "row-123",
  "values": [...],
  "version": 1
}
```

```http
PUT /api/v1/doc/{doc-type}/{doc-id}/data/{row-id}
```

**Section sources**
- [document/core/data.tsp](file://api/document/core/data.tsp#L254-L262)
- [main.tsp](file://api/main.tsp#L92-L95)

## 错误处理

### 统一错误格式

所有错误响应遵循统一的格式，便于客户端处理。

```json
{
  "success": false,
  "code": "ERROR_CODE",
  "message": {
    "zh": "错误信息（中文）",
    "en": "Error message (English)"
  }
}
```

### 错误码分类

错误码按功能模块分类，便于识别和处理。

- **认证相关**: BAD_USER_NAME, INVALID_TOKEN, UNAUTHORIZED
- **文档相关**: DOC_NOT_FOUND, DOC_ACCESS_DENIED
- **数据相关**: ROW_NOT_FOUND, FIELD_TYPE_MISMATCH
- **用户相关**: USER_NOT_FOUND, USER_ALREADY_EXISTS

**Section sources**
- [shared/common.tsp](file://api/shared/common.tsp#L80-L151)
- [main.tsp](file://api/main.tsp#L71-L83)
- [docs-src/references/api-reference.md](file://docs-src/references/api-reference.md#L71-L83)

## 客户端实现指南

### 认证流程

所有API请求需要在请求头中包含有效的Bearer Token：

```http
Authorization: Bearer <access_token>
```

获取Token的方式：
1. 使用客户端凭证流程: POST /auth/token
2. 使用授权码流程: GET /auth/authorize + POST /auth/token

### 请求最佳实践

- 使用聚合查询减少请求数量
- 合理使用分页避免大数据量传输
- 处理并发冲突时实现重试机制
- 缓存元数据和视图配置提高性能

### 错误处理策略

- 统一处理错误响应格式
- 根据错误码进行分类处理
- 提供用户友好的错误提示
- 记录错误日志用于调试

**Section sources**
- [main.tsp](file://api/main.tsp#L60-L70)
- [docs-src/references/api-reference.md](file://docs-src/references/api-reference.md#L61-L65)

## 性能优化技巧

### 批量操作

使用批量更新接口减少网络往返次数。

```http
POST /api/v1/doc/{doc-type}/{doc-id}/data/bulk
```

### 数据缓存

- 缓存元数据和视图配置
- 使用ETag进行条件请求
- 实现本地数据缓存

### 查询优化

- 使用索引字段进行过滤
- 避免全表扫描
- 合理设置分页大小

### 连接管理

- 复用HTTP连接
- 使用连接池
- 合理设置超时时间

**Section sources**
- [document/core/data.tsp](file://api/document/core/data.tsp#L482-L490)
- [docs-src/references/api-reference.md](file://docs-src/references/api-reference.md#L203-L214)