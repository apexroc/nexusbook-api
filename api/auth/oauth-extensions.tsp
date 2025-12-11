import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * OAuth 2.0 扩展功能模块
 *
 * OAuth 2.0 Extended Features Module
 *
 * 提供 OAuth 2.0 标准扩展功能。
 * Provides OAuth 2.0 standard extended features.
 *
 * 功能 Features:
 * - 令牌撤销 (RFC 7009) Token revocation
 * - 令牌自省 (RFC 7662) Token introspection
 * - 设备授权流程 (RFC 8628) Device authorization grant
 * - PKCE 支持 (RFC 7636) PKCE support
 */
namespace NexusBook.Api.Auth;

// ==================== 令牌撤销 Token Revocation (RFC 7009) ====================

/**
 * 令牌撤销请求
 * Token revocation request
 */
model TokenRevocationRequest {
    /**
     * 要撤销的令牌
     * Token to revoke
     */
    token: string;

    /**
     * 令牌类型提示
     * Token type hint
     */
    token_type_hint?: "access_token" | "refresh_token";

    /**
     * 客户端ID
     * Client ID
     */
    client_id?: string;

    /**
     * 客户端密钥
     * Client secret
     */
    client_secret?: string;
}

// ==================== 令牌自省 Token Introspection (RFC 7662) ====================

/**
 * 令牌自省请求
 * Token introspection request
 */
model TokenIntrospectionRequest {
    /**
     * 要检查的令牌
     * Token to introspect
     */
    token: string;

    /**
     * 令牌类型提示
     * Token type hint
     */
    token_type_hint?: "access_token" | "refresh_token";

    /**
     * 客户端ID
     * Client ID
     */
    client_id?: string;

    /**
     * 客户端密钥
     * Client secret
     */
    client_secret?: string;
}

/**
 * 令牌自省响应
 * Token introspection response
 */
model TokenIntrospectionResponse {
    /**
     * 令牌是否活跃
     * Whether the token is active
     */
    active: boolean;

    /**
     * 授权范围
     * Scope
     */
    scope?: string;

    /**
     * 客户端ID
     * Client ID
     */
    client_id?: string;

    /**
     * 用户名
     * Username
     */
    username?: string;

    /**
     * 令牌类型
     * Token type
     */
    token_type?: string;

    /**
     * 过期时间（Unix 时间戳）
     * Expiration time (Unix timestamp)
     */
    exp?: int64;

    /**
     * 签发时间（Unix 时间戳）
     * Issued at (Unix timestamp)
     */
    iat?: int64;

    /**
     * 生效时间（Unix 时间戳）
     * Not before (Unix timestamp)
     */
    nbf?: int64;

    /**
     * 主体
     * Subject
     */
    sub?: string;

    /**
     * 受众
     * Audience
     */
    aud?: string;

    /**
     * 发行者
     * Issuer
     */
    iss?: string;

    /**
     * JWT ID
     */
    jti?: string;
}

// ==================== 设备授权流程 Device Authorization (RFC 8628) ====================

/**
 * 设备授权请求
 * Device authorization request
 */
model DeviceAuthorizationRequest {
    /**
     * 客户端ID
     * Client ID
     */
    client_id: string;

    /**
     * 授权范围
     * Scope
     */
    scope?: string;
}

/**
 * 设备授权响应
 * Device authorization response
 */
model DeviceAuthorizationResponse {
    /**
     * 设备码
     * Device code
     */
    device_code: string;

    /**
     * 用户码
     * User code
     */
    user_code: string;

    /**
     * 验证 URI
     * Verification URI
     */
    verification_uri: string;

    /**
     * 完整验证 URI（包含用户码）
     * Complete verification URI (includes user code)
     */
    verification_uri_complete?: string;

    /**
     * 过期时间（秒）
     * Expires in seconds
     */
    expires_in: int32;

    /**
     * 轮询间隔（秒）
     * Polling interval (seconds)
     */
    interval?: int32;
}

/**
 * 设备令牌请求
 * Device token request
 */
model DeviceTokenRequest {
    /**
     * 授权类型
     * Grant type
     */
    grant_type: "urn:ietf:params:oauth:grant-type:device_code";

    /**
     * 设备码
     * Device code
     */
    device_code: string;

    /**
     * 客户端ID
     * Client ID
     */
    client_id: string;
}

/**
 * 设备授权确认请求
 * Device authorization confirmation request
 */
model DeviceAuthorizationConfirmRequest {
    /**
     * 用户码
     * User code
     */
    user_code: string;

    /**
     * 是否授权
     * Whether to authorize
     */
    approved: boolean;

    /**
     * 授权范围（可选，覆盖请求的范围）
     * Scopes (optional, override requested scopes)
     */
    scopes?: string[];
}

// ==================== PKCE (RFC 7636) ====================

/**
 * PKCE 授权请求参数
 * PKCE authorization request parameters
 *
 * 这些参数会作为查询参数添加到授权请求中
 * These parameters are added as query parameters to the authorization request
 */
model PkceAuthorizationParams {
    /**
     * 代码质询
     * Code challenge
     */
    code_challenge: string;

    /**
     * 代码质询方法
     * Code challenge method
     */
    code_challenge_method: "S256" | "plain";
}

/**
 * PKCE 令牌请求参数
 * PKCE token request parameters
 *
 * 这些参数会作为表单参数添加到令牌请求中
 * These parameters are added as form parameters to the token request
 */
model PkceTokenParams {
    /**
     * 代码验证器
     * Code verifier
     */
    code_verifier: string;
}

// ==================== 授权同意 Authorization Consent ====================

/**
 * 授权请求详情
 * Authorization request details
 */
model AuthorizationRequestDetails {
    /**
     * 请求ID
     * Request ID
     */
    requestId: string;

    /**
     * 客户端信息
     * Client information
     */
    client: {
        /**
         * 客户端ID
         * Client ID
         */
        clientId: string;

        /**
         * 客户端名称
         * Client name
         */
        name: string;

        /**
         * Logo URL
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
    };

    /**
     * 请求的授权范围
     * Requested scopes
     */
    requestedScopes: {
        /**
         * 范围
         * Scope
         */
        scope: string;

        /**
         * 描述
         * Description
         */
        description: string;

        /**
         * 是否必需
         * Is required
         */
        required: boolean;
    }[];

    /**
     * 重定向 URI
     * Redirect URI
     */
    redirectUri: string;

    /**
     * 状态码
     * State
     */
    state?: string;

    /**
     * 响应类型
     * Response type
     */
    responseType: string;

    /**
     * 是否使用 PKCE
     * Uses PKCE
     */
    usesPkce: boolean;
}

/**
 * 授权决策请求
 * Authorization decision request
 */
model AuthorizationDecisionRequest {
    /**
     * 请求ID
     * Request ID
     */
    requestId: string;

    /**
     * 是否授权
     * Whether to authorize
     */
    approved: boolean;

    /**
     * 授权的范围（可选，覆盖请求的范围）
     * Granted scopes (optional, override requested scopes)
     */
    grantedScopes?: string[];
}

/**
 * 授权决策响应
 * Authorization decision response
 */
model AuthorizationDecisionResponse {
    /**
     * 重定向 URI（包含授权码或错误）
     * Redirect URI (includes authorization code or error)
     */
    redirectUri: string;
}

// ==================== API 接口 ====================

@route("/")
@tag("OAuth Extensions")
interface OAuthExtensionsApi {
    /**
     * 撤销令牌 (RFC 7009)
     * Revoke token (RFC 7009)
     *
     * 撤销访问令牌或刷新令牌。
     * Revoke access token or refresh token.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://auth.nexusbook.app/revoke' \
     *   -H 'Content-Type: application/x-www-form-urlencoded' \
     *   -d 'token=ACCESS_TOKEN&token_type_hint=access_token&client_id=CLIENT_ID&client_secret=CLIENT_SECRET'
     * ```
     */
    @post
    @route("revoke")
    @summary("撤销令牌")
    revokeToken(@body request: TokenRevocationRequest): void;

    /**
     * 令牌自省 (RFC 7662)
     * Token introspection (RFC 7662)
     *
     * 检查令牌是否有效及其元数据。
     * Check if token is valid and get its metadata.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://auth.nexusbook.app/introspect' \
     *   -H 'Content-Type: application/x-www-form-urlencoded' \
     *   -d 'token=ACCESS_TOKEN&client_id=CLIENT_ID&client_secret=CLIENT_SECRET'
     * ```
     */
    @post
    @route("introspect")
    @summary("令牌自省")
    introspectToken(
        @body request: TokenIntrospectionRequest
    ): TokenIntrospectionResponse;

    /**
     * 设备授权请求 (RFC 8628)
     * Device authorization request (RFC 8628)
     *
     * 启动设备授权流程，返回设备码和用户码。
     * Start device authorization flow, returns device code and user code.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://auth.nexusbook.app/device/authorize' \
     *   -H 'Content-Type: application/x-www-form-urlencoded' \
     *   -d 'client_id=CLIENT_ID&scope=doc:read data:read'
     * ```
     */
    @post
    @route("device/authorize")
    @summary("设备授权请求")
    deviceAuthorization(
        @body request: DeviceAuthorizationRequest
    ): DeviceAuthorizationResponse;

    /**
     * 设备授权确认
     * Device authorization confirmation
     *
     * 用户在验证页面输入用户码后确认授权。
     * User confirms authorization after entering user code on verification page.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://auth.nexusbook.app/device/confirm' \
     *   -H 'Authorization: Bearer USER_TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "user_code": "WDJB-MJHT",
     *     "approved": true
     *   }'
     * ```
     */
    @post
    @route("device/confirm")
    @summary("设备授权确认")
    confirmDeviceAuthorization(
        @body request: DeviceAuthorizationConfirmRequest
    ): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 获取授权请求详情
     * Get authorization request details
     *
     * 获取授权请求的详细信息，用于显示授权同意界面。
     * Get details of authorization request for displaying consent screen.
     */
    @get
    @route("consent")
    @summary("获取授权请求详情")
    getAuthorizationRequestDetails(
        @query requestId: string
    ): NexusBook.Api.Common.ApiResponse<AuthorizationRequestDetails>;

    /**
     * 提交授权决策
     * Submit authorization decision
     *
     * 用户确认或拒绝授权请求。
     * User approves or denies authorization request.
     */
    @post
    @route("consent")
    @summary("提交授权决策")
    submitAuthorizationDecision(
        @body request: AuthorizationDecisionRequest
    ): NexusBook.Api.Common.ApiResponse<AuthorizationDecisionResponse>;
}
