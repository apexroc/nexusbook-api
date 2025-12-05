import "@typespec/http";
import "@typespec/openapi3";

using TypeSpec.Http;
using OpenAPI;

/**
 * WebSocket 消息格式定义 (Realtime Messages)
 *
 * 说明：这些模型用于文档化 WebSocket 传输层的消息帧结构，帮助前端与服务端在实时协同中达成一致。
 * OpenAPI 不直接描述 WebSocket，但我们在 TypeSpec 中记录消息格式以生成可读文档。
 */
namespace NexusBook.Api;

/**
 * 消息类型（客户端与服务端通用）
 */
enum RealtimeMessageKind {
  /** 认证：客户端发送 */
  auth,
  /** 订阅文档：客户端发送 */
  subscribe_doc,
  /** 取消订阅文档：客户端发送 */
  unsubscribe_doc,
  /** Yjs 增量更新：双向 */
  yjs_update,
  /** Awareness 状态更新：双向 */
  awareness_update,
  /** 锁定单元格请求：客户端发送 */
  lock_request,
  /** 释放锁定：客户端发送 */
  lock_release,
  /** 心跳：客户端或服务端 */
  ping,
  /** 心跳回复：服务端或客户端 */
  pong,
  /** 错误消息：服务端发送 */
  error
}

/**
 * 客户端 → 服务端：消息帧
 *
 * 所有字段均为 JSON 传输。
 */
model RealtimeClientMessage {
  /** 消息类型 */
  kind: RealtimeMessageKind;
  /** 序号（客户端自增，用于 Ack 对齐） */
  seq?: int64;
  /** 目标文档类型（部分消息需要） */
  docType?: string;
  /** 目标文档ID（部分消息需要） */
  docId?: string;
  /** 负载数据（各类型具体见下方 Payload 模型） */
  payload?: unknown;
  /** 发送时间（ISO8601） */
  timestamp?: string;
}

/** 认证负载 */
model AuthPayload {
  /** Bearer Token 或自定义短期连接令牌 */
  token: string;
}

/** 订阅负载 */
model SubscribePayload {
  docType: string;
  docId: string;
}

/** Yjs 更新负载 */
model YjsUpdatePayload {
  /** Yjs update（二进制 Base64） */
  update: string;
  /** 客户端版本（可选） */
  clientVersion?: int64;
}

/** Awareness 更新负载 */
model AwarenessPayload {
  /** Awareness 状态（光标、选区、用户颜色等） */
  awareness: unknown;
}

/** 锁定请求负载 */
model LockRequestPayload {
  rowId: string;
  fieldId: string;
  duration?: int32;
  autoRenew?: boolean;
}

/** 错误负载 */
model ErrorPayload {
  /** 错误码（例如：unauthorized、forbidden、invalid_payload、not_found、rate_limited） */
  code: string;
  /** 错误信息 */
  message: string;
  /** 详细数据（可选） */
  details?: unknown;
}

/**
 * 服务端 → 客户端：消息帧
 */
model RealtimeServerMessage {
  /** 消息类型 */
  kind: RealtimeMessageKind;
  /** 服务端序号（与客户端 seq 进行 ack 对齐） */
  seq?: int64;
  /** 对应客户端的 seq（当为确认或错误时） */
  ack?: int64;
  /** 会话ID（登录后分配） */
  sessionId?: string;
  /** 用户ID（若已识别） */
  userId?: string;
  /** 负载数据（如 YjsUpdatePayload、AwarenessPayload、ErrorPayload） */
  payload?: unknown;
  /** 发送时间（ISO8601） */
  timestamp: string;
}

/**
 * 示例：认证握手
 *
 * 客户端：
 * {
 *   "kind": "auth",
 *   "seq": 1,
 *   "payload": { "token": "Bearer ey..." },
 *   "timestamp": "2024-12-05T12:00:00Z"
 * }
 *
 * 服务端成功：
 * {
 *   "kind": "pong",
 *   "seq": 1001,
 *   "ack": 1,
 *   "sessionId": "sess-abc",
 *   "userId": "user-123",
 *   "timestamp": "2024-12-05T12:00:00Z"
 * }
 *
 * 服务端失败：
 * {
 *   "kind": "error",
 *   "seq": 1002,
 *   "ack": 1,
 *   "payload": { "code": "unauthorized", "message": "Invalid token" },
 *   "timestamp": "2024-12-05T12:00:00Z"
 * }
 */
