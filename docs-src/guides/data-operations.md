# 数据操作指南

本指南介绍如何使用 NexusBook API 进行数据行的增删改查操作。

## 数据行基本概念

数据行（Row）是文档的核心内容，每一行包含多个字段值。

### 数据行结构

```typescript
{
  "id": "row-001",              // 行 ID（唯一标识）
  "values": [                   // 字段值数组
    {
      "fieldId": "name",        // 字段 ID
      "value": {                // 字段值（根据字段类型不同）
        "text": "产品名称"
      }
    },
    {
      "fieldId": "price",
      "value": {
        "number": 99.99
      }
    }
  ],
  "version": 1,                 // 版本号（用于并发控制）
  "createdAt": "2024-12-01T10:00:00Z",
  "createdBy": "user-123",
  "updatedAt": "2024-12-01T11:00:00Z",
  "updatedBy": "user-456"
}
```

## CRUD 操作

### 创建数据行

**单行创建**：

```bash
curl -X POST 'https://open.nexusbook.com/api/v1/doc/product/123/data?apply=true' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "id": "row-001",
    "values": [
      {"fieldId": "name", "value": {"text": "iPhone 15"}},
      {"fieldId": "price", "value": {"number": 799.99}},
      {"fieldId": "stock", "value": {"number": 100}}
    ]
  }'
```

**批量创建**：

```bash
curl -X POST 'https://open.nexusbook.com/api/v1/doc/product/123/data/bulk?apply=true' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "rows": [
      {
        "id": "row-001",
        "values": [...]
      },
      {
        "id": "row-002",
        "values": [...]
      }
    ]
  }'
```

### 读取数据行

**获取单行**：

```bash
curl 'https://open.nexusbook.com/api/v1/doc/product/123/data/row-001' \
  -H 'Authorization: Bearer TOKEN'
```

**列表查询**：

```bash
curl 'https://open.nexusbook.com/api/v1/doc/product/123/data?page=1&pageSize=20' \
  -H 'Authorization: Bearer TOKEN'
```

**结构化查询**：

```bash
curl -X POST 'https://open.nexusbook.com/api/v1/doc/product/123/data/query' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "filters": {
      "logic": "and",
      "conditions": [
        {"field": "status", "operator": "eq", "value": "active"},
        {"field": "price", "operator": "gte", "value": 100}
      ]
    },
    "sorts": [{"field": "price", "direction": "desc"}],
    "page": 1,
    "pageSize": 50
  }'
```

### 更新数据行

**全量更新**：

```bash
curl -X PUT 'https://open.nexusbook.com/api/v1/doc/product/123/data/row-001?apply=true' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "values": [
      {"fieldId": "name", "value": {"text": "iPhone 15 Pro"}},
      {"fieldId": "price", "value": {"number": 999.99}}
    ],
    "version": 1
  }'
```

**部分更新**：

```bash
curl -X PATCH 'https://open.nexusbook.com/api/v1/doc/product/123/data/row-001?apply=true' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "values": [
      {"fieldId": "price", "value": {"number": 899.99}}
    ],
    "version": 1
  }'
```

### 删除数据行

**单行删除**：

```bash
curl -X DELETE 'https://open.nexusbook.com/api/v1/doc/product/123/data/row-001?apply=true' \
  -H 'Authorization: Bearer TOKEN'
```

**批量删除**：

```bash
curl -X POST 'https://open.nexusbook.com/api/v1/doc/product/123/data/bulk?apply=true' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "delete": ["row-001", "row-002", "row-003"]
  }'
```

## 字段值类型映射

不同的字段类型对应不同的值格式：

| 字段类型 | 值类型 | 示例 |
|---------|-------|------|
| text | string | `{"text": "文本内容"}` |
| number | float64 | `{"number": 123.45}` |
| boolean | boolean | `{"boolean": true}` |
| date | string (ISO 8601) | `{"date": "2024-12-01"}` |
| datetime | string (ISO 8601) | `{"datetime": "2024-12-01T10:00:00Z"}` |
| single_select | SelectOption | `{"selectOption": {"id": "opt-1", "name": "选项A"}}` |
| multi_select | SelectOption[] | `{"selectOptions": [{"id": "opt-1"}, {"id": "opt-2"}]}` |

完整的字段类型参考见：[字段类型参考](../references/field-types.html)

## apply 参数说明

`apply` 参数控制变更如何应用：

### apply=true（直接应用）

变更立即生效，直接修改数据：

```bash
curl -X POST '.../data?apply=true' \
  -H 'Authorization: Bearer TOKEN' \
  -d '...'
```

**适用场景**：
- 权限充足的直接操作
- 不需要审批的简单变更
- 系统自动化操作

### apply=false 或不提供（创建变更请求）

创建变更请求（Request），需要审核后合并：

```bash
curl -X POST '.../data?apply=false' \
  -H 'Authorization: Bearer TOKEN' \
  -d '...'
```

**适用场景**：
- 需要审批的重要变更
- 多人协作编辑
- 变更追踪和审计

## 并发控制

使用版本号（version）进行乐观锁控制：

```bash
# 1. 获取当前数据
curl 'https://open.nexusbook.com/api/v1/doc/product/123/data/row-001' \
  -H 'Authorization: Bearer TOKEN'

# 响应
{
  "id": "row-001",
  "values": [...],
  "version": 5
}

# 2. 更新时提供版本号
curl -X PUT 'https://open.nexusbook.com/api/v1/doc/product/123/data/row-001?apply=true' \
  -H 'Authorization: Bearer TOKEN' \
  -d '{
    "values": [...],
    "version": 5  // 必须匹配当前版本
  }'
```

**冲突处理**：

如果版本不匹配，API 返回错误：
```json
{
  "success": false,
  "code": "VERSION_CONFLICT",
  "message": {
    "zh": "数据已被其他用户修改，请刷新后重试",
    "en": "Data has been modified by another user, please refresh and retry"
  }
}
```

## 性能优化建议

### 1. 优先使用批量操作

```bash
# ❌ 不推荐：循环调用 100 次
for i in {1..100}; do
  curl -X POST '.../data?apply=true' -d "{...row $i...}"
done

# ✅ 推荐：一次批量创建 100 行
curl -X POST '.../data/bulk?apply=true' -d '{
  "rows": [
    {...row 1...},
    {...row 2...},
    ...
    {...row 100...}
  ]
}'
```

### 2. 合理设置分页大小

```bash
# ❌ 太小：请求次数过多
curl '.../data?page=1&pageSize=10'

# ❌ 太大：响应时间长
curl '.../data?page=1&pageSize=1000'

# ✅ 推荐：20-100 之间
curl '.../data?page=1&pageSize=50'
```

### 3. 只查询需要的字段

```bash
# ❌ 查询所有字段
curl '.../data/query' -d '{
  "fields": ["*"]
}'

# ✅ 只查询需要的字段
curl '.../data/query' -d '{
  "fields": ["id", "name", "price", "stock"]
}'
```

### 4. 使用过滤减少数据量

```bash
# ❌ 获取所有数据后在客户端过滤
curl '.../data?pageSize=1000'

# ✅ 在服务端过滤
curl -X POST '.../data/query' -d '{
  "filters": {
    "logic": "and",
    "conditions": [
      {"field": "status", "operator": "eq", "value": "active"}
    ]
  }
}'
```

## 常见问题

### 1. 如何处理大数据量？

使用游标分页：

```bash
# 首次请求
curl '.../data?pageSize=100'

# 响应包含 cursor
{
  "items": [...],
  "cursor": "eyJpZCI6InJvdy0xMDAifQ==",
  "hasMore": true
}

# 下一页
curl '.../data?pageSize=100&cursor=eyJpZCI6InJvdy0xMDAifQ=='
```

### 2. 如何处理复杂查询？

使用嵌套过滤条件：

```bash
curl -X POST '.../data/query' -d '{
  "filters": {
    "logic": "or",
    "conditions": [
      {
        "logic": "and",
        "conditions": [
          {"field": "category", "operator": "eq", "value": "electronics"},
          {"field": "price", "operator": "gte", "value": 1000}
        ]
      },
      {
        "field": "featured", "operator": "eq", "value": true
      }
    ]
  }
}'
```

### 3. 如何导出数据？

```bash
# 导出为 JSON
curl '.../data/export?format=json' \
  -H 'Authorization: Bearer TOKEN' \
  > data.json

# 导出为 CSV
curl '.../data/export?format=csv' \
  -H 'Authorization: Bearer TOKEN' \
  > data.csv
```

## 下一步

- 📊 阅读 [文档模型详解](document-model.html)
- 🔔 阅读 [Webhook 使用指南](webhooks.html)
- 💡 阅读 [最佳实践](best-practices.html)
- 📚 查看 [完整示例](examples.html)
