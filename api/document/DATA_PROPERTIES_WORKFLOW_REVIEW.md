# Data 和 Properties 数据维护逻辑完整 Review

## 📋 你的理解验证

### ✅ 1. 查看元数据（数据结构）

**你的理解**: 可以查看 data 和 properties 的元数据，也就是数据结构

**实际设计**: ✅ **完全正确**

#### API 接口

```http
GET /api/v1/doc/{docType}/{docId}/metadata
```

#### 返回结构

```json
{
  "success": true,
  "payload": {
    "fields": [  // 数据行字段定义（表格列）
      {
        "id": "name",
        "name": "产品名称",
        "type": "text",
        "required": true
      },
      {
        "id": "price",
        "name": "价格",
        "type": "currency",
        "required": true
      },
      {
        "id": "category",
        "name": "分类",
        "type": "single_select",
        "selectOptions": [
          {"id": "electronics", "label": "电子产品", "color": "#blue"},
          {"id": "clothing", "label": "服装", "color": "#green"}
        ]
      }
    ],
    "properties": [  // 文档属性字段定义
      {
        "id": "orderTime",
        "name": "订单时间",
        "type": "datetime",
        "required": true
      },
      {
        "id": "totalAmount",
        "name": "总金额",
        "type": "currency",
        "required": true
      },
      {
        "id": "store",
        "name": "门店",
        "type": "text"
      }
    ]
  }
}
```

**设计要点**:
- ✅ `fields` 定义数据行（表格行）的字段结构
- ✅ `properties` 定义文档属性的字段结构
- ✅ 包含字段类型、是否必填、选项等元信息
- ✅ 一次请求获取完整的数据结构定义

---

### ✅ 2. 单个或批量更新数据/属性

**你的理解**: 可以单个或者批量更新数据或者属性

**实际设计**: ✅ **完全支持**

---

## 📊 Data（数据行）操作

### 单个数据行操作

#### 创建单行

```http
POST /api/v1/doc/{docType}/{docId}/data?apply=true
Content-Type: application/json

{
  "id": "row-1",
  "values": [
    {"fieldId": "name", "value": {"text": "iPhone 15"}},
    {"fieldId": "price", "value": {"currency": 999.99}},
    {"fieldId": "category", "value": {"single_select": {"id": "electronics", "label": "电子产品"}}}
  ]
}
```

**参数说明**:
- `apply=true` - 直接应用修改
- `apply=false` 或不传 - 创建变更请求（需审批）

#### 更新单行

```http
PUT /api/v1/doc/{docType}/{docId}/data/{rowId}?apply=true
Content-Type: application/json

{
  "id": "row-1",
  "values": [
    {"fieldId": "price", "value": {"currency": 1099.99}}
  ],
  "version": 1
}
```

**并发控制**:
- ✅ 使用 `version` 字段实现乐观锁
- ✅ 服务端检查版本号，防止并发冲突

#### 删除单行

```http
DELETE /api/v1/doc/{docType}/{docId}/data/{rowId}?apply=true
```

#### 查询单行

```http
GET /api/v1/doc/{docType}/{docId}/data/{rowId}
```

---

### 批量数据行操作

#### 批量创建/更新/删除

```http
POST /api/v1/doc/{docType}/{docId}/data/bulk?apply=true
Content-Type: application/json

[
  {
    "id": "row-1",
    "values": [
      {"fieldId": "name", "value": {"text": "iPhone 15"}},
      {"fieldId": "price", "value": {"currency": 999.99}}
    ]
  },
  {
    "id": "row-2",
    "values": [
      {"fieldId": "name", "value": {"text": "MacBook Pro"}},
      {"fieldId": "price", "value": {"currency": 1999.99}}
    ]
  }
]
```

**批量操作特点**:
- ✅ 一次请求处理多行数据
- ✅ 支持混合操作（创建+更新+删除）
- ✅ 同样支持 `apply` 参数控制是否直接生效

---

### 查询数据行

#### 简单查询（分页）

```http
GET /api/v1/doc/product/123/data?page=1&pageSize=20&sort=price:desc
```

**查询参数**:
- `page` - 页码（默认 1）
- `pageSize` - 每页数量（默认 20，最大 200）
- `sort` - 排序（例如：`price:desc`）
- `filter` - 简单过滤（DSL 字符串）
- `cursor` - 游标分页

#### 高级查询（结构化）

```http
POST /api/v1/doc/product/123/data/query
Content-Type: application/json

{
  "filters": {
    "logic": "and",
    "conditions": [
      {
        "field": "category",
        "operator": "eq",
        "value": "electronics"
      },
      {
        "field": "price",
        "operator": "range",
        "rangeStart": 500,
        "rangeEnd": 2000
      }
    ]
  },
  "sorts": [
    {"field": "price", "direction": "desc"}
  ],
  "page": 1,
  "pageSize": 20
}
```

**高级查询特性**:
- ✅ 支持嵌套的过滤条件组合
- ✅ 支持多字段排序
- ✅ 支持分组和聚合
- ✅ 支持游标分页

---

## 🏷️ Properties（文档属性）操作

### 获取文档属性

```http
GET /api/v1/doc/purchaseOrder/order-123/properties
```

**返回**:
```json
{
  "success": true,
  "payload": {
    "id": "prop-123",
    "docId": "order-123",
    "docType": "purchaseOrder",
    "properties": [
      {"fieldId": "orderTime", "value": {"datetime": "2024-12-01T10:00:00Z"}},
      {"fieldId": "totalAmount", "value": {"currency": 5000.00}},
      {"fieldId": "store", "value": {"text": "Beijing Branch"}}
    ],
    "version": 1,
    "createdAt": "2024-12-01T10:00:00Z",
    "updatedAt": "2024-12-01T10:00:00Z",
    "updatedBy": "user-123"
  }
}
```

---

### 完全替换属性（PUT）

```http
PUT /api/v1/doc/purchaseOrder/order-123/properties
Content-Type: application/json

{
  "id": "prop-123",
  "docId": "order-123",
  "docType": "purchaseOrder",
  "version": 1,
  "properties": [
    {"fieldId": "orderTime", "value": {"datetime": "2024-12-01T10:00:00Z"}},
    {"fieldId": "totalAmount", "value": {"currency": 6000.00}},
    {"fieldId": "store", "value": {"text": "Shanghai Branch"}}
  ]
}
```

**特点**:
- ✅ 完全替换所有属性
- ✅ 需要提供 `version` 做并发控制
- ✅ 未提供的字段会被删除

---

### 部分更新属性（PATCH）

```http
PATCH /api/v1/doc/purchaseOrder/order-123/properties?merge=true&version=1
Content-Type: application/json

{
  "properties": [
    {"fieldId": "totalAmount", "value": {"currency": 7000.00}},
    {"fieldId": "status", "value": {"single_select": {"id": "approved", "label": "已批准"}}}
  ],
  "note": "更新总金额和状态"
}
```

**参数说明**:
- `merge=true` (默认) - 合并模式，只更新提供的字段
- `merge=false` - 覆盖模式
- `version` - 当前版本号（用于并发检查）

**特点**:
- ✅ 只更新指定的字段
- ✅ 未提供的字段保持不变
- ✅ 支持添加变更说明（`note`）

---

### 查看属性历史

```http
GET /api/v1/doc/purchaseOrder/order-123/properties/history?page=1&pageSize=10
```

**返回**:
```json
{
  "success": true,
  "payload": {
    "items": [
      {
        "version": 2,
        "properties": [
          {"fieldId": "totalAmount", "value": {"currency": 7000.00}}
        ],
        "changedAt": "2024-12-02T10:00:00Z",
        "changedBy": "user-456",
        "note": "更新总金额和状态"
      },
      {
        "version": 1,
        "properties": [
          {"fieldId": "totalAmount", "value": {"currency": 5000.00}}
        ],
        "changedAt": "2024-12-01T10:00:00Z",
        "changedBy": "user-123",
        "note": "初始创建"
      }
    ],
    "page": 1,
    "pageSize": 10,
    "total": 2
  }
}
```

**特点**:
- ✅ 完整的修订历史
- ✅ 记录每次变更的版本、时间、操作人
- ✅ 支持分页查询

---

### ✅ 3. 简单字段提交，服务端负责映射

**你的理解**: 更新的时候可以用简单的字段，比如货币、日期，我不用关心，只负责提供数据，具体映射和检查交给服务

**实际设计**: ⚠️ **部分正确，需要澄清**

---

## 🔄 值类型系统详解

### 当前设计：类型化的值结构

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

### 你需要提供的数据格式

#### ❌ 错误方式（过于简单）

```json
{
  "properties": [
    {"fieldId": "orderTime", "value": "2024-12-01T10:00:00Z"},  // ❌ 缺少类型标识
    {"fieldId": "amount", "value": 5000.00}                      // ❌ 不知道是 number 还是 currency
  ]
}
```

#### ✅ 正确方式（明确类型）

```json
{
  "properties": [
    {"fieldId": "orderTime", "value": {"datetime": "2024-12-01T10:00:00Z"}},  // ✅ 明确是 datetime
    {"fieldId": "amount", "value": {"currency": 5000.00}}                      // ✅ 明确是 currency
  ]
}
```

---

### 为什么需要类型标识？

#### 问题场景

假设你有两个字段：
- `price` (currency 类型) - 需要货币符号、小数位处理
- `stock` (number 类型) - 整数，不需要货币符号

如果你只传数字：
```json
{"value": 99.99}
```

**服务端无法知道**:
- 这是价格还是库存？
- 是否需要货币符号？
- 小数位保留几位？

**有了类型标识**:
```json
{"value": {"currency": 99.99}}   // 明确是货币
{"value": {"number": 100}}       // 明确是数字
```

服务端可以：
- ✅ 根据类型渲染正确的 UI（输入框 vs 货币输入框）
- ✅ 应用正确的验证规则
- ✅ 格式化显示（$99.99 vs 100）

---

## 🎯 服务端职责

### ✅ 服务端会做的事情

#### 1. 类型验证

```json
// 客户端提交
{"fieldId": "price", "value": {"currency": 99.99}}

// 服务端检查
1. price 字段是否存在？
2. price 字段类型是否为 currency？
3. 值是否为有效的数字？
4. 是否满足验证规则（如最小值、最大值）？
```

#### 2. 必填校验

```typescript
// Metadata 定义
{
  "id": "price",
  "type": "currency",
  "required": true  // 必填
}

// 服务端检查
if (field.required && value == null) {
  throw Error("价格字段为必填项");
}
```

#### 3. 格式校验

```typescript
// 日期格式
{"value": {"datetime": "2024-12-01T10:00:00Z"}}  // ✅ ISO 8601 格式
{"value": {"datetime": "2024/12/01 10:00:00"}}   // ❌ 格式错误

// 选择类型
{"value": {"single_select": {"id": "pending", "label": "待处理"}}}  // ✅ 完整对象
{"value": {"single_select": "pending"}}                             // ❌ 缺少 label
```

#### 4. 唯一性检查

```typescript
// Metadata 定义
{
  "id": "sku",
  "type": "text",
  "unique": true  // 唯一
}

// 服务端检查
if (field.unique && isDuplicate(value)) {
  throw Error("SKU 已存在");
}
```

#### 5. 只读检查

```typescript
// Metadata 定义
{
  "id": "createdTime",
  "type": "created_time",
  "readOnly": true  // 只读
}

// 服务端检查
if (field.readOnly && isUpdating) {
  throw Error("创建时间字段不可修改");
}
```

#### 6. 选项验证

```typescript
// Metadata 定义
{
  "id": "status",
  "type": "single_select",
  "selectOptions": [
    {"id": "pending", "label": "待处理"},
    {"id": "approved", "label": "已批准"}
  ]
}

// 服务端检查
if (!isValidOption(value.single_select.id)) {
  throw Error("无效的状态选项");
}
```

#### 7. 计算字段处理

```typescript
// Metadata 定义
{
  "id": "total",
  "type": "formula",
  "formula": "price * quantity"
}

// 服务端行为
// 自动计算，客户端不需要提供值
total = evaluateFormula(formula, rowData);
```

---

### ❌ 服务端不会做的事情

#### 1. 自动类型推断

```json
// ❌ 服务端不会猜测这是什么类型
{"fieldId": "price", "value": 99.99}

// ✅ 必须明确指定类型
{"fieldId": "price", "value": {"currency": 99.99}}
```

#### 2. 自动类型转换

```json
// ❌ 不会自动把字符串转成数字
{"fieldId": "price", "value": {"currency": "99.99"}}

// ✅ 必须提供正确的数据类型
{"fieldId": "price", "value": {"currency": 99.99}}
```

#### 3. 格式自动修复

```json
// ❌ 不会修复错误的日期格式
{"fieldId": "orderTime", "value": {"datetime": "2024/12/01"}}

// ✅ 必须使用正确的 ISO 8601 格式
{"fieldId": "orderTime", "value": {"datetime": "2024-12-01T00:00:00Z"}}
```

---

## 📐 完整工作流程

### 场景：创建一个产品数据行

#### Step 1: 获取元数据（了解数据结构）

```http
GET /api/v1/doc/product/123/metadata
```

**返回**:
```json
{
  "fields": [
    {"id": "name", "type": "text", "required": true},
    {"id": "price", "type": "currency", "required": true},
    {"id": "category", "type": "single_select", "selectOptions": [...]},
    {"id": "releaseDate", "type": "date"}
  ]
}
```

**客户端知道了**:
- ✅ name 是文本类型，必填
- ✅ price 是货币类型，必填
- ✅ category 是单选，有哪些选项
- ✅ releaseDate 是日期类型

---

#### Step 2: 构造符合规范的数据

```json
{
  "id": "row-1",
  "values": [
    {
      "fieldId": "name",
      "value": {"text": "iPhone 15"}  // 文本类型
    },
    {
      "fieldId": "price",
      "value": {"currency": 999.99}   // 货币类型
    },
    {
      "fieldId": "category",
      "value": {
        "single_select": {
          "id": "electronics",
          "label": "电子产品"
        }
      }
    },
    {
      "fieldId": "releaseDate",
      "value": {"date": "2024-09-15"}  // 日期类型
    }
  ]
}
```

---

#### Step 3: 提交数据

```http
POST /api/v1/doc/product/123/data?apply=true
Content-Type: application/json

{上面构造的数据}
```

---

#### Step 4: 服务端验证

```
1. ✅ 检查 name 字段存在且为 text 类型
2. ✅ 检查 name 值非空（必填）
3. ✅ 检查 price 字段存在且为 currency 类型
4. ✅ 检查 price 值非空（必填）且为有效数字
5. ✅ 检查 category 选项 ID 是否在允许的列表中
6. ✅ 检查 releaseDate 格式是否正确
```

---

#### Step 5: 服务端响应

**成功**:
```json
{
  "success": true,
  "payload": {
    "id": "req-123",
    "status": "applied",  // 已应用（因为 apply=true）
    "changes": [...]
  }
}
```

**失败**:
```json
{
  "success": false,
  "code": "FIELD_TYPE_MISMATCH",
  "message": {
    "zh": "价格字段类型不匹配",
    "en": "Price field type mismatch"
  }
}
```

---

## 🎨 客户端最佳实践

### 1. 动态表单生成

根据 Metadata 动态生成表单：

```typescript
function renderField(field: Field) {
  switch (field.type) {
    case 'text':
      return <TextInput required={field.required} />;
    
    case 'currency':
      return <CurrencyInput required={field.required} />;
    
    case 'single_select':
      return <Select options={field.selectOptions} required={field.required} />;
    
    case 'date':
      return <DatePicker required={field.required} />;
    
    // ... 其他类型
  }
}
```

### 2. 值的封装

创建工具函数封装值：

```typescript
// 工具函数
function createValue(type: FieldType, rawValue: any): Value {
  switch (type) {
    case 'text':
      return {text: rawValue};
    
    case 'currency':
      return {currency: parseFloat(rawValue)};
    
    case 'date':
      return {date: formatDate(rawValue)};
    
    case 'single_select':
      return {single_select: rawValue}; // rawValue 已经是 SelectOption
    
    // ... 其他类型
  }
}

// 使用
const value = createValue('currency', 99.99);
// 结果: {currency: 99.99}
```

### 3. 类型安全提交

```typescript
function submitRow(docType: string, docId: string, formData: any, metadata: Metadata) {
  const values = metadata.fields.map(field => ({
    fieldId: field.id,
    value: createValue(field.type, formData[field.id])
  }));
  
  return api.post(`/doc/${docType}/${docId}/data?apply=true`, {
    id: generateId(),
    values
  });
}
```

---

## ⚡ 性能优化建议

### 1. 批量操作

**推荐**:
```http
POST /api/v1/doc/product/123/data/bulk?apply=true
[{row1}, {row2}, {row3}, ...]  // 一次提交多行
```

**避免**:
```http
POST /api/v1/doc/product/123/data?apply=true  // 多次请求
POST /api/v1/doc/product/123/data?apply=true
POST /api/v1/doc/product/123/data?apply=true
```

### 2. 部分字段更新

**推荐** (PATCH):
```json
{
  "properties": [
    {"fieldId": "price", "value": {"currency": 99.99}}  // 只更新价格
  ]
}
```

**避免** (PUT):
```json
{
  "properties": [
    {"fieldId": "name", "value": {"text": "iPhone 15"}},
    {"fieldId": "price", "value": {"currency": 99.99}},  // 全部字段
    {"fieldId": "category", "value": {...}},
    // ... 所有字段
  ]
}
```

### 3. 游标分页

**大数据集推荐**:
```http
GET /api/v1/doc/product/123/data?cursor=eyJpZCI6InJvdy0xMDAifQ==&pageSize=100
```

**小数据集**:
```http
GET /api/v1/doc/product/123/data?page=1&pageSize=20
```

---

## 🎯 总结

### ✅ 你的理解正确的部分

1. ✅ **查看元数据** - `GET /metadata` 可以获取完整的数据结构定义
2. ✅ **批量操作** - 支持批量创建/更新/删除 data 和 properties
3. ✅ **服务端验证** - 服务端负责类型验证、必填检查、唯一性等

### ⚠️ 需要澄清的部分

**你说的"简单字段"**:

- ❌ 不能直接提交原始值（如 `"value": 99.99`）
- ✅ 必须提供类型化的值（如 `"value": {"currency": 99.99}`）

**原因**:
- 同一个数字可能是 `number`、`currency`、`percent` 等不同类型
- 同一个字符串可能是 `text`、`date`、`datetime` 等不同类型
- 类型标识帮助服务端和客户端正确处理数据

**好消息**:
- ✅ 客户端可以通过 Metadata 知道每个字段的类型
- ✅ 可以封装工具函数自动添加类型标识
- ✅ 服务端会做全面的验证和检查

---

## 🔄 完整数据流

```
┌─────────────┐
│  客户端      │
└──────┬──────┘
       │
       │ 1. GET /metadata (获取数据结构)
       ↓
┌─────────────┐
│  服务端      │ → 返回 fields 和 properties 定义
└──────┬──────┘
       │
       │ 2. 客户端根据 metadata 构造数据
       ↓
┌─────────────┐
│  客户端      │ → {"fieldId": "price", "value": {"currency": 99.99}}
└──────┬──────┘
       │
       │ 3. POST /data 或 PATCH /properties
       ↓
┌─────────────┐
│  服务端      │ → 验证类型、必填、唯一性、格式等
└──────┬──────┘
       │
       │ 4. 验证通过，保存数据
       ↓
┌─────────────┐
│  数据库      │
└─────────────┘
```

---

这就是完整的 Data 和 Properties 数据维护逻辑！🎉
