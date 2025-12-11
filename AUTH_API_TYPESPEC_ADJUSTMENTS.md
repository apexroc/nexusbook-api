# Auth 模块 TypeSpec 调整建议

**目的**: 列出当前实现与 TypeSpec 的差异，用于调整 API 定义文档  
**日期**: 2025-12-11  
**版本**: v1.0

---

## 📋 一、当前实现存在但 TypeSpec 缺失的端点

### 1.1 OIDC 提供商列表端点（管理员）

**当前实现**：
```
GET /api/v1/oidc/providers/all
```

**TypeSpec 现状**：
- `oidc-providers.tsp` 只定义了 `GET /api/v1/oidc/providers`（公开端点）
- 缺少管理员获取完整列表的端点

**建议调整**：

在 `oidc-providers.tsp` 的 `OidcProviderApi` 接口中添加：

```typescript
/**
 * 列出所有 OIDC 提供商配置（管理员）
 * List all OIDC provider configurations (admin)
 *
 * 获取所有 OIDC 提供商的完整配置信息，包括密钥等敏感信息。
 * Get complete configuration of all OIDC providers, including sensitive data like secrets.
 *
 * 权限要求：平台管理员
 * Permission required: Platform administrator
 */
@get
@route("/all")
@summary("列出所有 OIDC 提供商配置")
listAllProviders(): NexusBook.Api.Common.ApiResponse<OidcProviderConfig[]>;
```

**说明**：
- `GET /providers` - 公开端点，返回简化信息（不含密钥），用于登录页面
- `GET /providers/all` - 管理员端点，返回完整配置信息，需要管理员权限

---



## 📋 二、TypeSpec 需要调整以符合实际域名规划

### 2.1 域名规划总览

根据项目实际架构，建议的域名划分：

```
┌─────────────────────────────────────────────────────────┐
│ auth.nexusbook.app (认证授权中心)                        │
├─────────────────────────────────────────────────────────┤
│ OAuth2/OIDC 核心协议端点                                 │
│ /.well-known/openid-configuration                      │
│ /jwks.json                                              │
│ /authorize                                              │
│ /token                                                  │
│ /userinfo                                               │
│                                                         │
│ OAuth2 扩展端点（待实现）                                │
│ /revoke                                                 │
│ /introspect                                             │
│ /device/authorize                                       │
│ /device/confirm                                         │
│ /consent                                                │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ open.nexusbook.app (开放业务 API)                        │
├─────────────────────────────────────────────────────────┤
│ 用户认证与管理                                           │
│ /api/v1/auth/*                                          │
│   - /register, /login, /login/phone                     │
│   - /logout, /refresh                                   │
│   - /verification-code                                  │
│   - /forgot-password, /reset-password, /change-password│
│   - /sessions, /sessions/:id, /sessions/revoke-all     │
│                                                         │
│ API 密钥管理（用户自助）                                  │
│ /api/v1/api-keys/*                                      │
│   - /, /:apiKeyId                                       │
│   - /:apiKeyId/revoke                                   │
│                                                         │
│ OAuth 客户端管理（开发者自助）                            │
│ /api/v1/oauth/clients/*                                 │
│   - /, /:clientId                                       │
│   - /:clientId/regenerate-secret                        │
│   - /:clientId/revoke                                   │
│                                                         │
│ OIDC 提供商（公开查询）                                  │
│ /api/v1/oidc/providers                                  │
│                                                         │
│ OAuth 登录（第三方登录）                                 │
│ /api/v1/auth/oauth/:provider/authorize                  │
│ /api/v1/auth/oauth/:provider/callback                   │
│ /api/v1/auth/oauth/:provider/link                       │
│ /api/v1/auth/oauth/linked-accounts                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ admin.nexusbook.app (管理后台 API)                       │
├─────────────────────────────────────────────────────────┤
│ OIDC 提供商管理（需要平台管理员权限）                     │
│ /api/v1/admin/oidc/providers/*                          │
│   - /, /all                                             │
│   - /:providerId (GET/PATCH/DELETE)                     │
│                                                         │
│ 注意：当前实现路径为 /api/v1/oidc/providers/*            │
│       建议迁移至 /api/v1/admin/oidc/providers/*         │
└─────────────────────────────────────────────────────────┘
```

### 2.2 TypeSpec 文件调整建议

#### 2.2.1 models.tsp (OAuth2/OIDC 核心端点)

**当前 TypeSpec**：
```typescript
@route("/")
namespace NexusBook.Api.Auth {
```

**建议调整**：明确标注域名和说明

```typescript
/**
 * OAuth2/OIDC 核心端点
 * 
 * 域名: https://auth.nexusbook.app
 * Domain: https://auth.nexusbook.app
 * 
 * 路由前缀: / (根路径)
 * Route prefix: / (root path)
 */
@route("/")
@server("Auth", "https://auth.nexusbook.app")
namespace NexusBook.Api.Auth {
    // ... 现有定义
}
```

#### 2.2.2 registration.tsp (用户注册登录)

**当前 TypeSpec**：
```typescript
@route("/api/v1/auth")
@tag("Authentication")
interface AuthenticationApi {
```

**建议调整**：明确标注域名

```typescript
/**
 * 用户注册与登录 API
 * 
 * 域名: https://open.nexusbook.app
 * Domain: https://open.nexusbook.app
 * 
 * 路由前缀: /api/v1/auth
 * Route prefix: /api/v1/auth
 */
@route("/api/v1/auth")
@tag("Authentication")
@server("Open", "https://open.nexusbook.app/api/v1")
interface AuthenticationApi {
    // ... 现有定义
}
```

#### 2.2.3 apikeys.tsp (API 密钥管理)

**当前 TypeSpec**：
```typescript
@route("/api/v1/api-keys")
@tag("API Keys")
interface ApiKeyApi {
```

**建议调整**：明确标注域名和定位

```typescript
/**
 * API 密钥管理 API
 * 
 * 域名: https://open.nexusbook.app
 * Domain: https://open.nexusbook.app
 * 
 * 路由前缀: /api/v1/api-keys
 * Route prefix: /api/v1/api-keys
 * 
 * 定位: toC 用户自助式功能（类似 GitHub Personal Access Token）
 * Positioning: Self-service for end users (similar to GitHub Personal Access Token)
 */
@route("/api/v1/api-keys")
@tag("API Keys")
@server("Open", "https://open.nexusbook.app/api/v1")
interface ApiKeyApi {
    // ... 现有定义
}
```

#### 2.2.4 oauth-clients.tsp (OAuth 客户端管理)

**当前 TypeSpec**：
```typescript
@route("/api/v1/oauth/clients")
@tag("OAuth Clients")
interface OAuthClientApi {
```

**建议调整**：明确标注域名和定位

```typescript
/**
 * OAuth 客户端管理 API
 * 
 * 域名: https://open.nexusbook.app
 * Domain: https://open.nexusbook.app
 * 
 * 路由前缀: /api/v1/oauth/clients
 * Route prefix: /api/v1/oauth/clients
 * 
 * 定位: toC 开发者自助式功能（类似 GitHub OAuth Apps）
 * Positioning: Self-service for developers (similar to GitHub OAuth Apps)
 */
@route("/api/v1/oauth/clients")
@tag("OAuth Clients")
@server("Open", "https://open.nexusbook.app/api/v1")
interface OAuthClientApi {
    // ... 现有定义
}
```

#### 2.2.5 oidc-providers.tsp (OIDC 提供商)

**当前 TypeSpec**：
```typescript
@route("/api/v1/oidc/providers")
@tag("OIDC Providers")
interface OidcProviderApi {
```

**建议拆分为两个接口**：

```typescript
/**
 * OIDC 提供商公开查询 API
 * 
 * 域名: https://open.nexusbook.app
 * Domain: https://open.nexusbook.app
 * 
 * 路由前缀: /api/v1/oidc/providers
 * Route prefix: /api/v1/oidc/providers
 * 
 * 定位: 公开查询，用于登录页面显示可用的第三方登录选项
 * Positioning: Public query for displaying available third-party login options
 */
@route("/api/v1/oidc/providers")
@tag("OIDC Providers - Public")
@server("Open", "https://open.nexusbook.app/api/v1")
interface OidcProviderPublicApi {
    /**
     * 列出可用的 OIDC 提供商（公开）
     * List available OIDC providers (public)
     */
    @get
    @summary("列出可用的 OIDC 提供商")
    listAvailableProviders(): NexusBook.Api.Common.ApiResponse<{
        id: string;
        providerType: OidcProviderType;
        name: string;
        logoUrl?: string;
    }[]>;
}

/**
 * OIDC 提供商管理 API
 * 
 * 域名: https://admin.nexusbook.app (建议迁移)
 * Domain: https://admin.nexusbook.app (recommended)
 * 
 * 当前实现: https://open.nexusbook.app/api/v1/oidc/providers
 * Current implementation: https://open.nexusbook.app/api/v1/oidc/providers
 * 
 * 建议路径: /api/v1/admin/oidc/providers
 * Recommended path: /api/v1/admin/oidc/providers
 * 
 * 定位: 平台管理员功能，配置第三方登录提供商
 * Positioning: Platform admin function, configure third-party login providers
 * 
 * 权限要求: 平台管理员
 * Permission required: Platform administrator
 */
@route("/api/v1/admin/oidc/providers")  // 建议路径
@tag("OIDC Providers - Admin")
@server("Admin", "https://admin.nexusbook.app/api/v1")
interface OidcProviderAdminApi {
    /**
     * 列出所有 OIDC 提供商配置（管理员）
     */
    @get
    @route("/all")
    @summary("列出所有 OIDC 提供商配置")
    listAllProviders(): NexusBook.Api.Common.ApiResponse<OidcProviderConfig[]>;

    /**
     * 添加 OIDC 提供商配置（管理员）
     */
    @post
    @summary("添加 OIDC 提供商")
    addOidcProvider(
        @body request: AddOidcProviderRequest
    ): NexusBook.Api.Common.ApiResponse<OidcProviderConfig>;

    /**
     * 获取 OIDC 提供商配置（管理员）
     */
    @get
    @route("/{providerId}")
    @summary("获取 OIDC 提供商配置")
    getOidcProvider(@path providerId: string): NexusBook.Api.Common.ApiResponse<OidcProviderConfig>;

    /**
     * 更新 OIDC 提供商配置（管理员）
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
     */
    @delete
    @route("/{providerId}")
    @summary("删除 OIDC 提供商配置")
    deleteOidcProvider(@path providerId: string): NexusBook.Api.Common.ApiResponse<{}>;
}
```

#### 2.2.6 oauth-extensions.tsp (OAuth 扩展)

**当前 TypeSpec**：
```typescript
@route("/")
@tag("OAuth Extensions")
interface OAuthExtensionsApi {
```

**建议调整**：明确标注域名

```typescript
/**
 * OAuth 扩展功能 API
 * 
 * 域名: https://auth.nexusbook.app
 * Domain: https://auth.nexusbook.app
 * 
 * 路由前缀: / (根路径)
 * Route prefix: / (root path)
 * 
 * 说明: OAuth2 标准扩展端点，包括令牌撤销、自省、设备授权等
 * Description: OAuth2 standard extension endpoints, including token revocation, introspection, device authorization, etc.
 */
@route("/")
@tag("OAuth Extensions")
@server("Auth", "https://auth.nexusbook.app")
interface OAuthExtensionsApi {
    // ... 现有定义
}
```

---

### 2.3 域名服务器定义建议

在 TypeSpec 根文件（如 `main.tsp`）中统一定义服务器：

```typescript
/**
 * Auth Service - 认证授权中心
 * OAuth2/OIDC 标准协议端点
 */
@server("Auth", "https://auth.nexusbook.app")
@service(#{ title: "NexusBook Auth API" })
namespace NexusBook.Auth {
    // OAuth2/OIDC 核心端点
}

/**
 * Open API - 开放业务 API
 * 面向最终用户和第三方应用的业务接口
 */
@server("Open", "https://open.nexusbook.app/api/v1")
@service(#{ title: "NexusBook Open API" })
namespace NexusBook.Open {
    // 用户认证、API Keys、OAuth Clients 等
}

/**
 * Admin API - 管理后台 API
 * 平台管理员专用接口
 */
@server("Admin", "https://admin.nexusbook.app/api/v1")
@service(#{ title: "NexusBook Admin API" })
namespace NexusBook.Admin {
    // OIDC 提供商管理、用户管理、审计等
}
```

---

## 📋 三、路由路径对照表

### 3.1 当前实现路径 vs TypeSpec 建议路径

| 功能 | 当前实现 | TypeSpec 当前定义 | 建议调整后 | 说明 |
|------|---------|------------------|-----------|------|
| **OAuth2/OIDC 核心** |
| OIDC Discovery | `/.well-known/openid-configuration` | `/.well-known/openid-configuration` | 保持不变 | auth 域名 |
| JWKS | `/jwks.json` | `/jwks.json` | 保持不变 | auth 域名 |
| 授权 | `/authorize` | `/authorize` | 保持不变 | auth 域名 |
| 令牌 | `/token` | `/token` | 保持不变 | auth 域名 |
| 用户信息 | `/userinfo` | `/userinfo` | 保持不变 | auth 域名 |
| **用户认证** |
| 注册 | `/api/v1/auth/register` | `/api/v1/auth/register` | 保持不变 | open 域名 |
| 登录 | `/api/v1/auth/login` | `/api/v1/auth/login` | 保持不变 | open 域名 |
| 退出 | `/api/v1/auth/logout` | `/api/v1/auth/logout` | 保持不变 | open 域名 |
| 刷新令牌 | `/api/v1/auth/refresh` | `/api/v1/auth/refresh` | 保持不变 | open 域名 |
| 发送验证码 | `/api/v1/auth/verification-code` | `/api/v1/auth/verification-code` | 保持不变 | open 域名 |
| 忘记密码 | `/api/v1/auth/forgot-password` | `/api/v1/auth/forgot-password` | 保持不变 | open 域名 |
| 重置密码 | `/api/v1/auth/reset-password` | `/api/v1/auth/reset-password` | 保持不变 | open 域名 |
| 修改密码 | `/api/v1/auth/change-password` | `/api/v1/auth/change-password` | 保持不变 | open 域名 |
| 列出会话 | `/api/v1/auth/sessions` | `/api/v1/auth/sessions` | 保持不变 | open 域名 |
| 吊销会话 | `/api/v1/auth/sessions/:sessionId` | `/api/v1/auth/sessions/{sessionId}` | 保持不变 | open 域名 |
| 吊销所有会话 | `/api/v1/auth/sessions/revoke-all` | `/api/v1/auth/sessions/revoke-all` | 保持不变 | open 域名 |
| **API Keys** |
| 创建 API Key | `/api/v1/api-keys` | `/api/v1/api-keys` | 保持不变 | open 域名 |
| 列出 API Keys | `/api/v1/api-keys` | `/api/v1/api-keys` | 保持不变 | open 域名 |
| 获取 API Key | `/api/v1/api-keys/:apiKeyId` | `/api/v1/api-keys/{apiKeyId}` | 保持不变 | open 域名 |
| 更新 API Key | `/api/v1/api-keys/:apiKeyId` | `/api/v1/api-keys/{apiKeyId}` | 保持不变 | open 域名 |
| 吊销 API Key | `/api/v1/api-keys/:apiKeyId/revoke` | `/api/v1/api-keys/{apiKeyId}/revoke` | 保持不变 | open 域名 |
| 删除 API Key | `/api/v1/api-keys/:apiKeyId` | `/api/v1/api-keys/{apiKeyId}` | 保持不变 | open 域名 |
| **OAuth Clients** |
| 创建客户端 | `/api/v1/oauth/clients` | `/api/v1/oauth/clients` | 保持不变 | open 域名 |
| 列出客户端 | `/api/v1/oauth/clients` | `/api/v1/oauth/clients` | 保持不变 | open 域名 |
| 获取客户端 | `/api/v1/oauth/clients/:clientId` | `/api/v1/oauth/clients/{clientId}` | 保持不变 | open 域名 |
| 更新客户端 | `/api/v1/oauth/clients/:clientId` | `/api/v1/oauth/clients/{clientId}` | 保持不变 | open 域名 |
| 重新生成密钥 | `/api/v1/oauth/clients/:clientId/regenerate-secret` | `/api/v1/oauth/clients/{clientId}/regenerate-secret` | 保持不变 | open 域名 |
| 吊销客户端 | `/api/v1/oauth/clients/:clientId/revoke` | `/api/v1/oauth/clients/{clientId}/revoke` | 保持不变 | open 域名 |
| 删除客户端 | `/api/v1/oauth/clients/:clientId` | `/api/v1/oauth/clients/{clientId}` | 保持不变 | open 域名 |
| **OIDC 提供商** |
| 列出可用提供商 | `/api/v1/oidc/providers` | `/api/v1/oidc/providers` | 保持不变 | open 域名（公开） |
| 列出所有提供商 | `/api/v1/oidc/providers/all` | ❌ 未定义 | 添加到 TypeSpec | admin 域名（建议迁移） |
| 添加提供商 | `/api/v1/oidc/providers` | `/api/v1/oidc/providers` | 迁移至 `/api/v1/admin/oidc/providers` | admin 域名 |
| 获取提供商 | `/api/v1/oidc/providers/:providerId` | `/api/v1/oidc/providers/{providerId}` | 迁移至 `/api/v1/admin/oidc/providers/{providerId}` | admin 域名 |
| 更新提供商 | `/api/v1/oidc/providers/:providerId` | `/api/v1/oidc/providers/{providerId}` | 迁移至 `/api/v1/admin/oidc/providers/{providerId}` | admin 域名 |
| 删除提供商 | `/api/v1/oidc/providers/:providerId` | `/api/v1/oidc/providers/{providerId}` | 迁移至 `/api/v1/admin/oidc/providers/{providerId}` | admin 域名 |
| **OAuth 登录** |
| 获取登录 URL | `/api/v1/auth/oauth/:provider/authorize` | `/api/v1/auth/oauth/{provider}/authorize` | 保持不变 | open 域名 |
| 回调处理 | `/api/v1/auth/oauth/:provider/callback` | `/api/v1/auth/oauth/{provider}/callback` | 保持不变 | open 域名 |
| 关联账号 | `/api/v1/auth/oauth/:provider/link` | `/api/v1/auth/oauth/{provider}/link` | 保持不变 | open 域名 |
| 列出关联账号 | `/api/v1/auth/oauth/linked-accounts` | `/api/v1/auth/oauth/linked-accounts` | 保持不变 | open 域名 |
| 解除关联 | `/api/v1/auth/oauth/linked-accounts/:linkId` | `/api/v1/auth/oauth/linked-accounts/{linkId}` | 保持不变 | open 域名 |
| **其他** |
| 测试端点 | `/api/v1/test` | ❌ 未定义 | 建议移除或改为 `/health` | - |

---

## 📝 四、实施建议

### 4.1 TypeSpec 文档调整优先级

**P0 - 必须调整**：
1. 为所有接口添加 `@server` 注解，明确域名归属
2. 拆分 `oidc-providers.tsp` 为公开接口和管理接口
3. 添加 `GET /api/v1/oidc/providers/all` 端点定义

**P1 - 建议调整**：
1. 在 `/login` 端点文档中明确说明支持多种登录方式
2. 统一路径参数命名风格（`:paramName` vs `{paramName}`）

**P2 - 可选调整**：
1. 移除或改造 `/api/v1/test` 端点为标准健康检查
2. 在 `main.tsp` 中添加域名服务器统一定义

### 4.2 代码实现调整建议

**未来迁移计划**（不影响 TypeSpec 调整）：
1. 将 OIDC 提供商管理端点从 `/api/v1/oidc/providers` 迁移至 `/api/v1/admin/oidc/providers`
2. 添加 `RequirePlatformAdmin` 中间件
3. 整合 `/login/phone` 到 `/login`（保留旧端点作为别名）

---

## ✅ 总结

### TypeSpec 需要调整的内容

1. **新增端点定义**：
   - `GET /api/v1/admin/oidc/providers/all`

2. **拆分接口定义**：
   - 将 `oidc-providers.tsp` 拆分为 `OidcProviderPublicApi` 和 `OidcProviderAdminApi`

3. **添加域名注解**：
   - 所有接口添加 `@server` 注解
   - 明确标注 `auth.nexusbook.app`、`open.nexusbook.app`、`admin.nexusbook.app`

4. **完善文档说明**：
   - 在 `/login` 端点说明中明确多种登录方式
   - 在管理接口中标注权限要求

### 域名规划确认

- **auth.nexusbook.app**: OAuth2/OIDC 核心协议端点
- **open.nexusbook.app**: 用户业务 API（认证、API Keys、OAuth Clients、第三方登录）
- **admin.nexusbook.app**: 平台管理 API（OIDC 提供商管理等）

---

**文档维护**: API 设计团队  
**更新日期**: 2025-12-11  
**版本**: 1.0.0
