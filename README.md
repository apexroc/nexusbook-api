# NexusBook API（TypeSpec）

> 中文 / English

## 概览 Overview
- API 基址 Base URL：`https://open.nexusbook.com/api/v1`
- 认证域名 Auth Domain：`https://auth.nexusbook.com`
- 版本 Version：所有业务接口以 `/api/v1` 开头 All business endpoints start with `/api/v1`
- 规范 Spec：使用 TypeSpec 定义并生成 OpenAPI 3.0 Generated OpenAPI 3.0 via TypeSpec

## 统一响应结构 Unified ApiResponse
- 结构 Structure：`ApiResponse<T>`
  - `success:boolean` 是否成功
  - `code:ErrorCode?` 错误码（失败时）
  - `message:{ zh:string; en:string }?` 多语言消息
  - `payload:T|null` 实际数据载荷
- 示例 Example：
```json
{
  "success": false,
  "code": "BAD_USER_NAME",
  "message": { "zh": "错误消息", "en": "error message" },
  "payload": null
}
```

## 认证与 OIDC Authentication & OIDC
- 端点 Endpoints（`auth.nexusbook.com`）：
  - `GET /.well-known/openid-configuration`
  - `GET /jwks.json`
  - `GET /authorize`（授权码流程 Authorization Code Flow）
  - `POST /token`（令牌 Token）
  - `GET /userinfo`（用户信息 User Info）
- Token 响应 Token Response：
  - `access_token`、`token_type: Bearer`、`expires_in`、`refresh_token?`、`scope?`
- 示例获取令牌 Example (Client Credentials)：
```bash
curl -X POST https://auth.nexusbook.com/token \
  -d 'grant_type=client_credentials' \
  -d 'client_id=YOUR_CLIENT_ID' \
  -d 'client_secret=YOUR_CLIENT_SECRET' \
  -d 'scope=doc:read data:read'
```
- 在业务 API 中使用 Bearer：
```bash
curl -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  https://open.nexusbook.com/api/v1/doc/product/123/metadata
```
- 建议 Scopes（参考）：`doc:read`、`doc:write`、`data:read`、`data:write`、`views:manage`、`comments:write`、`approvals:manage`、`requests:manage`

## 资源抽象 Resource Model
- Doc：`{doc-type}`（业务类型）+ `{doc-id}`（文档标识）
- 子资源 Sub-resources：`metadata`、`views`、`data`、`comments`、`revisions`、`requests`、`approval`、`settings`

## 字段与值 Field & Value（对齐多维表格 SaaS）
- 字段类型 FieldType：
  - `text|long_text|number|currency|percent|date|datetime|boolean|single_select|multi_select|attachment|user|collaborator|relation|lookup|rollup|formula|auto_number|created_time|updated_time|created_by|updated_by`
- 字段定义 Field：
  - `required|unique|readOnly|defaultValue|selectOptions[]|formula|lookup|rollup|validations[]`
- 值联合 Value Union（随字段类型不同而变化）：
  - 文本/数值/日期时间/选择（单选、多选）/附件/用户/关联 等

## 查询与视图 Query & Views
- 过滤与排序 Filters & Sorts：
  - 操作符 Operators：`eq|ne|in|range|contains|is_empty|is_not_empty`
  - 组合 Grouping：`FilterGroup{ logic: and|or, conditions[], groups[] }`
  - 排序 Sort：`Sort{ field, direction: asc|desc }`
- 分组与聚合 Group & Aggregation：
  - `GroupBy{ fields[], aggregations[] }`，聚合函数 `count|sum|avg|min|max`
- 视图 View：
  - `type: grid|gallery|kanban|document`、`displayFields[]`、`filters`、`sorts[]`、`group`、`columnConfig{ width/order/pinned/hidden }`

## 主要端点 Key Endpoints
- Doc 根 Root：`GET /api/v1/doc/{doc-type}/{doc-id}`（说明性占位，可用于健康/权限校验）
- Metadata：
  - `GET /api/v1/doc/{doc-type}/{doc-id}/metadata`
  - `PUT /api/v1/doc/{doc-type}/{doc-id}/metadata`
- Views：
  - `GET|POST /api/v1/doc/{doc-type}/{doc-id}/views`
  - `GET|PUT|DELETE /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}`
  - `POST /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}/default`
- Data：
  - `GET /api/v1/doc/{doc-type}/{doc-id}/data?page=&pageSize=&sort=&filter=&group=&cursor=`
  - 结构化查询 Structured Query：`POST /api/v1/doc/{doc-type}/{doc-id}/data/query`（体含 `filters/sorts/group/page/pageSize/cursor`）
  - 行操作 Row Ops：`POST /data`、`POST /data/bulk`、`GET|PUT|DELETE /data/{rowId}`
- Comments：
  - 文档级 Doc：`GET|POST /comments`
  - 元字段 Field：`GET|POST /metadata/{fieldId}/comments`
  - 行 Row：`GET|POST /rows/{rowId}/comments`
  - 行字段 Row Field：`GET|POST /rows/{rowId}/fields/{fieldId}/comments`
- Revisions：
  - `GET /revisions`、`GET /revisions/{revId}`、`GET /revisions/{revId}/diff?base=...`、`POST /revisions/{revId}/revert`
- Requests（未生效合并）：
  - `GET|POST /requests`、`GET /requests/{reqId}`、`POST /requests/{reqId}/merge|close|reopen`、`GET /requests/{reqId}/conflicts`
- Approvals：
  - `GET /approval`、`POST /approval/start`、`GET /approval/{instanceId}`、`POST /approval/{instanceId}/decision?result=approved|rejected`
- Settings：
  - 文档级 Doc-level：`GET|PUT /settings`
  - 文档类型公共 Type-level：`GET|PUT /doc/{doc-type}/setting`

## 错误码 Error Codes
- 统一枚举 Unified Enum：`ErrorCode`
  - 认证 Auth：`BAD_USER_NAME|INVALID_CLIENT|INVALID_TOKEN|UNAUTHORIZED|FORBIDDEN`
  - 文档 Doc：`DOC_NOT_FOUND|DOC_TYPE_UNKNOWN|DOC_ACCESS_DENIED`
  - 视图 View：`VIEW_NOT_FOUND|VIEW_INVALID_DEFINITION`
  - 数据 Data：`ROW_NOT_FOUND|FIELD_TYPE_MISMATCH|CONSTRAINT_VIOLATION|PAGE_OUT_OF_RANGE`
  - 评论 Comments：`COMMENT_NOT_FOUND`
  - 审批 Approvals：`APPROVAL_NOT_FOUND|APPROVAL_INVALID_STATE|APPROVAL_DECISION_REQUIRED`
  - 请求合并 Requests：`REQUEST_NOT_FOUND|REQUEST_CONFLICT|REQUEST_ALREADY_CLOSED`

## 生成与预览 Generate & Inspect
- 安装依赖 Install deps：
```bash
make deps
```
- 生成 OpenAPI 文档 Generate OpenAPI：
```bash
make openapi
# 输出 Output:
# dist/api/@typespec/openapi3/openapi.yaml
# dist/auth/@typespec/openapi3/openapi.yaml
```
- 清理 Clean：
```bash
make clean
```

## 目录结构 Project Layout
```text
api/
  main.api.tsp        # 业务服务 Business service (NexusBook.Api)
  main.auth.tsp       # 认证服务 Auth service (NexusBook.Auth)
  types/
    common.tsp        # 通用模型 Common models (ApiResponse, Filter, GroupBy, Value...)
    auth.tsp          # OAuth2/OIDC 模型 Auth models
    doc.tsp           # Doc 标识 Doc identifiers
    metadata.tsp      # 字段与元数据 Field & metadata
    views.tsp         # 视图 View definitions
    data.tsp          # 数据与查询 Data & query
    comments.tsp      # 评论 Comments
    revisions.tsp     # 修订与回滚 Revisions & revert
    requests.tsp      # 未生效合并 Requests
    approvals.tsp     # 审批流程 Approvals
    settings.tsp      # 设置 Settings
```

## 最佳实践 Best Practices
- 始终使用 Bearer 令牌访问受保护端点 Always use Bearer token for protected endpoints
- 错误统一落在 `ApiResponse.code/message`，HTTP 状态保持 200 Errors via `ApiResponse.code/message`, HTTP status stays 200
- 复杂查询推荐使用 `POST /data/query`（结构化过滤、分组与聚合） Prefer `POST /data/query` for complex queries
- 保持 `doc-type` 由后端 Provider 解析并路由 Use provider to resolve `doc-type`

## 变更与审计 Change & Audit
- `Revision` 记录变更集，支持差异与回滚 Revisions track changes; supports diff & revert
- `Approval` 支持流程与节点历史 Approvals capture workflow & node history
- `Request` 管理未生效变更合并 Reviews & merges uncommitted changes

如需更多示例（Examples）或安全方案（Security Schemes）在 OpenAPI 中的直接标注，请告知，我将补充到 TypeSpec 并重新生成文档。