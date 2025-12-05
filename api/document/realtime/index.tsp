import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";
import "./messages.tsp";

using TypeSpec.Http;
using OpenAPI;


/**
 * 实时协作模块 (Realtime Collaboration)
 *
 * 基于 Yjs CRDT 的实时协作功能，支持多用户同时编辑。
 * Realtime collaboration based on Yjs CRDT, supporting concurrent editing by multiple users.
 *
 * ## 核心功能
 *
 * - **实时同步** - 基于 Yjs 的 CRDT 冲突自动解决
 * - **在线状态** - 实时显示在线用户和光标位置
 * - **单元格锁定** - 防止编辑冲突的临时锁定
 * - **操作历史** - 完整的协作操作记录
 * - **撤销/重做** - 支持协作环境下的撤销重做
 * - **Awareness** - 用户状态和选择区域共享
 *
 * ## 技术实现
 *
 * - **传输协议** - WebSocket / Server-Sent Events
 * - **CRDT 引擎** - Yjs (Y.Doc, Y.Array, Y.Map)
 * - **持久化** - 定期保存 Yjs 文档快照
 * - **增量更新** - 仅传输变更增量，减少带宽
 *
 * ## 使用场景
 *
 * - **多人编辑** - 多个用户同时编辑同一文档
 * - **实时反馈** - 查看其他用户的编辑位置
 * - **冲突解决** - 自动合并并发编辑
 * - **离线支持** - 离线编辑后自动同步
 *
 * ## 示例
 *
 * ### WebSocket 连接
 * ```javascript
 * const ws = new WebSocket('wss://open.nexusbook.com/api/v1/realtime/doc/product/123');
 * ws.onopen = () => {
 *   ws.send(JSON.stringify({
 *     type: 'auth',
 *     token: 'Bearer TOKEN'
 *   }));
 * };
 * ```
 */
namespace NexusBook.Api.Document;

/**
 * 实时会话
 * Realtime session
 */
model RealtimeSession {
    /**
     * 会话ID
     * Session id
     */
    id: string;

    /**
     * 文档类型
     * Document type
     */
    docType: string;

    /**
     * 文档ID
     * Document id
     */
    docId: string;

    /**
     * 用户ID
     * User id
     */
    userId: string;

    /**
     * WebSocket 连接ID
     * WebSocket connection id
     */
    connectionId?: string;

    /**
     * 加入时间
     * Joined at
     */
    joinedAt: string;

    /**
     * 最后活跃时间
     * Last active at
     */
    lastActiveAt?: string;

    /**
     * 用户状态
     * User awareness state
     */
    awareness?: {
        /**
         * 光标位置
         * Cursor position
         */
        cursor?: {
            rowId?: string;
            fieldId?: string;
            position?: int32;
        };

        /**
         * 选择区域
         * Selection
         */
        selection?: {
            startRowId?: string;
            endRowId?: string;
            startFieldId?: string;
            endFieldId?: string;
        };

        /**
         * 当前编辑的单元格
         * Currently editing cell
         */
        editingCell?: {
            rowId: string;
            fieldId: string;
        };

        /**
         * 用户颜色（用于光标显示）
         * User color (for cursor display)
         */
        color?: string;

        /**
         * 自定义状态
         * Custom state
         */
        custom?: unknown;
    };
}

/**
 * 在线用户
 * Online user
 */
model OnlineUser {
    /**
     * 用户ID
     * User id
     */
    userId: string;

    /**
     * 显示名称
     * Display name
     */
    displayName: string;

    /**
     * 头像URL
     * Avatar URL
     */
    avatarUrl?: string;

    /**
     * 用户颜色
     * User color
     */
    color?: string;

    /**
     * 会话ID
     * Session id
     */
    sessionId: string;

    /**
     * 加入时间
     * Joined at
     */
    joinedAt: string;

    /**
     * 最后活跃时间
     * Last active at
     */
    lastActiveAt: string;

    /**
     * Awareness 状态
     * Awareness state
     */
    awareness?: unknown;
}

/**
 * 单元格锁定
 * Cell lock
 */
model CellLock {
    /**
     * 锁ID
     * Lock id
     */
    id: string;

    /**
     * 行ID
     * Row id
     */
    rowId: string;

    /**
     * 字段ID
     * Field id
     */
    fieldId: string;

    /**
     * 锁定者用户ID
     * Locked by user id
     */
    lockedBy: string;

    /**
     * 锁定者会话ID
     * Locked by session id
     */
    sessionId: string;

    /**
     * 锁定时间
     * Locked at
     */
    lockedAt: string;

    /**
     * 过期时间
     * Expires at
     */
    expiresAt: string;

    /**
     * 是否自动续期
     * Auto renew
     */
    autoRenew?: boolean;
}

/**
 * 实时事件类型
 * Realtime event type
 */
enum RealtimeEventType {
    /**
     * Yjs 更新
     * Yjs update
     */
    yjs_update,

    /**
     * Awareness 更新
     * Awareness update
     */
    awareness_update,

    /**
     * 用户加入
     * User joined
     */
    user_joined,

    /**
     * 用户离开
     * User left
     */
    user_left,

    /**
     * 单元格锁定
     * Cell locked
     */
    cell_locked,

    /**
     * 单元格解锁
     * Cell unlocked
     */
    cell_unlocked,

    /**
     * 光标移动
     * Cursor moved
     */
    cursor_moved,

    /**
     * 选择变更
     * Selection changed
     */
    selection_changed,

    /**
     * 评论添加
     * Comment added
     */
    comment_added,

    /**
     * 数据变更
     * Data changed
     */
    data_changed,
}

/**
 * 实时事件
 * Realtime event
 */
model RealtimeEvent {
    /**
     * 事件类型
     * Event type
     */
    type: RealtimeEventType;

    /**
     * 文档类型
     * Document type
     */
    docType?: string;

    /**
     * 文档ID
     * Document id
     */
    docId?: string;

    /**
     * 用户ID
     * User id
     */
    userId?: string;

    /**
     * 会话ID
     * Session id
     */
    sessionId?: string;

    /**
     * 事件数据
     * Event data
     */
    data?: unknown;

    /**
     * 时间戳
     * Timestamp
     */
    timestamp: string;
}

/**
 * Yjs 文档快照
 * Yjs document snapshot
 */
model YjsSnapshot {
    /**
     * 快照ID
     * Snapshot id
     */
    id: string;

    /**
     * 文档类型
     * Document type
     */
    docType: string;

    /**
     * 文档ID
     * Document id
     */
    docId: string;

    /**
     * Yjs 状态向量（Base64）
     * Yjs state vector (Base64)
     */
    stateVector: string;

    /**
     * Yjs 文档更新（Base64）
     * Yjs document update (Base64)
     */
    docUpdate: string;

    /**
     * 版本号
     * Version
     */
    version: int64;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 文件大小（字节）
     * Size in bytes
     */
    size?: int64;
}

@route("/realtime")
@tag("Realtime")
interface RealtimeApi {
    /**
     * 获取 WebSocket 连接信息
     *
     * Get WebSocket connection info
     *
     * 返回 WebSocket 连接 URL 和认证令牌。
     * Return WebSocket connection URL and auth token.
     *
     * 客户端使用流程：
     * 1. 调用此 API 获取连接信息
     * 2. 使用返回的 wsUrl 和 token 建立 WebSocket 连接
     * 3. 发送认证消息
     * 4. 开始接收和发送实时事件
     */
    @route("/doc/{docType}/{docId}/connect")
    @get
    @summary("获取连接信息")
    getConnectionInfo(
        @path docType: string,
        @path docId: string,
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * WebSocket URL
         */
        wsUrl: string;

        /**
         * WebSocket 主机（单独端口）
         * WebSocket host (dedicated port)
         */
        wsHost?: string;

        /**
         * WebSocket 路径
         * WebSocket path
         */
        wsPath?: string;

        /**
         * 端口号
         * Port
         */
        port?: int32;

        /**
         * 支持的协议（例如：['websocket']）
         * Supported protocols
         */
        protocols?: string[];

        /**
         * SSE 流地址（只读）
         * Readonly SSE stream URL
         */
        sseUrl?: string;

        /**
         * 连接令牌
         * Connection token
         */
        token: string;

        /**
         * 令牌过期时间
         * Token expires at
         */
        expiresAt: string;

        /**
         * 服务器时间
         * Server time
         */
        serverTime: string;
    }>;

    /**
     * 获取在线用户列表
     *
     * Get online users
     *
     * 返回当前文档的所有在线用户。
     * Return all online users of current document.
     */
    @route("/doc/{docType}/{docId}/users")
    @get
    @summary("获取在线用户")
    getOnlineUsers(
        @path docType: string,
        @path docId: string,
    ): NexusBook.Api.Common.ApiResponse<OnlineUser[]>;

    /**
     * 锁定单元格
     *
     * Lock cell
     *
     * 请求锁定单元格以进行编辑。
     * Request cell lock for editing.
     */
    @route("/doc/{docType}/{docId}/lock")
    @post
    @summary("锁定单元格")
    lockCell(
        @path docType: string,
        @path docId: string,
        @body body: {
            /**
             * 行ID
             * Row id
             */
            rowId: string;

            /**
             * 字段ID
             * Field id
             */
            fieldId: string;

            /**
             * 锁定时长（秒）
             * Lock duration in seconds
             */
            duration?: int32;

            /**
             * 是否自动续期
             * Auto renew
             */
            autoRenew?: boolean;
        },
    ): NexusBook.Api.Common.ApiResponse<CellLock>;

    /**
     * 解锁单元格
     *
     * Unlock cell
     *
     * 释放单元格锁定。
     * Release cell lock.
     */
    @route("/doc/{docType}/{docId}/unlock/{lockId}")
    @delete
    @summary("解锁单元格")
    unlockCell(
        @path docType: string,
        @path docId: string,
        @path lockId: string,
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 获取当前锁定
     *
     * Get current locks
     *
     * 返回文档的所有活跃锁定。
     * Return all active locks of the document.
     */
    @route("/doc/{docType}/{docId}/locks")
    @get
    @summary("获取锁定列表")
    getCellLocks(
        @path docType: string,
        @path docId: string,
    ): NexusBook.Api.Common.ApiResponse<CellLock[]>;

    /**
     * 获取 Yjs 文档快照
     *
     * Get Yjs document snapshot
     *
     * 返回最新的 Yjs 文档快照，用于初始化客户端。
     * Return latest Yjs document snapshot for client initialization.
     */
    @route("/doc/{docType}/{docId}/snapshot")
    @get
    @summary("获取 Yjs 快照")
    getYjsSnapshot(
        @path docType: string,
        @path docId: string,
        @query version?: int64,
    ): NexusBook.Api.Common.ApiResponse<YjsSnapshot>;

    /**
     * 保存 Yjs 文档快照
     *
     * Save Yjs document snapshot
     *
     * 保存当前 Yjs 文档状态。通常由服务器定期调用。
     * Save current Yjs document state. Usually called periodically by server.
     */
    @route("/doc/{docType}/{docId}/snapshot")
    @post
    @summary("保存 Yjs 快照")
    saveYjsSnapshot(
        @path docType: string,
        @path docId: string,
        @body body: {
            /**
             * Yjs 状态向量（Base64）
             * Yjs state vector (Base64)
             */
            stateVector: string;

            /**
             * Yjs 文档更新（Base64）
             * Yjs document update (Base64)
             */
            docUpdate: string;
        },
    ): NexusBook.Api.Common.ApiResponse<YjsSnapshot>;

    /**
     * 获取快照历史
     *
     * Get snapshot history
     *
     * 返回文档的 Yjs 快照历史。
     * Return Yjs snapshot history of the document.
     */
    @route("/doc/{docType}/{docId}/snapshots")
    @get
    @summary("获取快照历史")
    getYjsSnapshots(
        @path docType: string,
        @path docId: string,
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<YjsSnapshot>>;

    /**
     * 应用 Yjs 更新
     *
     * Apply Yjs update
     *
     * 应用客户端的 Yjs 更新到服务器。
     * Apply client Yjs update to server.
     *
     * 注意：通常应该通过 WebSocket 发送更新，此 HTTP 接口用于备用场景。
     * Note: Updates should normally be sent via WebSocket. This HTTP endpoint is for fallback scenarios.
     */
    @route("/doc/{docType}/{docId}/apply-update")
    @post
    @summary("应用 Yjs 更新")
    applyYjsUpdate(
        @path docType: string,
        @path docId: string,
        @body body: {
            /**
             * Yjs 更新数据（Base64）
             * Yjs update data (Base64)
             */
            update: string;

            /**
             * 客户端版本
             * Client version
             */
            clientVersion?: int64;
        },
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 是否成功
         * Success
         */
        success: boolean;

        /**
         * 新版本号
         * New version
         */
        version: int64;

        /**
         * 服务器时间
         * Server time
         */
        serverTime: string;
    }>;

    /**
     * 更新 Awareness 状态
     *
     * Update awareness state
     *
     * 更新用户的 awareness 状态（光标、选择等）。
     * Update user awareness state (cursor, selection, etc).
     *
     * 注意：通常应该通过 WebSocket 发送，此接口用于备用场景。
     * Note: Should normally be sent via WebSocket. This endpoint is for fallback scenarios.
     */
    @route("/doc/{docType}/{docId}/awareness")
    @post
    @summary("更新 Awareness")
    updateAwareness(
        @path docType: string,
        @path docId: string,
        @body body: {
            /**
             * Awareness 状态
             * Awareness state
             */
            awareness: unknown;
        },
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 获取实时事件历史
     *
     * Get realtime event history
     *
     * 返回文档的实时协作事件历史。
     * Return realtime collaboration event history of the document.
     */
    @route("/doc/{docType}/{docId}/events")
    @get
    @summary("获取事件历史")
    getRealtimeEvents(
        @path docType: string,
        @path docId: string,
        @query eventType?: RealtimeEventType,
        @query userId?: string,
        @query startTime?: string,
        @query endTime?: string,
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<RealtimeEvent>>;

    /**
     * 断开所有会话
     *
     * Disconnect all sessions
     *
     * 强制断开文档的所有实时协作会话。
     * Force disconnect all realtime collaboration sessions of the document.
     */
    @route("/doc/{docType}/{docId}/disconnect-all")
    @post
    @summary("断开所有会话")
    disconnectAll(
        @path docType: string,
        @path docId: string,
        @body body?: {
            /**
             * 断开原因
             * Reason
             */
            reason?: string;
        },
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 断开的会话数
         * Disconnected count
         */
        disconnectedCount: int32;
    }>;

    /**
     * 获取 WebSocket 消息格式
     * Get WebSocket message schema
     *
     * 返回客户端与服务端的消息帧模型以及可用的消息类型枚举。
     * Return client/server message frames and available message kinds.
     */
    @route("/messages/schema")
    @get
    @summary("获取 WebSocket 消息格式")
    getMessageSchema(): NexusBook.Api.Common.ApiResponse<{
        /** 客户端 → 服务端 消息帧 */
        clientMessage: RealtimeClientMessage,
        /** 服务端 → 客户端 消息帧 */
        serverMessage: RealtimeServerMessage,
        /** 可用消息类型 */
        kinds: RealtimeMessageKind[]
    }>;

    /**
     * 事件流（SSE）
     * Server-Sent Events stream
     *
     * Content-Type: text/event-stream
     * 用于只读的实时事件推送（替代 WebSocket 的只读场景）。
     */
    @route("/doc/{docType}/{docId}/events/stream")
    @get
    @summary("SSE 事件流")
    sseEvents(
        @path docType: string,
        @path docId: string,
        @query since?: string,
        @query types?: string,
    ): string;
}
