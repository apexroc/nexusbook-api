# 认证与授权模块完整设计

## 创建日期
2024-12-05

## 模块概述

NexusBook 认证模块提供完整的身份认证、授权和 API 密钥管理功能，包含三个核心子模块：

1. **OAuth2/OIDC 认证** (`models.tsp`) - 标准 OAuth2 和 OIDC 协议支持
2. **用户注册与登录** (`registration.tsp`) - 完整的用户生命周期管理
3. **API 密钥管理** (`apikeys.tsp`) - 开放 API 密钥的全生命周期管理

---

## 1. OAuth2/OIDC 认证模块

### 功能列表

- ✅ 授权码流程 (Authorization Code Flow)
- ✅ 客户端凭证流程 (Client Credentials Flow)
- ✅ 令牌颁发和管理
- ✅ 刷新令牌
- ✅ OIDC 元数据发现
- ✅ JWKS 公钥管理
- ✅ 用户信息查询

### 核心接口

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 授权请求 | GET | `/auth/authorize` | 授权码流程的授权端点 |
| 令牌颁发 | POST | `/auth/token` | 颁发访问令牌和刷新令牌 |
| 用户信息 | GET | `/auth/userinfo` | 获取登录用户信息声明 |
| OIDC元数据 | GET | `/auth/.well-known/openid-configuration` | OIDC 提供方发现文档 |
| JWKS 公钥 | GET | `/auth/jwks.json` | JSON Web Key Set 公钥集合 |

### 使用示例

```bash
# 客户端凭证流程获取令牌
curl -X POST 'https://auth.nexusbook.com/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=client_credentials&client_id=CLIENT_ID&client_secret=CLIENT_SECRET&scope=doc:read data:read'
```

---

## 2. 用户注册与登录模块

### 功能列表

#### 2.1 用户注册
- ✅ 邮箱注册（邮箱 + 密码）
- ✅ 手机号注册（手机 + 验证码）
- ✅ 邀请码支持
- ✅ 服务条款确认

#### 2.2 用户登录
- ✅ 邮箱 + 密码登录
- ✅ 手机 + 验证码登录
- ✅ OAuth 第三方登录
- ✅ 魔法链接登录（无密码）
- ✅ 两步验证支持
- ✅ "记住我"功能

#### 2.3 密码管理
- ✅ 找回密码（验证码重置）
- ✅ 重置密码
- ✅ 修改密码

#### 2.4 两步验证 (2FA/MFA)
- ✅ TOTP（Google Authenticator 等）
- ✅ SMS 短信验证码
- ✅ Email 邮件验证码
- ✅ 备用码（Backup Codes）
- ✅ 设置和启用流程
- ✅ 禁用两步验证

#### 2.5 会话管理
- ✅ 列出所有活跃会话
- ✅ 查看会话详情（设备、IP、位置）
- ✅ 吊销指定会话
- ✅ 吊销所有其他会话

### 核心接口

| 功能分类 | 接口 | 方法 | 路径 |
|---------|------|------|------|
| **注册登录** |
| | 用户注册 | POST | `/api/v1/auth/register` |
| | 用户登录 | POST | `/api/v1/auth/login` |
| | 退出登录 | POST | `/api/v1/auth/logout` |
| | 刷新令牌 | POST | `/api/v1/auth/refresh` |
| **验证码** |
| | 发送验证码 | POST | `/api/v1/auth/verification-code` |
| **密码管理** |
| | 忘记密码 | POST | `/api/v1/auth/forgot-password` |
| | 重置密码 | POST | `/api/v1/auth/reset-password` |
| | 修改密码 | POST | `/api/v1/auth/change-password` |
| **两步验证** |
| | 设置两步验证 | POST | `/api/v1/auth/two-factor/setup` |
| | 启用两步验证 | POST | `/api/v1/auth/two-factor/enable` |
| | 禁用两步验证 | POST | `/api/v1/auth/two-factor/disable` |
| **会话管理** |
| | 列出会话 | GET | `/api/v1/auth/sessions` |
| | 吊销会话 | DELETE | `/api/v1/auth/sessions/{sessionId}` |
| | 吊销所有其他会话 | POST | `/api/v1/auth/sessions/revoke-all` |

### 使用示例

#### 邮箱注册

```bash
curl -X POST 'https://open.nexusbook.com/api/v1/auth/register' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "user@example.com",
    "password": "SecurePassword123!",
    "displayName": "张三",
    "agreeToTerms": true
  }'
```

#### 邮箱登录

```bash
curl -X POST 'https://open.nexusbook.com/api/v1/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "user@example.com",
    "password": "SecurePassword123!",
    "rememberMe": true
  }'
```

#### 手机号登录

```bash
# 1. 发送验证码
curl -X POST 'https://open.nexusbook.com/api/v1/auth/verification-code' \
  -H 'Content-Type: application/json' \
  -d '{
    "target": "+86 138 1234 5678",
    "type": "login"
  }'

# 2. 使用验证码登录
curl -X POST 'https://open.nexusbook.com/api/v1/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{
    "phone": "+86 138 1234 5678",
    "verificationCode": "123456"
  }'
```

#### 设置 TOTP 两步验证

```bash
# 1. 初始化设置
curl -X POST 'https://open.nexusbook.com/api/v1/auth/two-factor/setup' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "method": "totp"
  }'

# 响应包含 secret 和 qrCodeUrl
{
  "data": {
    "method": "totp",
    "secret": "JBSWY3DPEHPK3PXP",
    "qrCodeUrl": "otpauth://totp/NexusBook:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=NexusBook"
  }
}

# 2. 使用 Google Authenticator 扫描二维码后，启用两步验证
curl -X POST 'https://open.nexusbook.com/api/v1/auth/two-factor/enable' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "method": "totp",
    "code": "123456"
  }'
```

#### 密码找回流程

```bash
# 1. 请求密码重置
curl -X POST 'https://open.nexusbook.com/api/v1/auth/forgot-password' \
  -H 'Content-Type: application/json' \
  -d '{
    "target": "user@example.com"
  }'

# 2. 使用验证码重置密码
curl -X POST 'https://open.nexusbook.com/api/v1/auth/reset-password' \
  -H 'Content-Type: application/json' \
  -d '{
    "target": "user@example.com",
    "verificationCode": "123456",
    "newPassword": "NewSecurePassword123!"
  }'
```

---

## 3. API 密钥管理模块

### 功能列表

- ✅ 创建 API Key（带权限范围）
- ✅ 列出和查看 API Key
- ✅ 更新 API Key（名称、权限、速率限制等）
- ✅ 吊销 API Key
- ✅ 重新生成 API Key
- ✅ 删除 API Key
- ✅ 使用记录和日志
- ✅ 使用统计分析
- ✅ 批量吊销
- ✅ 速率限制配置
- ✅ IP 白名单
- ✅ CORS 来源限制

### 权限范围 (Scopes)

| Scope | 说明 |
|-------|------|
| `doc:read` | 读取文档 |
| `doc:write` | 写入文档 |
| `doc:delete` | 删除文档 |
| `data:read` | 读取数据 |
| `data:write` | 写入数据 |
| `data:delete` | 删除数据 |
| `org:manage` | 管理组织 |
| `workspace:manage` | 管理工作区 |
| `user:manage` | 管理用户 |
| `webhook:manage` | Webhook 管理 |
| `all` | 完整权限 |

### 核心接口

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 创建 API Key | POST | `/api/v1/api-keys` | 创建新的 API 密钥 |
| 列出 API Keys | GET | `/api/v1/api-keys` | 获取 API 密钥列表 |
| 获取详情 | GET | `/api/v1/api-keys/{apiKeyId}` | 获取指定密钥详情 |
| 更新 API Key | PATCH | `/api/v1/api-keys/{apiKeyId}` | 更新密钥配置 |
| 吊销 API Key | POST | `/api/v1/api-keys/{apiKeyId}/revoke` | 吊销密钥 |
| 重新生成 | POST | `/api/v1/api-keys/{apiKeyId}/regenerate` | 重新生成密钥 |
| 删除 API Key | DELETE | `/api/v1/api-keys/{apiKeyId}` | 删除密钥 |
| 使用记录 | GET | `/api/v1/api-keys/{apiKeyId}/logs` | 获取使用日志 |
| 使用统计 | GET | `/api/v1/api-keys/{apiKeyId}/stats` | 获取使用统计 |
| 批量吊销 | POST | `/api/v1/api-keys/batch-revoke` | 批量吊销密钥 |

### 使用示例

#### 创建 API Key

```bash
curl -X POST 'https://open.nexusbook.com/api/v1/api-keys' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "生产环境 API Key",
    "description": "用于生产环境的后端服务",
    "scopes": ["doc:read", "doc:write", "data:read", "data:write"],
    "expiresInDays": 365,
    "rateLimit": 1000,
    "ipWhitelist": ["192.168.1.100", "10.0.0.0/24"]
  }'
```

响应：
```json
{
  "data": {
    "id": "key_abc123",
    "key": "sk_example_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",  // 示例密钥（仅示例，不可用）
    "keyPrefix": "sk_live_123...",
    "name": "生产环境 API Key",
    "description": "用于生产环境的后端服务",
    "scopes": ["doc:read", "doc:write", "data:read", "data:write"],
    "status": "active",
    "createdAt": "2024-12-05T10:00:00Z",
    "expiresAt": "2025-12-05T10:00:00Z",
    "usageCount": 0,
    "rateLimit": 1000
  }
}
```

#### 列出 API Keys

```bash
curl -X GET 'https://open.nexusbook.com/api/v1/api-keys?page=1&pageSize=20&status=active' \
  -H 'Authorization: Bearer TOKEN'
```

#### 更新 API Key

```bash
curl -X PATCH 'https://open.nexusbook.com/api/v1/api-keys/key_abc123' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "生产环境 API Key (更新)",
    "scopes": ["doc:read", "data:read"],
    "rateLimit": 500
  }'
```

#### 吊销 API Key

```bash
curl -X POST 'https://open.nexusbook.com/api/v1/api-keys/key_abc123/revoke' \
  -H 'Authorization: Bearer TOKEN'
```

#### 查看使用记录

```bash
curl -X GET 'https://open.nexusbook.com/api/v1/api-keys/key_abc123/logs?page=1&pageSize=50&startTime=2024-12-01T00:00:00Z&endTime=2024-12-05T23:59:59Z' \
  -H 'Authorization: Bearer TOKEN'
```

响应：
```json
{
  "data": {
    "items": [
      {
        "id": "log_123",
        "apiKeyId": "key_abc123",
        "timestamp": "2024-12-05T10:15:30Z",
        "method": "POST",
        "path": "/api/v1/doc/product/123/data/bulk",
        "statusCode": 200,
        "ipAddress": "192.168.1.100",
        "userAgent": "MyApp/1.0",
        "responseTime": 145
      }
    ],
    "total": 1523,
    "page": 1,
    "pageSize": 50
  }
}
```

#### 查看使用统计

```bash
curl -X GET 'https://open.nexusbook.com/api/v1/api-keys/key_abc123/stats?period=7d' \
  -H 'Authorization: Bearer TOKEN'
```

响应：
```json
{
  "data": {
    "apiKeyId": "key_abc123",
    "periodStart": "2024-11-28T00:00:00Z",
    "periodEnd": "2024-12-05T23:59:59Z",
    "totalRequests": 15234,
    "successfulRequests": 14987,
    "failedRequests": 247,
    "averageResponseTime": 156.8,
    "byEndpoint": [
      {"path": "/api/v1/doc/.../data/bulk", "count": 8521},
      {"path": "/api/v1/doc/.../data", "count": 4123},
      {"path": "/api/v1/doc/.../ properties", "count": 2590}
    ],
    "byStatusCode": [
      {"code": 200, "count": 14987},
      {"code": 400, "count": 156},
      {"code": 429, "count": 91}
    ]
  }
}
```

---

## 安全最佳实践

### 1. API Key 安全

#### 密钥格式
```
sk_example_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
│  │    │
│  │    └─ 随机字符串（32+ 字符）
│  └────── 环境标识（live/test）
└──────── 前缀（sk = Secret Key）
```

#### 存储和传输
- ✅ **创建时只返回一次**：完整密钥只在创建时返回，之后只显示前缀
- ✅ **安全存储**：使用环境变量或密钥管理服务（如 AWS Secrets Manager）
- ✅ **HTTPS 传输**：所有 API 请求必须使用 HTTPS
- ✅ **不记录日志**：不要在日志中记录完整密钥

#### 权限控制
- ✅ **最小权限原则**：只授予必需的权限范围
- ✅ **分环境管理**：生产环境和测试环境使用不同的密钥
- ✅ **定期轮换**：定期重新生成密钥
- ✅ **IP 白名单**：限制允许使用密钥的 IP 地址

#### 速率限制
```json
{
  "rateLimit": 1000,  // 1000 请求/分钟
  "burstLimit": 100   // 突发限制：100 请求/秒
}
```

---

### 2. 两步验证 (2FA) 安全

#### TOTP 最佳实践
- ✅ **安全的密钥生成**：使用加密强度的随机数生成器
- ✅ **备用码**：提供 10 个备用码，每个只能使用一次
- ✅ **时间窗口**：允许 ±30 秒的时间漂移
- ✅ **防暴力破解**：限制验证码尝试次数（5 次/10 分钟）

#### SMS/Email 验证码
- ✅ **随机生成**：6 位随机数字
- ✅ **有效期限**：5-10 分钟
- ✅ **一次性使用**：验证后立即失效
- ✅ **防重放**：同一个验证码不能重复使用
- ✅ **速率限制**：限制发送频率（1 次/60 秒）

---

### 3. 会话管理安全

#### 会话生命周期
- ✅ **访问令牌**：短期有效（15-60 分钟）
- ✅ **刷新令牌**：长期有效（7-30 天）
- ✅ **"记住我"**：延长刷新令牌有效期（30-90 天）

#### 会话安全
- ✅ **设备追踪**：记录设备类型、操作系统、浏览器
- ✅ **地理位置**：记录 IP 和地理位置，检测异常登录
- ✅ **并发会话**：限制同一用户的并发会话数量
- ✅ **自动过期**：长时间不活跃自动过期
- ✅ **强制登出**：密码修改后强制所有会话登出

---

## 数据模型设计

### 用户表 (users)

```sql
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255),
    display_name VARCHAR(100),
    avatar_url VARCHAR(500),
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_method ENUM('totp', 'sms', 'email') NULL,
    totp_secret VARCHAR(255) NULL,
    backup_codes JSON NULL,
    status ENUM('active', 'suspended', 'deleted') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_phone (phone)
);
```

### API Keys 表 (api_keys)

```sql
CREATE TABLE api_keys (
    id VARCHAR(36) PRIMARY KEY,
    key_hash VARCHAR(255) UNIQUE NOT NULL,
    key_prefix VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    user_id VARCHAR(36) NOT NULL,
    organization_id VARCHAR(36) NULL,
    workspace_id VARCHAR(36) NULL,
    scopes JSON NOT NULL,
    status ENUM('active', 'expired', 'revoked', 'disabled') DEFAULT 'active',
    rate_limit INT DEFAULT 1000,
    ip_whitelist JSON NULL,
    allowed_origins JSON NULL,
    usage_count BIGINT DEFAULT 0,
    last_used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    INDEX idx_user (user_id),
    INDEX idx_key_hash (key_hash),
    INDEX idx_status (status),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 会话表 (sessions)

```sql
CREATE TABLE sessions (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    refresh_token_hash VARCHAR(255) UNIQUE NOT NULL,
    device_type VARCHAR(50),
    device_os VARCHAR(50),
    device_browser VARCHAR(50),
    ip_address VARCHAR(45),
    location_country VARCHAR(50),
    location_city VARCHAR(100),
    status ENUM('active', 'expired', 'revoked') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    INDEX idx_user (user_id),
    INDEX idx_status (status),
    INDEX idx_expires (expires_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### API Key 使用日志表 (api_key_usage_logs)

```sql
CREATE TABLE api_key_usage_logs (
    id VARCHAR(36) PRIMARY KEY,
    api_key_id VARCHAR(36) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    method VARCHAR(10),
    path VARCHAR(500),
    status_code INT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    origin VARCHAR(500),
    response_time INT,
    error TEXT NULL,
    INDEX idx_api_key (api_key_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_status (status_code),
    FOREIGN KEY (api_key_id) REFERENCES api_keys(id) ON DELETE CASCADE
);
```

---

## 总结

### 新增功能

✅ **用户注册与登录**
- 邮箱/手机号注册
- 多种登录方式（邮箱+密码、手机+验证码、OAuth）
- 验证码发送和验证

✅ **密码管理**
- 找回密码流程
- 重置密码
- 修改密码

✅ **两步验证 (2FA)**
- TOTP 支持（Google Authenticator）
- SMS 短信验证码
- Email 邮件验证码
- 备用码

✅ **会话管理**
- 列出所有活跃会话
- 查看会话详情（设备、IP、位置）
- 吊销会话
- 吊销所有其他会话

✅ **API Key 管理**
- 创建/更新/吊销/删除 API Key
- 权限范围管理（11 种 scopes）
- 速率限制配置
- IP 白名单
- CORS 来源限制
- 使用记录和日志
- 使用统计分析
- 批量操作

### 文件结构

```
api/auth/
├── index.tsp           # 模块入口和总览
├── models.tsp          # OAuth2/OIDC 标准认证
├── registration.tsp    # 用户注册、登录、密码、2FA、会话（711 行）
└── apikeys.tsp         # API 密钥管理（803 行）
```

### API 统计

- **总接口数**：30+ 个
- **用户认证**：11 个接口
- **API Key 管理**：10 个接口
- **OAuth2/OIDC**：5 个接口
- **会话管理**：3 个接口

所有功能都已完整实现，包括详细的注释、示例和错误处理！
