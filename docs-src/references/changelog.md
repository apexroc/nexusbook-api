# 变更日志

本文档记录 NexusBook API 的主要功能变更和版本历史。

## 版本 1.0.0（当前版本）

**发布日期**：2024-12-01

### 核心功能

#### 📊 文档与数据管理
- ✅ 统一的文档抽象（Document Model）
- ✅ 25+ 种字段类型支持
- ✅ 强大的数据查询能力（过滤、排序、分组、聚合）
- ✅ Properties（文档属性）管理
- ✅ Metadata（元数据）管理
- ✅ 数据行 CRUD 操作
- ✅ 批量操作支持

#### 👁️ 视图系统
- ✅ 8 种视图类型（Table, Gallery, Kanban, Calendar, Chart, Form, Map, Timeline）
- ✅ 自定义过滤和排序
- ✅ 视图配置管理
- ✅ 默认视图设置

#### 💬 协作功能
- ✅ 统一评论系统（支持文档/字段/行/单元格级别）
- ✅ @提及功能
- ✅ 评论回复和讨论线程
- ✅ 表情反应
- ✅ 置顶和解决标记

#### 🔄 版本控制
- ✅ Request（变更请求）机制
- ✅ Revision（修订历史）追踪
- ✅ 版本对比（diff）
- ✅ 回滚功能
- ✅ 并发控制（乐观锁）

#### ✅ 审批工作流
- ✅ 多层级审批流程
- ✅ 审批决策（通过/拒绝/请求修改）
- ✅ 完整的审批历史
- ✅ 基于角色的权限控制

#### 🔐 认证与授权
- ✅ OAuth2 客户端凭证流程
- ✅ OAuth2 授权码流程
- ✅ OIDC 集成
- ✅ JWT Token 管理
- ✅ 基于 Scope 的权限控制
- ✅ JWKS 端点支持

#### 🔔 Webhooks
- ✅ 20+ 种事件类型
- ✅ HMAC-SHA256 签名验证
- ✅ 自动重试机制
- ✅ 事件过滤
- ✅ 投递历史查询
- ✅ 测试端点

### API 端点

#### 文档管理
- `GET /doc/{doc-type}/{doc-id}` - 聚合查询
- `GET/POST/PUT/PATCH/DELETE /doc/{doc-type}/{doc-id}/properties` - 属性管理
- `GET/PUT /doc/{doc-type}/{doc-id}/metadata` - 元数据管理
- `GET/POST/PUT/DELETE /doc/{doc-type}/{doc-id}/views/*` - 视图管理
- `GET/POST/PUT/DELETE /doc/{doc-type}/{doc-id}/data/*` - 数据管理
- `GET/POST/PUT/DELETE /doc/{doc-type}/{doc-id}/comments/*` - 评论管理

#### 版本控制
- `GET/POST /doc/{doc-type}/{doc-id}/requests/*` - 变更请求
- `GET /doc/{doc-type}/{doc-id}/revisions/*` - 修订历史

#### 审批流程
- `GET/POST /doc/{doc-type}/{doc-id}/approval/*` - 审批管理

#### 认证授权
- `GET /auth/authorize` - 授权端点
- `POST /auth/token` - 令牌颁发
- `GET /auth/userinfo` - 用户信息
- `GET /auth/.well-known/openid-configuration` - OIDC 发现
- `GET /auth/jwks.json` - 公钥集合

#### Webhooks
- `GET/POST/PUT/DELETE /webhooks/*` - Webhook 管理
- `POST /webhooks/{id}/pause` - 暂停
- `POST /webhooks/{id}/resume` - 恢复
- `POST /webhooks/{id}/test` - 测试
- `GET /webhooks/{id}/deliveries/*` - 投递管理

### 技术栈

- **API 定义**: TypeSpec 1.6.0
- **规范**: OpenAPI 3.0
- **文档生成**: Redocly
- **认证**: OAuth2 & OIDC
- **Token**: JWT

### 已知限制

- 单次批量操作最多支持 1000 行数据
- Webhook 投递超时时间为 30 秒
- Token 默认有效期为 1 小时
- API 请求频率限制：100 请求/分钟

## 即将推出

### 版本 1.1.0（计划中）

- 🔜 实时协作（WebSocket 支持）
- 🔜 数据导入导出增强（支持更多格式）
- 🔜 自定义函数支持
- 🔜 更多视图类型（Gantt、Timeline）
- 🔜 高级权限管理（行级权限）

### 版本 1.2.0（规划中）

- 🔜 API 版本控制（v2）
- 🔜 GraphQL 支持
- 🔜 数据备份和恢复
- 🔜 审计日志增强
- 🔜 性能优化（缓存层）

## API 兼容性

### 版本策略

NexusBook API 遵循语义化版本控制（SemVer）：

- **主版本号**（Major）：不兼容的 API 变更
- **次版本号**（Minor）：向后兼容的功能新增
- **修订号**（Patch）：向后兼容的问题修复

### 废弃政策

- API 废弃将提前至少 6 个月通知
- 废弃的 API 将在响应头中标记 `X-API-Deprecated: true`
- 建议及时迁移到新的 API

### 破坏性变更

目前版本 1.0.0 为首个正式版本，暂无破坏性变更。

## 迁移指南

### 从 Beta 版本迁移

如果您使用的是 Beta 版本，请注意以下变更：

#### 1. 响应格式统一

**旧格式**（Beta）：
```json
{
  "data": {...},
  "error": null
}
```

**新格式**（v1.0）：
```json
{
  "success": true,
  "payload": {...}
}
```

#### 2. 多语言消息

**旧格式**（Beta）：
```json
{
  "message": {
    "zh": "...",
    "en": "..."
  }
}
```

**新格式**（v1.0）：支持任意语言代码
```json
{
  "message": {
    "zh": "...",
    "en": "...",
    "ja": "...",
    "ko": "..."
  }
}
```

#### 3. 评论 API 统一

Beta 版本中评论 API 分散在不同端点，v1.0 统一到：

```
POST /doc/{doc-type}/{doc-id}/comments
```

使用 `target` 参数指定位置：
```json
{
  "target": {
    "scope": "cell",
    "rowId": "row-001",
    "fieldId": "price"
  },
  "content": "..."
}
```

## 获取最新信息

- 📚 [API 文档](../api/index.html)
- 🐛 [问题反馈](https://github.com/NexusBook/nexusbook-api/issues)
- 💬 [讨论区](https://github.com/NexusBook/nexusbook-api/discussions)
- 📢 [发布说明](https://github.com/NexusBook/nexusbook-api/releases)

## 贡献

欢迎提交问题报告、功能建议和代码贡献！

- 提交 Issue：[GitHub Issues](https://github.com/NexusBook/nexusbook-api/issues)
- 功能请求：[GitHub Discussions](https://github.com/NexusBook/nexusbook-api/discussions)

---

最后更新：2024-12-01
