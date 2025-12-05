# 实时协同开发指南

> 本指南详细说明 NexusBook 的实时协同（Realtime Collaboration）如何接入，包括 WebSocket 握手、消息格式、增量同步（Yjs）、Awareness、锁定机制、断线重连与后备 HTTP 接口等。

## 1. 总览

- **传输协议**：WebSocket（推荐）；HTTP 备用端点用于断线或低配环境
- **CRDT 引擎**：Yjs（Y.Doc/Y.Map/Y.Array）
- **状态共享**：Awareness（光标、选区、用户颜色等）
- **冲突控制**：Cell Lock（单元格锁定）
- **持久化**：Yjs 快照（State Vector + Update）

## 2.1 连接信息字段

`GET /realtime/doc/{docType}/{docId}/connect` 响应：
- `wsUrl`：完整 WS 连接地址
- `wsHost/wsPath/port/protocols`：用于独立端口或代理部署
- `sseUrl`：只读事件流地址（`text/event-stream`）
- `token/expiresAt`：短期连接令牌与过期时间



1. 调用获取连接信息接口：
   - `GET /realtime/doc/{docType}/{docId}/connect`
   - 返回：`wsUrl`、`token`（短期连接令牌）、`expiresAt`
2. 建立 WebSocket 连接：`new WebSocket(wsUrl)`
3. 发送认证消息（客户端 → 服务端）：
   ```json
   {
     "kind": "auth",
     "seq": 1,
     "payload": { "token": "Bearer {ACCESS_TOKEN}" },
     "timestamp": "2025-12-05T12:00:00Z"
   }
   ```
4. 服务端返回成功（`pong`）或失败（`error`）：
   ```json
   {
     "kind": "pong",
     "seq": 1001,
     "ack": 1,
     "sessionId": "sess-abc",
     "userId": "user-123",
     "timestamp": "2025-12-05T12:00:00Z"
   }
   ```

## 3. 消息格式（WebSocket）

消息类型枚举定义见 `api/document/realtime/messages.tsp`：`RealtimeMessageKind`

- `auth`：认证（客户端 → 服务端）
- `subscribe_doc` / `unsubscribe_doc`：订阅/取消订阅文档（客户端 → 服务端）
- `yjs_update`：Yjs 增量更新（双向）
- `awareness_update`：Awareness 状态更新（双向）
- `lock_request` / `lock_release`：单元格锁定/释放（客户端 → 服务端）
- `ping` / `pong`：心跳（双向）
- `error`：错误（服务端 → 客户端）

### 3.1 客户端消息帧（RealtimeClientMessage）
```json
{
  "kind": "yjs_update",
  "seq": 12,
  "docType": "product",
  "docId": "123",
  "payload": { "update": "BASE64_YJS_UPDATE", "clientVersion": 88 },
  "timestamp": "2025-12-05T12:00:12Z"
}
```

### 3.2 服务端消息帧（RealtimeServerMessage）
```json
{
  "kind": "awareness_update",
  "seq": 2203,
  "payload": { "awareness": { "cursor": { "rowId": "row-1", "fieldId": "name" }, "color": "#007AFF" } },
  "timestamp": "2025-12-05T12:01:03Z"
}
```

### 3.3 错误消息（ErrorPayload）
```json
{
  "kind": "error",
  "seq": 3002,
  "ack": 12,
  "payload": { "code": "invalid_payload", "message": "Missing update" },
  "timestamp": "2025-12-05T12:01:30Z"
}
```

## 4. 文档订阅与初始化

1. 订阅文档：
   ```json
   { "kind": "subscribe_doc", "seq": 2, "payload": { "docType": "product", "docId": "123" } }
   ```
2. 初始化（HTTP 后备）
   - 获取快照：`GET /realtime/doc/{docType}/{docId}/snapshot`
   - 快照历史：`GET /realtime/doc/{docType}/{docId}/snapshots`

## 5. Yjs 增量同步

- 发送增量更新（客户端 → 服务端）：`kind = yjs_update`
- 服务端广播给同订阅者：`kind = yjs_update`
- 推荐在客户端合并：`Y.applyUpdate(doc, update)`

注意：update 为二进制数据，需用 Base64 编解码。

## 6. Awareness 状态

- 更新：`kind = awareness_update`，payload 中包含 `cursor/selection/color` 等
- 服务端广播给其他在线用户
- 与锁定机制结合：当 `editingCell` 与锁状态冲突时，服务端返回错误或拒绝广播

## 7. 单元格锁定（冲突控制）

- 请求锁定（HTTP 或 WS）
  - HTTP：`POST /realtime/doc/{docType}/{docId}/lock`
  - WS：`kind = lock_request`，payload `rowId/fieldId/duration/autoRenew`
- 释放锁定
  - HTTP：`DELETE /realtime/doc/{docType}/{docId}/unlock/{lockId}`
  - WS：`kind = lock_release`
- 查询锁定：`GET /realtime/doc/{docType}/{docId}/locks`

## 8. 断线重连与后备策略

- 心跳：`ping/pong`，间隔建议 15s
- 断线重连：指数退避（1s/2s/4s…，最大 30s），最多 10 次
- 后备 HTTP：在 WS 不可用时，使用：
  - `POST /realtime/doc/{docType}/{docId}/apply-update`
  - `POST /realtime/doc/{docType}/{docId}/awareness`
- 快照恢复：重连后拉取最新快照并对齐状态向量（State Vector）

## 9. 安全与权限

- 认证：`auth` 消息携带 Bearer Token 或短期连接令牌（`connect` 接口返回）
- Scopes 建议：
  - `document:collab:read`（订阅、快照、事件）
  - `document:collab:write`（yjs_update、awareness_update、锁定）
- 速率限制与会话上限：
  - 每用户最大会话数（如：5）
  - 每秒最大消息数（如：30）

## 10. 与审批工作流的关系

- 实时协同产生的变更在服务端转为 **变更请求（Request）** 的候选变更
- 审批通过后生效；拒绝则回滚或保留为草稿
- 建议在事件历史中标注 `data_changed` 与 Request 关联 ID

## 11. 客户端示例（伪代码）

```javascript
const ws = new WebSocket(wsUrl);
ws.onopen = () => {
  ws.send(JSON.stringify({ kind: 'auth', seq: 1, payload: { token } }));
  ws.send(JSON.stringify({ kind: 'subscribe_doc', seq: 2, payload: { docType, docId } }));
};

ws.onmessage = (evt) => {
  const msg = JSON.parse(evt.data);
  switch (msg.kind) {
    case 'yjs_update':
      Y.applyUpdate(doc, base64ToUint8Array(msg.payload.update));
      break;
    case 'awareness_update':
      updateAwareness(msg.payload.awareness);
      break;
    case 'error':
      console.error('Realtime error:', msg.payload);
      break;
  }
};

function sendUpdate(update) {
  ws.send(JSON.stringify({ kind: 'yjs_update', seq: nextSeq(), docType, docId, payload: { update: uint8ArrayToBase64(update) } }));
}
```

## 12. SSE 事件流（只读）

```bash
curl 'https://open.nexusbook.com/api/v1/realtime/doc/product/123/events/stream'
```
- Content-Type: `text/event-stream`
- 适用于只读订阅、日志/审计等场景


如需我把该指南加入侧边栏“核心概念”，我已配置 `redocly.yaml` 的 sidebars，构建后即可从左侧导航进入本页。