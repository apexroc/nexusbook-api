import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 第三方 OIDC 提供商集成模块
 *
 * Third-party OIDC Provider Integration Module
 *
 * 支持国际主流 OIDC 提供商登录，如 Google, GitHub, Microsoft 等。
 * Supports international mainstream OIDC providers like Google, GitHub, Microsoft, etc.
 *
 * 功能 Features:
 * - 配置第三方 OIDC 提供商 Configure third-party OIDC providers
 * - 用户账号关联管理 User account linking management
 * - 统一的 OAuth 登录流程 Unified OAuth login flow
 * - 自动账号创建或关联 Automatic account creation or linking
 */
namespace NexusBook.Api.Auth;

// ==================== 枚举和常量 ====================

/**
 * OIDC 提供商类型
 * OIDC provider type
 */
enum OidcProviderType {
    /**
     * Google
     */
    google,

    /**
     * GitHub
     */
    github,

    /**
     * Microsoft / Azure AD
     */
    microsoft,

    /**
     * Apple
     */
    apple,

    /**
     * Facebook
     */
    facebook,

    /**
     * Twitter / X
     */
    twitter,

    /**
     * LinkedIn
     */
    linkedin,

    /**
     * Slack
     */
    slack,

    /**
     * GitLab
     */
    gitlab,

    /**
     * Bitbucket
     */
    bitbucket,

    /**
     * 企业微信
     * WeChat Work
     */
    wechat_work,

    /**
     * 钉钉
     * DingTalk
     */
    dingtalk,

    /**
     * 飞书
     * Lark / Feishu
     */
    lark,

    /**
     * 自定义 OIDC
     * Custom OIDC
     */
    custom,
}

/**
 * OIDC 提供商配置状态
 * OIDC provider configuration status
 */
enum OidcProviderStatus {
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
}

// ==================== 核心模型 ====================

/**
 * OIDC 提供商配置
 * OIDC provider configuration
 */
model OidcProviderConfig {
    /**
     * 配置ID
     * Config ID
     */
    id: string;

    /**
     * 提供商类型
     * Provider type
     */
    providerType: OidcProviderType;

    /**
     * 提供商名称（显示用）
     * Provider name (for display)
     */
    name: string;

    /**
     * 客户端ID
     * Client ID
     */
    clientId: string;

    /**
     * 客户端密钥（仅在创建/更新时可见）
     * Client secret (only visible on create/update)
     */
    clientSecret?: string;

    /**
     * 授权端点（自定义 OIDC 时使用）
     * Authorization endpoint (for custom OIDC)
     */
    authorizationEndpoint?: string;

    /**
     * 令牌端点（自定义 OIDC 时使用）
     * Token endpoint (for custom OIDC)
     */
    tokenEndpoint?: string;

    /**
     * 用户信息端点（自定义 OIDC 时使用）
     * Userinfo endpoint (for custom OIDC)
     */
    userinfoEndpoint?: string;

    /**
     * JWKS URI（自定义 OIDC 时使用）
     * JWKS URI (for custom OIDC)
     */
    jwksUri?: string;

    /**
     * 发行者（自定义 OIDC 时使用）
     * Issuer (for custom OIDC)
     */
    issuer?: string;

    /**
     * 授权范围
     * Scopes
     */
    scopes: string[];

    /**
     * 是否启用
     * Enabled
     */
    status: OidcProviderStatus;

    /**
     * 是否允许自动创建账号
     * Allow auto account creation
     */
    allowAutoAccountCreation: boolean;

    /**
     * 是否允许关联已有账号
     * Allow linking existing accounts
     */
    allowAccountLinking: boolean;

    /**
     * 所属组织ID（可选，用于企业级配置）
     * Organization ID (optional, for enterprise configuration)
     */
    organizationId?: string;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt: string;
}

/**
 * 添加 OIDC 提供商请求
 * Add OIDC provider request
 */
model AddOidcProviderRequest {
    /**
     * 提供商类型
     * Provider type
     */
    providerType: OidcProviderType;

    /**
     * 提供商名称（显示用）
     * Provider name (for display)
     */
    name: string;

    /**
     * 客户端ID
     * Client ID
     */
    clientId: string;

    /**
     * 客户端密钥
     * Client secret
     */
    clientSecret: string;

    /**
     * 授权端点（自定义 OIDC 时必填）
     * Authorization endpoint (required for custom OIDC)
     */
    authorizationEndpoint?: string;

    /**
     * 令牌端点（自定义 OIDC 时必填）
     * Token endpoint (required for custom OIDC)
     */
    tokenEndpoint?: string;

    /**
     * 用户信息端点（自定义 OIDC 时必填）
     * Userinfo endpoint (required for custom OIDC)
     */
    userinfoEndpoint?: string;

    /**
     * JWKS URI（自定义 OIDC 时可选）
     * JWKS URI (optional for custom OIDC)
     */
    jwksUri?: string;

    /**
     * 发行者（自定义 OIDC 时必填）
     * Issuer (required for custom OIDC)
     */
    issuer?: string;

    /**
     * 授权范围
     * Scopes
     */
    scopes?: string[];

    /**
     * 是否允许自动创建账号
     * Allow auto account creation
     */
    allowAutoAccountCreation?: boolean;

    /**
     * 是否允许关联已有账号
     * Allow linking existing accounts
     */
    allowAccountLinking?: boolean;
}

/**
 * 更新 OIDC 提供商请求
 * Update OIDC provider request
 */
model UpdateOidcProviderRequest {
    /**
     * 提供商名称（显示用）
     * Provider name (for display)
     */
    name?: string;

    /**
     * 客户端ID
     * Client ID
     */
    clientId?: string;

    /**
     * 客户端密钥
     * Client secret
     */
    clientSecret?: string;

    /**
     * 授权范围
     * Scopes
     */
    scopes?: string[];

    /**
     * 是否启用
     * Enabled
     */
    enabled?: boolean;

    /**
     * 是否允许自动创建账号
     * Allow auto account creation
     */
    allowAutoAccountCreation?: boolean;

    /**
     * 是否允许关联已有账号
     * Allow linking existing accounts
     */
    allowAccountLinking?: boolean;
}

/**
 * 用户关联的第三方账号
 * User's linked third-party account
 */
model LinkedAccount {
    /**
     * 关联ID
     * Link ID
     */
    id: string;

    /**
     * 提供商类型
     * Provider type
     */
    providerType: OidcProviderType;

    /**
     * 提供商名称
     * Provider name
     */
    providerName: string;

    /**
     * 第三方账号ID
     * Third-party account ID
     */
    providerAccountId: string;

    /**
     * 第三方账号邮箱
     * Third-party account email
     */
    providerEmail?: string;

    /**
     * 第三方账号显示名称
     * Third-party account display name
     */
    providerDisplayName?: string;

    /**
     * 第三方账号头像
     * Third-party account avatar
     */
    providerAvatar?: string;

    /**
     * 关联时间
     * Linked at
     */
    linkedAt: string;

    /**
     * 最后使用时间
     * Last used at
     */
    lastUsedAt?: string;
}

/**
 * OAuth 登录 URL 响应
 * OAuth login URL response
 */
model OAuthLoginUrlResponse {
    /**
     * 授权 URL
     * Authorization URL
     */
    authorizationUrl: string;

    /**
     * 状态码（用于防止 CSRF）
     * State code (for CSRF protection)
     */
    state: string;
}

/**
 * OAuth 回调请求
 * OAuth callback request
 */
model OAuthCallbackRequest {
    /**
     * 授权码
     * Authorization code
     */
    code: string;

    /**
     * 状态码
     * State code
     */
    state: string;

    /**
     * 重定向 URI
     * Redirect URI
     */
    redirectUri: string;
}

// ==================== API 接口 ====================

@route("/api/v1/oidc/providers")
@tag("OIDC Providers")
interface OidcProviderApi {
    /**
     * 列出可用的 OIDC 提供商
     * List available OIDC providers
     *
     * 获取系统配置的所有 OIDC 提供商列表（公开接口，用于登录页面）。
     * Get list of all configured OIDC providers (public endpoint, for login page).
     */
    @get
    @summary("列出可用的 OIDC 提供商")
    listAvailableProviders(): NexusBook.Api.Common.ApiResponse<{
        /**
         * 提供商ID
         * Provider ID
         */
        id: string;

        /**
         * 提供商类型
         * Provider type
         */
        providerType: OidcProviderType;

        /**
         * 提供商名称
         * Provider name
         */
        name: string;

        /**
         * Logo URL
         */
        logoUrl?: string;
    }[]>;

    /**
     * 添加 OIDC 提供商配置（管理员）
     * Add OIDC provider configuration (admin)
     *
     * 添加新的 OIDC 提供商配置，需要管理员权限。
     * Add new OIDC provider configuration, requires admin permission.
     *
     * 示例（Google）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/oidc/providers' \
     *   -H 'Authorization: Bearer ADMIN_TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "providerType": "google",
     *     "name": "Google",
     *     "clientId": "YOUR_GOOGLE_CLIENT_ID",
     *     "clientSecret": "YOUR_GOOGLE_CLIENT_SECRET",
     *     "scopes": ["openid", "profile", "email"]
     *   }'
     * ```
     */
    @post
    @summary("添加 OIDC 提供商")
    addOidcProvider(
        @body request: AddOidcProviderRequest
    ): NexusBook.Api.Common.ApiResponse<OidcProviderConfig>;

    /**
     * 获取 OIDC 提供商配置（管理员）
     * Get OIDC provider configuration (admin)
     */
    @get
    @route("/{providerId}")
    @summary("获取 OIDC 提供商配置")
    getOidcProvider(@path providerId: string): NexusBook.Api.Common.ApiResponse<OidcProviderConfig>;

    /**
     * 更新 OIDC 提供商配置（管理员）
     * Update OIDC provider configuration (admin)
     */
    @patch
    @route("/{providerId}")
    @summary("更新 OIDC 提供商配置")
    updateOidcProvider(
        @path providerId: string,
        @body request: UpdateOidcProviderRequest
    ): NexusBook.Api.Common.ApiResponse<OidcProviderConfig>;

    /**
     * 删除 OIDC 提供商配置（管理员）
     * Delete OIDC provider configuration (admin)
     */
    @delete
    @route("/{providerId}")
    @summary("删除 OIDC 提供商配置")
    deleteOidcProvider(@path providerId: string): NexusBook.Api.Common.ApiResponse<{}>;
}

@route("/api/v1/auth/oauth")
@tag("OAuth Login")
interface OAuthLoginApi {
    /**
     * 获取 OAuth 登录 URL
     * Get OAuth login URL
     *
     * 生成第三方 OAuth 登录的授权 URL。
     * Generate authorization URL for third-party OAuth login.
     *
     * 示例（Google 登录）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/auth/oauth/google/authorize?redirectUri=https://myapp.com/callback'
     * ```
     */
    @get
    @route("/{provider}/authorize")
    @summary("获取 OAuth 登录 URL")
    getOAuthLoginUrl(
        @path provider: string,
        @query redirectUri: string
    ): NexusBook.Api.Common.ApiResponse<OAuthLoginUrlResponse>;

    /**
     * OAuth 回调处理
     * OAuth callback handler
     *
     * 处理第三方 OAuth 提供商的回调，完成登录或账号关联。
     * Handle OAuth provider callback, complete login or account linking.
     *
     * 示例（Google 回调）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/auth/oauth/google/callback' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "code": "AUTHORIZATION_CODE",
     *     "state": "STATE_CODE",
     *     "redirectUri": "https://myapp.com/callback"
     *   }'
     * ```
     */
    @post
    @route("/{provider}/callback")
    @summary("OAuth 回调处理")
    handleOAuthCallback(
        @path provider: string,
        @body request: OAuthCallbackRequest
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 访问令牌
         * Access token
         */
        accessToken: string;

        /**
         * 刷新令牌
         * Refresh token
         */
        refreshToken: string;

        /**
         * 令牌类型
         * Token type
         */
        tokenType: "Bearer";

        /**
         * 过期时间（秒）
         * Expires in seconds
         */
        expiresIn: int32;

        /**
         * 用户信息
         * User info
         */
        user: {
            id: string;
            email?: string;
            displayName: string;
            avatarUrl?: string;
        };

        /**
         * 是否新创建的账号
         * Is newly created account
         */
        isNewAccount: boolean;
    }>;

    /**
     * 关联第三方账号
     * Link third-party account
     *
     * 将第三方 OAuth 账号关联到当前用户（需要已登录）。
     * Link third-party OAuth account to current user (requires authentication).
     */
    @post
    @route("/{provider}/link")
    @summary("关联第三方账号")
    linkOAuthAccount(
        @path provider: string,
        @body request: OAuthCallbackRequest
    ): NexusBook.Api.Common.ApiResponse<LinkedAccount>;

    /**
     * 列出关联的第三方账号
     * List linked third-party accounts
     *
     * 获取当前用户关联的所有第三方账号。
     * Get all linked third-party accounts for current user.
     */
    @get
    @route("/linked-accounts")
    @summary("列出关联的第三方账号")
    listLinkedAccounts(): NexusBook.Api.Common.ApiResponse<LinkedAccount[]>;

    /**
     * 解除第三方账号关联
     * Unlink third-party account
     *
     * 解除当前用户与指定第三方账号的关联。
     * Unlink specified third-party account from current user.
     */
    @delete
    @route("/linked-accounts/{linkId}")
    @summary("解除第三方账号关联")
    unlinkOAuthAccount(@path linkId: string): NexusBook.Api.Common.ApiResponse<{}>;
}
