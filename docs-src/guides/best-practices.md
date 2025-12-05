# 最佳实践

本指南总结了使用 NexusBook API 的最佳实践，帮助您构建高效、可靠的应用。

## 属性设计

### 命名规范

✅ **推荐**：
```json
{
  "orderTime": "2024-12-01T10:00:00Z",
  "storeName": "Beijing Branch",
  "totalAmount": 5000.00
}
```

❌ **不推荐**：
```json
{
  "time": "2024-12-01T10:00:00Z",  // 不够描述性
  "s_name": "Beijing Branch",      // 使用了下划线
  "amt": 5000.00                    // 过度缩写
}
```

### 结构设计

✅ **推荐**：扁平化结构
```json
{
  "shipping_city": "Beijing",
  "shipping_address": "123 Main St",
  "billing_city": "Shanghai",
  "billing_address": "456 Park Ave"
}
```

❌ **不推荐**：过度嵌套
```json
{
  "shipping": {
    "address": {
      "city": "Beijing",
      "street": "123 Main St"
    }
  }
}
```

## 元数据设计

### 字段定义规范

✅ **推荐**：
```json
{
  "id": "productName",
  "name": "产品名称",
  "type": "text",
  "required": true,
  "description": "产品的完整名称",
  "validation": {
    "minLength": 1,
    "maxLength": 200
  }
}
```

### 避免频繁修改元数据

元数据变更会影响已有数据，应该：
- 充分规划字段结构
- 使用版本迁移策略
- 提供数据迁移脚本

## 数据操作

### 批量操作优先

✅ **推荐**：
```javascript
// 批量创建 100 行
await api.post('/data/bulk?requestId=req-1', {
  rows: Array.from({length: 100}, (_, i) => ({
    id: `row-${i}`,
    values: [...]
  }))
});
```

❌ **不推荐**：
```javascript
// 循环创建 100 次
for (let i = 0; i < 100; i++) {
  await api.post('/data?apply=true', {
    id: `row-${i}`,
    values: [...]
  });
}
```

### 并发控制

始终使用版本号：
```javascript
async function updateRow(rowId, newValues) {
  // 1. 获取最新数据
  const row = await api.get(`/data/${rowId}`);
  
  // 2. 更新时提供版本号
  await api.put(`/data/${rowId}?requestId=req-1`, {
    values: newValues,
    version: row.version
  });
}
```

### 错误处理

```javascript
async function safeUpdate(rowId, newValues) {
  const maxRetries = 3;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const row = await api.get(`/data/${rowId}`);
      await api.put(`/data/${rowId}?requestId=req-1`, {
        values: newValues,
        version: row.version
      });
      return; // 成功
    } catch (error) {
      if (error.code === 'VERSION_CONFLICT' && i < maxRetries - 1) {
        // 版本冲突，重试
        continue;
      }
      throw error; // 其他错误或达到重试上限
    }
  }
}
```

## 评论协作

### 精确定位

✅ **推荐**：明确指定评论位置
```javascript
// 针对特定单元格
await api.post('/comments', {
  target: {
    scope: 'cell',
    rowId: 'row-001',
    fieldId: 'price'
  },
  content: '这个价格需要确认'
});
```

### 使用 @提及

```javascript
await api.post('/comments', {
  target: { scope: 'document' },
  content: '@张三 @李四 请review这个订单',
  mentions: ['user-123', 'user-456']
});
```

### 及时标记已解决

```javascript
// 问题解决后标记
await api.post(`/comments/${commentId}/resolve`);
```

## 版本控制

### 修订说明编写

✅ **推荐**：
```javascript
await api.post('/requests', {
  title: '更新产品价格',
  description: '根据供应商调价通知，更新以下产品价格：\n- iPhone 15: 799.99 → 749.99\n- iPad Pro: 1099.99 → 999.99',
  changes: [...]
});
```

❌ **不推荐**：
```javascript
await api.post('/requests', {
  title: '更新',
  description: '修改了一些数据',
  changes: [...]
});
```

### 历史审计

定期检查修订历史：
```javascript
// 查看特定行的变更历史
const history = await api.get('/revisions/history', {
  params: {
    targetKind: 'row',
    rowId: 'row-001'
  }
});
```

## 性能优化

### 分页策略

```javascript
// ✅ 合理的分页大小
const pageSize = 50;

// 游标分页（用于深分页）
async function* fetchAllData() {
  let cursor = null;
  
  do {
    const response = await api.get('/data', {
      params: { pageSize, cursor }
    });
    
    yield response.items;
    cursor = response.cursor;
  } while (cursor);
}
```

### 按需加载

```javascript
// ✅ 只获取需要的部分
const doc = await api.get('/doc/product/123', {
  params: {
    include: 'metadata,data',  // 不包括 comments 和 revisions
    pageSize: 20
  }
});

// ❌ 获取所有数据
const doc = await api.get('/doc/product/123', {
  params: {
    include: 'metadata,views,data,comments,revisions,settings'
  }
});
```

### 缓存策略

```javascript
class ApiClient {
  constructor() {
    this.cache = new Map();
    this.cacheTTL = 60000; // 1 分钟
  }
  
  async getMetadata(docType, docId) {
    const key = `metadata:${docType}:${docId}`;
    const cached = this.cache.get(key);
    
    if (cached && Date.now() - cached.time < this.cacheTTL) {
      return cached.data;
    }
    
    const data = await api.get(`/doc/${docType}/${docId}/metadata`);
    this.cache.set(key, { data, time: Date.now() });
    
    return data;
  }
}
```

## 安全建议

### 权限控制

```javascript
// ✅ 最小权限原则
const token = await getToken({
  scope: 'doc:read data:read'  // 只读应用只请求读权限
});

// ❌ 请求不必要的权限
const token = await getToken({
  scope: 'doc:read doc:write data:read data:write approvals:manage'
});
```

### 数据验证

```javascript
function validateRowData(values) {
  const errors = [];
  
  values.forEach(fieldValue => {
    // 验证必填字段
    if (field.required && !fieldValue.value) {
      errors.push(`${field.name} 是必填字段`);
    }
    
    // 验证数据类型
    if (field.type === 'number') {
      if (typeof fieldValue.value.number !== 'number') {
        errors.push(`${field.name} 必须是数字`);
      }
    }
    
    // 验证范围
    if (field.validation?.min !== undefined) {
      if (fieldValue.value.number < field.validation.min) {
        errors.push(`${field.name} 不能小于 ${field.validation.min}`);
      }
    }
  });
  
  return errors;
}
```

### 日志记录

```javascript
class AuditLogger {
  async logApiCall(method, endpoint, user, response) {
    await db.insert('audit_logs', {
      timestamp: new Date(),
      user: user.id,
      method,
      endpoint,
      success: response.success,
      errorCode: response.code,
      ipAddress: request.ip
    });
  }
}
```

## 测试建议

### 单元测试

```javascript
describe('数据行 CRUD', () => {
  test('创建数据行', async () => {
    const row = {
      id: 'test-row-001',
      values: [
        { fieldId: 'name', value: { text: '测试产品' } }
      ]
    };
    
    const response = await api.post('/data?apply=true', row);
    
    expect(response.success).toBe(true);
    expect(response.payload.id).toBe('test-row-001');
  });
  
  test('并发冲突处理', async () => {
    const row = await api.get('/data/row-001');
    
    // 模拟另一个用户更新
    await api.put('/data/row-001?requestId=req-1', {
      values: [...],
      version: row.version
    });
    
    // 当前更新应该失败
    await expect(
      api.put('/data/row-001?apply=true', {
        values: [...],
        version: row.version
      })
    ).rejects.toThrow('VERSION_CONFLICT');
  });
});
```

### 集成测试

```javascript
describe('订货单工作流', () => {
  test('完整流程', async () => {
    // 1. 创建订货单
    const doc = await api.post('/doc/purchaseOrder', {...});
    
    // 2. 添加产品行
    await api.post(`/doc/purchaseOrder/${doc.id}/data/bulk?apply=true`, {
      rows: [...]
    });
    
    // 3. 添加评论
    await api.post(`/doc/purchaseOrder/${doc.id}/comments`, {
      content: '请尽快处理'
    });
    
    // 4. 发起审批
    const approval = await api.post(`/doc/purchaseOrder/${doc.id}/approval/start`);
    
    // 5. 审批通过
    await api.post(`/doc/purchaseOrder/${doc.id}/approval/${approval.id}/decision`, {
      result: 'approved'
    });
    
    // 验证最终状态
    const finalDoc = await api.get(`/doc/purchaseOrder/${doc.id}`);
    expect(finalDoc.status).toBe('approved');
  });
});
```

## 监控和告警

### 性能监控

```javascript
class PerformanceMonitor {
  async trackApiCall(apiCall) {
    const start = Date.now();
    
    try {
      const result = await apiCall();
      const duration = Date.now() - start;
      
      // 记录响应时间
      metrics.histogram('api.response_time', duration, {
        endpoint: apiCall.endpoint,
        method: apiCall.method
      });
      
      // 慢查询告警
      if (duration > 3000) {
        logger.warn('Slow API call', {
          endpoint: apiCall.endpoint,
          duration
        });
      }
      
      return result;
    } catch (error) {
      // 错误率监控
      metrics.increment('api.errors', {
        endpoint: apiCall.endpoint,
        errorCode: error.code
      });
      
      throw error;
    }
  }
}
```

## 总结

遵循这些最佳实践，可以帮助您：

- ✅ 提高应用性能和响应速度
- ✅ 增强数据一致性和可靠性
- ✅ 简化错误处理和调试
- ✅ 提升代码可维护性
- ✅ 保障系统安全性

## 下一步

- 📚 查看 [完整示例](examples.html)
- 📖 阅读 [API 参考文档](../api/index.html)
- 🔧 阅读 [数据操作指南](data-operations.html)
