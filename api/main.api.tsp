import "@typespec/http";
import "@typespec/openapi3";

import "./types/common.tsp";
import "./types/metadata.tsp";
import "./types/views.tsp";
import "./types/data.tsp";
import "./types/comments.tsp";
import "./types/revisions.tsp";
import "./types/requests.tsp";
import "./types/approvals.tsp";
import "./types/settings.tsp";

using TypeSpec.Http;
using OpenAPI;

@server("Open", "https://open.nexusbook.com/api/v1")
@service
@doc("""
NexusBook.Api 提供以 `/api/v1` 为前缀的业务 API，涵盖文档（Document）域的核心能力：

1) 文档聚合查询（DocBundle）：一次性获取 metadata/views/data/comments/revisions/settings，用于视图渲染。
2) 元数据（Metadata）：字段类型与校验、公式/查找/汇总配置。
3) 视图（Views）：过滤、排序、分组聚合与列配置，支持 CRUD 与设为默认视图。
4) 数据（Data）：分页与结构化查询（嵌套过滤、排序、分组/聚合）；行 CRUD 默认生成合并请求（merge-request），可用 `apply=true` 直接应用。
5) 评论（Comments）：文档/元字段/数据行/行字段的评论管理。
6) 修订（Revisions）：修订列表、详情、差异与回滚。
7) 合并请求（Requests）：未生效变更的评审/合并/关闭/重开与冲突检测，工作机制类似 git。
8) 审批（Approvals）：流程与实例、历史与决策（通过/拒绝）。
9) 设置（Settings）：文档级与类型级设置（默认视图、分享、权限与保留策略）。

统一响应结构 `ApiResponse<T>`：始终返回 HTTP 200；失败通过 `success=false + code(ErrorCode) + message(多语言)` 表达。
域名与安全：业务 API 在 `open.nexusbook.com` 域下；认证/OIDC 在 `auth.nexusbook.com`（授权与令牌、`/userinfo`、发现 `/.well-known/openid-configuration` 与 `JWKS`）。

NexusBook.Api exposes business APIs with `/api/v1` prefix under the Document domain: aggregate doc query, metadata, views, data (structured queries), comments, revisions, merge-requests, approvals and settings. Row mutations default to merge-requests; use `apply=true` to bypass. Standard `ApiResponse<T>` with HTTP 200 always; errors via `success=false + code + message`.
""")
namespace NexusBook.Api {}