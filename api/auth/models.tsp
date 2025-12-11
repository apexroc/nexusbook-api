import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * NexusBook Authentication & Authorization - Data Models
 * NexusBook 认证与授权 - 数据模型
 *
 * 提供 OAuth2 和 OIDC 兼容的身份认证和授权功能。
 * Provides OAuth2 and OIDC compatible identity authentication and authorization features.
 *
 * Domain: https://auth.nexusbook.app
 * Route Prefix: / (根路径)
 *
 * 此模块定义 OAuth2/OIDC 标准协议端点，包括授权、令牌、用户信息等核心功能。
 * This module defines OAuth2/OIDC standard protocol endpoints, including authorization, token, userinfo, etc.
 *
 * 主要功能 / Main Features:
 * - OAuth2 客户端应用管理 OAuth2 client application management
 * - 令牌颁发和管理 Token issuance and management
 * - OIDC 身份提供商元数据 OIDC provider metadata
 * - JWT 密钥管理 (JWKS) JWT key management (JWKS)
 * - 用户信息查询和权限声明 User info query and permission claims
 *
 * ## 认证流程 Authentication Flows
 *
 * ### 授权码流程 Authorization Code Flow
 * 1. GET /authorize - 重定向用户到认证服务器 Redirect user to auth server
 * 2. POST /token - 使用授权码交换令牌 Exchange authorization code for token
 *
 * ### 客户端凭证流程 Client Credentials Flow
 * 1. POST /token - 使用客户端 ID 和密钥获取令牌 Get token with client ID and secret
 *
 * ### OIDC 发现 OIDC Discovery
 * GET /.well-known/openid-configuration - 获取 OIDC 元数据 Get OIDC metadata
 * GET /jwks.json - 获取公钥集合用于验证 Get public key set for verification
 */
@route("/")
namespace NexusBook.Api.Auth {
    // ==================== 公共权限范围枚举 ====================

    /**
     * 统一权限范围定义
     * Unified authorization scope
     * 
     * 此枚举为所有认证方式(OAuth Client、API Key)提供统一的权限范围定义
     * This enum provides unified scope definitions for all authentication methods
     */
    enum AuthScope {
        /**
         * 读取文档 Read documents
         */
        "doc:read",

        /**
         * 写入文档 Write documents
         */
        "doc:write",

        /**
         * 删除文档 Delete documents
         */
        "doc:delete",

        /**
         * 读取数据 Read data
         */
        "data:read",

        /**
         * 写入数据 Write data
         */
        "data:write",

        /**
         * 删除数据 Delete data
         */
        "data:delete",

        /**
         * 管理组织 Manage organizations
         */
        "org:manage",

        /**
         * 管理工作区 Manage workspaces
         */
        "workspace:manage",

        /**
         * 管理用户 Manage users
         */
        "user:manage",

        /**
         * Webhook 管理 Webhook management
         */
        "webhook:manage",

        /**
         * 完整权限 Full access
         */
        "all",
    }

    /**
     * OIDC 标准 Scope
     * OIDC standard scopes
     */
    enum OidcStandardScope {
        /**
         * OpenID Connect
         */
        openid,

        /**
         * 个人资料 Profile
         */
        profile,

        /**
         * 邮箱 Email
         */
        email,

        /**
         * 离线访问(获取刷新令牌) Offline access (get refresh token)
         */
        offline_access,
    }

    /**
     * OAuth2 客户端基础元数据 (协议层)
     * OAuth2 client metadata (protocol layer)
     * 
     * 此模型定义 OAuth2 标准协议层的客户端基础信息,供业务管理模型复用
     * This model defines OAuth2 standard protocol layer client metadata for reuse
     */
    model ClientMetadata {
        /**
         * 客户端ID
         * Client ID
         */
        client_id: string;

        /**
         * 客户端名称
         * Client name
         */
        client_name?: string;

        /**
         * 允许的授权类型
         * Grant types
         */
        grant_types?: string[];

        /**
         * 重定向 URI 列表
         * Redirect URIs
         */
        redirect_uris?: string[];

        /**
         * 授权范围
         * Scopes
         */
        scopes?: string[];

        /**
         * 令牌端点认证方法
         * Token endpoint auth method
         */
        token_endpoint_auth_method?: string;
    }

    /**
     * 令牌颁发响应
     * Token issuance response
     */
    model TokenResponse {
        /**
         * 访问令牌
         * Access token
         */
        access_token: string;

        /**
         * 令牌类型
         * Token type
         */
        token_type: "Bearer";

        /**
         * 过期时间（秒）
         * Expires in seconds
         */
        expires_in: int32;

        /**
         * 刷新令牌
         * Refresh token
         */
        refresh_token?: string;

        /**
         * 授权范围
         * Granted scope
         */
        scope?: string;
    }

    /**
     * OIDC 提供方元数据
     * OIDC provider metadata
     */
    model ProviderMetadata {
        /**
         * 发行者
         * Issuer
         */
        issuer: string;

        /**
         * 授权端点
         * Authorization endpoint
         */
        authorization_endpoint: string;

        /**
         * 令牌端点
         * Token endpoint
         */
        token_endpoint: string;

        /**
         * 用户信息端点
         * Userinfo endpoint
         */
        userinfo_endpoint: string;

        /**
         * JWKS地址
         * JWKS URI
         */
        jwks_uri: string;

        /**
         * 支持的范围
         * Supported scopes
         */
        scopes_supported?: string[];

        /**
         * 支持的响应类型
         * Supported response types
         */
        response_types_supported?: string[];

        /**
         * 支持的授权模式
         * Supported grant types
         */
        grant_types_supported?: string[];

        /**
         * ID Token签名算法
         * ID Token signing algorithms
         */
        id_token_signing_alg_values_supported?: string[];

        /**
         * 支持的声明
         * Supported claims
         */
        claims_supported?: string[];
    }

    /**
     * JSON Web Key
     * JSON Web Key
     */
    model JWK {
        /**
         * 密钥类型
         * Key type
         */
        kty: string;

        /**
         * 密钥ID
         * Key id
         */
        kid?: string;

        /**
         * 用途
         * Use
         */
        use?: string;

        /**
         * 算法
         * Algorithm
         */
        alg?: string;

        /**
         * RSA modulus (n)
         */
        n?: string;

        /**
         * RSA exponent (e)
         */
        e?: string;

        /**
         * 曲线
         * Curve
         */
        crv?: string;

        /**
         * X 坐标
         * X coordinate
         */
        x?: string;

        /**
         * Y 坐标
         * Y coordinate
         */
        y?: string;
    }

    /**
     * 用户信息声明 (OIDC Core 1.0 标准)
     * User info claims (OIDC Core 1.0 Standard)
     * 
     * 包含 OIDC 标准字段和 NexusBook 扩展字段
     * Includes OIDC standard claims and NexusBook extensions
     */
    model UserInfo {
        /**
         * 主体ID (必需)
         * Subject identifier (required)
         */
        `sub`: string;

        // ========== OIDC 标准字段 Standard Claims ==========

        /**
         * 全名
         * Full name
         */
        name?: string;

        /**
         * 名字
         * Given name / First name
         */
        given_name?: string;

        /**
         * 姓氏
         * Family name / Last name
         */
        family_name?: string;

        /**
         * 中间名
         * Middle name
         */
        middle_name?: string;

        /**
         * 昵称
         * Nickname
         */
        nickname?: string;

        /**
         * 用户名
         * Preferred username
         */
        preferred_username?: string;

        /**
         * 个人主页 URL
         * Profile page URL
         */
        profile?: string;

        /**
         * 头像 URL
         * Picture URL
         */
        picture?: string;

        /**
         * 个人网站
         * Website URL
         */
        website?: string;

        /**
         * 邮箱
         * Email address
         */
        email?: string;

        /**
         * 邮箱已验证
         * Email verified
         */
        email_verified?: boolean;

        /**
         * 性别
         * Gender
         */
        gender?: string;

        /**
         * 生日 (YYYY-MM-DD 格式)
         * Birthdate (YYYY-MM-DD format)
         */
        birthdate?: string;

        /**
         * 时区信息
         * Time zone (e.g., "Asia/Shanghai")
         */
        zoneinfo?: string;

        /**
         * 语言区域
         * Locale (e.g., "zh-CN", "en-US")
         */
        locale?: string;

        /**
         * 手机号
         * Phone number
         */
        phone_number?: string;

        /**
         * 手机号已验证
         * Phone number verified
         */
        phone_number_verified?: boolean;

        /**
         * 地址信息
         * Address
         */
        address?: {
            /**
             * 完整地址
             * Formatted address
             */
            formatted?: string;

            /**
             * 街道地址
             * Street address
             */
            street_address?: string;

            /**
             * 城市
             * Locality / City
             */
            locality?: string;

            /**
             * 省/州
             * Region / State
             */
            region?: string;

            /**
             * 邮编
             * Postal code
             */
            postal_code?: string;

            /**
             * 国家
             * Country
             */
            country?: string;
        };

        /**
         * 信息更新时间 (Unix 时间戳)
         * Updated at (Unix timestamp)
         */
        updated_at?: int64;

        // ========== NexusBook 扩展字段 Extensions ==========

        /**
         * 角色列表
         * Roles
         */
        roles?: string[];

        /**
         * 租户列表
         * Tenants
         */
        tenants?: string[];
    }

    @tag("OAuth")
    interface AuthApi {
        /**
         * 授权码流程的授权端点。
         *
         * Authorization endpoint for authorization code flow.
         */
        @route("authorize")
        @get
        @summary("授权请求")
        authorize(): void;

        /**
         * 颁发访问令牌与刷新令牌。
         *
         * Issue access and refresh tokens.
         *
         * 示例（cURL）:
         * ```bash
         * curl -X POST 'https://auth.nexusbook.app/token' \\
         *   -H 'Content-Type: application/x-www-form-urlencoded' \\
         *   -d 'grant_type=client_credentials&client_id=CLIENT_ID&client_secret=CLIENT_SECRET&scope=doc:read data:read'
         * ```
         */
        @route("token")
        @post
        @summary("令牌颁发")
        token(): NexusBook.Api.Common.ApiResponse<TokenResponse>;

        /**
         * 返回登录用户的信息声明。
         *
         * Return user info claims.
         */
        @route("userinfo")
        @get
        @summary("用户信息")
        userinfo(): NexusBook.Api.Common.ApiResponse<UserInfo>;

        /**
         * 返回 OIDC 提供方的标准发现文档。
         *
         * Return OIDC provider discovery document.
         */
        @route(".well-known/openid-configuration")
        @get
        @summary("OIDC元数据")
        openidConfiguration(): ProviderMetadata;

        /**
         * 返回 JSON Web Key Set 公钥集合。
         *
         * Return JSON Web Key Set public keys.
         */
        @route("jwks.json")
        @get
        @summary("JWKS 公钥")
        jwks(): {
            keys: JWK[];
        };
    }
}
