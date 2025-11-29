import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

namespace NexusBook.Auth;

@doc("OAuth2 客户端应用信息。\nOAuth2 client application info.")
model Client {
  client_id: string;
  client_name?: string;
  grant_types?: string[];
  redirect_uris?: string[];
  scopes?: string[];
  token_endpoint_auth_method?: string;
}

@doc("令牌颁发响应。\nToken issuance response.")
model TokenResponse {
  @doc("访问令牌。\nAccess token.")
  access_token: string;
  @doc("令牌类型。\nToken type.")
  token_type: "Bearer";
  @doc("过期时间（秒）。\nExpires in seconds.")
  expires_in: int32;
  @doc("刷新令牌。\nRefresh token.")
  refresh_token?: string;
  @doc("授权范围。\nGranted scope.")
  scope?: string;
}

@doc("OIDC 提供方元数据。\nOIDC provider metadata.")
model ProviderMetadata {
  @doc("发行者。\nIssuer.")
  issuer: string;
  @doc("授权端点。\nAuthorization endpoint.")
  authorization_endpoint: string;
  @doc("令牌端点。\nToken endpoint.")
  token_endpoint: string;
  @doc("用户信息端点。\nUserinfo endpoint.")
  userinfo_endpoint: string;
  @doc("JWKS地址。\nJWKS URI.")
  jwks_uri: string;
  @doc("支持的范围。\nSupported scopes.")
  scopes_supported?: string[];
  @doc("支持的响应类型。\nSupported response types.")
  response_types_supported?: string[];
  @doc("支持的授权模式。\nSupported grant types.")
  grant_types_supported?: string[];
  @doc("ID Token签名算法。\nID Token signing algorithms.")
  id_token_signing_alg_values_supported?: string[];
  @doc("支持的声明。\nSupported claims.")
  claims_supported?: string[];
}

@doc("JSON Web Key。\nJSON Web Key.")
model JWK {
  @doc("密钥类型。\nKey type.")
  kty: string;
  @doc("密钥ID。\nKey id.")
  kid?: string;
  @doc("用途。\nUse.")
  use?: string;
  @doc("算法。\nAlgorithm.")
  alg?: string;
  @doc("RSA modulus (n)。")
  n?: string;
  @doc("RSA exponent (e)。")
  e?: string;
  @doc("曲线。\nCurve.")
  crv?: string;
  @doc("X 坐标。\nX coordinate.")
  x?: string;
  @doc("Y 坐标。\nY coordinate.")
  y?: string;
}

@doc("用户信息声明。\nUser info claims.")
model UserInfo {
  @doc("主体ID。\nSubject id.")
  sub: string;
  @doc("姓名。\nName.")
  name?: string;
  @doc("用户名。\nPreferred username.")
  preferred_username?: string;
  @doc("邮箱。\nEmail.")
  email?: string;
  @doc("邮箱已验证。\nEmail verified.")
  email_verified?: boolean;
  @doc("语言区域。\nLocale.")
  locale?: string;
  @doc("更新时间。\nUpdated at.")
  updated_at?: int64;
  @doc("头像。\nPicture.")
  picture?: string;
  @doc("角色列表。\nRoles.")
  roles?: string[];
  @doc("租户列表。\nTenants.")
  tenants?: string[];
}

@tag("Auth")
interface AuthApi {
  @route("/authorize")
  @get
  @summary("授权请求")
  @doc("""
  授权码流程的授权端点。

  Authorization endpoint for authorization code flow.
  """
  )
  op authorize(): void;

  @route("/token")
  @post
  @summary("令牌颁发")
  @doc("""
  颁发访问令牌与刷新令牌。

  Issue access and refresh tokens.

  示例（cURL）:
  ```bash
  curl -X POST 'https://auth.nexusbook.com/token' -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=client_credentials&client_id=CLIENT_ID&client_secret=CLIENT_SECRET&scope=doc:read data:read'
  ```
  """
  )
  op token(): NexusBook.Common.ApiResponse<TokenResponse>;

  @route("/userinfo")
  @get
  @summary("用户信息")
  @doc("""
  返回登录用户的信息声明。

  Return user info claims.
  """
  )
  op userinfo(): NexusBook.Common.ApiResponse<UserInfo>;

  @route("/.well-known/openid-configuration")
  @get
  @summary("OIDC元数据")
  @doc("""
  返回 OIDC 提供方的标准发现文档。

  Return OIDC provider discovery document.
  """
  )
  op openidConfiguration(): ProviderMetadata;

  @route("/jwks.json")
  @get
  @summary("JWKS 公钥")
  @doc("""
  返回 JSON Web Key Set 公钥集合。

  Return JSON Web Key Set public keys.
  """
  )
  op jwks(): { keys: JWK[] };
}
