# 完整示例

本指南提供完整的使用场景示例，展示如何在实际项目中使用 NexusBook API。

## 场景 1：订货单系统

### 系统架构

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  前端应用    │────>│  后端服务     │────>│ NexusBook   │
│  (Vue.js)   │     │  (Node.js)   │     │   API       │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                           ├──> Webhook 通知
                           ├──> 数据验证
                           └──> 审批流程
```

### 步骤 1：创建订货单文档

```javascript
// 1. 初始化文档属性
const orderProperties = {
  orderTime: new Date().toISOString(),
  storeName: 'Beijing Branch',
  totalAmount: 0,
  totalQuantity: 0,
  status: 'draft'
};

await api.post('/doc/purchaseOrder/order-001/properties', {
  properties: orderProperties
});

// 2. 定义字段元数据
const metadata = {
  fields: [
    {
      id: 'productName',
      name: '产品名称',
      type: 'text',
      required: true
    },
    {
      id: 'quantity',
      name: '数量',
      type: 'number',
      required: true,
      validation: { min: 1 }
    },
    {
      id: 'unitPrice',
      name: '单价',
      type: 'currency',
      required: true
    },
    {
      id: 'total',
      name: '小计',
      type: 'formula',
      formula: 'quantity * unitPrice'
    }
  ]
};

await api.put('/doc/purchaseOrder/order-001/metadata', metadata);
```

### 步骤 2：添加产品行

```javascript
// 批量添加订单项
const rows = [
  {
    id: 'row-001',
    values: [
      { fieldId: 'productName', value: { text: 'iPhone 15' } },
      { fieldId: 'quantity', value: { number: 10 } },
      { fieldId: 'unitPrice', value: { number: 799.99 } }
    ]
  },
  {
    id: 'row-002',
    values: [
      { fieldId: 'productName', value: { text: 'iPad Pro' } },
      { fieldId: 'quantity', value: { number: 5 } },
      { fieldId: 'unitPrice', value: { number: 1099.99 } }
    ]
  }
];

await api.post('/doc/purchaseOrder/order-001/data/bulk?requestId=req-1', {
  rows
});
```

### 步骤 3：创建视图

```javascript
// 创建"待处理"视图
await api.post('/doc/purchaseOrder/order-001/views', {
  id: 'view-pending',
  name: '待处理订单',
  type: 'table',
  config: {
    filters: {
      logic: 'and',
      conditions: [
        { field: 'status', operator: 'eq', value: 'pending' }
      ]
    },
    sorts: [
      { field: 'orderTime', direction: 'desc' }
    ]
  }
});
```

### 步骤 4：配置 Webhook

```javascript
// 订阅订单变更通知
await api.post('/webhooks', {
  name: '订单变更通知',
  url: 'https://yourapp.com/webhooks/order-changes',
  events: ['data_row_created', 'data_row_updated', 'request_merged'],
  filters: {
    docTypes: ['purchaseOrder']
  },
  secret: 'your_webhook_secret'
});
```

### 完整代码（Node.js）

```javascript
const axios = require('axios');

class OrderManagementSystem {
  constructor(apiUrl, accessToken) {
    this.api = axios.create({
      baseURL: apiUrl,
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      }
    });
  }
  
  async createOrder(orderData) {
    const orderId = `order-${Date.now()}`;
    
    // 1. 创建属性
    await this.api.post(`/doc/purchaseOrder/${orderId}/properties`, {
      properties: {
        orderTime: new Date().toISOString(),
        storeName: orderData.store,
        status: 'draft'
      }
    });
    
    // 2. 设置元数据
    await this.api.put(`/doc/purchaseOrder/${orderId}/metadata`, {
      fields: this.getOrderFields()
    });
    
    // 3. 添加产品行
    const rows = orderData.items.map((item, index) => ({
      id: `row-${index + 1}`,
      values: [
        { fieldId: 'productName', value: { text: item.name } },
        { fieldId: 'quantity', value: { number: item.quantity } },
        { fieldId: 'unitPrice', value: { number: item.price } }
      ]
    }));
    
    await this.api.post(`/doc/purchaseOrder/${orderId}/data/bulk?requestId=req-1`, {
      rows
    });
    
    return orderId;
  }
  
  getOrderFields() {
    return [
      { id: 'productName', name: '产品名称', type: 'text', required: true },
      { id: 'quantity', name: '数量', type: 'number', required: true },
      { id: 'unitPrice', name: '单价', type: 'currency', required: true },
      { id: 'total', name: '小计', type: 'formula', formula: 'quantity * unitPrice' }
    ];
  }
}

// 使用示例
const oms = new OrderManagementSystem(
  'https://open.nexusbook.com/api/v1',
  'YOUR_ACCESS_TOKEN'
);

const orderId = await oms.createOrder({
  store: 'Beijing Branch',
  items: [
    { name: 'iPhone 15', quantity: 10, price: 799.99 },
    { name: 'iPad Pro', quantity: 5, price: 1099.99 }
  ]
});

console.log(`订单创建成功: ${orderId}`);
```

## 场景 2：Webhook 集成

### Webhook 接收器实现

**Node.js + Express**:

```javascript
const express = require('express');
const crypto = require('crypto');

const app = express();
app.use(express.json());

// Webhook 端点
app.post('/webhooks/nexusbook', (req, res) => {
  // 1. 验证签名
  const signature = req.headers['x-nexusbook-signature'];
  const secret = process.env.WEBHOOK_SECRET;
  
  const hmac = crypto.createHmac('sha256', secret);
  const expectedSignature = hmac.update(JSON.stringify(req.body)).digest('hex');
  
  if (signature !== expectedSignature) {
    return res.status(401).send('Invalid signature');
  }
  
  // 2. 处理事件
  const { event, payload } = req.body;
  
  switch (event) {
    case 'request_merged':
      handleRequestMerged(payload);
      break;
    case 'data_row_created':
      handleDataRowCreated(payload);
      break;
    case 'approval_approved':
      handleApprovalApproved(payload);
      break;
  }
  
  res.status(200).send('OK');
});

function handleRequestMerged(payload) {
  console.log('变更请求已合并:', payload.requestId);
  // 发送通知、更新缓存等
}

app.listen(3000);
```

**Python + Flask**:

```python
from flask import Flask, request, jsonify
import hmac
import hashlib
import json

app = Flask(__name__)
WEBHOOK_SECRET = 'your_webhook_secret'

@app.route('/webhooks/nexusbook', methods=['POST'])
def handle_webhook():
    # 验证签名
    signature = request.headers.get('X-Nexusbook-Signature')
    body = request.get_data()
    
    expected_signature = hmac.new(
        WEBHOOK_SECRET.encode(),
        body,
        hashlib.sha256
    ).hexdigest()
    
    if signature != expected_signature:
        return 'Invalid signature', 401
    
    # 处理事件
    data = request.get_json()
    event = data['event']
    payload = data['payload']
    
    if event == 'request_merged':
        handle_request_merged(payload)
    elif event == 'data_row_created':
        handle_data_row_created(payload)
    
    return 'OK', 200

def handle_request_merged(payload):
    print(f"变更请求已合并: {payload['requestId']}")

if __name__ == '__main__':
    app.run(port=3000)
```

## 场景 3：库存管理系统

### 低库存预警

```javascript
// 1. 创建低库存视图
await api.post('/doc/inventory/inv-001/views', {
  id: 'view-low-stock',
  name: '低库存预警',
  type: 'table',
  config: {
    filters: {
      logic: 'and',
      conditions: [
        { field: 'stock', operator: 'lte', value: 10 }
      ]
    },
    sorts: [
      { field: 'stock', direction: 'asc' }
    ]
  }
});

// 2. 配置 Webhook 监控库存变化
await api.post('/webhooks', {
  name: '库存变化通知',
  url: 'https://yourapp.com/webhooks/inventory',
  events: ['data_row_updated'],
  filters: {
    docTypes: ['inventory'],
    customConditions: {
      'values.stock.number': { $lte: 10 }
    }
  }
});

// 3. 处理低库存通知
app.post('/webhooks/inventory', async (req, res) => {
  const { payload } = req.body;
  
  if (payload.values.stock.number <= 10) {
    // 发送预警通知
    await sendAlert({
      type: 'low_stock',
      product: payload.values.productName.text,
      currentStock: payload.values.stock.number,
      reorderLevel: 50
    });
    
    // 自动创建采购订单
    await createPurchaseOrder(payload);
  }
  
  res.status(200).send('OK');
});
```

## 场景 4：数据导入导出

### 批量导入

```javascript
async function importFromCSV(filePath, docType, docId) {
  const csv = require('csv-parser');
  const fs = require('fs');
  
  const rows = [];
  let index = 0;
  
  // 读取 CSV
  fs.createReadStream(filePath)
    .pipe(csv())
    .on('data', (row) => {
      rows.push({
        id: `imported-row-${++index}`,
        values: [
          { fieldId: 'name', value: { text: row['产品名称'] } },
          { fieldId: 'price', value: { number: parseFloat(row['价格']) } },
          { fieldId: 'stock', value: { number: parseInt(row['库存']) } }
        ]
      });
    })
    .on('end', async () => {
      // 批量导入（每次 100 行）
      const batchSize = 100;
      for (let i = 0; i < rows.length; i += batchSize) {
        const batch = rows.slice(i, i + batchSize);
        
        await api.post(`/doc/${docType}/${docId}/data/bulk?requestId=req-1`, {
          rows: batch
        });
        
        console.log(`已导入 ${i + batch.length}/${rows.length} 行`);
      }
      
      console.log('导入完成！');
    });
}
```

### 批量导出

```javascript
async function exportToCSV(docType, docId, outputPath) {
  const { createObjectCsvWriter } = require('csv-writer');
  
  // 获取元数据
  const metadata = await api.get(`/doc/${docType}/${docId}/metadata`);
  
  // 创建 CSV writer
  const csvWriter = createObjectCsvWriter({
    path: outputPath,
    header: metadata.fields.map(f => ({
      id: f.id,
      title: f.name
    }))
  });
  
  // 分页获取所有数据
  let cursor = null;
  const allRows = [];
  
  do {
    const response = await api.get(`/doc/${docType}/${docId}/data`, {
      params: { pageSize: 100, cursor }
    });
    
    const records = response.items.map(row => {
      const record = {};
      row.values.forEach(v => {
        record[v.fieldId] = v.value.text || v.value.number || v.value.boolean;
      });
      return record;
    });
    
    allRows.push(...records);
    cursor = response.cursor;
  } while (cursor);
  
  // 写入 CSV
  await csvWriter.writeRecords(allRows);
  console.log(`已导出 ${allRows.length} 行到 ${outputPath}`);
}
```

## 测试示例

### 单元测试

```javascript
const { describe, test, expect } = require('@jest/globals');

describe('NexusBook API 集成', () => {
  test('创建订货单', async () => {
    const oms = new OrderManagementSystem(apiUrl, token);
    
    const orderId = await oms.createOrder({
      store: 'Test Store',
      items: [
        { name: 'Product A', quantity: 5, price: 99.99 }
      ]
    });
    
    expect(orderId).toMatch(/^order-\d+$/);
    
    // 验证数据已创建
    const data = await api.get(`/doc/purchaseOrder/${orderId}/data`);
    expect(data.items).toHaveLength(1);
    expect(data.items[0].values[0].value.text).toBe('Product A');
  });
});
```

## 性能优化示例

### 并行请求

```javascript
async function loadDashboard(docType, docId) {
  // 并行加载多个资源
  const [metadata, views, summary] = await Promise.all([
    api.get(`/doc/${docType}/${docId}/metadata`),
    api.get(`/doc/${docType}/${docId}/views`),
    api.post(`/doc/${docType}/${docId}/data/query`, {
      aggregate: {
        count: true,
        sum: ['totalAmount'],
        avg: ['unitPrice']
      }
    })
  ]);
  
  return { metadata, views, summary };
}
```

### 请求去重

```javascript
class RequestDeduplicator {
  constructor() {
    this.pending = new Map();
  }
  
  async fetch(key, fetcher) {
    // 如果相同请求正在进行，直接返回
    if (this.pending.has(key)) {
      return this.pending.get(key);
    }
    
    const promise = fetcher();
    this.pending.set(key, promise);
    
    try {
      const result = await promise;
      return result;
    } finally {
      this.pending.delete(key);
    }
  }
}

const dedup = new RequestDeduplicator();

// 多次调用只会发起一次请求
const [result1, result2, result3] = await Promise.all([
  dedup.fetch('metadata-123', () => api.get('/metadata')),
  dedup.fetch('metadata-123', () => api.get('/metadata')),
  dedup.fetch('metadata-123', () => api.get('/metadata'))
]);
```

## 下一步

- 📖 阅读 [API 参考文档](../api/index.html)
- 💡 阅读 [最佳实践](best-practices.html)
- 🔧 阅读 [数据操作指南](data-operations.html)
