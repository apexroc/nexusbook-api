# 错误码参考

本文档列出了 NexusBook API 所有可能返回的错误码及其说明。

## 错误响应格式

所有错误响应遵循统一格式：

```json
{
  "success": false,
  "code": "ERROR_CODE",
  "message": {
    "zh": "错误信息（中文）",
    "en": "Error message (English)"
  },
  "payload": null
}
```

## HTTP 状态码映射

| HTTP 状态码 | 说明 | 示例错误码 |
|-----------|------|-----------|
| 400 | 请求参数错误 | `INVALID_PARAMETER`, `VALIDATION_ERROR` |
| 401 | 未认证 | `INVALID_TOKEN`, `UNAUTHORIZED` |
| 403 | 权限不足 | `FORBIDDEN`, `INSUFFICIENT_SCOPE` |
| 404 | 资源不存在 | `DOC_NOT_FOUND`, `ROW_NOT_FOUND` |
| 409 | 资源冲突 | `VERSION_CONFLICT`, `DUPLICATE_ID` |
| 429 | 请求过于频繁 | `RATE_LIMIT_EXCEEDED` |
| 500 | 服务器错误 | `INTERNAL_ERROR` |

## 认证相关错误

### INVALID_CLIENT
- **说明**：客户端凭证无效
- **原因**：client_id 或 client_secret 错误
- **解决方案**：检查客户端凭证是否正确

### INVALID_TOKEN
- **说明**：访问令牌无效或已过期
- **原因**：Token 过期、格式错误或已被撤销
- **解决方案**：使用 refresh_token 刷新或重新获取 Token

### UNAUTHORIZED
- **说明**：未提供认证信息
- **原因**：请求头中缺少 Authorization
- **解决方案**：添加 `Authorization: Bearer YOUR_TOKEN`

### FORBIDDEN
- **说明**：权限不足
- **原因**：Token 的 Scope 不包含所需权限
- **解决方案**：请求包含所需权限的 Token

### INSUFFICIENT_SCOPE
- **说明**：Scope 权限不足
- **原因**：操作需要的权限未在 Token 中授予
- **解决方案**：重新获取包含所需 Scope 的 Token

## 文档相关错误

### DOC_NOT_FOUND
- **说明**：文档不存在
- **原因**：指定的 doc-id 不存在
- **解决方案**：检查文档 ID 是否正确

### DOC_TYPE_UNKNOWN
- **说明**：未知的文档类型
- **原因**：doc-type 参数不被支持
- **解决方案**：检查文档类型拼写

### DOC_ACCESS_DENIED
- **说明**：文档访问被拒绝
- **原因**：用户无权访问该文档
- **解决方案**：联系文档所有者授予权限

### DOC_LOCKED
- **说明**：文档已被锁定
- **原因**：文档处于锁定状态，不允许修改
- **解决方案**：等待锁定解除或联系管理员

## 视图相关错误

### VIEW_NOT_FOUND
- **说明**：视图不存在
- **原因**：指定的 view-id 不存在
- **解决方案**：检查视图 ID 是否正确

### VIEW_INVALID_DEFINITION
- **说明**：视图定义无效
- **原因**：视图配置不符合规范
- **解决方案**：检查视图配置，确保字段 ID、过滤条件等正确

### VIEW_PERMISSION_DENIED
- **说明**：无权操作视图
- **原因**：用户无权创建、修改或删除视图
- **解决方案**：请求 `views:manage` 权限

## 数据相关错误

### ROW_NOT_FOUND
- **说明**：数据行不存在
- **原因**：指定的 row-id 不存在
- **解决方案**：检查行 ID 是否正确

### FIELD_TYPE_MISMATCH
- **说明**：字段类型不匹配
- **原因**：提供的值类型与字段定义不符
- **解决方案**：检查字段值格式

### CONSTRAINT_VIOLATION
- **说明**：约束违反
- **原因**：违反了字段的验证规则（必填、唯一等）
- **解决方案**：检查数据是否满足字段约束

### VERSION_CONFLICT
- **说明**：版本冲突
- **原因**：数据已被其他用户修改
- **解决方案**：刷新数据后重试

### DUPLICATE_ID
- **说明**：ID 重复
- **原因**：尝试创建的 ID 已存在
- **解决方案**：使用不同的 ID

### INVALID_FIELD_ID
- **说明**：无效的字段 ID
- **原因**：元数据中不存在该字段
- **解决方案**：检查字段 ID 拼写

### REQUIRED_FIELD_MISSING
- **说明**：必填字段缺失
- **原因**：未提供必填字段的值
- **解决方案**：补充必填字段

### VALIDATION_ERROR
- **说明**：数据验证失败
- **原因**：数据不符合验证规则
- **解决方案**：检查数据格式和范围

## 评论相关错误

### COMMENT_NOT_FOUND
- **说明**：评论不存在
- **原因**：指定的 comment-id 不存在
- **解决方案**：检查评论 ID 是否正确

### COMMENT_PERMISSION_DENIED
- **说明**：无权操作评论
- **原因**：只有评论创建者或管理员可以编辑/删除
- **解决方案**：确认操作权限

## 审批相关错误

### APPROVAL_NOT_FOUND
- **说明**：审批实例不存在
- **原因**：指定的审批 ID 不存在
- **解决方案**：检查审批 ID 是否正确

### APPROVAL_ALREADY_COMPLETED
- **说明**：审批已完成
- **原因**：审批流程已结束
- **解决方案**：无需再次审批

### APPROVAL_PERMISSION_DENIED
- **说明**：无审批权限
- **原因**：用户不在审批人列表中
- **解决方案**：确认审批权限

## Webhook 相关错误

### WEBHOOK_NOT_FOUND
- **说明**：Webhook 不存在
- **原因**：指定的 webhook-id 不存在
- **解决方案**：检查 Webhook ID

### WEBHOOK_URL_INVALID
- **说明**：Webhook URL 无效
- **原因**：URL 格式错误或无法访问
- **解决方案**：检查 URL 格式

### WEBHOOK_DELIVERY_FAILED
- **说明**：Webhook 投递失败
- **原因**：目标服务器返回错误或超时
- **解决方案**：检查目标服务器状态

## 请求相关错误

### REQUEST_NOT_FOUND
- **说明**：变更请求不存在
- **原因**：指定的 request-id 不存在
- **解决方案**：检查请求 ID

### REQUEST_ALREADY_MERGED
- **说明**：请求已合并
- **原因**：变更请求已经被合并
- **解决方案**：无需再次合并

### REQUEST_CONFLICT
- **说明**：请求冲突
- **原因**：请求中的变更与当前状态冲突
- **解决方案**：解决冲突后重试

## 通用错误

### INVALID_PARAMETER
- **说明**：参数无效
- **原因**：请求参数格式错误或缺失
- **解决方案**：检查请求参数

### RATE_LIMIT_EXCEEDED
- **说明**：请求频率超限
- **原因**：短时间内请求过多
- **解决方案**：降低请求频率，查看 `Retry-After` 响应头

### INTERNAL_ERROR
- **说明**：服务器内部错误
- **原因**：服务器处理请求时发生异常
- **解决方案**：稍后重试，如果持续出现请联系技术支持

### SERVICE_UNAVAILABLE
- **说明**：服务暂时不可用
- **原因**：服务器维护或过载
- **解决方案**：稍后重试

## 错误处理最佳实践

### 1. 错误重试策略

```javascript
async function retryableRequest(requestFn, maxRetries = 3) {
  const retryableCodes = ['INTERNAL_ERROR', 'SERVICE_UNAVAILABLE'];
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await requestFn();
    } catch (error) {
      if (!retryableCodes.includes(error.code) || i === maxRetries - 1) {
        throw error;
      }
      
      // 指数退避
      await sleep(Math.pow(2, i) * 1000);
    }
  }
}
```

### 2. 用户友好提示

```javascript
function getUserFriendlyMessage(error, userLang = 'zh') {
  // 优先使用 API 返回的多语言消息
  if (error.message && error.message[userLang]) {
    return error.message[userLang];
  }
  
  // 降级到通用提示
  const fallbackMessages = {
    'INVALID_TOKEN': '登录已过期，请重新登录',
    'FORBIDDEN': '您没有权限执行此操作',
    'VERSION_CONFLICT': '数据已被修改，请刷新后重试',
    'RATE_LIMIT_EXCEEDED': '操作过于频繁，请稍后再试'
  };
  
  return fallbackMessages[error.code] || '操作失败，请稍后重试';
}
```

### 3. 错误日志记录

```javascript
function logError(error, context) {
  logger.error('API Error', {
    code: error.code,
    message: error.message,
    endpoint: context.endpoint,
    method: context.method,
    userId: context.userId,
    timestamp: new Date().toISOString()
  });
}
```

## 实时协同相关错误

### WS_AUTH_FAILED
- **说明**：WebSocket 认证失败
- **原因**：连接令牌无效或过期
- **解决方案**：重新获取连接信息并认证

### WS_RATE_LIMITED
- **说明**：WebSocket 消息速率超限
- **原因**：单位时间内消息过多
- **解决方案**：降低消息频率或启用批处理

### LOCK_CONFLICT
- **说明**：单元格锁冲突
- **原因**：目标单元格已被其他会话锁定
- **解决方案**：等待释放或申请更长的锁定时间

### SSE_UNSUPPORTED
- **说明**：目标环境不支持 SSE
- **原因**：代理或浏览器限制
- **解决方案**：改用 WebSocket 或轮询

## 下一步

- 📖 阅读 [API 参考文档](../api/index.html)
- 🚀 阅读 [快速开始](../guides/getting-started.html)
- 💡 阅读 [最佳实践](../guides/best-practices.html)
