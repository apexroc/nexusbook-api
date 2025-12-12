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
 * 一个功能强大的开源文档管理和数据协作平台 API。
 *
 * ## 主要功能模块
 *
 * ### 1. 文档管理 (`/doc`)
 * - **元数据** - 字段定义、类型和验证配置
 * - **视图** - 多种视图类型支持（表格/相册/看板/文档）
 * - **数据** - 结构化数据行管理和查询
 * - **修订** - 版本控制和历史记录
 * - **评论** - 多层级评论系统（文档级/字段级/行级）
 * - **审批** - 工作流审批流程
 * - **请求** - 变更请求和合并机制
 * - **设置** - 文档级和类型级配置
 *
 * ### 2. 认证与授权 (`/auth`)
 * - OAuth2 客户端应用管理
 * - OIDC 身份提供商集成
 * - JWT 令牌管理
 * - 用户信息和权限
 *
 * ### 3. 扩展功能 (`/webhooks`)
 * - **Webhooks** - 事件驱动的通知机制
 * - 支持 Request、Approval、Comment、Metadata、View 等事件
 * - 自动重试和签名验证
 * - 投递历史和统计
 *
 * ## API 调用示例
 *
 * ```bash
 * # 获取聚合文档包
 * curl -H 'Authorization: Bearer TOKEN' \
 *   'https://open.nexusbook.app/api/v1/doc/product/123?include=metadata,views,data'
 *
 * # 创建数据行
 * curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/data' \
 *   -H 'Authorization: Bearer TOKEN' \
 *   -H 'Content-Type: application/json' \
 *   -d '{"id":"row-1","values":[{"fieldId":"name","value":{"text":"新产品"}}]}'
 * ```
 *
 * ## 认证
 *
 * 所有 API 请求需要在请求头中包含有效的 Bearer Token：
 * ```
 * Authorization: Bearer <access_token>
 * ```
 *
 * 获取 Token 的方式：
 * 1. 使用客户端凭证流程: POST /auth/token
 * 2. 使用授权码流程: GET /auth/authorize + POST /auth/token
 *
 * ## 错误处理
 *
 * 所有错误响应遵循统一的格式：
 * ```json
 * {
 *   "success": false,
 *   "code": "ERROR_CODE",
 *   "message": {
 *     "zh": "错误信息（中文）",
 *     "en": "Error message (English)"
 *   }
 * }
 * ```
 *
 * ## 分页和查询
 *
 * 支持多种查询方式：
 * - 简单分页：`page`, `pageSize`
 * - 高级查询：嵌套过滤、排序、分组和聚合
 * - 游标分页：用于深分页场景
 *
 * ## 并发控制
 *
 * 数据行使用版本号 (version) 进行并发控制。更新时需要提供当前版本号。
 */
@server("Open", "https://open.nexusbook.app")
@service(#{ title: "NexusBook OpenAPI" })
namespace NexusBook.Api {
/**
 * API 文档入口
 *
 * 欢迎使用 NexusBook OpenAPI！本 API 提供完整的文档管理和数据协作能力。
 *
 * - 📚 **文档**: 完整的 API 文档请访问 https://docs.nexusbook.app
 * - 🔐 **认证**: 详见本文档顶部的认证说明
 * - 🚀 **快速开始**: 查看 API 调用示例
 * - 💡 **最佳实践**: 参考错误处理和并发控制章节
 */

}

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
@server("Auth", "https://auth.nexusbook.app")
@service(#{ title: "NexusBook Auth API" })
namespace NexusBook.Auth {
/**
 * 认证服务入口
 *
 * 提供 OAuth2 和 OIDC 兼容的身份认证服务。
 */

}
