import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * API 密钥管理模块
 *
 * API Key Management Module
 *
 * 提供开放 API 密钥的完整生命周期管理：
 * - 创建 API Key（带权限范围）
 * - 列出和查看 API Key
 * - 更新 API Key（名称、权限、过期时间）
 * - 吊销 API Key
 * - 重新生成 API Key
 * - 使用记录和审计
 *
 * Features:
 * - Create API Keys (with scopes)
 * - List and view API Keys
 * - Update API Keys (name, scopes, expiration)
 * - Revoke API Keys
 * - Regenerate API Keys
 * - Usage logs and audit
 */
namespace NexusBook.Auth;

// ==================== 枚举和常量 ====================

/**
 * API Key 状态
 * API Key status
 */
enum ApiKeyStatus {
    /**
     * 活跃
     * Active
     */
    active,

    /**
     * 已过期
     * Expired
     */
    expired,

    /**
     * 已吊销
     * Revoked
     */
    revoked,

    /**
     * 已禁用
     * Disabled
     */
    disabled,
}

/**
 * API Key 权限范围
 * API Key scope
 */
enum ApiKeyScope {
    /**
     * 读取文档
     * Read documents
     */
    "doc:read",

    /**
     * 写入文档
     * Write documents
     */
    "doc:write",

    /**
     * 删除文档
     * Delete documents
     */
    "doc:delete",

    /**
     * 读取数据
     * Read data
     */
    "data:read",

    /**
     * 写入数据
     * Write data
     */
    "data:write",

    /**
     * 删除数据
     * Delete data
     */
    "data:delete",

    /**
     * 管理组织
     * Manage organizations
     */
    "org:manage",

    /**
     * 管理工作区
     * Manage workspaces
     */
    "workspace:manage",

    /**
     * 管理用户
     * Manage users
     */
    "user:manage",

    /**
     * Webhook 管理
     * Webhook management
     */
    "webhook:manage",

    /**
     * 完整权限
     * Full access
     */
    "all",
}

// ==================== 核心模型 ====================

/**
 * API Key 信息
 * API Key info
 */
model ApiKey {
    /**
     * API Key ID
     */
    id: string;

    /**
     * API Key（仅在创建时返回完整密钥）
     * API Key (full key only returned on creation)
     */
    key?: string;

    /**
     * 密钥前缀（用于识别，例如 "sk_live_abc123..."）
     * Key prefix (for identification, e.g., "sk_live_abc123...")
     */
    keyPrefix: string;

    /**
     * 名称
     * Name
     */
    name: string;

    /**
     * 描述
     * Description
     */
    description?: string;

    /**
     * 权限范围
     * Scopes
     */
    scopes: ApiKeyScope[];

    /**
     * 所属用户ID
     * Owner user ID
     */
    userId: string;

    /**
     * 所属组织ID（可选）
     * Organization ID (optional)
     */
    organizationId?: string;

    /**
     * 所属工作区ID（可选）
     * Workspace ID (optional)
     */
    workspaceId?: string;

    /**
     * 状态
     * Status
     */
    status: ApiKeyStatus;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 最后使用时间
     * Last used at
     */
    lastUsedAt?: string;

    /**
     * 过期时间
     * Expires at
     */
    expiresAt?: string;

    /**
     * 使用次数统计
     * Usage count
     */
    usageCount: int64;

    /**
     * 速率限制（请求数/分钟）
     * Rate limit (requests per minute)
     */
    rateLimit?: int32;

    /**
     * IP 白名单
     * IP whitelist
     */
    ipWhitelist?: string[];

    /**
     * 允许的来源（CORS）
     * Allowed origins (CORS)
     */
    allowedOrigins?: string[];
}

/**
 * 创建 API Key 请求
 * Create API Key request
 */
model CreateApiKeyRequest {
    /**
     * 名称
     * Name
     */
    name: string;

    /**
     * 描述
     * Description
     */
    description?: string;

    /**
     * 权限范围
     * Scopes
     */
    scopes: ApiKeyScope[];

    /**
     * 所属组织ID（可选）
     * Organization ID (optional)
     */
    organizationId?: string;

    /**
     * 所属工作区ID（可选）
     * Workspace ID (optional)
     */
    workspaceId?: string;

    /**
     * 过期天数（不设置则永不过期）
     * Expiration days (never expires if not set)
     */
    expiresInDays?: int32;

    /**
     * 速率限制（请求数/分钟）
     * Rate limit (requests per minute)
     */
    rateLimit?: int32;

    /**
     * IP 白名单
     * IP whitelist
     */
    ipWhitelist?: string[];

    /**
     * 允许的来源（CORS）
     * Allowed origins (CORS)
     */
    allowedOrigins?: string[];
}

/**
 * 更新 API Key 请求
 * Update API Key request
 */
model UpdateApiKeyRequest {
    /**
     * 名称
     * Name
     */
    name?: string;

    /**
     * 描述
     * Description
     */
    description?: string;

    /**
     * 权限范围
     * Scopes
     */
    scopes?: ApiKeyScope[];

    /**
     * 速率限制（请求数/分钟）
     * Rate limit (requests per minute)
     */
    rateLimit?: int32;

    /**
     * IP 白名单
     * IP whitelist
     */
    ipWhitelist?: string[];

    /**
     * 允许的来源（CORS）
     * Allowed origins (CORS)
     */
    allowedOrigins?: string[];

    /**
     * 启用/禁用
     * Enable/disable
     */
    enabled?: boolean;
}

/**
 * API Key 使用记录
 * API Key usage log
 */
model ApiKeyUsageLog {
    /**
     * 记录ID
     * Log ID
     */
    id: string;

    /**
     * API Key ID
     */
    apiKeyId: string;

    /**
     * 请求时间
     * Request time
     */
    timestamp: string;

    /**
     * 请求方法
     * Request method
     */
    method: string;

    /**
     * 请求路径
     * Request path
     */
    path: string;

    /**
     * 响应状态码
     * Response status code
     */
    statusCode: int32;

    /**
     * IP 地址
     * IP address
     */
    ipAddress: string;

    /**
     * User Agent
     */
    userAgent?: string;

    /**
     * 来源
     * Origin
     */
    origin?: string;

    /**
     * 响应时间（毫秒）
     * Response time (ms)
     */
    responseTime: int32;

    /**
     * 错误信息（如果有）
     * Error message (if any)
     */
    error?: string;
}

/**
 * API Key 使用统计
 * API Key usage statistics
 */
model ApiKeyUsageStats {
    /**
     * API Key ID
     */
    apiKeyId: string;

    /**
     * 统计周期开始时间
     * Period start time
     */
    periodStart: string;

    /**
     * 统计周期结束时间
     * Period end time
     */
    periodEnd: string;

    /**
     * 总请求数
     * Total requests
     */
    totalRequests: int64;

    /**
     * 成功请求数
     * Successful requests
     */
    successfulRequests: int64;

    /**
     * 失败请求数
     * Failed requests
     */
    failedRequests: int64;

    /**
     * 平均响应时间（毫秒）
     * Average response time (ms)
     */
    averageResponseTime: float64;

    /**
     * 按端点统计
     * Stats by endpoint
     */
    byEndpoint: {
        /**
         * 端点路径
         * Endpoint path
         */
        path: string;

        /**
         * 请求数
         * Request count
         */
        count: int64;
    }[];

    /**
     * 按状态码统计
     * Stats by status code
     */
    byStatusCode: {
        /**
         * 状态码
         * Status code
         */
        code: int32;

        /**
         * 请求数
         * Request count
         */
        count: int64;
    }[];
}

// ==================== API 接口 ====================

@route("/api/v1/api-keys")
@tag("API Keys")
interface ApiKeyApi {
    /**
     * 创建 API Key
     * Create API Key
     *
     * 创建新的 API 密钥。密钥只在创建时返回完整内容，请妥善保存。
     * Create new API key. Full key is only returned on creation, please save it securely.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/api-keys' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "生产环境 API Key",
     *     "description": "用于生产环境的后端服务",
     *     "scopes": ["doc:read", "doc:write", "data:read", "data:write"],
     *     "expiresInDays": 365,
     *     "rateLimit": 1000
     *   }'
     * ```
     */
    @post
    @summary("创建 API Key")
    createApiKey(@body request: CreateApiKeyRequest): NexusBook.Common.ApiResponse<ApiKey>;

    /**
     * 列出 API Keys
     * List API Keys
     *
     * 获取当前用户的所有 API 密钥列表。
     * Get list of all API keys for current user.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/api-keys?page=1&pageSize=20&status=active' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @summary("列出 API Keys")
    listApiKeys(
        /**
         * 页码（从1开始）
         * Page number (starts from 1)
         */
        @query page?: int32 = 1,

        /**
         * 每页数量
         * Page size
         */
        @query pageSize?: int32 = 20,

        /**
         * 按状态筛选
         * Filter by status
         */
        @query status?: ApiKeyStatus,

        /**
         * 按组织ID筛选
         * Filter by organization ID
         */
        @query organizationId?: string,

        /**
         * 按工作区ID筛选
         * Filter by workspace ID
         */
        @query workspaceId?: string
    ): NexusBook.Common.ApiResponse<NexusBook.Common.Page<ApiKey>>;

    /**
     * 获取 API Key 详情
     * Get API Key details
     *
     * 获取指定 API 密钥的详细信息（不包含完整密钥）。
     * Get details of specified API key (without full key).
     */
    @get
    @route("/{apiKeyId}")
    @summary("获取 API Key 详情")
    getApiKey(@path apiKeyId: string): NexusBook.Common.ApiResponse<ApiKey>;

    /**
     * 更新 API Key
     * Update API Key
     *
     * 更新 API 密钥的配置信息。
     * Update API key configuration.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.com/api/v1/api-keys/{apiKeyId}' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "生产环境 API Key (更新)",
     *     "scopes": ["doc:read", "data:read"],
     *     "rateLimit": 500
     *   }'
     * ```
     */
    @patch
    @route("/{apiKeyId}")
    @summary("更新 API Key")
    updateApiKey(
        @path apiKeyId: string,
        @body request: UpdateApiKeyRequest
    ): NexusBook.Common.ApiResponse<ApiKey>;

    /**
     * 吊销 API Key
     * Revoke API Key
     *
     * 永久吊销 API 密钥，吊销后无法恢复。
     * Permanently revoke API key, cannot be restored after revocation.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/api-keys/{apiKeyId}/revoke' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @post
    @route("/{apiKeyId}/revoke")
    @summary("吊销 API Key")
    revokeApiKey(@path apiKeyId: string): NexusBook.Common.ApiResponse<{}>;

    /**
     * 重新生成 API Key
     * Regenerate API Key
     *
     * 重新生成 API 密钥。旧密钥立即失效，新密钥只返回一次。
     * Regenerate API key. Old key is immediately invalidated, new key is returned only once.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/api-keys/{apiKeyId}/regenerate' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @post
    @route("/{apiKeyId}/regenerate")
    @summary("重新生成 API Key")
    regenerateApiKey(@path apiKeyId: string): NexusBook.Common.ApiResponse<ApiKey>;

    /**
     * 删除 API Key
     * Delete API Key
     *
     * 彻底删除 API 密钥及其所有使用记录。
     * Permanently delete API key and all its usage logs.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.com/api/v1/api-keys/{apiKeyId}' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/{apiKeyId}")
    @summary("删除 API Key")
    deleteApiKey(@path apiKeyId: string): NexusBook.Common.ApiResponse<{}>;

    /**
     * 获取 API Key 使用记录
     * Get API Key usage logs
     *
     * 获取 API 密钥的使用记录。
     * Get usage logs of API key.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/api-keys/{apiKeyId}/logs?page=1&pageSize=50&startTime=2024-12-01T00:00:00Z&endTime=2024-12-05T23:59:59Z' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/{apiKeyId}/logs")
    @summary("获取使用记录")
    getApiKeyUsageLogs(
        @path apiKeyId: string,

        /**
         * 页码
         * Page number
         */
        @query page?: int32 = 1,

        /**
         * 每页数量
         * Page size
         */
        @query pageSize?: int32 = 50,

        /**
         * 开始时间
         * Start time
         */
        @query startTime?: string,

        /**
         * 结束时间
         * End time
         */
        @query endTime?: string,

        /**
         * 按方法筛选
         * Filter by method
         */
        @query method?: string,

        /**
         * 按路径筛选
         * Filter by path
         */
        @query path?: string,

        /**
         * 按状态码筛选
         * Filter by status code
         */
        @query statusCode?: int32
    ): NexusBook.Common.ApiResponse<NexusBook.Common.Page<ApiKeyUsageLog>>;

    /**
     * 获取 API Key 使用统计
     * Get API Key usage statistics
     *
     * 获取 API 密钥的使用统计信息。
     * Get usage statistics of API key.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/api-keys/{apiKeyId}/stats?period=7d' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/{apiKeyId}/stats")
    @summary("获取使用统计")
    getApiKeyUsageStats(
        @path apiKeyId: string,

        /**
         * 统计周期（1h, 24h, 7d, 30d, 90d）
         * Statistics period (1h, 24h, 7d, 30d, 90d)
         */
        @query period?: string = "7d"
    ): NexusBook.Common.ApiResponse<ApiKeyUsageStats>;

    /**
     * 批量吊销 API Keys
     * Batch revoke API Keys
     *
     * 批量吊销多个 API 密钥。
     * Batch revoke multiple API keys.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/api-keys/batch-revoke' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "apiKeyIds": ["key-1", "key-2", "key-3"]
     *   }'
     * ```
     */
    @post
    @route("/batch-revoke")
    @summary("批量吊销 API Keys")
    batchRevokeApiKeys(@body request: {
        /**
         * API Key ID 列表
         * API Key ID list
         */
        apiKeyIds: string[];
    }): NexusBook.Common.ApiResponse<{
        /**
         * 成功吊销的数量
         * Successfully revoked count
         */
        revokedCount: int32;

        /**
         * 失败的 API Key IDs
         * Failed API Key IDs
         */
        failed?: string[];
    }>;
}
