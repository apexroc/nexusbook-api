## 域名与版本
- API 域名：`https://open.nexusbook.app/api/v1`
- 认证域名：`https://auth.nexusbook.app`
- OIDC 发现：`https://auth.nexusbook.app/.well-known/openid-configuration`；JWKS：`https://auth.nexusbook.app/jwks.json`

## 统一响应与错误码
- 统一响应：`ApiResponse<T>`（始终 HTTP 200）
  - `success:boolean`、`code:string`、`message:{ zh:string; en:string; ... }`、`payload:T|null`
- 错误码前缀：`AUTH_*`、`DOC_*`、`VIEW_*`、`DATA_*`、`COMMENT_*`、`APPROVAL_*`、`REQUEST_*`
- 示例：
  - `{ "success": false, "code": "BAD_USER_NAME", "message": { "zh": "错误消息", "en": "error message" }, "payload": null }`

## 安全与鉴权（OAuth2/OIDC）
- 授权码与客户端凭证流；`/authorize`、`/token`、`/userinfo`
- OpenAPI 安全组件在 API 文档中引用 `authorizationUrl` 与 `tokenUrl` 指向 `auth.nexusbook.app`
- Scopes（建议）：`doc:read`、`doc:write`、`data:read`、`data:write`、`views:manage`、`comments:write`、`approvals:manage`、`requests:manage`
- API 以 `Authorization: Bearer <token>` 保护；必要时在端点标注所需 Scope

## 资源模型
- Doc：`{doc-type}`（业务类型枚举/字符串），`{doc-id}`（文档标识）
- Metadata：字段集合（类型：`text|number|date|boolean|single_select|multi_select|attachment|user|relation`）、分组、显示配置
- Views：过滤（操作符 `=, !=, in, range, contains`）、展示字段、排序（多字段）、分组与聚合（count/sum/avg）
- Data：`Row{id, values: map<string, any>}`，分页与批量操作
- Comments：挂载点 `doc | metadata.field | row | row.field`
- Revisions：变更集记录、列表查询与差异对比
- Requests：未生效变更，请求合并的生命周期（创建、评审、合并、关闭）
- Approvals：流程、节点、条件、动作、结果；状态 `pending|approved|rejected|canceled`
- Settings：文档个性化设置；文档类型公共配置

## 路由设计（API）
- Doc 根：`/api/v1/doc/{doc-type}/{doc-id}`
- Metadata：
  - `GET /api/v1/doc/{doc-type}/{doc-id}/metadata`
  - `PUT /api/v1/doc/{doc-type}/{doc-id}/metadata`
- Views：
  - `GET /api/v1/doc/{doc-type}/{doc-id}/views`
  - `POST /api/v1/doc/{doc-type}/{doc-id}/views`
  - `GET /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}`
  - `PUT /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}`
  - `DELETE /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}`
  - `POST /api/v1/doc/{doc-type}/{doc-id}/views/{view-id}/default`
- Data（分页与批量）：
  - `GET /api/v1/doc/{doc-type}/{doc-id}/data`（`page,pageSize,sort,filter,group`）
  - `POST /api/v1/doc/{doc-type}/{doc-id}/data`（创建单条）
  - `POST /api/v1/doc/{doc-type}/{doc-id}/data/bulk`（批量创建/更新/删除）
  - `GET /api/v1/doc/{doc-type}/{doc-id}/data/{row-id}`
  - `PUT /api/v1/doc/{doc-type}/{doc-id}/data/{row-id}`
  - `DELETE /api/v1/doc/{doc-type}/{doc-id}/data/{row-id}`
- Comments（统一挂载路径）：
  - 文档级：`/api/v1/doc/{doc-type}/{doc-id}/comments`
  - 元字段：`/api/v1/doc/{doc-type}/{doc-id}/metadata/{field-id}/comments`
  - 数据行：`/api/v1/doc/{doc-type}/{doc-id}/rows/{row-id}/comments`
  - 行字段：`/api/v1/doc/{doc-type}/{doc-id}/rows/{row-id}/fields/{field-id}/comments`
  - 所有以上路径支持：`GET 列表`、`POST 创建`、`GET/{comment-id}`、`PUT/{comment-id}`、`DELETE/{comment-id}`
- Revisions：
  - `GET /api/v1/doc/{doc-type}/{doc-id}/revisions`
  - `GET /api/v1/doc/{doc-type}/{doc-id}/revisions/{rev-id}`
  - `GET /api/v1/doc/{doc-type}/{doc-id}/revisions/{rev-id}/diff?base={rev-id}`
- Requests（未生效合并）：
  - `GET /api/v1/doc/{doc-type}/{doc-id}/requests`
  - `POST /api/v1/doc/{doc-type}/{doc-id}/requests`
  - `GET /api/v1/doc/{doc-type}/{doc-id}/requests/{req-id}`
  - `POST /api/v1/doc/{doc-type}/{doc-id}/requests/{req-id}/merge`
  - `POST /api/v1/doc/{doc-type}/{doc-id}/requests/{req-id}/close`
- Approvals：
  - `GET /api/v1/doc/{doc-type}/{doc-id}/approval`（流程定义/实例）
  - `POST /api/v1/doc/{doc-type}/{doc-id}/approval/start`
  - `GET /api/v1/doc/{doc-type}/{doc-id}/approval/{instance-id}`
  - `POST /api/v1/doc/{doc-type}/{doc-id}/approval/{instance-id}/decision`（`approved|rejected`）
- Settings：
  - 文档级：`GET|PUT /api/v1/doc/{doc-type}/{doc-id}/settings`
  - 文档类型公共配置：`GET|PUT /api/v1/doc/{doc-type}/setting`

## 查询与分页规范
- 分页：`page`（默认 1）、`pageSize`（默认 20，最大 200），返回 `total`
- 排序：`sort=field:asc,other:desc`
- 过滤：DSL 或结构化表达：`filter=field:eq:value`、`field:in:[...]`、`field:range:start,end`、`field:contains:substr`
- 分组与聚合：`group=field1,field2`；`agg=count(field),sum(field)`
- 游标（可选）：`cursor` 与 `nextCursor` 扩展

## TypeSpec 目录结构
- `api/main.tsp`：入口（注册 `NexusBook.Api` 与 `NexusBook.Auth`，emit OpenAPI）
- `api/types/common.tsp`：`ApiResponse<T>`、`Message`、分页/排序/过滤、错误码
- `api/types/auth.tsp`：OAuth2/OIDC 端点与模型（`authorize`、`token`、`userinfo`、`openid-configuration`、`jwks.json`）
- `api/types/doc.tsp`：Doc 顶层模型与根路由
- `api/types/metadata.tsp`、`views.tsp`、`data.tsp`、`comments.tsp`、`revisions.tsp`、`requests.tsp`、`approvals.tsp`、`settings.tsp`

## OpenAPI 生成与查看
- 依赖：`@typespec/http`、`@typespec/openapi3`
- Makefile 目标：
  - `openapi`：生成 `dist/openapi.api.yaml`（业务）与 `dist/openapi.auth.yaml`（认证）
  - `preview`：打开文档查看器（TypeSpec preview 或 Redoc/Swagger UI）
  - `clean`：清理产物

## 约定与实践
- 幂等：`PUT`、`DELETE` 幂等；批量操作提供去重与结果报告
- 资源标识：路径参数使用短 ID，避免泄露内键；`{doc-type}` 由 Provider 解析
- 国际化：`message` 至少包含 `zh`、`en`，可扩展更多语言键
- CORS 与 Cookie：跨域放行前端域；Cookie 使用 `Secure`、`SameSite=None`

## 验证与质量门槛
- TypeSpec 编译无警告；OpenAPI 校验通过
- 统一响应结构与错误码覆盖；示例请求/响应齐备
- 安全方案与 Scope 标注完整；受保护端点均声明所需权限

## 里程碑与交付
- M1：骨架与通用模型（`main.tsp`、`common.tsp`、Makefile）
- M2：Doc/Metadata/Views/Data 基础 CRUD
- M3：Comments/Revisions/Requests/Approvals 完整
- M4：Auth/OIDC 端点与安全组件绑定
- M5：Viewer、示例完善与一致性校验
- 交付：`api/` 模块与 TypeSpec 文件、`dist/openapi.api.yaml` 与 `dist/openapi.auth.yaml`、Makefile、错误码清单与说明