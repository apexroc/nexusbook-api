## 更新目标
- 修正斜杠乱码，统一业务路由前缀为 `/api/v1`。
- 明确双域架构：`open.nexusbook.app`（业务 API）与 `auth.nexusbook.app`（认证/OIDC）。
- 更正并统一 `ApiResponse` 示例与字段拼写（`sucess` → `success`）。
- 完善 TypeSpec 目录结构、模块拆分与 Makefile 生成与预览说明。
- 规范 Doc 顶层路由与子资源设计，并修复重复项与表述不一致。

## 文件范围
- 仅更新：`/Users/eric/Desktop/personal/NexusBook.AI/nexusbook-api/STORY.md`

## 结构调整与新增章节
1. 在“技术需求”之后新增“域名与路由约定”章节：
   - API 基址：`https://open.nexusbook.app/api/v1`
   - Auth 基址：`https://auth.nexusbook.app`
   - OIDC 发现：`https://auth.nexusbook.app/.well-known/openid-configuration`
   - JWKS：`https://auth.nexusbook.app/jwks.json`
2. 在“生成要求”章节中：
   - 指定双命名空间：业务 `NexusBook.Api` 与认证 `NexusBook.Auth`
   - 更正 `ApiResponse` JSON 示例并说明多语言 `message` 字典
   - 补充 TypeSpec 目录结构与模块拆分建议
   - 扩展 Makefile 目标，输出两份 OpenAPI 文档与查看器预览
3. 在“Doc 的设计思路”章节中：
   - 统一子资源路由：`/api/v1/doc/{doc-type}/{doc-id}/revision|views|comments|approval|request|metadata|settings`
   - 修复重复的 `approval` 项；保留一个并分别描述 `approval` 与 `request`
   - 明确公共配置：`/api/v1/doc/{doc-type}/setting`

## 精确修改内容（拟稿）
- 更正 `ApiResponse` 示例：
```json
{
  "success": false,
  "code": "BAD_USER_NAME",
  "message": { "zh": "错误消息", "en": "error message" },
  "payload": null
}
```
- 新增“域名与路由约定”段落（中文说明，简洁明了）。
- 统一所有路由展示为以 `/api/v1` 开头的形式，避免 `\u002F` 乱码。
- 增补 TypeSpec 模块与目录结构清单：
  - `api/main.tsp`（入口与 emit 配置）
  - `api/types/common.tsp`（`ApiResponse`、`Message`、分页/排序/过滤、错误码）
  - `api/types/auth.tsp`（OAuth2/OIDC 端点与模型）
  - `api/types/doc.tsp`（顶层 Doc 模型与路由）
  - `api/types/metadata.tsp`、`views.tsp`、`data.tsp`、`comments.tsp`、`revisions.tsp`、`requests.tsp`、`approvals.tsp`、`settings.tsp`
- Makefile 目标：
  - `openapi`：生成 `dist/openapi.api.yaml` 与 `dist/openapi.auth.yaml`
  - `preview`：打开 API 查看器（TypeSpec preview 或 Redoc/Swagger UI）
  - `clean`：清理生成产物

## 文案优化与一致性
- 保留原始业务背景与 Doc 抽象描述；对术语进行统一（如“请求合并”与“审批”分属不同模块）。
- 所有英文缩写与端点以标准形式呈现，确保易读与可实现性。

## 交付与验收
- 修改后的 `STORY.md` 完整呈现双域架构、路由规范、统一响应结构、模块拆分与生成预览说明。
- 内容无拼写错误、示例 JSON 可直接复制使用；路由与端点一致、无重复。

## 后续拓展（可选）
- 增加“安全与跨域”小节：Bearer 校验、Scopes 与资源映射、CORS 与 Cookie 策略说明。
- 增加 OpenAPI 示例（examples）片段以提升可读性与对接效率。

确认后，我将按照以上计划直接更新 `STORY.md`。