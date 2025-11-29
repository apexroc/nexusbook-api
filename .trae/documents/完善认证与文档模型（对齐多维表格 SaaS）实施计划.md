## 目标与原则
- 以 TypeSpec 定义完整的认证（OAuth2/OIDC）与文档（Doc）模型，覆盖多维表格 SaaS 能力。
- 双域：open.nexusbook.com（API）、auth.nexusbook.com（认证）。所有业务路由以 `/api/v1` 开头。
- 统一响应结构 `ApiResponse<T>`，错误码枚举化，双语文档注释（中文/English）。

## 认证模型完善（Auth）
- 客户端与权限：
  - Client：`client_id`、`client_name`、`grant_types`、`redirect_uris[]`、`scopes[]`、`token_endpoint_auth_method`。
  - Scope：`doc:read|doc:write|data:read|data:write|views:manage|comments:write|approvals:manage|requests:manage`。
- OAuth2 响应：
  - TokenResponse：`access_token`、`token_type`（Bearer）、`expires_in`、`refresh_token?`、`scope`。
  - ErrorResponse：`error`、`error_description`、`error_uri?`（映射到统一 `ApiResponse`）。
- OIDC 模型：
  - ProviderMetadata：`issuer`、`authorization_endpoint`、`token_endpoint`、`userinfo_endpoint`、`jwks_uri`、`scopes_supported[]`、`response_types_supported[]`、`grant_types_supported[]`、`id_token_signing_alg_values_supported[]`、`claims_supported[]`。
  - JWKS：`keys[]`（`kty`、`kid`、`use`、`alg`、`n/e` 或 `crv/x/y`）。
  - UserInfo Claims：`sub`、`name`、`preferred_username`、`email`、`email_verified`、`locale`、`updated_at`、`picture?`、`roles[]`、`tenants[]`。
- 授权请求与同意：
  - AuthorizationRequest：`response_type`、`client_id`、`redirect_uri`、`scope`、`state`、`code_challenge?`、`code_challenge_method?`。
  - Consent：`accepted_scopes[]`、`rejected_scopes[]`、`purpose`、`expires_at?`。
- 安全与密钥轮转：
  - KeyRotationPolicy：`rotation_interval`、`overlap_window`、`deprecation_notice_days`。

## 文档与多维表格模型完善（Api）
- 字段类型与值模型：
  - FieldType：`text|long_text|number|currency|percent|boolean|date|datetime|duration|rating|single_select|multi_select|attachment|user|collaborator|relation|lookup|rollup|formula|auto_number|created_time|updated_time|created_by|updated_by`。
  - SelectOption：`id`、`label`、`color?`、`disabled?`。
  - Attachment：`id`、`fileName`、`url`、`mimeType`、`size`、`checksum?`、`width?`、`height?`、`createdAt`、`createdBy`。
  - UserRef：`id`、`displayName`、`email?`、`avatarUrl?`。
  - RelationRef：`targetDocType`、`targetDocId`、`rowId`。
  - Value（联合）：根据 `FieldType` 对应结构（如 `text:string`、`number:float64`、`date: string(ISO8601)`、`single_select: SelectOption`、`multi_select: SelectOption[]`、`attachment: Attachment[]`、`user: UserRef`、`relation: RelationRef[]` 等）。
- 字段定义与校验：
  - Field：`id`、`name`、`type: FieldType`、`required?`、`unique?`、`readOnly?`、`defaultValue?`、`options?`（选择类）。
  - ValidationRule：`ruleType`（`regex|min|max|length|range|before|after|includes|excludes|unique`）、`config`、`message`（双语）。
  - Computed：`formula?`（表达式字符串）/`lookup?`（指向 relation 字段与目标字段）/`rollup?`（`fn: count|sum|avg|min|max` + 目标字段）。
- 视图与查询：
  - ViewType：`grid|gallery|kanban|document`。
  - View：`id`、`name`、`type`、`displayFields[]`、`filters: FilterGroup`、`sorts[]`、`group: GroupBy`、`columnConfig{ width/order/pinned/visibility }`、`conditionalFormatting[]`。
  - Filter/FilterGroup：支持嵌套 AND/OR 组合，条件为 `field + operator(eq/ne/in/range/contains/is_empty/is_not_empty)` + 值。
  - Aggregation：`kind(count|sum|avg|min|max)`、`field`。
- 数据与批量：
  - Row：`id`、`values: Record<string, Value>`、`createdAt/By`、`updatedAt/By`、`version`。
  - 批量：`bulk` 输入支持 `create[]|update[]|delete[]`，返回逐项结果与错误。
  - 并发：ETag/`version` 检测，`preconditionFailed` 错误码。
  - 查询端点：新增 `POST /data/query` 接收结构化 `filters[]`、`sorts[]`、`group`、`page/pageSize/cursor`。
- 评论与协作：
  - Comment：`id`、`content`（支持富文本）`mentions: UserRef[]`、`attachments: Attachment[]`、`reactions{ like/thumbs_up/... }`、`pinned?`、`createdAt/By`、`updatedAt/By`、`location{ doc|metadata.field|row|row.field }`。
  - 线程：`parentId?` 支持回复与折叠。
- 修订与差异：
  - Revision：`id`、`author`、`createdAt`、`changes[]`（`op: add|remove|replace`、`path`、`before/after`），支持 Diff 视图。
  - Revert：`POST /revisions/{revId}/revert`，生成新的修订。
- 请求合并（未生效变更）：
  - Request：`id`、`title`、`description`、`status(open|merged|closed)`、`author`、`reviewers[]`、`changes[]`、`createdAt/updatedAt`、`mergeStrategy`、`conflicts[]`。
  - 操作：`merge`、`close`、`reopen`，与审批可联动。
- 审批流程：
  - Flow：`id`、`name`、`version`、`nodes[]`（`type: approve|review|auto`，`assignees`，`conditions`，`actions`）`transitions[]`。
  - Instance：`id`、`status(pending|approved|rejected|canceled)`、`currentNode`、`history[]`。
  - 决策：`POST decision?result=approved|rejected&comment=...`。
- 设置与权限：
  - Settings：`defaultViewId`、`sharing{ publicLinkEnabled, password? }`、`permissions{ rolePolicies }`、`retention{ revisions }`。
  - 权限策略：`role(name)` → `permissions{ doc|view|field|row }`（读/写/管理），支持行/字段级限制。

## 端点优化与扩展
- 结构化查询端点：`POST /api/v1/doc/{doc-type}/{doc-id}/data/query`，请求体为 `filters/sorts/group/page/pageSize/cursor`。
- 修订回滚端点：`POST /api/v1/doc/{doc-type}/{doc-id}/revisions/{revId}/revert`。
- 请求合并：新增 `POST /requests/{reqId}/reopen` 与冲突检测端点 `GET /requests/{reqId}/conflicts`。
- 视图：新增 `POST /views/{viewId}/share`（生成只读分享链接）。

## 双语注释约定
- 所有模型与端点使用 TypeSpec 文档注释：
  - 中文说明在前，English 说明在后，以 `///` 注释方式嵌入。
  - 关键属性给出示例与使用建议（如过滤、聚合、并发控制）。

## TypeSpec 文件改造清单
- `api/types/common.tsp`：`ErrorCode`、`Message`、`ApiResponse`、分页、排序/过滤、聚合/分组、值类型辅助枚举与接口。
- `api/types/auth.tsp`：`Client`、`Scope`、`TokenResponse`、`ErrorResponse`、`ProviderMetadata`、`JWK`、`UserInfo`、`AuthorizationRequest`、`Consent`、`KeyRotationPolicy` 与双语注释。
- `api/types/metadata.tsp`：`FieldType`、`Field`、`ValidationRule`、`Computed`（`formula|lookup|rollup`）与端点注释。
- `api/types/views.tsp`：`ViewType`、`View`、`FilterGroup`、`ColumnConfig`、`ConditionalFormatting`、端点扩展与注释。
- `api/types/data.tsp`：`Value` 联合、`Row` 完整结构、`POST /data/query`、批量/并发模型与注释。
- `api/types/comments.tsp`：`Comment`、`Thread`、挂载点模型与注释。
- `api/types/revisions.tsp`：`Change`、`Revision`、`Revert` 端点与注释。
- `api/types/requests.tsp`：`Request` 完整结构、冲突与重开端点与注释。
- `api/types/approvals.tsp`：`Flow`、`Node`、`Transition`、`Instance`、`Decision` 与注释。
- `api/types/settings.tsp`：`Settings`、`Sharing`、`Permissions`、`Retention` 与注释。

## 错误码与安全方案集成
- 在业务 OpenAPI 中声明 OAuth2 安全组件（`authorizationUrl`、`tokenUrl` 指向 `auth.nexusbook.com`）。
- 受保护端点标注所需 Scopes；在示例中展示 `success=false + code + message` 的统一错误返回。

## 验证与交付
- 编译通过（无错误），OpenAPI 校验通过。
- 每个模型与端点附带中英文注释；提供示例请求/响应（examples）。
- 交付：更新后的 TypeSpec 文件与两份 OpenAPI，Makefile 保持可生成。

## 里程碑
- M1：补齐 Auth 与 Common 的模型与注释。
- M2：完善 Doc/Metadata/Views/Data（含值联合、结构化查询）。
- M3：协作（Comments/Requests/Revisions/Approvals）与端点扩展。
- M4：安全方案与示例补充、全面注释审校。

确认后我将按上述清单逐文件补充模型与注释，并保证重新生成的 OpenAPI 可用。