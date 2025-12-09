import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * OAuth 2.0 客户端应用管理模块
 *
 * OAuth 2.0 Client Application Management Module
 *
 * 提供 OAuth 2.0 客户端应用的完整生命周期管理，支持第三方应用接入。
 * Provides complete lifecycle management for OAuth 2.0 client applications, supporting third-party app integration.
 *
 * 功能 Features:
 * - 注册和管理 OAuth 客户端应用 Register and manage OAuth client applications
 * - 客户端凭证管理（ID/Secret） Client credentials management (ID/Secret)
 * - 重定向 URI 管理 Redirect URI management
 * - 授权范围配置 Authorization scope configuration
 * - 客户端类型（公开/机密） Client types (public/confidential)
 * - PKCE 支持 PKCE support
 */
namespace NexusBook.Api.Auth;

// ==================== 枚举和常量 ====================

/**
 * OAuth 客户端类型
 * OAuth client type
 */
enum OAuthClientType {
    /**
     * 公开客户端（无法安全存储密钥，如 SPA、移动应用）
     * Public client (cannot securely store secrets, e.g., SPA, mobile apps)
     */
    public,

    /**
     * 机密客户端（可以安全存储密钥，如服务器端应用）
     * Confidential client (can securely store secrets, e.g., server-side apps)
     */
    confidential,
}

/**
 * OAuth 授权类型
 * OAuth grant type
 */
enum OAuthGrantType {
    /**
     * 授权码流程
     * Authorization code flow
     */
    authorization_code,

    /**
     * 客户端凭证流程
     * Client credentials flow
     */
    client_credentials,

    /**
     * 刷新令牌
     * Refresh token
     */
    refresh_token,

    /**
     * 设备授权流程
     * Device authorization flow
     */
    urn_ietf_params_oauth_grant_type_device_code,
}

/**
 * OAuth 客户端状态
 * OAuth client status
 */
enum OAuthClientStatus {
    /**
     * 活跃
     * Active
     */
    active,

    /**
     * 已禁用
     * Disabled
     */
    disabled,

    /**
     * 已撤销
     * Revoked
     */
    revoked,
}

/**
 * OAuth 授权范围 (组合公共枚举)
 * OAuth scope (combines common enums)
 * 
 * OAuth 客户端支持所有 AuthScope 和 OIDC 标准 Scope
 * OAuth clients support all AuthScope and OIDC standard scopes
 */
model OAuthScope {
    /**
     * 业务权限范围 (doc:*, data:*, org:*, etc.)
     * Business scopes
     */
    businessScopes?: NexusBook.Api.Auth.AuthScope[];

    /**
     * OIDC 标准范围 (openid, profile, email, offline_access)
     * OIDC standard scopes
     */
    oidcScopes?: NexusBook.Api.Auth.OidcStandardScope[];
}

// ==================== 核心模型 ====================

/**
 * OAuth 客户端应用信息 (扩展基础元数据)
 * OAuth client application info (extends base metadata)
 * 
 * 继承 ClientMetadata 并添加管理侧字段
 * Extends ClientMetadata with management fields
 */
model OAuthClient {
    /**
     * 客户端ID
     * Client ID
     */
    clientId: string;

    /**
     * 客户端密钥（仅在创建时返回完整密钥）
     * Client secret (full secret only returned on creation)
     */
    clientSecret?: string;

    /**
     * 密钥前缀（用于识别）
     * Secret prefix (for identification)
     */
    secretPrefix?: string;

    /**
     * 客户端名称
     * Client name
     */
    name: string;

    /**
     * 客户端描述
     * Client description
     */
    description?: string;

    /**
     * 客户端类型
     * Client type
     */
    clientType: OAuthClientType;

    /**
     * 允许的授权类型
     * Allowed grant types
     */
    grantTypes: OAuthGrantType[];

    /**
     * 重定向 URI 列表
     * Redirect URIs
     */
    redirectUris: string[];

    /**
     * 允许的授权范围 (使用字符串数组以兼容 AuthScope 和 OidcStandardScope)
     * Allowed scopes (string array for compatibility)
     */
    scopes: string[];

    /**
     * 是否需要 PKCE
     * Requires PKCE
     */
    requirePkce: boolean;

    /**
     * 令牌有效期（秒）
     * Token lifetime (seconds)
     */
    tokenLifetime: int32;

    /**
     * 刷新令牌有效期（秒）
     * Refresh token lifetime (seconds)
     */
    refreshTokenLifetime?: int32;

    /**
     * 客户端 Logo URL
     * Client logo URL
     */
    logoUrl?: string;

    /**
     * 主页 URL
     * Homepage URL
     */
    homepageUrl?: string;

    /**
     * 隐私政策 URL
     * Privacy policy URL
     */
    privacyPolicyUrl?: string;

    /**
     * 服务条款 URL
     * Terms of service URL
     */
    termsOfServiceUrl?: string;

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
     * 状态
     * Status
     */
    status: OAuthClientStatus;

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
     * 授权次数统计
     * Authorization count
     */
    authorizationCount: int64;
}

/**
 * 创建 OAuth 客户端请求
 * Create OAuth client request
 */
model CreateOAuthClientRequest {
    /**
     * 客户端名称
     * Client name
     */
    name: string;

    /**
     * 客户端描述
     * Client description
     */
    description?: string;

    /**
     * 客户端类型
     * Client type
     */
    clientType: OAuthClientType;

    /**
     * 允许的授权类型
     * Allowed grant types
     */
    grantTypes: OAuthGrantType[];

    /**
     * 重定向 URI 列表
     * Redirect URIs
     */
    redirectUris: string[];

    /**
     * 允许的授权范围 (使用字符串数组以兼容 AuthScope 和 OidcStandardScope)
     * Allowed scopes (string array for compatibility)
     */
    scopes: string[];

    /**
     * 是否需要 PKCE
     * Requires PKCE
     */
    requirePkce?: boolean;

    /**
     * 令牌有效期（秒，默认 3600）
     * Token lifetime (seconds, default 3600)
     */
    tokenLifetime?: int32;

    /**
     * 刷新令牌有效期（秒，默认 2592000 = 30天）
     * Refresh token lifetime (seconds, default 2592000 = 30 days)
     */
    refreshTokenLifetime?: int32;

    /**
     * 客户端 Logo URL
     * Client logo URL
     */
    logoUrl?: string;

    /**
     * 主页 URL
     * Homepage URL
     */
    homepageUrl?: string;

    /**
     * 隐私政策 URL
     * Privacy policy URL
     */
    privacyPolicyUrl?: string;

    /**
     * 服务条款 URL
     * Terms of service URL
     */
    termsOfServiceUrl?: string;
}

/**
 * 更新 OAuth 客户端请求
 * Update OAuth client request
 */
model UpdateOAuthClientRequest {
    /**
     * 客户端名称
     * Client name
     */
    name?: string;

    /**
     * 客户端描述
     * Client description
     */
    description?: string;

    /**
     * 重定向 URI 列表
     * Redirect URIs
     */
    redirectUris?: string[];

    /**
     * 允许的授权范围
     * Allowed scopes
     */
    scopes?: OAuthScope[];

    /**
     * 是否需要 PKCE
     * Requires PKCE
     */
    requirePkce?: boolean;

    /**
     * 令牌有效期（秒）
     * Token lifetime (seconds)
     */
    tokenLifetime?: int32;

    /**
     * 刷新令牌有效期（秒）
     * Refresh token lifetime (seconds)
     */
    refreshTokenLifetime?: int32;

    /**
     * 客户端 Logo URL
     * Client logo URL
     */
    logoUrl?: string;

    /**
     * 主页 URL
     * Homepage URL
     */
    homepageUrl?: string;

    /**
     * 隐私政策 URL
     * Privacy policy URL
     */
    privacyPolicyUrl?: string;

    /**
     * 服务条款 URL
     * Terms of service URL
     */
    termsOfServiceUrl?: string;

    /**
     * 启用/禁用
     * Enable/disable
     */
    enabled?: boolean;
}

/**
 * OAuth 授权记录
 * OAuth authorization record
 */
model OAuthAuthorization {
    /**
     * 授权ID
     * Authorization ID
     */
    id: string;

    /**
     * 客户端ID
     * Client ID
     */
    clientId: string;

    /**
     * 客户端名称
     * Client name
     */
    clientName: string;

    /**
     * 用户ID
     * User ID
     */
    userId: string;

    /**
     * 授权的范围 (使用字符串数组以兼容 AuthScope 和 OidcStandardScope)
     * Authorized scopes (string array for compatibility)
     */
    scopes: string[];

    /**
     * 授权时间
     * Authorized at
     */
    authorizedAt: string;

    /**
     * 最后使用时间
     * Last used at
     */
    lastUsedAt?: string;

    /**
     * 过期时间（如果有）
     * Expires at (if any)
     */
    expiresAt?: string;
}

// ==================== API 接口 ====================

@route("/api/v1/oauth/clients")
@tag("OAuth Clients")
interface OAuthClientApi {
    /**
     * 注册 OAuth 客户端应用
     * Register OAuth client application
     *
     * 创建新的 OAuth 客户端应用。客户端密钥只在创建时返回完整内容，请妥善保存。
     * Create new OAuth client application. Full client secret is only returned on creation, please save it securely.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/oauth/clients' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "我的应用",
     *     "clientType": "confidential",
     *     "grantTypes": ["authorization_code", "refresh_token"],
     *     "redirectUris": ["https://myapp.com/callback"],
     *     "scopes": ["openid", "profile", "email", "doc:read"],
     *     "requirePkce": false
     *   }'
     * ```
     */
    @post
    @summary("注册 OAuth 客户端")
    createOAuthClient(
        @body request: CreateOAuthClientRequest
    ): NexusBook.Api.Common.ApiResponse<OAuthClient>;

    /**
     * 列出 OAuth 客户端
     * List OAuth clients
     *
     * 获取当前用户的所有 OAuth 客户端应用列表。
     * Get list of all OAuth client applications for current user.
     */
    @get
    @summary("列出 OAuth 客户端")
    listOAuthClients(
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
        @query status?: OAuthClientStatus,

        /**
         * 按组织ID筛选
         * Filter by organization ID
         */
        @query organizationId?: string
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<OAuthClient>>;

    /**
     * 获取 OAuth 客户端详情
     * Get OAuth client details
     *
     * 获取指定 OAuth 客户端的详细信息（不包含完整密钥）。
     * Get details of specified OAuth client (without full secret).
     */
    @get
    @route("/{clientId}")
    @summary("获取 OAuth 客户端详情")
    getOAuthClient(@path clientId: string): NexusBook.Api.Common.ApiResponse<OAuthClient>;

    /**
     * 更新 OAuth 客户端
     * Update OAuth client
     *
     * 更新 OAuth 客户端的配置信息。
     * Update OAuth client configuration.
     */
    @patch
    @route("/{clientId}")
    @summary("更新 OAuth 客户端")
    updateOAuthClient(
        @path clientId: string,
        @body request: UpdateOAuthClientRequest
    ): NexusBook.Api.Common.ApiResponse<OAuthClient>;

    /**
     * 重新生成客户端密钥
     * Regenerate client secret
     *
     * 重新生成 OAuth 客户端密钥。旧密钥立即失效，新密钥只返回一次。
     * Regenerate OAuth client secret. Old secret is immediately invalidated, new secret is returned only once.
     */
    @post
    @route("/{clientId}/regenerate-secret")
    @summary("重新生成客户端密钥")
    regenerateClientSecret(@path clientId: string): NexusBook.Api.Common.ApiResponse<OAuthClient>;

    /**
     * 吊销 OAuth 客户端
     * Revoke OAuth client
     *
     * 永久吊销 OAuth 客户端，吊销后无法恢复。
     * Permanently revoke OAuth client, cannot be restored after revocation.
     */
    @post
    @route("/{clientId}/revoke")
    @summary("吊销 OAuth 客户端")
    revokeOAuthClient(@path clientId: string): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 删除 OAuth 客户端
     * Delete OAuth client
     *
     * 彻底删除 OAuth 客户端及其所有授权记录。
     * Permanently delete OAuth client and all its authorization records.
     */
    @delete
    @route("/{clientId}")
    @summary("删除 OAuth 客户端")
    deleteOAuthClient(@path clientId: string): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 列出用户授权
     * List user authorizations
     *
     * 获取当前用户授权给第三方应用的列表。
     * Get list of third-party apps authorized by current user.
     */
    @get
    @route("/authorizations")
    @summary("列出用户授权")
    listUserAuthorizations(): NexusBook.Api.Common.ApiResponse<OAuthAuthorization[]>;

    /**
     * 撤销用户授权
     * Revoke user authorization
     *
     * 撤销当前用户对指定客户端的授权。
     * Revoke current user's authorization for specified client.
     */
    @delete
    @route("/authorizations/{authorizationId}")
    @summary("撤销用户授权")
    revokeUserAuthorization(
        @path authorizationId: string
    ): NexusBook.Api.Common.ApiResponse<{}>;
}
