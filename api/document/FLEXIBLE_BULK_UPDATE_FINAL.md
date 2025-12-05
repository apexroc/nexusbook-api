# 灵活批量更新 API 设计（最终版）

## 修改日期
2024-12-05

## 设计理念

> **一个接口，灵活处理所有更新场景**
>
> - Target 灵活：可以是单行、多行、单字段、多字段、单属性、多属性
> - Value 简单：始终使用原始值（数字、字符串、布尔值、对象、数组）
> - 服务端智能：根据 metadata 自动解析类型和验证

---

## 核心 API

### 统一的批量更新接口

```
POST /doc/{docType}/{docId}/data/bulk?requestId={requestId}
Body: BulkUpdate[]
```

**BulkUpdate 结构**：

```typescript
{
  target: {},      // 灵活的目标结构
  value: unknown   // 原始值（可以是单值、对象或数组）
}
```

---

## Target 结构详解

### 1. 修改单个字段

```json
{
  "target": {"row": "row-1", "field": "price"},
  "value": 99.99
}
```

**语义**：修改 row-1 的 price 字段为 99.99

**服务端处理**：
1. 查找 row-1 的 price 字段定义
2. 发现是 currency 类型
3. 转换为 `{"currency": 99.99}`

---

### 2. 修改整行（多个字段）

```json
{
  "target": {"row": "row-1"},
  "value": {
    "price": 99.99,
    "name": "iPhone 15",
    "stock": 50
  }
}
```

**语义**：修改 row-1 的三个字段

**服务端处理**：
1. 遍历 value 对象的每个键
2. 查找对应字段定义
3. 分别转换类型：
   - price → `{"currency": 99.99}`
   - name → `{"text": "iPhone 15"}`
   - stock → `{"number": 50}`

---

### 3. 修改多行的同一字段（相同值）

```json
{
  "target": {"rows": ["row-1", "row-2", "row-3"], "field": "status"},
  "value": "active"
}
```

**语义**：将 row-1、row-2、row-3 的 status 字段都设置为 "active"

**服务端处理**：
1. 查找 status 字段定义（假设是 single_select 类型）
2. 转换为 `{"single_select": {"id": "active", ...}}`
3. 应用到三行

---

### 4. 修改多行的同一字段（不同值）

```json
{
  "target": {"rows": ["row-1", "row-2", "row-3"], "field": "price"},
  "value": [99.99, 88.88, 77.77]
}
```

**语义**：
- row-1 的 price → 99.99
- row-2 的 price → 88.88
- row-3 的 price → 77.77

**服务端处理**：
1. 查找 price 字段定义（currency 类型）
2. 分别转换：
   - row-1 → `{"currency": 99.99}`
   - row-2 → `{"currency": 88.88}`
   - row-3 → `{"currency": 77.77}`

**注意**：value 数组长度必须与 rows 数组长度一致

---

### 5. 修改单个属性

```json
{
  "target": {"property": "amount"},
  "value": 5000.00
}
```

**语义**：修改文档属性 amount 为 5000.00

**服务端处理**：
1. 查找 properties 中的 amount 字段定义
2. 转换为 `{"currency": 5000.00}`

---

### 6. 修改多个属性

```json
{
  "target": {"properties": true},
  "value": {
    "amount": 5000.00,
    "quantity": 100,
    "date": "2024-12-05"
  }
}
```

**语义**：修改文档的三个属性

**服务端处理**：
1. 遍历 value 对象的每个键
2. 查找 properties 中的字段定义
3. 分别转换类型：
   - amount → `{"currency": 5000.00}`
   - quantity → `{"number": 100}`
   - date → `{"date": "2024-12-05"}`

---

## 批量操作示例

### 场景 1：混合更新（数据 + 属性）

一次请求同时修改数据行和文档属性：

```bash
curl -X POST '.../data/bulk?requestId=req-1' \
  -H 'Content-Type: application/json' \
  -d '[
    {
      "target": {"row": "row-1", "field": "price"},
      "value": 99.99
    },
    {
      "target": {"row": "row-1", "field": "stock"},
      "value": 50
    },
    {
      "target": {"property": "totalAmount"},
      "value": 4999.50
    }
  ]'
```

---

### 场景 2：批量更新多行

一次更新 100 行的状态字段：

```bash
curl -X POST '.../data/bulk?requestId=req-1' \
  -d '[
    {
      "target": {
        "rows": ["row-1", "row-2", ..., "row-100"],
        "field": "status"
      },
      "value": "completed"
    }
  ]'
```

---

### 场景 3：复杂的批量操作

一次请求完成多种类型的更新：

```bash
curl -X POST '.../data/bulk?requestId=req-1' \
  -d '[
    // 1. 修改整行
    {
      "target": {"row": "row-1"},
      "value": {"price": 99.99, "name": "iPhone 15", "stock": 50}
    },
    
    // 2. 修改单个字段
    {
      "target": {"row": "row-2", "field": "status"},
      "value": "active"
    },
    
    // 3. 批量修改多行
    {
      "target": {"rows": ["row-3", "row-4", "row-5"], "field": "discount"},
      "value": [0.1, 0.15, 0.2]
    },
    
    // 4. 修改文档属性
    {
      "target": {"properties": true},
      "value": {"amount": 5000.00, "quantity": 150}
    }
  ]'
```

---

## Value 类型说明

### 单值（Single Value）

适用于：
- 单个字段更新
- 多行相同值更新
- 单个属性更新

```json
{
  "target": {"row": "row-1", "field": "price"},
  "value": 99.99  // ✅ 单值
}
```

---

### 对象（Object）

适用于：
- 整行更新（多个字段）
- 多个属性更新

```json
{
  "target": {"row": "row-1"},
  "value": {  // ✅ 对象
    "price": 99.99,
    "name": "iPhone 15",
    "stock": 50
  }
}
```

---

### 数组（Array）

适用于：
- 多行不同值更新

```json
{
  "target": {"rows": ["row-1", "row-2", "row-3"], "field": "price"},
  "value": [99.99, 88.88, 77.77]  // ✅ 数组
}
```

**重要规则**：数组长度必须与 rows 长度一致

---

## 服务端处理流程

```typescript
async function processBulkUpdate(
  docId: string,
  updates: BulkUpdate[],
  requestId?: string
) {
  // 1. 获取 metadata
  const metadata = await getMetadata(docId);
  const dataFields = new Map(metadata.fields.map(f => [f.id, f]));
  const propFields = new Map(metadata.properties.map(f => [f.id, f]));
  
  // 2. 处理每个更新项
  const changes: Change[] = [];
  
  for (const update of updates) {
    const { target, value } = update;
    
    // 3. 解析 target 类型
    if (target.row && target.field) {
      // 单行单字段
      const field = dataFields.get(target.field);
      const typedValue = convertRawValue(value, field.type);
      changes.push(createDataChange(target.row, target.field, typedValue));
    }
    else if (target.row && !target.field) {
      // 整行（value 是对象）
      for (const [fieldId, rawValue] of Object.entries(value)) {
        const field = dataFields.get(fieldId);
        const typedValue = convertRawValue(rawValue, field.type);
        changes.push(createDataChange(target.row, fieldId, typedValue));
      }
    }
    else if (target.rows && target.field) {
      // 多行同一字段
      const field = dataFields.get(target.field);
      
      if (Array.isArray(value)) {
        // 不同值
        for (let i = 0; i < target.rows.length; i++) {
          const typedValue = convertRawValue(value[i], field.type);
          changes.push(createDataChange(target.rows[i], target.field, typedValue));
        }
      } else {
        // 相同值
        const typedValue = convertRawValue(value, field.type);
        for (const rowId of target.rows) {
          changes.push(createDataChange(rowId, target.field, typedValue));
        }
      }
    }
    else if (target.property) {
      // 单个属性
      const field = propFields.get(target.property);
      const typedValue = convertRawValue(value, field.type);
      changes.push(createPropertyChange(target.property, typedValue));
    }
    else if (target.properties) {
      // 多个属性（value 是对象）
      for (const [fieldId, rawValue] of Object.entries(value)) {
        const field = propFields.get(fieldId);
        const typedValue = convertRawValue(rawValue, field.type);
        changes.push(createPropertyChange(fieldId, typedValue));
      }
    }
  }
  
  // 4. 添加到 Request
  return await addToRequest(requestId, changes);
}
```

---

## 类型自动转换

服务端根据字段定义自动转换值类型：

| 字段类型 | 客户端提交 | 服务端转换 |
|---------|----------|-----------|
| `text` | `"iPhone 15"` | `{"text": "iPhone 15"}` |
| `number` | `99.99` | `{"number": 99.99}` |
| `currency` | `5000.00` | `{"currency": 5000.00}` |
| `boolean` | `true` | `{"boolean": true}` |
| `date` | `"2024-12-05"` | `{"date": "2024-12-05"}` |
| `single_select` | `"active"` 或 `{"id": "active"}` | `{"single_select": {...}}` |
| `multi_select` | `["opt-1", "opt-2"]` | `{"multi_select": [{...}, {...}]}` |

---

## 错误处理

### 1. Target 格式错误

```json
// ❌ 错误：target 不完整
{
  "target": {"row": "row-1"},  // 缺少 field
  "value": 99.99  // value 是单值，但没有指定字段
}
```

**响应**：
```json
{
  "error": {
    "code": "INVALID_TARGET",
    "message": "Target structure is invalid. When value is a single value, target must specify a field",
    "details": {
      "target": {"row": "row-1"},
      "expectedStructure": "One of: {row, field}, {rows, field}, {property}, {properties}"
    }
  }
}
```

---

### 2. Value 数组长度不匹配

```json
// ❌ 错误：value 数组长度与 rows 不匹配
{
  "target": {"rows": ["row-1", "row-2", "row-3"], "field": "price"},
  "value": [99.99, 88.88]  // 只有 2 个值，但有 3 行
}
```

**响应**：
```json
{
  "error": {
    "code": "VALUE_LENGTH_MISMATCH",
    "message": "Value array length must match rows array length",
    "details": {
      "rowsCount": 3,
      "valuesCount": 2
    }
  }
}
```

---

### 3. 字段不存在

```json
{
  "target": {"row": "row-1", "field": "invalidField"},
  "value": 123
}
```

**响应**：
```json
{
  "error": {
    "code": "FIELD_NOT_FOUND",
    "message": "Field 'invalidField' not found in document metadata",
    "details": {
      "fieldId": "invalidField",
      "availableFields": ["price", "name", "stock", "status"]
    }
  }
}
```

---

## 完整使用示例

### 场景：订货单数据更新

假设订货单有以下结构：
- **数据行**：产品列表（price, quantity, discount）
- **文档属性**：订单总额（totalAmount）、订单日期（orderDate）

```bash
curl -X POST 'https://api.nexusbook.com/v1/doc/purchaseOrder/order-123/data/bulk?requestId=req-1' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '[
    {
      "comment": "修改 iPhone 15 的价格和库存",
      "target": {"row": "row-1"},
      "value": {
        "price": 5999.00,
        "quantity": 50
      }
    },
    {
      "comment": "批量更新折扣",
      "target": {
        "rows": ["row-1", "row-2", "row-3"],
        "field": "discount"
      },
      "value": [0.1, 0.15, 0.2]
    },
    {
      "comment": "更新订单总额和日期",
      "target": {"properties": true},
      "value": {
        "totalAmount": 29999.50,
        "orderDate": "2024-12-05"
      }
    }
  ]'
```

**响应**：
```json
{
  "data": {
    "id": "req-1",
    "status": "open",
    "changes": [
      {
        "id": "change-1",
        "type": "data",
        "operation": "update",
        "targetId": "row-1",
        "data": {
          "price": {"currency": 5999.00},
          "quantity": {"number": 50}
        }
      },
      {
        "id": "change-2",
        "type": "data",
        "operation": "update",
        "targetId": "row-1",
        "data": {"discount": {"percent": 0.1}}
      },
      // ... 更多变更
      {
        "id": "change-8",
        "type": "properties",
        "operation": "update",
        "data": {
          "totalAmount": {"currency": 29999.50},
          "orderDate": {"date": "2024-12-05"}
        }
      }
    ],
    "contributors": ["user-1"],
    "createdAt": "2024-12-05T10:00:00Z"
  }
}
```

---

## 客户端最佳实践

### 1. 使用类型化的客户端库

```typescript
// TypeScript 客户端示例
interface BulkUpdateItem {
  target: {
    row?: string;
    rows?: string[];
    field?: string;
    property?: string;
    properties?: boolean;
  };
  value: any;
}

class DocumentAPI {
  async bulkUpdate(
    docType: string,
    docId: string,
    updates: BulkUpdateItem[],
    requestId?: string
  ) {
    return await fetch(`/doc/${docType}/${docId}/data/bulk`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(updates),
      params: {requestId}
    });
  }
}

// 使用
const api = new DocumentAPI();
await api.bulkUpdate('purchaseOrder', 'order-123', [
  {target: {row: 'row-1', field: 'price'}, value: 99.99},
  {target: {property: 'amount'}, value: 5000.00}
], 'req-1');
```

---

### 2. 批量操作优化

```typescript
// ❌ 不好：多次单个请求
for (const row of rows) {
  await api.update(row.id, row.data);
}

// ✅ 好：一次批量请求
await api.bulkUpdate('product', 'doc-1', 
  rows.map(row => ({
    target: {row: row.id},
    value: row.data
  }))
);
```

---

### 3. 错误处理

```typescript
try {
  const response = await api.bulkUpdate(...);
  console.log(`成功更新 ${response.data.changes.length} 个变更`);
} catch (error) {
  if (error.code === 'FIELD_NOT_FOUND') {
    console.error('字段不存在:', error.details.fieldId);
    console.log('可用字段:', error.details.availableFields);
  } else if (error.code === 'VALUE_LENGTH_MISMATCH') {
    console.error('值数量不匹配');
  }
}
```

---

## 性能优化

### 1. 批量处理

**建议**：单次请求不超过 1000 个更新项

```typescript
// 如果超过 1000 项，分批处理
const BATCH_SIZE = 1000;
for (let i = 0; i < updates.length; i += BATCH_SIZE) {
  const batch = updates.slice(i, i + BATCH_SIZE);
  await api.bulkUpdate(docType, docId, batch, requestId);
}
```

---

### 2. 服务端缓存

```typescript
// 缓存 metadata 减少数据库查询
const metadataCache = new Map();

async function getMetadata(docId: string) {
  if (!metadataCache.has(docId)) {
    const metadata = await db.getMetadata(docId);
    metadataCache.set(docId, metadata);
  }
  return metadataCache.get(docId);
}
```

---

## 总结

### 核心优势

1. **✅ 灵活性**
   - 一个接口处理所有更新场景
   - Target 结构支持多种组合
   - Value 可以是单值、对象或数组

2. **✅ 简单性**
   - Value 始终使用原始格式
   - 无需客户端了解字段类型
   - 服务端自动处理类型转换

3. **✅ 高效性**
   - 批量操作减少网络往返
   - 一次请求可处理数据+属性
   - 支持 1000+ 项的批量更新

4. **✅ 一致性**
   - 数据行和属性使用相同接口
   - 统一的错误处理
   - 统一的变更请求工作流

### 适用场景

- ✅ 表格批量编辑
- ✅ 导入数据
- ✅ 批量状态更新
- ✅ 数据同步
- ✅ 表单提交（数据+属性）
- ✅ 复杂的数据迁移

这个设计完美契合了变更请求工作流，提供了最大的灵活性和最简单的使用体验。
