# 字段类型参考

NexusBook 支持 25+ 种字段类型，满足各种数据管理需求。

## 字段类型总览

| 分类 | 字段类型 | 说明 |
|------|---------|------|
| 基础类型 | text, long_text, number, currency, percent, boolean | 常用基础数据类型 |
| 日期时间 | date, datetime, duration | 时间相关类型 |
| 选择类型 | single_select, multi_select, rating | 选项和评分 |
| 关联类型 | attachment, user, collaborator, relation | 关联和引用 |
| 计算类型 | lookup, rollup, formula, auto_number | 自动计算字段 |
| 系统字段 | created_time, updated_time, created_by, updated_by | 系统自动维护 |

## 基础类型

### text（文本）

**用途**：短文本，如名称、标题、标签

**值类型**：`{"text": string}`

**示例**：
```json
{
  "fieldId": "productName",
  "value": {"text": "iPhone 15"}
}
```

**配置选项**：
```json
{
  "type": "text",
  "validation": {
    "minLength": 1,
    "maxLength": 200,
    "pattern": "^[a-zA-Z0-9\\s]+$"
  }
}
```

### long_text（长文本）

**用途**：多行文本，如描述、备注

**值类型**：`{"text": string}`

**示例**：
```json
{
  "fieldId": "description",
  "value": {"text": "这是一段很长的产品描述..."}
}
```

### number（数字）

**用途**：数值，如数量、金额

**值类型**：`{"number": float64}`

**示例**：
```json
{
  "fieldId": "quantity",
  "value": {"number": 100}
}
```

**配置选项**：
```json
{
  "type": "number",
  "validation": {
    "min": 0,
    "max": 9999,
    "precision": 2
  }
}
```

### currency（货币）

**用途**：货币金额，自动格式化

**值类型**：`{"number": float64}`

**示例**：
```json
{
  "fieldId": "price",
  "value": {"number": 99.99}
}
```

**配置选项**：
```json
{
  "type": "currency",
  "currencyCode": "CNY",
  "precision": 2
}
```

### percent（百分比）

**用途**：百分比数值

**值类型**：`{"number": float64}`（存储为小数，如 0.85 表示 85%）

**示例**：
```json
{
  "fieldId": "discount",
  "value": {"number": 0.15}  // 15%
}
```

### boolean（布尔值）

**用途**：是/否、真/假

**值类型**：`{"boolean": boolean}`

**示例**：
```json
{
  "fieldId": "isActive",
  "value": {"boolean": true}
}
```

## 日期时间类型

### date（日期）

**用途**：日期（不含时间）

**值类型**：`{"date": string}`（ISO 8601 格式）

**示例**：
```json
{
  "fieldId": "dueDate",
  "value": {"date": "2024-12-01"}
}
```

### datetime（日期时间）

**用途**：完整的日期和时间

**值类型**：`{"datetime": string}`（ISO 8601 格式）

**示例**：
```json
{
  "fieldId": "createdAt",
  "value": {"datetime": "2024-12-01T10:30:00Z"}
}
```

### duration（时长）

**用途**：时间段

**值类型**：`{"duration": int64}`（毫秒）

**示例**：
```json
{
  "fieldId": "processingTime",
  "value": {"duration": 3600000}  // 1 小时
}
```

## 选择类型

### single_select（单选）

**用途**：从预定义选项中选择一个

**值类型**：`{"selectOption": SelectOption}`

**示例**：
```json
{
  "fieldId": "status",
  "value": {
    "selectOption": {
      "id": "opt-active",
      "name": "Active",
      "color": "#28a745"
    }
  }
}
```

**配置选项**：
```json
{
  "type": "single_select",
  "options": [
    {"id": "opt-active", "name": "Active", "color": "#28a745"},
    {"id": "opt-inactive", "name": "Inactive", "color": "#dc3545"}
  ]
}
```

### multi_select（多选）

**用途**：从预定义选项中选择多个

**值类型**：`{"selectOptions": SelectOption[]}`

**示例**：
```json
{
  "fieldId": "tags",
  "value": {
    "selectOptions": [
      {"id": "tag-1", "name": "Electronics"},
      {"id": "tag-2", "name": "Featured"}
    ]
  }
}
```

### rating（评分）

**用途**：星级评分

**值类型**：`{"rating": int32}`（1-5）

**示例**：
```json
{
  "fieldId": "quality",
  "value": {"rating": 4}
}
```

## 关联类型

### attachment（附件）

**用途**：文件附件

**值类型**：`{"attachments": Attachment[]}`

**示例**：
```json
{
  "fieldId": "documents",
  "value": {
    "attachments": [
      {
        "id": "file-1",
        "name": "invoice.pdf",
        "url": "https://...",
        "size": 1024000,
        "mimeType": "application/pdf"
      }
    ]
  }
}
```

### user（用户）

**用途**：单个用户引用

**值类型**：`{"user": UserRef}`

**示例**：
```json
{
  "fieldId": "assignee",
  "value": {
    "user": {
      "id": "user-123",
      "name": "张三",
      "email": "zhangsan@example.com"
    }
  }
}
```

### collaborator（协作者）

**用途**：多个用户引用

**值类型**：`{"collaborators": UserRef[]}`

### relation（关联）

**用途**：关联到其他文档的数据行

**值类型**：`{"relations": RelationRef[]}`

**示例**：
```json
{
  "fieldId": "relatedProducts",
  "value": {
    "relations": [
      {"docType": "product", "docId": "123", "rowId": "row-1"},
      {"docType": "product", "docId": "123", "rowId": "row-2"}
    ]
  }
}
```

## 计算类型

### lookup（查找）

**用途**：从关联记录中查找值

**配置**：
```json
{
  "type": "lookup",
  "relationField": "relatedProduct",
  "lookupField": "price"
}
```

### rollup（汇总）

**用途**：对关联记录进行聚合计算

**配置**：
```json
{
  "type": "rollup",
  "relationField": "orderItems",
  "rollupField": "total",
  "aggregateFunction": "sum"
}
```

**聚合函数**：
- `count` - 计数
- `sum` - 求和
- `avg` - 平均值
- `min` - 最小值
- `max` - 最大值

### formula（公式）

**用途**：根据公式计算

**配置**：
```json
{
  "type": "formula",
  "formula": "quantity * unitPrice"
}
```

**支持的运算符**：
- 算术：`+`, `-`, `*`, `/`, `%`
- 比较：`>`, `<`, `>=`, `<=`, `==`, `!=`
- 逻辑：`&&`, `||`, `!`
- 函数：`SUM()`, `AVG()`, `IF()`, `ROUND()`

### auto_number（自动编号）

**用途**：自动递增的序列号

**值类型**：`{"number": int64}`

**配置**：
```json
{
  "type": "auto_number",
  "prefix": "INV-",
  "digits": 6,
  "startFrom": 1
}
```

**生成示例**：`INV-000001`, `INV-000002`, ...

## 系统字段

这些字段由系统自动维护，不可手动修改。

### created_time（创建时间）

**值类型**：`{"datetime": string}`

### updated_time（更新时间）

**值类型**：`{"datetime": string}`

### created_by（创建人）

**值类型**：`{"user": UserRef}`

### updated_by（最后更新人）

**值类型**：`{"user": UserRef}`

## 字段配置通用选项

所有字段类型都支持以下配置：

```json
{
  "id": "fieldId",
  "name": "字段名称",
  "type": "text",
  "description": "字段说明",
  "required": false,
  "unique": false,
  "readonly": false,
  "defaultValue": null,
  "validation": {}
}
```

### 配置说明

- **id**: 字段唯一标识符
- **name**: 显示名称
- **type**: 字段类型
- **description**: 字段说明
- **required**: 是否必填
- **unique**: 是否唯一
- **readonly**: 是否只读
- **defaultValue**: 默认值
- **validation**: 验证规则

## 值类型映射表

| 字段类型 | JSON 值格式 | 示例 |
|---------|-----------|------|
| text / long_text | `{"text": "..."}` | `{"text": "Hello"}` |
| number / currency / percent | `{"number": 123.45}` | `{"number": 99.99}` |
| boolean | `{"boolean": true}` | `{"boolean": false}` |
| date | `{"date": "2024-12-01"}` | `{"date": "2024-12-01"}` |
| datetime | `{"datetime": "...Z"}` | `{"datetime": "2024-12-01T10:00:00Z"}` |
| duration | `{"duration": 3600000}` | `{"duration": 3600000}` |
| single_select | `{"selectOption": {...}}` | `{"selectOption": {"id": "opt-1"}}` |
| multi_select | `{"selectOptions": [{...}]}` | `{"selectOptions": [{"id": "opt-1"}]}` |
| rating | `{"rating": 4}` | `{"rating": 5}` |
| attachment | `{"attachments": [{...}]}` | `{"attachments": [{"id": "file-1"}]}` |
| user | `{"user": {...}}` | `{"user": {"id": "user-123"}}` |
| collaborator | `{"collaborators": [{...}]}` | `{"collaborators": [{"id": "user-1"}]}` |
| relation | `{"relations": [{...}]}` | `{"relations": [{"rowId": "row-1"}]}` |

## 下一步

- 📖 阅读 [数据操作指南](../guides/data-operations.html)
- 📊 阅读 [文档模型详解](../guides/document-model.html)
- 💡 阅读 [最佳实践](../guides/best-practices.html)
