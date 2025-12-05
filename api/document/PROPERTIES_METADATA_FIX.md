# Properties 和 Metadata 设计修复

## 🔍 发现的问题

### 问题 1: `DocumentProperties.properties` 类型不一致

**原设计问题**:
- `DocumentProperties.properties` 使用 `unknown` 类型（灵活但无类型）
- 数据行的 cell 值使用 `Value` union 类型（类型化）
- 两者设计不一致，难以统一处理

**示例对比**:

```typescript
// ❌ 原设计 - unknown 类型
{
  "properties": {
    "orderTime": "2024-12-01T10:00:00Z",  // 字符串？日期？
    "amount": 5000.00,                     // 数字？货币？
    "coverImage": "att-123"                // 字符串ID？附件对象？
  }
}

// ✅ 修复后 - 类型化的 ValueEntry[]
{
  "properties": [
    {"fieldId": "orderTime", "value": {"datetime": "2024-12-01T10:00:00Z"}},
    {"fieldId": "amount", "value": {"currency": 5000.00}},
    {"fieldId": "coverImage", "value": {"attachment": [{"id": "att-123", "fileName": "cover.jpg", ...}]}}
  ]
}
```

---

### 问题 2: `Metadata` 缺少文档属性定义

**原设计问题**:
- `Metadata` 只有 `fields: Field[]`（数据行字段）
- 缺少文档属性的字段定义
- 无法知道 properties 中有哪些字段及其类型

**示例对比**:

```typescript
// ❌ 原设计
{
  "fields": [
    {"id": "name", "type": "text", ...},
    {"id": "price", "type": "currency", ...}
  ]
  // 缺少 properties 的字段定义
}

// ✅ 修复后
{
  "fields": [  // 数据行字段（表格列）
    {"id": "name", "type": "text", ...},
    {"id": "price", "type": "currency", ...}
  ],
  "properties": [  // 文档属性字段
    {"id": "orderTime", "type": "datetime", ...},
    {"id": "store", "type": "text", ...},
    {"id": "amount", "type": "currency", ...}
  ]
}
```

---

## ✅ 修复方案

### 修复 1: `DocumentProperties.properties` 改为 `ValueEntry[]`

**文件**: `api/document/core/properties.tsp`

**修改内容**:

```typescript
model DocumentProperties {
    // ... 其他字段

    /**
     * 属性值集合
     * Property values
     *
     * 使用类型化的值结构，与数据行的 cell 值设计一致。
     * Uses typed value structure, consistent with data row cell values.
     */
    properties?: NexusBook.Common.ValueEntry[];
    
    // ... 其他字段
}
```

**影响的接口**:
1. `PATCH /doc/{docType}/{docId}/properties` - 更新请求体
2. 属性历史记录的快照类型

---

### 修复 2: `Metadata` 增加 `properties` 字段

**文件**: `api/document/core/metadata.tsp`

**修改内容**:

```typescript
/**
 * 文档元数据集合
 * Document metadata collection
 *
 * 包含数据行字段定义和文档属性定义。
 * Contains data row field definitions and document property definitions.
 */
model Metadata {
    /**
     * 数据行字段定义
     * Data row field definitions
     *
     * 定义数据行（表格行）的字段结构。
     */
    fields: Field[];

    /**
     * 文档属性字段定义
     * Document property field definitions
     *
     * 定义文档级别属性的字段结构（如订单时间、总金额等）。
     * 这些字段定义用于 `DocumentProperties.properties` 中的值。
     */
    properties?: Field[];
}
```

---

## 🎯 设计优势

### 1. **类型安全**
- 所有值都有明确的类型标识
- 前端可以根据类型正确渲染和验证
- 避免类型混淆导致的错误

### 2. **统一设计**
- 数据行的 cell 值和文档属性值使用相同的结构
- 代码可以复用相同的类型定义和处理逻辑
- 降低学习成本

### 3. **完整定义**
- Metadata 同时包含数据行字段和文档属性字段
- 客户端可以一次性获取所有字段定义
- 支持动态表单生成和验证

### 4. **支持复杂类型**
- 附件类型：`{"attachment": [...]}`
- 选择类型：`{"single_select": {...}}`
- 用户类型：`{"user": {...}}`
- 关联类型：`{"relation": [...]}`
- 等等...

---

## 📊 数据结构对比

### 数据行 (Row)

```json
{
  "id": "row-123",
  "values": [
    {"fieldId": "name", "value": {"text": "iPhone 15"}},
    {"fieldId": "price", "value": {"currency": 999.99}},
    {"fieldId": "image", "value": {"attachment": [{"id": "att-1", "fileName": "iphone.jpg", ...}]}}
  ]
}
```

### 文档属性 (DocumentProperties)

```json
{
  "id": "prop-123",
  "docId": "order-456",
  "docType": "purchaseOrder",
  "properties": [
    {"fieldId": "orderTime", "value": {"datetime": "2024-12-01T10:00:00Z"}},
    {"fieldId": "totalAmount", "value": {"currency": 5000.00}},
    {"fieldId": "coverImage", "value": {"attachment": [{"id": "att-2", "fileName": "cover.jpg", ...}]}}
  ]
}
```

### 元数据 (Metadata)

```json
{
  "fields": [
    {"id": "name", "type": "text", "required": true},
    {"id": "price", "type": "currency", "required": true},
    {"id": "image", "type": "attachment"}
  ],
  "properties": [
    {"id": "orderTime", "type": "datetime", "required": true},
    {"id": "totalAmount", "type": "currency", "required": true},
    {"id": "coverImage", "type": "attachment"}
  ]
}
```

---

## 🔄 使用流程

### 1. 获取元数据

```bash
GET /api/v1/doc/purchaseOrder/order-123/metadata
```

返回：
```json
{
  "fields": [...],      // 数据行字段定义
  "properties": [...]   // 文档属性字段定义
}
```

### 2. 获取文档属性

```bash
GET /api/v1/doc/purchaseOrder/order-123/properties
```

返回：
```json
{
  "id": "prop-123",
  "properties": [
    {"fieldId": "orderTime", "value": {"datetime": "2024-12-01T10:00:00Z"}},
    {"fieldId": "totalAmount", "value": {"currency": 5000.00}}
  ]
}
```

### 3. 更新文档属性

```bash
PATCH /api/v1/doc/purchaseOrder/order-123/properties
```

请求体：
```json
{
  "properties": [
    {"fieldId": "totalAmount", "value": {"currency": 6000.00}},
    {"fieldId": "status", "value": {"single_select": {"id": "approved", "label": "已批准"}}}
  ]
}
```

---

## 🎨 Value Union 类型支持

当前支持的值类型（来自 `api/shared/common.tsp`）:

```typescript
union Value {
    text: string,
    long_text: string,
    number: float64,
    currency: float64,
    percent: float64,
    boolean: boolean,
    date: string,
    datetime: string,
    single_select: SelectOption,
    multi_select: SelectOption[],
    attachment: Attachment[],
    user: UserRef,
    collaborator: CollaboratorRef,
    relation: RelationRef[],
    rating: int32,
    duration: int64,
}
```

---

## ✅ 验证清单

- [x] `DocumentProperties.properties` 改为 `ValueEntry[]`
- [x] 更新所有示例代码为新格式
- [x] `Metadata` 增加 `properties?: Field[]`
- [x] 添加详细的字段说明
- [x] TypeSpec 编译成功（0 errors, 6 warnings）
- [x] 设计统一：数据行和文档属性使用相同的值结构

---

## 📝 后续建议

### 1. 客户端实现
- 创建统一的 `ValueEntry` 渲染组件
- 根据字段类型动态生成表单控件
- 实现类型安全的值验证

### 2. 服务端实现
- 使用 Metadata 中的字段定义验证 properties 值
- 实现字段类型转换和校验逻辑
- 支持字段级权限控制

### 3. 文档更新
- 更新 API 文档示例
- 添加字段类型使用指南
- 提供最佳实践文档

---

## 🎉 总结

本次修复解决了两个核心设计问题：

1. **统一了值的类型系统** - properties 和 data 都使用 `ValueEntry[]`
2. **完善了元数据定义** - Metadata 同时包含 fields 和 properties

这使得整个 API 设计更加一致、类型安全，并且易于使用。
