# 认证授权指南

NexusBook API 使用 OAuth2 和 OIDC 标准进行认证和授权，提供安全可靠的访问控制机制。

## 域名规划

NexusBook 采用基于功能分离的域名架构，将认证协议层、开放业务 API 和管理 API 部署在不同的域名下，以提供更好的安全性和可维护性。

### 认证授权中心 (auth.nexusbook.app)

**用途**：OAuth2/OIDC 标准协议端点

此域名专门用于 OAuth2 和 OIDC 核心协议端点，所有接口直接挂载在根路径下：

```bash
# OIDC 发现端点
GET https://auth.nexusbook.app/.well-known/openid-configuration

# JWKS 公钥端点
GET https://auth.nexusbook.app/jwks.json

# 授权端点
GET https://auth.nexusbook.app/authorize

# 令牌端点
POST https://auth.nexusbook.app/token

# 用户信息端点
GET https://auth.nexusbook.app/userinfo
```

**注意**：根据部署规范，`auth.nexusbook.app` 域名下的 API 接口**不包含** `/auth` 子路径，所有接口直接挂载在根路径下。

### 开放业务 API (open.nexusbook.app)

**用途**：面向最终用户和第三方应用的业务接口

#### 用户认证与管理

```bash
# 用户注册
POST https://open.nexusbook.app/api/v1/auth/register

# 用户登录（支持多种方式：邮箱+密码、手机+验证码）
POST https://open.nexusbook.app/api/v1/auth/login

# 会话管理
GET https://open.nexusbook.app/api/v1/auth/sessions
DELETE https://open.nexusbook.app/api/v1/auth/sessions/{sessionId}
```

#### API 密钥管理

```bash
# 创建 API Key
POST https://open.nexusbook.app/api/v1/api-keys

# 列出 API Keys
GET https://open.nexusbook.app/api/v1/api-keys

# 吊销 API Key
POST https://open.nexusbook.app/api/v1/api-keys/{keyId}/revoke
```

#### OAuth 客户端管理

```bash
# 创建 OAuth 客户端
POST https://open.nexusbook.app/api/v1/oauth/clients

# 重新生成密钥
POST https://open.nexusbook.app/api/v1/oauth/clients/{clientId}/regenerate-secret
```

#### 第三方登录

```bash
# 列出可用的第三方登录选项（公开）
GET https://open.nexusbook.app/api/v1/oidc/providers

# 获取 OAuth 登录 URL
GET https://open.nexusbook.app/api/v1/auth/oauth/{provider}/authorize

# OAuth 回调处理
POST https://open.nexusbook.app/api/v1/auth/oauth/{provider}/callback
```

#### OIDC 提供商管理（管理员）

```bash
# 列出所有 OIDC 提供商配置
GET https://open.nexusbook.app/api/v1/admin/oidc/providers

# 添加 OIDC 提供商
POST https://open.nexusbook.app/api/v1/admin/oidc/providers

# 更新 OIDC 提供商
PATCH https://open.nexusbook.app/api/v1/admin/oidc/providers/{providerId}

# 删除 OIDC 提供商
DELETE https://open.nexusbook.app/api/v1/admin/oidc/providers/{providerId}
```

### 域名总览

| 域名 | 路径前缀 | 用途 | 权限 |
|------|---------|------|------|
| `auth.nexusbook.app` | `/` | OAuth2/OIDC 核心协议 | 公开 |
| `open.nexusbook.app` | `/api/v1/auth` | 用户认证与管理 | 用户自助 |
| `open.nexusbook.app` | `/api/v1/api-keys` | API 密钥管理 | 用户自助 |
| `open.nexusbook.app` | `/api/v1/oauth/clients` | OAuth 客户端管理 | 开发者自助 |
| `open.nexusbook.app` | `/api/v1/oidc/providers` | 第三方登录查询 | 公开 |
| `open.nexusbook.app` | `/api/v1/auth/oauth` | 第三方 OAuth 登录 | 公开 |
| `open.nexusbook.app` | `/api/v1/admin/oidc/providers` | OIDC 提供商管理 | 管理员 |

---

## OAuth2 认证流程

### 客户端凭证流程（Client Credentials Flow）

**适用场景**：服务端应用、后台任务、系统集成

这是最简单的认证方式，适合不需要用户交互的场景。

#### 流程图

```
┌─────────┐                                  ┌──────────┐
│  客户端  │                                  │ 授权服务器 │
└────┬────┘                                  └────┬─────┘
     │                                            │
     │  POST /token                               │
     │  grant_type=client_credentials             │
     │  client_id=xxx                             │
     │  client_secret=xxx                         │
     │  scope=doc:read data:write                 │
     ├───────────────────────────────────────────>│
     │                                            │
     │                 access_token               │
     │<───────────────────────────────────────────┤
     │                                            │
```

#### 示例代码

**cURL**:
```bash
curl -X POST https://auth.nexusbook.app/token \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=client_credentials' \
  -d 'client_id=your_client_id' \
  -d 'client_secret=your_client_secret' \
  -d 'scope=doc:read data:read data:write'
```

**JavaScript (Node.js)**:
```javascript
const axios = require('axios');
const qs = require('querystring');

async function getAccessToken() {
  const response = await axios.post(
    'https://auth.nexusbook.app/token',
    qs.stringify({
      grant_type: 'client_credentials',
      client_id: 'your_client_id',
      client_secret: 'your_client_secret',
      scope: 'doc:read data:read data:write'
    }),
    {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
    }
  );
  
  return response.data.access_token;
}
```

**Python**:
```python
import requests

def get_access_token():
    response = requests.post(
        'https://auth.nexusbook.app/token',
        data={
            'grant_type': 'client_credentials',
            'client_id': 'your_client_id',
            'client_secret': 'your_client_secret',
            'scope': 'doc:read data:read data:write'
        }
    )
    
    return response.json()['access_token']
```

### 授权码流程（Authorization Code Flow）

**适用场景**：Web 应用、移动应用（需要用户授权）

这是最安全的认证方式，适合需要用户授权的场景。

#### 流程图

```
┌─────────┐          ┌──────────┐          ┌──────────┐
│  用户    │          │  客户端   │          │ 授权服务器 │
└────┬────┘          └────┬─────┘          └────┬─────┘
     │                    │                     │
     │  访问应用           │                     │
     ├───────────────────>│                     │
     │                    │  重定向到授权页面     │
     │                    ├────────────────────>│
     │                    │                     │
     │                    │  显示授权页面         │
     │<──────────────────────────────────────────┤
     │                    │                     │
     │  用户授权           │                     │
     ├────────────────────────────────────────>│
     │                    │                     │
     │                    │  重定向+授权码        │
     │                    │<────────────────────┤
     │                    │                     │
     │                    │  用授权码换取Token    │
     │                    ├────────────────────>│
     │                    │                     │
     │                    │  access_token       │
     │                    │<────────────────────┤
     │                    │                     │
```

#### 步骤详解

**步骤 1：引导用户到授权页面**

```javascript
// 构建授权 URL
const authUrl = new URL('https://auth.nexusbook.app/authorize');
authUrl.searchParams.set('response_type', 'code');
authUrl.searchParams.set('client_id', 'your_client_id');
authUrl.searchParams.set('redirect_uri', 'https://yourapp.com/callback');
authUrl.searchParams.set('scope', 'doc:read data:read data:write');
authUrl.searchParams.set('state', generateRandomState()); // CSRF 保护

// 重定向用户
window.location.href = authUrl.toString();
```

**步骤 2：处理回调并换取 Token**

```javascript
// 在回调端点处理
app.get('/callback', async (req, res) => {
  const { code, state } = req.query;
  
  // 验证 state 防止 CSRF
  if (state !== expectedState) {
    return res.status(400).send('Invalid state');
  }
  
  // 用授权码换取 Token
  const response = await axios.post(
    'https://auth.nexusbook.app/token',
    qs.stringify({
      grant_type: 'authorization_code',
      code: code,
      client_id: 'your_client_id',
      client_secret: 'your_client_secret',
      redirect_uri: 'https://yourapp.com/callback'
    }),
    {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
    }
  );
  
  const { access_token, refresh_token } = response.data;
  
  // 保存 Token
  // ...
});
```

## OIDC 集成

### 发现端点

获取 OIDC 配置信息：

```bash
curl https://auth.nexusbook.app/.well-known/openid-configuration
```

**响应示例**：
```json
{
  "issuer": "https://auth.nexusbook.app",
  "authorization_endpoint": "https://auth.nexusbook.app/authorize",
  "token_endpoint": "https://auth.nexusbook.app/token",
  "userinfo_endpoint": "https://auth.nexusbook.app/userinfo",
  "jwks_uri": "https://auth.nexusbook.app/jwks.json",
  "scopes_supported": ["openid", "profile", "email", "doc:read", "data:write"],
  "response_types_supported": ["code", "token"],
  "grant_types_supported": ["authorization_code", "client_credentials", "refresh_token"]
}
```

### JWKS 端点

获取 JWT 验证公钥：

```bash
curl https://auth.nexusbook.app/jwks.json
```

### UserInfo 端点

获取当前用户信息：

```bash
curl https://auth.nexusbook.app/userinfo \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN'
```

## Token 管理

### Token 结构

NexusBook 使用 JWT (JSON Web Token) 格式：

```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.    # Header
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6I... # Payload
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQss... # Signature
```

**解码后的 Payload**：
```json
{
  "sub": "user-12345",
  "client_id": "your_client_id",
  "scope": "doc:read data:write",
  "iat": 1638360000,
  "exp": 1638363600
}
```

### Token 存储

**安全存储建议**：

1. **Web 应用**：使用 HttpOnly Cookie
   ```javascript
   res.cookie('access_token', token, {
     httpOnly: true,
     secure: true,
     sameSite: 'strict',
     maxAge: 3600000 // 1 小时
   });
   ```

2. **移动应用**：使用安全存储（iOS Keychain、Android Keystore）

3. **服务端应用**：环境变量或加密配置文件

**不安全的做法**：
- ❌ 存储在 localStorage
- ❌ 存储在普通 Cookie（非 HttpOnly）
- ❌ 硬编码在代码中
- ❌ 明文保存在数据库

### Token 刷新

使用 Refresh Token 获取新的 Access Token：

```bash
curl -X POST https://auth.nexusbook.app/token \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=refresh_token' \
  -d 'refresh_token=YOUR_REFRESH_TOKEN' \
  -d 'client_id=your_client_id' \
  -d 'client_secret=your_client_secret'
```

**自动刷新示例**：
```javascript
class TokenManager {
  constructor(clientId, clientSecret) {
    this.clientId = clientId;
    this.clientSecret = clientSecret;
    this.accessToken = null;
    this.refreshToken = null;
    this.expiresAt = null;
  }
  
  async getAccessToken() {
    // 如果 Token 还有效，直接返回
    if (this.accessToken && Date.now() < this.expiresAt - 60000) {
      return this.accessToken;
    }
    
    // Token 过期，使用 refresh_token 刷新
    if (this.refreshToken) {
      await this.refreshAccessToken();
      return this.accessToken;
    }
    
    // 没有 Token，获取新的
    await this.fetchNewToken();
    return this.accessToken;
  }
  
  async refreshAccessToken() {
    const response = await axios.post('https://auth.nexusbook.app/token', {
      grant_type: 'refresh_token',
      refresh_token: this.refreshToken,
      client_id: this.clientId,
      client_secret: this.clientSecret
    });
    
    this.updateTokens(response.data);
  }
  
  updateTokens(data) {
    this.accessToken = data.access_token;
    this.refreshToken = data.refresh_token || this.refreshToken;
    this.expiresAt = Date.now() + (data.expires_in * 1000);
  }
}
```

## Scope 权限详解

### 权限级别

| Scope | 权限 | 说明 |
|-------|------|------|
| `doc:read` | 文档读取 | 读取文档属性、元数据、视图、设置 |
| `doc:write` | 文档写入 | 创建、更新、删除文档和元数据 |
| `data:read` | 数据读取 | 查询数据行 |
| `data:write` | 数据写入 | 创建、更新、删除数据行 |
| `views:manage` | 视图管理 | 创建、更新、删除视图 |
| `comments:write` | 评论管理 | 创建、更新、删除评论 |
| `approvals:manage` | 审批管理 | 发起和处理审批流程 |
| `requests:manage` | 请求管理 | 创建、合并、关闭变更请求 |
| `webhooks:manage` | Webhook 管理 | 创建、更新、删除 Webhook |

### 权限组合

**只读访问**：
```
scope=doc:read data:read
```

**数据管理**：
```
scope=doc:read data:read data:write
```

**完全访问**：
```
scope=doc:read doc:write data:read data:write views:manage comments:write approvals:manage requests:manage
```

## API Keys 管理

API 密钥用于服务集成与自动化任务，支持最小权限与可撤销。

### 创建 API Key
```bash
curl -X POST 'https://auth.nexusbook.app/api-keys' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "CI Pipeline",
    "scopes": ["doc:read", "data:read"],
    "expiresAt": "2026-01-01T00:00:00Z"
  }'
```

### 吊销 API Key
```bash
curl -X POST 'https://auth.nexusbook.app/api-keys/{keyId}/revoke' \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN'
```

### 最佳实践
- 使用最小权限的 scopes
- 配置过期时间与 IP 白名单
- 开启使用日志与速率限制

## 两步验证（2FA/MFA）

支持 TOTP（Authenticator）、短信、邮件与备用码。
- 开启：`POST /auth/2fa/enable`（返回二维码与密钥）
- 验证：`POST /auth/2fa/verify`
- 禁用：`POST /auth/2fa/disable`

## 会话管理

- 列出会话：`GET /auth/sessions`
- 关闭会话：`DELETE /auth/sessions/{sessionId}`
- 强制退出所有：`POST /auth/sessions/logout-all`


### 1. 使用 HTTPS

**始终使用 HTTPS** 传输敏感信息：
```javascript
// ✅ 正确
const apiUrl = 'https://open.nexusbook.app/api/v1/...';

// ❌ 错误
const apiUrl = 'http://open.nexusbook.app/api/v1/...';
```

### 2. Scope 最小权限原则

只请求应用需要的最小权限：
```javascript
// ✅ 正确 - 只读应用只请求读权限
scope: 'doc:read data:read'

// ❌ 错误 - 请求了不必要的写权限
scope: 'doc:read doc:write data:read data:write'
```

### 3. 保护 Client Secret

- ✅ 使用环境变量
- ✅ 使用密钥管理服务（AWS Secrets Manager、Azure Key Vault）
- ❌ 不要提交到代码仓库
- ❌ 不要在客户端代码中使用

## 安全最佳实践
function verifyToken(token) {
  return new Promise((resolve, reject) => {
    jwt.verify(token, getKey, {
      audience: 'your_client_id',
      issuer: 'https://auth.nexusbook.app',
      algorithms: ['RS256']
    }, (err, decoded) => {
      if (err) reject(err);
      else resolve(decoded);
    });
  });
}
```

### 5. 实施 Rate Limiting

保护您的应用免受滥用：
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 分钟
  max: 100 // 限制 100 个请求
});

app.use('/api/', limiter);
```

## 错误处理

### 常见认证错误

| 错误码 | 说明 | 解决方案 |
|--------|------|---------|
| `INVALID_CLIENT` | 客户端凭证错误 | 检查 client_id 和 client_secret |
| `INVALID_TOKEN` | Token 无效或过期 | 刷新或重新获取 Token |
| `UNAUTHORIZED` | 未授权 | 确保请求头包含有效 Token |
| `FORBIDDEN` | 权限不足 | 请求包含所需权限的 Scope |
| `INVALID_SCOPE` | Scope 无效 | 检查 Scope 拼写和可用性 |

### 错误处理示例

```javascript
async function callApi(endpoint, options = {}) {
  try {
    const token = await tokenManager.getAccessToken();
    
    const response = await axios.get(endpoint, {
      headers: {
        'Authorization': `Bearer ${token}`,
        ...options.headers
      }
    });
    
    return response.data;
  } catch (error) {
    if (error.response) {
      const { code, message } = error.response.data;
      
      // Token 过期，刷新后重试
      if (code === 'INVALID_TOKEN') {
        await tokenManager.refreshAccessToken();
        return callApi(endpoint, options); // 重试
      }
      
      // 权限不足
      if (code === 'FORBIDDEN') {
        throw new Error('权限不足，请联系管理员');
      }
      
      // 其他错误
      throw new Error(message.zh || message.en || '未知错误');
    }
    
    throw error;
  }
}
```

## 下一步

- 📊 阅读 [文档模型详解](document-model.html)
- 🔧 阅读 [数据操作指南](data-operations.html)
- 📚 查看 [API 参考文档](../api/index.html)
