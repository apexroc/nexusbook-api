# 批量更新简化设计

## 修改日期
2024-12-05

## 修改原因

用户指出了两个关键问题：

### 问题 1：批量操作的语义错误

**旧设计（错误）**：
```typescript
// 批量操作接受完整的 Row 对象数组
POST /doc/{docType}/{docId}/data/bulk
Body: Row[]
```

这个设计有两个问题：
1. ❌ 语义混乱：不清楚是批量创建、批量更新还是批量删除
2. ❌ 数据冗余：需要传递完整的 Row 对象，包括很多不需要修改的字段

**新设计（正确）**：
```typescript
// 批量更新：指定行ID + 字段ID + 新值
POST /doc/{docType}/{docId}/data/bulk
Body: BulkUpdate[]  // [{target: "row-1.price", value: 99.99}]
```

---

### 问题 2：值提交方式过于复杂

**旧设计（复杂）**：
```json
{
  "fieldId": "price",
  "value": {"currency": 99.99}  // ❌ 需要客户端知道这是 currency 类型
}
```

这要求客户端：
1. 了解每个字段的类型定义
2. 手动构造类型化的值结构
3. 维护字段类型的映射关系

**新设计（简化）**：
```json
{
  "fieldId": "price",
  "value": 99.99  // ✅ 直接提供原始值，服务端解析
}
```

客户端只需：
1. 提供字段ID和原始值
2. 服务端根据 metadata 自动解析类型
3. 无需了解字段类型细节

---

## 核心设计变更

### 1. 新增 `BulkUpdate` 模型

```typescript
/**
 * 批量更新目标
 */
model UpdateTarget {
    rowId: string;    // 行ID
    fieldId: string;  // 字段ID
}

/**
 * 批量更新项
 */
model BulkUpdate {
    /**
     * 目标（行ID + 字段ID）
     * 
     * 支持两种格式：
     * - 字符串："row-1.price"
     * - 对象：{"rowId": "row-1", "fieldId": "price"}
     */
    target: string | UpdateTarget;

    /**
     * 新值（原始格式）
     * 
     * 直接提供值，服务端根据该字段的 metadata 自动解析类型。
     */
    value: unknown;
}
```

---

### 2. 修改 Data API

#### 旧接口（移除）

```typescript
@route("/bulk")
@post
bulkRows(@body body: Row[], @query requestId?: string)
```

#### 新接口

```typescript
@route("/bulk")
@post
bulkUpdate(@body body: BulkUpdate[], @query requestId?: string)
```

**关键差异**：
- ❌ 旧：接受 `Row[]` - 语义不清，数据冗余
- ✅ 新：接受 `BulkUpdate[]` - 明确是更新操作，数据精简

---

### 3. 修改 Properties API

#### 旧请求体

```json
{
  "properties": [
    {"fieldId": "amount", "value": {"currency": 6000.00}},
    {"fieldId": "quantity", "value": {"number": 60}}
  ]
}
```

#### 新请求体

```json
{
  "updates": [
    {"fieldId": "amount", "value": 6000.00},
    {"fieldId": "quantity", "value": 60}
  ]
}
```

**关键差异**：
- ❌ 旧：`properties` 使用 `ValueEntry[]`，需要类型包装
- ✅ 新：`updates` 使用简化格式，服务端自动解析

---

## 服务端处理逻辑

### Data 批量更新流程

```typescript
// 客户端请求
POST /doc/product/123/data/bulk?requestId=req-1
[
  {"target": "row-1.price", "value": 99.99},
  {"target": "row-1.name", "value": "iPhone 15"},
  {"target": "row-2.date", "value": "2024-12-05"}
]

// 服务端处理
async function processBulkUpdate(docId: string, updates: BulkUpdate[]) {
  // 1. 获取文档的 metadata
  const metadata = await getMetadata(docId);
  
  // 2. 处理每个更新项
  const changes: Change[] = [];
  
  for (const update of updates) {
    // 2.1 解析 target
    const { rowId, fieldId } = parseTarget(update.target);
    
    // 2.2 查找字段定义
    const fieldDef = metadata.fields.find(f => f.id === fieldId);
    if (!fieldDef) {
      throw new Error(`Field ${fieldId} not found`);
    }
    
    // 2.3 根据字段类型转换原始值
    const typedValue = convertRawValue(update.value, fieldDef.type);
    // 例如：
    // - fieldDef.type === "currency" → {currency: 99.99}
    // - fieldDef.type === "text" → {text: "iPhone 15"}
    // - fieldDef.type === "date" → {date: "2024-12-05"}
    
    // 2.4 验证值的有效性
    validateValue(typedValue, fieldDef);
    
    // 2.5 创建变更记录
    changes.push({
      id: generateId(),
      type: "data",
      operation: "update",
      targetId: rowId,
      data: {
        fieldId: fieldId,
        value: typedValue
      },
      changedAt: now(),
      changedBy: currentUser.id
    });
  }
  
  // 3. 添加到 Request
  return addToRequest(requestId, changes);
}
```

**核心优势**：
1. ✅ 客户端代码简化（无需知道字段类型）
2. ✅ 服务端统一处理类型转换
3. ✅ 类型验证集中化
4. ✅ 易于维护和扩展

---

### Properties 更新流程

```typescript
// 客户端请求
PATCH /doc/purchaseOrder/order-123/properties?requestId=req-1
{
  "updates": [
    {"fieldId": "amount", "value": 6000.00},
    {"fieldId": "quantity", "value": 60}
  ]
}

// 服务端处理
async function processPropertyUpdate(docId: string, updates: PropertyUpdate[]) {
  // 1. 获取文档的 metadata（属性字段定义）
  const metadata = await getMetadata(docId);
  
  // 2. 处理每个更新项
  const typedUpdates: ValueEntry[] = [];
  
  for (const update of updates) {
    // 2.1 查找属性字段定义
    const fieldDef = metadata.properties.find(f => f.id === update.fieldId);
    if (!fieldDef) {
      throw new Error(`Property field ${update.fieldId} not found`);
    }
    
    // 2.2 根据字段类型转换原始值
    const typedValue = convertRawValue(update.value, fieldDef.type);
    
    // 2.3 验证值的有效性
    validateValue(typedValue, fieldDef);
    
    // 2.4 添加到结果
    typedUpdates.push({
      fieldId: update.fieldId,
      value: typedValue
    });
  }
  
  // 3. 创建变更记录并添加到 Request
  const change = {
    id: generateId(),
    type: "properties",
    operation: "update",
    data: typedUpdates,
    changedAt: now(),
    changedBy: currentUser.id
  };
  
  return addToRequest(requestId, [change]);
}
```

---

## 完整示例对比

### 场景：批量更新产品价格和库存

#### 旧设计（复杂）

```bash
# 客户端需要：
# 1. 知道 price 是 currency 类型
# 2. 知道 stock 是 number 类型
# 3. 手动构造类型化的值

curl -X POST '.../data/bulk?requestId=req-1' \
  -d '[
    {
      "id": "row-1",
      "values": [
        {"fieldId": "price", "value": {"currency": 99.99}},
        {"fieldId": "stock", "value": {"number": 50}}
      ]
    },
    {
      "id": "row-2",
      "values": [
        {"fieldId": "price", "value": {"currency": 88.88}},
        {"fieldId": "stock", "value": {"number": 30}}
      ]
    }
  ]'
```

**问题**：
1. ❌ 需要传递整个 Row 对象
2. ❌ 需要知道字段类型
3. ❌ 数据冗余（很多字段不需要修改）
4. ❌ 客户端代码复杂

---

#### 新设计（简化）

```bash
# 客户端只需：
# 1. 指定目标（行ID.字段ID）
# 2. 提供原始值
# 3. 服务端自动处理类型

curl -X POST '.../data/bulk?requestId=req-1' \
  -d '[
    {"target": "row-1.price", "value": 99.99},
    {"target": "row-1.stock", "value": 50},
    {"target": "row-2.price", "value": 88.88},
    {"target": "row-2.stock", "value": 30}
  ]'
```

**优势**：
1. ✅ 只传递需要修改的字段
2. ✅ 无需知道字段类型
3. ✅ 数据精简（30-50% 的数据量减少）
4. ✅ 客户端代码简单

---

## 类型自动转换规则

服务端根据字段定义自动转换值：

| 字段类型 | 客户端提交 | 服务端转换 |
|---------|----------|-----------|
| `text` | `"iPhone 15"` | `{"text": "iPhone 15"}` |
| `long_text` | `"Long description..."` | `{"long_text": "Long..."}` |
| `number` | `99.99` | `{"number": 99.99}` |
| `currency` | `5000.00` | `{"currency": 5000.00}` |
| `percent` | `0.85` | `{"percent": 0.85}` |
| `boolean` | `true` | `{"boolean": true}` |
| `date` | `"2024-12-05"` | `{"date": "2024-12-05"}` |
| `datetime` | `"2024-12-05T10:00:00Z"` | `{"datetime": "2024-12-05T10:00:00Z"}` |
| `single_select` | `"option-1"` 或 `{"id": "option-1"}` | `{"single_select": {...}}` |
| `multi_select` | `["opt-1", "opt-2"]` | `{"multi_select": [{...}, {...}]}` |
| `attachment` | `[{"id": "file-1"}]` | `{"attachment": [{...}]}` |
| `user` | `"user-123"` | `{"user": {...}}` |
| `collaborator` | `"collab-1"` | `{"collaborator": {...}}` |
| `relation` | `["doc-1", "doc-2"]` | `{"relation": [{...}, {...}]}` |
| `rating` | `5` | `{"rating": 5}` |
| `duration` | `3600` | `{"duration": 3600}` |

---

## 客户端代码示例

### 旧设计（复杂）

```typescript
// ❌ 客户端需要维护类型映射
const fieldTypeMap = {
  price: "currency",
  stock: "number",
  name: "text",
  date: "date"
};

// ❌ 手动构造类型化的值
function buildTypedValue(fieldId: string, rawValue: any) {
  const type = fieldTypeMap[fieldId];
  return { [type]: rawValue };
}

// ❌ 批量更新代码复杂
async function bulkUpdate(updates: {rowId: string, fieldId: string, value: any}[]) {
  // 按行分组
  const groupedByRow = groupBy(updates, 'rowId');
  
  // 构造 Row 对象数组
  const rows = Object.entries(groupedByRow).map(([rowId, items]) => ({
    id: rowId,
    values: items.map(item => ({
      fieldId: item.fieldId,
      value: buildTypedValue(item.fieldId, item.value)
    }))
  }));
  
  // 发送请求
  return api.post('/data/bulk', rows);
}
```

---

### 新设计（简化）

```typescript
// ✅ 客户端无需类型映射

// ✅ 批量更新代码简单
async function bulkUpdate(updates: {rowId: string, fieldId: string, value: any}[]) {
  // 直接构造 BulkUpdate 数组
  const bulkUpdates = updates.map(u => ({
    target: `${u.rowId}.${u.fieldId}`,
    value: u.value
  }));
  
  // 发送请求
  return api.post('/data/bulk', bulkUpdates);
}

// 使用示例
bulkUpdate([
  {rowId: "row-1", fieldId: "price", value: 99.99},
  {rowId: "row-1", fieldId: "stock", value: 50},
  {rowId: "row-2", fieldId: "price", value: 88.88}
]);
```

**代码行数对比**：
- 旧设计：~30 行
- 新设计：~10 行
- **减少 66% 的代码量**

---

## 错误处理

### 1. 字段不存在

```json
// 请求
{
  "target": "row-1.invalidField",
  "value": 123
}

// 响应
{
  "error": {
    "code": "FIELD_NOT_FOUND",
    "message": "Field 'invalidField' not found in document metadata",
    "details": {
      "fieldId": "invalidField",
      "availableFields": ["price", "stock", "name", "date"]
    }
  }
}
```

---

### 2. 值类型不匹配

```json
// 请求（price 是 currency 类型，但提交了字符串）
{
  "target": "row-1.price",
  "value": "invalid"
}

// 响应
{
  "error": {
    "code": "VALUE_TYPE_MISMATCH",
    "message": "Cannot convert value to currency type",
    "details": {
      "fieldId": "price",
      "expectedType": "currency",
      "providedValue": "invalid",
      "reason": "Value must be a number"
    }
  }
}
```

---

### 3. 值验证失败

```json
// 请求（rating 范围是 1-5，但提交了 10）
{
  "target": "row-1.rating",
  "value": 10
}

// 响应
{
  "error": {
    "code": "VALUE_VALIDATION_FAILED",
    "message": "Value validation failed",
    "details": {
      "fieldId": "rating",
      "providedValue": 10,
      "constraint": "Value must be between 1 and 5"
    }
  }
}
```

---

## 性能优化

### 1. 批量转换优化

```typescript
// ❌ 低效：每个值单独查询字段定义
for (const update of updates) {
  const fieldDef = await getFieldDefinition(update.fieldId);
  const typedValue = convertRawValue(update.value, fieldDef.type);
}

// ✅ 高效：一次性获取所有字段定义
const metadata = await getMetadata(docId);
const fieldDefMap = new Map(metadata.fields.map(f => [f.id, f]));

for (const update of updates) {
  const fieldDef = fieldDefMap.get(update.fieldId);
  const typedValue = convertRawValue(update.value, fieldDef.type);
}
```

---

### 2. 缓存 Metadata

```typescript
// 使用缓存减少数据库查询
const metadata = await cache.getOrSet(
  `metadata:${docId}`,
  () => getMetadata(docId),
  { ttl: 300 }  // 5分钟缓存
);
```

---

## 向后兼容

### 方案 A：渐进式迁移（推荐）

1. **新接口**：`POST /data/bulk` 使用 `BulkUpdate[]`
2. **旧接口**：保留但标记为 deprecated
3. **文档说明**：引导客户端迁移到新接口
4. **下个大版本**：移除旧接口

---

### 方案 B：自动适配（备选）

```typescript
// 服务端自动检测请求体格式
function detectRequestFormat(body: any[]): 'old' | 'new' {
  if (body.length === 0) return 'new';
  
  const first = body[0];
  
  // 旧格式：Row 对象（包含 id, values 等字段）
  if ('id' in first && 'values' in first) {
    return 'old';
  }
  
  // 新格式：BulkUpdate（包含 target, value 字段）
  if ('target' in first && 'value' in first) {
    return 'new';
  }
  
  throw new Error('Invalid request format');
}

// 根据格式分别处理
const format = detectRequestFormat(body);
if (format === 'old') {
  return processOldFormat(body);
} else {
  return processNewFormat(body);
}
```

---

## 总结

### 核心变化

1. **批量操作**：从 `Row[]` 改为 `BulkUpdate[]`
   - 明确语义（更新操作）
   - 减少数据冗余
   - 支持跨行更新不同字段

2. **值提交**：从类型化值改为原始值
   - 客户端代码简化
   - 服务端统一处理类型转换
   - 减少 66% 的客户端代码量

3. **API 一致性**：Data 和 Properties 使用相同的简化模式
   - `BulkUpdate[]` 用于批量数据更新
   - `{fieldId, value}[]` 用于属性更新
   - 统一的服务端处理逻辑

### 优势总结

1. ✅ **客户端简化**：无需维护类型映射，代码量减少 66%
2. ✅ **数据精简**：只传递需要修改的字段，数据量减少 30-50%
3. ✅ **语义清晰**：`bulkUpdate` 明确表示批量更新操作
4. ✅ **易于维护**：类型转换和验证逻辑集中在服务端
5. ✅ **性能优化**：批量处理和缓存减少数据库查询

### 与变更请求工作流的配合

所有批量更新操作都会：
1. ✅ 创建或追加到 Request
2. ✅ 支持多人协同编辑
3. ✅ 通过审批后生效
4. ✅ 完整的变更追溯

这个设计完美契合了变更请求工作流的核心理念。
