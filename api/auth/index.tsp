/**
 * 认证模块 (Auth Module)
 *
 * 提供完整的身份认证、授权和 API 密钥管理功能。
 *
 * 模块结构：
 * - models.tsp - OAuth2/OIDC 标准身份认证
 * - registration.tsp - 用户注册、登录、密码管理、两步验证
 * - apikeys.tsp - API 密钥管理
 * - oauth-clients.tsp - OAuth 客户端应用管理
 * - oidc-providers.tsp - 第三方 OIDC 提供商集成
 * - oauth-extensions.tsp - OAuth 扩展功能（令牌撤销、自省、设备授权、PKCE）
 *
 * 主要功能：
 * 1. 用户注册与登录
 *    - 邮箱/手机号注册
 *    - 多种登录方式（邮箱+密码、手机+验证码、OAuth）
 *    - 找回密码、修改密码
 *    - 两步验证（TOTP、SMS、Email）
 *    - 会话管理
 *
 * 2. OAuth2/OIDC 认证
 *    - 授权码流程
 *    - 客户端凭证流程
 *    - 令牌管理（访问令牌、刷新令牌）
 *    - OIDC 发现和 JWKS
 *    - OAuth 客户端应用管理
 *    - 第三方 OIDC 提供商集成（Google, GitHub, Microsoft 等）
 *    - 令牌撤销和自省
 *    - 设备授权流程
 *    - PKCE 支持
 *
 * 3. API 密钥管理
 *    - 创建/更新/吊销 API Key
 *    - 权限范围管理
 *    - 使用记录和统计
 *    - 速率限制和 IP 白名单
 *
 * 依赖关系：
 * - shared/index.tsp - 基础共享类型
 */
import "./models.tsp";
import "./registration.tsp";
import "./apikeys.tsp";
import "./oauth-clients.tsp";
import "./oidc-providers.tsp";
import "./oauth-extensions.tsp";
