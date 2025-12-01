import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 认证与授权模块
 *
 * 提供 OAuth2 和 OIDC 兼容的身份认证和授权功能。
 *
 * 主要功能：
 * - OAuth2 客户端应用管理
 * - 令牌颁发和管理（访问令牌、刷新令牌）
 * - OIDC 身份提供商元数据和发现
 * - JWT 密钥管理（JWKS）
 * - 用户信息查询和权限声明
 *
 * ## 认证流程
 *
 * ### 授权码流程 (Authorization Code Flow)
 * 1. GET /authorize - 重定向用户到认证服务器
 * 2. POST /token - 使用授权码交换令牌
 *
 * ### 客户端凭证流程 (Client Credentials Flow)
 * 1. POST /token - 使用客户端 ID 和密钥获取令牌
 *
 * ### OIDC 发现
 * GET /.well-known/openid-configuration - 获取 OIDC 元数据
 * GET /jwks.json - 获取公钥集合用于验证
 */
@route("/auth")
namespace NexusBook.Auth {
  /**
   * OAuth2 客户端应用信息
   * OAuth2 client application info
   */
  model Client {
    client_id: string;
    client_name?: string;
    grant_types?: string[];
    redirect_uris?: string[];
    scopes?: string[];
    token_endpoint_auth_method?: string;
  }

  /**
   * 令特颁发到情况
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
     * 令牵端点
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
     * 密锉类型
     * Key type
     */
    kty: string;

    /**
     * 密锉ID
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
   * 用户信息声明
   * User info claims
   */
  model UserInfo {
    /**
     * 主体ID
     * Subject id
     */
    `sub`: string;

    /**
     * 姓名
     * Name
     */
    name?: string;

    /**
     * 用户名
     * Preferred username
     */
    preferred_username?: string;

    /**
     * 邮箱
     * Email
     */
    email?: string;

    /**
     * 邮箱已验证
     * Email verified
     */
    email_verified?: boolean;

    /**
     * 语言区域
     * Locale
     */
    locale?: string;

    /**
     * 更新时间
     * Updated at
     */
    updated_at?: int64;

    /**
     * 头像
     * Picture
     */
    picture?: string;

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

  @tag("Auth")
  interface AuthApi {
    /**
     * 授权码流程的授权端点。
     *
     * Authorization endpoint for authorization code flow.
     */
    @route("/authorize")
    @get
    @summary("授权请求")
    authorize(): void;

    /**
     * 颁发访问令牵与刷新令牵。
     *
     * Issue access and refresh tokens.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X POST 'https://auth.nexusbook.com/token' \\
     *   -H 'Content-Type: application/x-www-form-urlencoded' \\
     *   -d 'grant_type=client_credentials&client_id=CLIENT_ID&client_secret=CLIENT_SECRET&scope=doc:read data:read'
     * ```
     */
    @route("/token")
    @post
    @summary("令牵颁发")
    token(): NexusBook.Common.ApiResponse<TokenResponse>;

    /**
     * 返回登录用户的信息声明。
     *
     * Return user info claims.
     */
    @route("/userinfo")
    @get
    @summary("用户信息")
    userinfo(): NexusBook.Common.ApiResponse<UserInfo>;

    /**
     * 返回 OIDC 提供方的标准发现文档。
     *
     * Return OIDC provider discovery document.
     */
    @route("/.well-known/openid-configuration")
    @get
    @summary("OIDC元数据")
    openidConfiguration(): ProviderMetadata;

    /**
     * 返回 JSON Web Key Set 公钥集合。
     *
     * Return JSON Web Key Set public keys.
     */
    @route("/jwks.json")
    @get
    @summary("JWKS 公钥")
    jwks(): {
      keys: JWK[];
    };
  }
}
