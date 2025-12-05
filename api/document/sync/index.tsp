import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 数据同步模块 (Data Sync)
 *
 * 提供与外部数据源的双向同步功能，支持定时同步、冲突处理等。
 * Provides bidirectional synchronization with external data sources, supports scheduled sync, conflict resolution, etc.
 *
 * ## 核心功能
 *
 * - **多数据源支持** - Google Sheets、CSV、API、数据库等
 * - **双向同步** - 支持单向和双向数据同步
 * - **冲突处理** - 智能冲突检测和解决策略
 * - **定时同步** - 基于 Cron 表达式的定时任务
 * - **增量同步** - 仅同步变更数据，提高效率
 * - **同步历史** - 完整的同步记录和审计日志
 *
 * ## 使用场景
 *
 * - **数据导入** - 从 Google Sheets 导入产品数据
 * - **数据导出** - 导出订单数据到 ERP 系统
 * - **实时同步** - 与外部 API 保持数据一致
 * - **数据备份** - 定期备份数据到云存储
 *
 * ## 示例
 *
 * ### 创建同步配置
 * ```bash
 * curl -X POST 'https://open.nexusbook.com/api/v1/doc/product/123/sync' \
 *   -H 'Authorization: Bearer TOKEN' \
 *   -d '{
 *     "name": "Sync from Google Sheets",
 *     "sourceType": "google_sheets",
 *     "sourceConfig": {
 *       "spreadsheetId": "abc123",
 *       "sheetName": "Products"
 *     },
 *     "syncMode": "one_way",
 *     "schedule": "0 * /6 * * *"
 *   }'
 * ```
 */
namespace NexusBook.Api;

/**
 * 同步源类型
 * Sync source type
 */
enum SyncSourceType {
    /**
     * Google Sheets
     */
    google_sheets,

    /**
     * Microsoft Excel Online
     */
    excel_online,

    /**
     * CSV 文件
     * CSV file
     */
    csv,

    /**
     * JSON API
     */
    json_api,

    /**
     * REST API
     */
    rest_api,

    /**
     * GraphQL API
     */
    graphql_api,

    /**
     * 数据库 (MySQL, PostgreSQL, etc.)
     * Database
     */
    database,

    /**
     * Webhook
     */
    webhook,

    /**
     * Airtable
     */
    airtable,

    /**
     * Notion
     */
    notion,
}

/**
 * 同步模式
 * Sync mode
 */
enum SyncMode {
    /**
     * 单向同步（仅导入）
     * One-way (import only)
     */
    one_way_import,

    /**
     * 单向同步（仅导出）
     * One-way (export only)
     */
    one_way_export,

    /**
     * 双向同步
     * Two-way
     */
    two_way,
}

/**
 * 冲突解决策略
 * Conflict resolution strategy
 */
enum ConflictResolution {
    /**
     * 保留本地
     * Keep local
     */
    keep_local,

    /**
     * 保留远程
     * Keep remote
     */
    keep_remote,

    /**
     * 询问用户
     * Ask user
     */
    ask_user,

    /**
     * 最新修改胜出
     * Latest modification wins
     */
    latest_wins,

    /**
     * 合并
     * Merge
     */
    merge,
}

/**
 * 同步状态
 * Sync status
 */
enum SyncTaskStatus {
    /**
     * 待执行
     * Pending
     */
    pending,

    /**
     * 执行中
     * Running
     */
    running,

    /**
     * 已完成
     * Completed
     */
    completed,

    /**
     * 失败
     * Failed
     */
    failed,

    /**
     * 已取消
     * Cancelled
     */
    cancelled,

    /**
     * 部分成功
     * Partial success
     */
    partial,
}

/**
 * 同步配置
 * Sync configuration
 */
model SyncConfig {
    /**
     * 配置ID
     * Config id
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
     * 数据源类型
     * Source type
     */
    sourceType: SyncSourceType;

    /**
     * 数据源配置
     * Source configuration
     *
     * 根据 sourceType 不同，配置内容不同。
     * Configuration varies by sourceType.
     */
    sourceConfig: unknown;

    /**
     * 同步模式
     * Sync mode
     */
    syncMode: SyncMode;

    /**
     * 字段映射
     * Field mapping
     *
     * 本地字段 -> 远程字段的映射。
     * Local field -> Remote field mapping.
     */
    fieldMapping?: {
        /**
         * 本地字段ID
         * Local field id
         */
        localFieldId: string;

        /**
         * 远程字段名称
         * Remote field name
         */
        remoteFieldName: string;

        /**
         * 类型转换
         * Type conversion
         */
        typeConversion?: string;
    }[];

    /**
     * 同步过滤器
     * Sync filters
     *
     * 仅同步符合条件的数据。
     * Only sync data matching conditions.
     */
    filters?: NexusBook.Common.FilterGroup;

    /**
     * 冲突解决策略
     * Conflict resolution
     */
    conflictResolution?: ConflictResolution;

    /**
     * 定时任务（Cron 表达式）
     * Schedule (Cron expression)
     *
     * 示例：
     * - "0 * /6 * * *" - 每 6 小时一次
     * - "0 0 * * *" - 每天午夜
     * - "0 9 * * 1-5" - 工作日早上 9 点
     */
    schedule?: string;

    /**
     * 是否启用
     * Enabled
     */
    enabled?: boolean;

    /**
     * 增量同步（仅同步变更）
     * Incremental sync
     */
    incremental?: boolean;

    /**
     * 最后同步时间
     * Last synced at
     */
    lastSyncedAt?: string;

    /**
     * 下次同步时间
     * Next sync at
     */
    nextSyncAt?: string;

    /**
     * 创建时间
     * Created at
     */
    createdAt?: string;

    /**
     * 创建人
     * Created by
     */
    createdBy?: string;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt?: string;
}

/**
 * 同步任务
 * Sync task
 */
model SyncTask {
    /**
     * 任务ID
     * Task id
     */
    id: string;

    /**
     * 配置ID
     * Config id
     */
    configId: string;

    /**
     * 任务状态
     * Status
     */
    status: SyncTaskStatus;

    /**
     * 同步方向
     * Sync direction
     */
    direction?: "import" | "export" | "bidirectional";

    /**
     * 开始时间
     * Started at
     */
    startedAt?: string;

    /**
     * 完成时间
     * Completed at
     */
    completedAt?: string;

    /**
     * 处理记录数
     * Records processed
     */
    recordsProcessed?: int32;

    /**
     * 成功记录数
     * Records succeeded
     */
    recordsSucceeded?: int32;

    /**
     * 失败记录数
     * Records failed
     */
    recordsFailed?: int32;

    /**
     * 创建记录数
     * Records created
     */
    recordsCreated?: int32;

    /**
     * 更新记录数
     * Records updated
     */
    recordsUpdated?: int32;

    /**
     * 删除记录数
     * Records deleted
     */
    recordsDeleted?: int32;

    /**
     * 冲突记录数
     * Records conflicted
     */
    recordsConflicted?: int32;

    /**
     * 错误信息
     * Error message
     */
    errorMessage?: string;

    /**
     * 错误详情
     * Error details
     */
    errorDetails?: unknown;

    /**
     * 日志
     * Logs
     */
    logs?: string[];

    /**
     * 触发方式
     * Triggered by
     */
    triggeredBy?: "manual" | "schedule" | "webhook" | "api";

    /**
     * 触发用户
     * Triggered user
     */
    triggeredUser?: string;
}

/**
 * 同步冲突
 * Sync conflict
 */
model SyncConflict {
    /**
     * 冲突ID
     * Conflict id
     */
    id: string;

    /**
     * 任务ID
     * Task id
     */
    taskId: string;

    /**
     * 行ID
     * Row id
     */
    rowId?: string;

    /**
     * 字段ID
     * Field id
     */
    fieldId?: string;

    /**
     * 本地值
     * Local value
     */
    localValue?: unknown;

    /**
     * 远程值
     * Remote value
     */
    remoteValue?: unknown;

    /**
     * 本地修改时间
     * Local modified at
     */
    localModifiedAt?: string;

    /**
     * 远程修改时间
     * Remote modified at
     */
    remoteModifiedAt?: string;

    /**
     * 冲突解决方案
     * Resolution
     */
    resolution?: ConflictResolution;

    /**
     * 已解决
     * Resolved
     */
    resolved?: boolean;

    /**
     * 解决人
     * Resolved by
     */
    resolvedBy?: string;

    /**
     * 解决时间
     * Resolved at
     */
    resolvedAt?: string;

    /**
     * 创建时间
     * Created at
     */
    createdAt?: string;
}

@route("/doc/{docType}/{docId}/sync")
@tag("Document")
interface SyncApi {
    /**
     * 列出同步配置
     *
     * List sync configurations
     *
     * 返回文档的所有同步配置。
     * Return all sync configurations of the document.
     */
    @get
    @summary("列出同步配置")
    listSyncConfigs(
        @path docType: string,
        @path docId: string,
    ): NexusBook.Common.ApiResponse<SyncConfig[]>;

    /**
     * 创建同步配置
     *
     * Create sync configuration
     *
     * 创建新的数据同步配置。
     * Create new data sync configuration.
     */
    @post
    @summary("创建同步配置")
    createSyncConfig(
        @path docType: string,
        @path docId: string,
        @body body: SyncConfig,
    ): NexusBook.Common.ApiResponse<SyncConfig>;

    /**
     * 获取同步配置详情
     *
     * Get sync configuration
     *
     * 返回指定同步配置的详细信息。
     * Return detailed information of specified sync configuration.
     */
    @route("/{configId}")
    @get
    @summary("获取同步配置")
    getSyncConfig(
        @path docType: string,
        @path docId: string,
        @path configId: string,
    ): NexusBook.Common.ApiResponse<SyncConfig>;

    /**
     * 更新同步配置
     *
     * Update sync configuration
     *
     * 更新同步配置的参数。
     * Update sync configuration parameters.
     */
    @route("/{configId}")
    @put
    @summary("更新同步配置")
    updateSyncConfig(
        @path docType: string,
        @path docId: string,
        @path configId: string,
        @body body: SyncConfig,
    ): NexusBook.Common.ApiResponse<SyncConfig>;

    /**
     * 删除同步配置
     *
     * Delete sync configuration
     *
     * 删除同步配置及其相关任务历史。
     * Delete sync configuration and its task history.
     */
    @route("/{configId}")
    @delete
    @summary("删除同步配置")
    deleteSyncConfig(
        @path docType: string,
        @path docId: string,
        @path configId: string,
    ): NexusBook.Common.ApiResponse<unknown>;

    /**
     * 手动触发同步
     *
     * Trigger sync manually
     *
     * 立即执行一次同步任务。
     * Execute sync task immediately.
     */
    @route("/{configId}/trigger")
    @post
    @summary("手动触发同步")
    triggerSync(
        @path docType: string,
        @path docId: string,
        @path configId: string,
        @body body?: {
            /**
             * 是否完全同步（忽略增量设置）
             * Full sync (ignore incremental setting)
             */
            fullSync?: boolean;

            /**
             * 是否空运行（仅检查，不实际同步）
             * Dry run (check only, don't actually sync)
             */
            dryRun?: boolean;
        },
    ): NexusBook.Common.ApiResponse<SyncTask>;

    /**
     * 获取同步任务历史
     *
     * Get sync task history
     *
     * 返回同步配置的执行历史。
     * Return execution history of sync configuration.
     */
    @route("/{configId}/tasks")
    @get
    @summary("获取同步历史")
    getSyncTasks(
        @path docType: string,
        @path docId: string,
        @path configId: string,
        @query status?: SyncTaskStatus,
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Common.ApiResponse<NexusBook.Common.Page<SyncTask>>;

    /**
     * 获取任务详情
     *
     * Get task details
     *
     * 返回同步任务的详细信息和日志。
     * Return detailed information and logs of sync task.
     */
    @route("/{configId}/tasks/{taskId}")
    @get
    @summary("获取任务详情")
    getSyncTask(
        @path docType: string,
        @path docId: string,
        @path configId: string,
        @path taskId: string,
    ): NexusBook.Common.ApiResponse<SyncTask>;

    /**
     * 取消同步任务
     *
     * Cancel sync task
     *
     * 取消正在执行的同步任务。
     * Cancel running sync task.
     */
    @route("/{configId}/tasks/{taskId}/cancel")
    @post
    @summary("取消同步任务")
    cancelSyncTask(
        @path docType: string,
        @path docId: string,
        @path configId: string,
        @path taskId: string,
    ): NexusBook.Common.ApiResponse<SyncTask>;

    /**
     * 获取同步冲突
     *
     * Get sync conflicts
     *
     * 返回需要手动解决的同步冲突。
     * Return sync conflicts that need manual resolution.
     */
    @route("/{configId}/conflicts")
    @get
    @summary("获取同步冲突")
    getSyncConflicts(
        @path docType: string,
        @path docId: string,
        @path configId: string,
        @query resolved?: boolean,
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Common.ApiResponse<NexusBook.Common.Page<SyncConflict>>;

    /**
     * 解决同步冲突
     *
     * Resolve sync conflict
     *
     * 手动解决同步冲突。
     * Manually resolve sync conflict.
     */
    @route("/{configId}/conflicts/{conflictId}/resolve")
    @post
    @summary("解决冲突")
    resolveSyncConflict(
        @path docType: string,
        @path docId: string,
        @path configId: string,
        @path conflictId: string,
        @body body: {
            /**
             * 解决策略
             * Resolution strategy
             */
            resolution: ConflictResolution;

            /**
             * 自定义值（当选择合并时）
             * Custom value (when merge is selected)
             */
            customValue?: unknown;
        },
    ): NexusBook.Common.ApiResponse<SyncConflict>;

    /**
     * 测试同步连接
     *
     * Test sync connection
     *
     * 测试与数据源的连接是否正常。
     * Test if connection to data source is working.
     */
    @route("/test-connection")
    @post
    @summary("测试连接")
    testSyncConnection(
        @path docType: string,
        @path docId: string,
        @body body: {
            sourceType: SyncSourceType;
            sourceConfig: unknown;
        },
    ): NexusBook.Common.ApiResponse<{
        /**
         * 是否成功
         * Success
         */
        success: boolean;

        /**
         * 消息
         * Message
         */
        message?: string;

        /**
         * 检测到的字段
         * Detected fields
         */
        detectedFields?: {
            name: string;
            type: string;
        }[];
    }>;
}
