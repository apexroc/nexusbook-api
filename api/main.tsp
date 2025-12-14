import "@typespec/http";
import "@typespec/openapi3";

import "./shared/index.tsp";
import "./auth/index.tsp";
import "./tenant/index.tsp";
import "./document/index.tsp";
import "./extensions/index.tsp";
import "./i18n/index.tsp";
import "./preferences/index.tsp";
import "./billing/index.tsp";
import "./audit/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * NexusBook OpenAPI
 *
 * 🚀 **NexusBook** 是一个功能强大的开源文档管理和数据协作平台，为企业提供灵活的结构化数据管理、实时协作和供应链数据协同能力。
 *
 * ---
 *
 * ## ✨ 核心特性
 *
 * ### 📋 灵活的文档模型
 * - **25+ 种字段类型**：文本、数字、日期、附件、关联等
 * - **多视图支持**：表格、相册、看板、日历、文档视图
 * - **自定义字段**：支持不同行业的个性化扩展
 * - **版本控制**：完整的修订历史和回溯能力
 *
 * ### 🤝 实时协作
 * - **多层级评论**：文档级、字段级、行级评论系统
 * - **审批工作流**：可配置的变更审批流程
 * - **请求与合并**：类 Git 的数据变更管理
 * - **并发控制**：基于版本号的乐观锁机制
 *
 * ### 🔗 供应链数据协同
 * - **Catalog（商品目录）**：供应商管理商品数据，支持行业自定义字段
 * - **OrderBook（订货本）**：采购商基于 Connection 创建订货视图
 * - **Connection（连接）**：供应商与采购商的数据共享通道
 * - **字段映射**：支持类型转换、单位转换、选项映射等 8 种转换类型
 * - **智能过滤**：嵌套条件组和自动接受/拒绝规则
 * - **中间商支持**：二级分销和多级数据传导
 *
 * ### 🔌 扩展能力
 * - **Webhooks**：事件驱动的通知机制
 * - **自动化集成**：支持 Zapier、Make 等自动化平台
 * - **API Keys**：安全的服务间调用
 * - **OAuth2/OIDC**：企业级身份认证集成
 *
 * ---
 *
 * ## 🏗️ API 架构
 *
 * ### 主要命名空间
 *
 * #### 1️⃣ 文档管理 (`/api/v1/doc`)
 * - **Metadata（元数据）**：字段定义、类型配置、验证规则
 * - **Views（视图）**：表格/相册/看板/日历/文档视图管理
 * - **Data（数据）**：结构化数据行的 CRUD 操作
 * - **Revisions（修订）**：版本历史和回溯
 * - **Comments（评论）**：多层级评论系统
 * - **Approvals（审批）**：工作流审批管理
 * - **Requests（请求）**：变更请求和合并
 * - **Settings（设置）**：文档级和类型级配置
 *
 * #### 2️⃣ 供应链协同 (`/api/v1/organizations/{orgId}`)
 * - **Catalog**：商品目录管理，支持自定义字段
 * - **OrderBook**：订货本管理，基于 Connection 自动生成
 * - **Connection**：供应商-采购商数据连接（Outbound）
 * - **Binding**：订货本数据绑定配置（Inbound），支持字段映射和接收过滤
 * - **Connector**：组织内文档转换器（OrderBook → Catalog）
 *
 * #### 3️⃣ 租户管理 (`/api/v1/users`, `/api/v1/organizations`, `/api/v1/workspaces`)
 * - **Users**：用户信息和偏好设置
 * - **Organizations**：组织管理和成员邀请
 * - **Workspaces**：工作区管理和权限控制
 *
 * #### 4️⃣ 扩展功能
 * - **Webhooks** (`/api/v1/webhooks`)：事件订阅和投递管理
 * - **I18n** (`/api/v1/i18n`)：国际化翻译服务
 * - **Billing** (`/api/v1/billing`)：订阅和计费管理
 * - **Audit** (`/api/v1/audit`)：审计日志查询
 *
 * ---
 *
 * ## 🚀 快速开始
 *
 * ### 认证
 *
 * 所有 API 请求需要在请求头中包含有效的 Bearer Token：
 *
 * ```http
 * Authorization: Bearer <access_token>
 * ```
 *
 * **获取 Token 的方式**：
 * 1. **客户端凭证流程**（服务间调用）：`POST /auth/token`
 * 2. **授权码流程**（用户授权）：`GET /auth/authorize` → `POST /auth/token`
 * 3. **API Keys**：适用于 Webhook 验证和自动化集成
 *
 * ### 基础调用示例
 *
 * ```bash
 * # 1. 获取聚合文档包（包含元数据、视图和数据）
 * curl -H 'Authorization: Bearer TOKEN' \
 *   'https://open.nexusbook.app/api/v1/doc/product/doc-123?include=metadata,views,data'
 *
 * # 2. 创建数据行
 * curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/doc-123/data' \
 *   -H 'Authorization: Bearer TOKEN' \
 *   -H 'Content-Type: application/json' \
 *   -d '{
 *     "id": "row-1",
 *     "values": [
 *       {"fieldId": "name", "value": {"text": "iPhone 15 Pro"}},
 *       {"fieldId": "price", "value": {"number": 7999}},
 *       {"fieldId": "stock", "value": {"number": 100}}
 *     ]
 *   }'
 *
 * # 3. 查询数据（高级查询）
 * curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/doc-123/data/query' \
 *   -H 'Authorization: Bearer TOKEN' \
 *   -H 'Content-Type: application/json' \
 *   -d '{
 *     "filter": {
 *       "and": [
 *         {"field": "price", "op": "gte", "value": 5000},
 *         {"field": "stock", "op": "gt", "value": 0}
 *       ]
 *     },
 *     "sort": [{"field": "price", "order": "desc"}],
 *     "page": 1,
 *     "pageSize": 20
 *   }'
 * ```
 *
 * ### 供应链协同示例
 *
 * ```bash
 * # 1. 供应商创建 Catalog
 * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs' \
 *   -H 'Authorization: Bearer TOKEN' \
 *   -d '{
 *     "name": "电子产品目录",
 *     "catalogType": "product",
 *     "fields": [
 *       {"name": "品牌", "type": "text", "required": true},
 *       {"name": "型号", "type": "text", "required": true},
 *       {"name": "价格", "type": "currency", "required": true}
 *     ]
 *   }'
 *
 * # 2. 供应商创建 Connection 并分享
 * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs/cat-456/connections' \
 *   -H 'Authorization: Bearer TOKEN' \
 *   -d '{
 *     "name": "华东地区分销商",
 *     "shareScope": {"type": "all"},
 *     "accessControl": "public"
 *   }'
 *
 * # 3. 采购商接受连接并创建 OrderBook
 * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-789/orderbooks' \
 *   -H 'Authorization: Bearer TOKEN' \
 *   -d '{
 *     "name": "供应商A订货本",
 *     "sourceConnectionIds": ["conn-111"]
 *   }'
 *
 * # 4. 采购商配置 Binding（字段映射和过滤）
 * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-789/orderbooks/ob-222/bindings' \
 *   -H 'Authorization: Bearer TOKEN' \
 *   -d '{
 *     "connectionId": "conn-111",
 *     "fieldMapping": [
 *       {"sourceFieldId": "price", "targetFieldId": "cost", "transformType": "unit_convert",
 *        "unitConversion": {"fromUnit": "USD", "toUnit": "CNY", "rate": 7.2}}
 *     ],
 *     "receiverFilter": {
 *       "acceptMode": "selective",
 *       "filterGroup": {
 *         "operator": "AND",
 *         "conditions": [{"field": "price", "op": "lte", "value": 10000}]
 *       }
 *     }
 *   }'
 * ```
 *
 * ---
 *
 * ## 📖 核心概念
 *
 * ### 文档包（Document Package）
 *
 * NexusBook 的文档包含三个核心部分：
 * - **Metadata**：定义文档结构（字段、类型、验证规则）
 * - **Views**：定义数据展示方式（表格、看板、相册等）
 * - **Data**：实际的结构化数据行
 *
 * ### 并发控制
 *
 * 所有数据行更新操作使用**版本号（version）**进行乐观锁控制：
 * ```json
 * {
 *   "id": "row-1",
 *   "version": 3,  // 必须提供当前版本号
 *   "values": [...]
 * }
 * ```
 * 如果版本号不匹配，API 将返回 `409 Conflict` 错误。
 *
 * ### 错误处理
 *
 * 所有错误响应遵循统一格式：
 * ```json
 * {
 *   "success": false,
 *   "code": "ERROR_CODE",
 *   "message": {
 *     "zh": "错误信息（中文）",
 *     "en": "Error message (English)"
 *   },
 *   "details": {  // 可选，提供额外的错误上下文
 *     "field": "price",
 *     "reason": "validation_failed"
 *   }
 * }
 * ```
 *
 * **常见错误码**：
 * - `UNAUTHORIZED`：未授权或 Token 无效
 * - `FORBIDDEN`：权限不足
 * - `NOT_FOUND`：资源不存在
 * - `VALIDATION_ERROR`：请求参数验证失败
 * - `CONFLICT`：并发冲突（版本号不匹配）
 * - `RATE_LIMIT_EXCEEDED`：请求频率超限
 *
 * ### 分页和查询
 *
 * #### 简单分页
 * ```http
 * GET /api/v1/doc/product/doc-123/data?page=1&pageSize=20
 * ```
 *
 * #### 高级查询（POST 方式）
 * 支持复杂过滤、排序、分组和聚合：
 * ```json
 * {
 *   "filter": {
 *     "and": [
 *       {"field": "status", "op": "eq", "value": "active"},
 *       {"or": [
 *         {"field": "category", "op": "eq", "value": "electronics"},
 *         {"field": "category", "op": "eq", "value": "computers"}
 *       ]}
 *     ]
 *   },
 *   "sort": [{"field": "createdAt", "order": "desc"}],
 *   "page": 1,
 *   "pageSize": 20
 * }
 * ```
 *
 * #### 游标分页（深分页场景）
 * ```http
 * GET /api/v1/doc/product/doc-123/data?cursor=eyJ...&limit=100
 * ```
 *
 * ---
 *
 * ## 🔗 相关资源
 *
 * - 📚 **完整文档**：https://docs.nexusbook.app
 * - 🚀 **快速开始指南**：https://docs.nexusbook.app/guides/getting-started
 * - 📘 **Catalog-OrderBook 数据协同参考**：https://docs.nexusbook.app/references/catalog-orderbook-sync
 * - 🔐 **认证授权指南**：https://docs.nexusbook.app/guides/authentication
 * - 📋 **字段类型参考**：https://docs.nexusbook.app/references/field-types
 * - ❌ **错误码参考**：https://docs.nexusbook.app/references/error-codes
 * - 🌐 **GitHub 仓库**：https://github.com/nexusbook/nexusbook-api
 * - 💬 **社区支持**：https://community.nexusbook.app
 *
 * ---
 *
 * ## 📊 API 版本与环境
 *
 * - **当前版本**：v1
 * - **生产环境**：https://open.nexusbook.app
 * - **测试环境**：https://open-sit.nexusbook.com
 * - **认证服务**：https://auth.nexusbook.app
 *
 * ---
 *
 * **需要帮助？** 请访问我们的[文档中心](https://docs.nexusbook.app)或加入[开发者社区](https://community.nexusbook.app)。
 */
@server("https://open.nexusbook.app", "生产环境 (Production)")
@server("https://open-sit.nexusbook.com", "测试环境 (SIT)")
@service(#{ title: "NexusBook OpenAPI" })
namespace NexusBook.Api {}


/**
 * NexusBook Auth API
 *
 * OAuth2 和 OIDC 兼容的身份认证和授权服务。
 *
 * 支持以下认证流程：
 * - OAuth2 授权码流程
 * - OAuth2 客户端凭证流程
 * - OIDC 身份提供商集成
 *
 * 标准 OIDC 发现端点: /.well-known/openid-configuration
 */
@server("https://auth.nexusbook.app", "生产环境认证服务 (Production Auth)")
@server("https://auth-sit.nexusbook.com", "测试环境认证服务 (SIT Auth)")
@service(#{ title: "NexusBook Auth API" })
namespace NexusBook.Auth {
/**
 * 认证服务入口
 *
 * 提供 OAuth2 和 OIDC 兼容的身份认证服务。
 */

}
