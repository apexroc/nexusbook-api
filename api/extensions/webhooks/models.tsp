import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * Webhook 模块
 *
 * 提供事件驱动的 Webhook 通知机制，支持订阅文档变更事件。
 *
 * 主要功能：
 * - **事件订阅** - 订阅文档的各种变更事件
 * - **自动通知** - 事件发生时自动推送到指定 URL
 * - **重试机制** - 失败自动重试，保证消息送达
 * - **签名验证** - HMAC 签名确保消息安全
 * - **事件过滤** - 灵活的事件类型和条件过滤
 *
 * ## 支持的事件类型
 *
 * ### 1. Request 相关事件
 * - `request.created` - 创建变更请求
 * - `request.merged` - 请求已合并
 * - `request.closed` - 请求已关闭
 * - `request.reopened` - 请求重新打开
 *
 * ### 2. Approval 相关事件
 * - `approval.started` - 审批流程开始
 * - `approval.approved` - 审批通过
 * - `approval.rejected` - 审批拒绝
 * - `approval.canceled` - 审批取消
 * - `approval.node_completed` - 审批节点完成
 *
 * ### 3. Comment 相关事件
 * - `comment.created` - 创建评论
 * - `comment.updated` - 更新评论
 * - `comment.deleted` - 删除评论
 * - `comment.resolved` - 评论已解决
 * - `comment.mentioned` - 用户被 @提及
 *
 * ### 4. Metadata 相关事件
 * - `metadata.updated` - 元数据更新
 * - `metadata.field_added` - 添加字段
 * - `metadata.field_updated` - 更新字段
 * - `metadata.field_deleted` - 删除字段
 *
 * ### 5. View 相关事件
 * - `view.created` - 创建视图
 * - `view.updated` - 更新视图
 * - `view.deleted` - 删除视图
 * - `view.default_changed` - 默认视图变更
 *
 * ### 6. Data 相关事件
 * - `data.row_created` - 创建数据行
 * - `data.row_updated` - 更新数据行
 * - `data.row_deleted` - 删除数据行
 * - `data.bulk_operation` - 批量操作
 *
 * ### 7. Revision 相关事件
 * - `revision.created` - 创建修订
 * - `revision.reverted` - 修订回滚
 *
 * ## Webhook 载荷格式
 *
 * ```json
 * {
 *   "event": "request.merged",
 *   "timestamp": "2024-12-01T10:00:00Z",
 *   "webhookId": "webhook-123",
 *   "deliveryId": "delivery-456",
 *   "docType": "product",
 *   "docId": "123",
 *   "payload": {
 *     // 事件相关数据
 *   }
 * }
 * ```
 *
 * ## 签名验证
 *
 * 每个 Webhook 请求都包含 `X-Webhook-Signature` 头：
 * ```
 * X-Webhook-Signature: sha256=<HMAC-SHA256(secret, body)>
 * ```
 */
namespace NexusBook.Api.Extensions.Webhooks;

/**
 * Webhook 事件类型
 * Webhook event types
 */
enum WebhookEventType {
    // Request 事件
    request_created,
    request_merged,
    request_closed,
    request_reopened,

    // Approval 事件
    approval_started,
    approval_approved,
    approval_rejected,
    approval_canceled,
    approval_node_completed,

    // Comment 事件
    comment_created,
    comment_updated,
    comment_deleted,
    comment_resolved,
    comment_mentioned,

    // Metadata 事件
    metadata_updated,
    metadata_field_added,
    metadata_field_updated,
    metadata_field_deleted,

    // View 事件
    view_created,
    view_updated,
    view_deleted,
    view_default_changed,

    // Data 事件
    data_row_created,
    data_row_updated,
    data_row_deleted,
    data_bulk_operation,

    // Revision 事件
    revision_created,
    revision_reverted,
}

/**
 * Webhook 状态
 * Webhook status
 */
enum WebhookStatus {
    /**
     * 活跃
     * Active
     */
    active,

    /**
     * 暂停
     * Paused
     */
    paused,

    /**
     * 失败（多次重试失败后）
     * Failed (after multiple retry failures)
     */
    failed,
}

/**
 * 事件过滤条件
 * Event filter condition
 */
model EventFilter {
    /**
     * 文档类型过滤
     * Document type filter
     *
     * 只接收指定文档类型的事件。
     * Only receive events for specified document types.
     */
    docTypes?: string[];

    /**
     * 文档 ID 过滤
     * Document ID filter
     *
     * 只接收指定文档的事件。
     * Only receive events for specified documents.
     */
    docIds?: string[];

    /**
     * 用户过滤
     * User filter
     *
     * 只接收指定用户触发的事件。
     * Only receive events triggered by specified users.
     */
    userIds?: NexusBook.Api.Common.UserRef[];

    /**
     * 自定义条件
     * Custom conditions
     *
     * 使用 JSONPath 表达式过滤事件载荷。
     * Filter event payload using JSONPath expressions.
     */
    conditions?: {
        /**
         * JSONPath 表达式
         * JSONPath expression
         */
        path: string;

        /**
         * 操作符
         * Operator
         */
        operator: "eq" | "ne" | "in" | "contains";

        /**
         * 期望值
         * Expected value
         */
        value: unknown;
    }[];
}

/**
 * Webhook 配置
 * Webhook configuration
 */
model Webhook {
    /**
     * Webhook ID
     * Webhook id
     */
    id: string;

    /**
     * 名称
     * Name
     */
    name: string;

    /**
     * 描述
     * Description
     */
    description?: string;

    /**
     * 目标 URL
     * Target URL
     *
     * 接收 Webhook 事件的 URL。
     * URL to receive webhook events.
     */
    url: string;

    /**
     * 订阅的事件类型
     * Subscribed event types
     */
    events: WebhookEventType[];

    /**
     * 事件过滤条件
     * Event filters
     */
    filters?: EventFilter;

    /**
     * 密钥（用于签名验证）
     * Secret (for signature verification)
     *
     * 用于生成 HMAC 签名，验证消息来源。
     * Used to generate HMAC signature for message verification.
     */
    secret?: string;

    /**
     * 状态
     * Status
     */
    status: WebhookStatus;

    /**
     * 自定义请求头
     * Custom headers
     *
     * 发送 Webhook 请求时附加的自定义头。
     * Custom headers to include in webhook requests.
     */
    headers?: Record<string>;

    /**
     * 超时时间（秒）
     * Timeout in seconds
     */
    timeout?: int32;

    /**
     * 最大重试次数
     * Max retry attempts
     */
    maxRetries?: int32;

    /**
     * 重试间隔（秒）
     * Retry interval in seconds
     */
    retryInterval?: int32;

    /**
     * 创建时间
     * Created at
     */
    createdAt?: string;

    /**
     * 创建人
     * Created by
     */
    createdBy?: NexusBook.Api.Common.UserRef;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt?: string;

    /**
     * 最后触发时间
     * Last triggered at
     */
    lastTriggeredAt?: string;

    /**
     * 触发次数
     * Trigger count
     */
    triggerCount?: int64;

    /**
     * 失败次数
     * Failure count
     */
    failureCount?: int64;
}

/**
 * Webhook 事件载荷
 * Webhook event payload
 */
model WebhookEvent {
    /**
     * 事件类型
     * Event type
     */
    event: WebhookEventType;

    /**
     * 事件时间戳
     * Event timestamp
     */
    timestamp: string;

    /**
     * Webhook ID
     * Webhook id
     */
    webhookId: string;

    /**
     * 投递 ID（唯一标识一次投递）
     * Delivery id (unique identifier for this delivery)
     */
    deliveryId: string;

    /**
     * 文档类型
     * Document type
     */
    docType?: string;

    /**
     * 文档 ID
     * Document id
     */
    docId?: string;

    /**
     * 触发用户
     * Triggered by user
     */
    triggeredBy?: string;

    /**
     * 事件载荷
     * Event payload
     *
     * 包含事件相关的详细数据。
     * Contains detailed data related to the event.
     */
    payload: unknown;
}

/**
 * Webhook 投递记录
 * Webhook delivery record
 */
model WebhookDelivery {
    /**
     * 投递 ID
     * Delivery id
     */
    id: string;

    /**
     * Webhook ID
     * Webhook id
     */
    webhookId: string;

    /**
     * 事件类型
     * Event type
     */
    event: WebhookEventType;

    /**
     * 投递状态
     * Delivery status
     */
    status: "pending" | "success" | "failed" | "retrying";

    /**
     * 请求 URL
     * Request URL
     */
    url: string;

    /**
     * 请求体
     * Request body
     */
    requestBody?: unknown;

    /**
     * 响应状态码
     * Response status code
     */
    responseStatus?: int32;

    /**
     * 响应体
     * Response body
     */
    responseBody?: string;

    /**
     * 错误信息
     * Error message
     */
    error?: string;

    /**
     * 重试次数
     * Retry count
     */
    retryCount?: int32;

    /**
     * 投递时间
     * Delivered at
     */
    deliveredAt?: string;

    /**
     * 响应时间（毫秒）
     * Response time in milliseconds
     */
    responseTime?: int64;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;
}

/**
 * Webhook 测试请求
 * Webhook test request
 */
model WebhookTestRequest {
    /**
     * 测试事件类型
     * Test event type
     */
    event: WebhookEventType;

    /**
     * 测试载荷
     * Test payload
     */
    payload?: unknown;
}

@route("/webhooks")
@tag("Webhooks")
interface WebhooksApi {
    /**
     * 列出所有 Webhook
     *
     * List all webhooks
     *
     * 返回当前用户/租户的所有 Webhook 配置。
     * Returns all webhook configurations for current user/tenant.
     */
    @get
    @summary("列出 Webhooks")
    listWebhooks(
        @query status?: WebhookStatus,
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<Webhook>>;

    /**
     * 创建 Webhook
     *
     * Create webhook
     *
     * 创建新的 Webhook 订阅。
     * Create a new webhook subscription.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/webhooks' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "Request Merged Notification",
     *     "url": "https://example.com/webhooks/nexusbook",
     *     "events": ["request_merged", "approval_approved"],
     *     "filters": {
     *       "docTypes": ["product", "inventory"]
     *     }
     *   }'
     * ```
     */
    @post
    @summary("创建 Webhook")
    createWebhook(
        @body body: Webhook,
    ): NexusBook.Api.Common.ApiResponse<Webhook>;

    /**
     * 获取 Webhook 详情
     *
     * Get webhook detail
     */
    @route("/{webhookId}")
    @get
    @summary("获取 Webhook 详情")
    getWebhook(
        @path webhookId: string,
    ): NexusBook.Api.Common.ApiResponse<Webhook>;

    /**
     * 更新 Webhook
     *
     * Update webhook
     */
    @route("/{webhookId}")
    @put
    @summary("更新 Webhook")
    updateWebhook(
        @path webhookId: string,
        @body body: Webhook,
    ): NexusBook.Api.Common.ApiResponse<Webhook>;

    /**
     * 删除 Webhook
     *
     * Delete webhook
     */
    @route("/{webhookId}")
    @delete
    @summary("删除 Webhook")
    deleteWebhook(
        @path webhookId: string,
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 暂停 Webhook
     *
     * Pause webhook
     *
     * 暂停 Webhook，停止发送事件通知。
     * Pause webhook to stop sending event notifications.
     */
    @route("/{webhookId}/pause")
    @post
    @summary("暂停 Webhook")
    pauseWebhook(
        @path webhookId: string,
    ): NexusBook.Api.Common.ApiResponse<Webhook>;

    /**
     * 恢复 Webhook
     *
     * Resume webhook
     *
     * 恢复已暂停的 Webhook。
     * Resume a paused webhook.
     */
    @route("/{webhookId}/resume")
    @post
    @summary("恢复 Webhook")
    resumeWebhook(
        @path webhookId: string,
    ): NexusBook.Api.Common.ApiResponse<Webhook>;

    /**
     * 测试 Webhook
     *
     * Test webhook
     *
     * 发送测试事件到 Webhook URL，验证配置是否正确。
     * Send a test event to webhook URL to verify configuration.
     */
    @route("/{webhookId}/test")
    @post
    @summary("测试 Webhook")
    testWebhook(
        @path webhookId: string,
        @body body?: WebhookTestRequest,
    ): NexusBook.Api.Common.ApiResponse<WebhookDelivery>;

    /**
     * 重新生成密钥
     *
     * Regenerate secret
     *
     * 重新生成 Webhook 签名密钥。
     * Regenerate webhook signature secret.
     */
    @route("/{webhookId}/regenerate-secret")
    @post
    @summary("重新生成密钥")
    regenerateSecret(
        @path webhookId: string,
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 新密钥
         * New secret
         */
        secret: string;
    }>;

    /**
     * 获取投递历史
     *
     * Get delivery history
     *
     * 查看 Webhook 的投递记录。
     * View webhook delivery records.
     */
    @route("/{webhookId}/deliveries")
    @get
    @summary("获取投递历史")
    getDeliveries(
        @path webhookId: string,
        @query status?: "pending" | "success" | "failed" | "retrying",
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<WebhookDelivery>>;

    /**
     * 获取投递详情
     *
     * Get delivery detail
     */
    @route("/{webhookId}/deliveries/{deliveryId}")
    @get
    @summary("获取投递详情")
    getDelivery(
        @path webhookId: string,
        @path deliveryId: string,
    ): NexusBook.Api.Common.ApiResponse<WebhookDelivery>;

    /**
     * 重新投递
     *
     * Redeliver
     *
     * 重新发送失败的 Webhook 事件。
     * Resend a failed webhook event.
     */
    @route("/{webhookId}/deliveries/{deliveryId}/redeliver")
    @post
    @summary("重新投递")
    redeliverWebhook(
        @path webhookId: string,
        @path deliveryId: string,
    ): NexusBook.Api.Common.ApiResponse<WebhookDelivery>;

    /**
     * 获取 Webhook 统计
     *
     * Get webhook statistics
     *
     * 获取 Webhook 的统计信息（成功率、失败率等）。
     * Get webhook statistics (success rate, failure rate, etc).
     */
    @route("/{webhookId}/stats")
    @get
    @summary("获取统计信息")
    getWebhookStats(
        @path webhookId: string,
        @query startDate?: string,
        @query endDate?: string,
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 总触发次数
         * Total triggers
         */
        totalTriggers: int64;

        /**
         * 成功次数
         * Successful deliveries
         */
        successCount: int64;

        /**
         * 失败次数
         * Failed deliveries
         */
        failureCount: int64;

        /**
         * 成功率
         * Success rate
         */
        successRate: float64;

        /**
         * 平均响应时间（毫秒）
         * Average response time in milliseconds
         */
        avgResponseTime: float64;

        /**
         * 最后成功时间
         * Last success at
         */
        lastSuccessAt?: string;

        /**
         * 最后失败时间
         * Last failure at
         */
        lastFailureAt?: string;
    }>;
}
