import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";
import "./models.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * Connector API 接口
 * Connector API Interface
 *
 * 提供组织内部文档联动管理功能。
 * Provides intra-organization document linkage management.
 */
namespace NexusBook.Api.Document.Connector;

@tag("Connector")
interface ConnectorApi {
    /**
     * 创建 Connector
     * Create connector
     *
     * 在组织内创建文档之间的联动关系。需要有源文档和目标文档的访问权限。
     * Create linkage between documents within organization. Requires access to both source and target documents.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-123/connectors' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "主商品库到分店商品库",
     *     "connectorType": "catalog_clone",
     *     "sourceDocId": "catalog-main-001",
     *     "targetDocId": "catalog-branch-001",
     *     "catalogCloneConfig": {
     *       "syncMode": "full",
     *       "syncDirection": "one_way",
     *       "linkedScope": {"mode": "all"},
     *       "localEnhancements": {
     *         "allowLocalAdd": true,
     *         "allowLocalDelete": true,
     *         "allowLocalModify": true
     *       },
     *       "conflictResolution": {"defaultStrategy": "keep_upstream"}
     *     }
     *   }'
     * ```
     */
    @post
    @route("/api/v1/organizations/{organizationId}/connectors")
    @summary("创建 Connector")
    createConnector(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 创建请求
         * Create request
         */
        @body body: CreateConnectorRequest
    ): NexusBook.Api.Common.ApiResponse<ConnectorDetails>;

    /**
     * 列出组织的 Connector
     * List organization connectors
     *
     * 获取组织下的所有 Connector 列表。
     * Get list of all connectors under organization.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/connectors?connectorType=catalog_clone&status=active' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/connectors")
    @summary("列出 Connector")
    listConnectors(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区 ID 过滤
         * Filter by workspace ID
         */
        @query workspaceId?: string,

        /**
         * Connector 类型过滤
         * Filter by connector type
         */
        @query connectorType?: ConnectorType,

        /**
         * 源文档 ID 过滤
         * Filter by source document ID
         */
        @query sourceDocId?: string,

        /**
         * 目标文档 ID 过滤
         * Filter by target document ID
         */
        @query targetDocId?: string,

        /**
         * Connector 状态过滤
         * Filter by connector status
         */
        @query status?: ConnectorStatus,

        /**
         * 搜索关键词
         * Search keyword
         */
        @query search?: string,

        /**
         * 排序字段
         * Sort field
         */
        @query sort?: string = "updatedAt",

        /**
         * 排序方向
         * Sort direction
         */
        @query direction?: NexusBook.Api.Common.Direction = NexusBook.Api.Common.Direction.desc,

        /**
         * 页码
         * Page number
         */
        @query page?: int32 = 1,

        /**
         * 每页数量
         * Page size
         */
        @query pageSize?: int32 = 20
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<ConnectorSummary>>;

    /**
     * 获取 Connector 详情
     * Get connector details
     *
     * 获取指定 Connector 的详细信息。
     * Get detailed information of specified connector.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/connectors/connector-456' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/connectors/{connectorId}")
    @summary("获取 Connector 详情")
    getConnector(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Connector ID
         * Connector ID
         */
        @path connectorId: string
    ): NexusBook.Api.Common.ApiResponse<ConnectorDetails>;

    /**
     * 更新 Connector
     * Update connector
     *
     * 更新 Connector 的配置信息。
     * Update connector configuration.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.app/api/v1/organizations/org-123/connectors/connector-456' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "status": "paused"
     *   }'
     * ```
     */
    @patch
    @route("/api/v1/organizations/{organizationId}/connectors/{connectorId}")
    @summary("更新 Connector")
    updateConnector(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Connector ID
         * Connector ID
         */
        @path connectorId: string,

        /**
         * 更新请求
         * Update request
         */
        @body body: UpdateConnectorRequest
    ): NexusBook.Api.Common.ApiResponse<ConnectorDetails>;

    /**
     * 删除 Connector
     * Delete connector
     *
     * 删除指定的 Connector。删除后,联动关系将被解除。
     * Delete specified connector. After deletion, linkage will be removed.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.app/api/v1/organizations/org-123/connectors/connector-456' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/api/v1/organizations/{organizationId}/connectors/{connectorId}")
    @summary("删除 Connector")
    deleteConnector(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Connector ID
         * Connector ID
         */
        @path connectorId: string,

        /**
         * 是否删除目标文档中的联动数据
         * Delete linked data in target document
         */
        @query deleteLinkedData?: boolean = false
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 触发 Connector 同步
     * Trigger connector sync
     *
     * 手动触发 Connector 的数据同步。
     * Manually trigger connector data synchronization.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-123/connectors/connector-456/sync' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @post
    @route("/api/v1/organizations/{organizationId}/connectors/{connectorId}/sync")
    @summary("触发同步")
    triggerSync(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Connector ID
         * Connector ID
         */
        @path connectorId: string,

        /**
         * 是否全量同步
         * Full sync
         */
        @query fullSync?: boolean = false
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 同步任务 ID
         * Sync task ID
         */
        taskId: string;

        /**
         * 同步状态
         * Sync status
         */
        status: string;

        /**
         * 开始时间
         * Started at
         */
        startedAt: string;
    }>;

    /**
     * 获取 Connector 统计信息
     * Get connector statistics
     *
     * 获取 Connector 的统计信息。
     * Get connector statistics.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/connectors/connector-456/stats' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/connectors/{connectorId}/stats")
    @summary("获取统计信息")
    getConnectorStats(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Connector ID
         * Connector ID
         */
        @path connectorId: string
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 联动行总数
         * Total linked rows
         */
        totalLinkedRows: int32;

        /**
         * 活跃联动数
         * Active links
         */
        activeLinks: int32;

        /**
         * 断开联动数
         * Broken links
         */
        brokenLinks: int32;

        /**
         * 最后同步时间
         * Last synced at
         */
        lastSyncedAt?: string;

        /**
         * 同步统计
         * Sync statistics
         */
        syncStats?: {
            /**
             * 总同步次数
             * Total syncs
             */
            totalSyncs: int32;

            /**
             * 成功次数
             * Success count
             */
            successCount: int32;

            /**
             * 失败次数
             * Failure count
             */
            failureCount: int32;
        };
    }>;

    /**
     * 列出 LinkedRow
     * List linked rows
     *
     * 获取 Connector 的所有联动行记录。
     * Get all linked row records of connector.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/connectors/connector-456/linked-rows' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/connectors/{connectorId}/linked-rows")
    @summary("列出联动行")
    listLinkedRows(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Connector ID
         * Connector ID
         */
        @path connectorId: string,

        /**
         * 联动状态过滤
         * Filter by link status
         */
        @query linkStatus?: "active" | "broken" | "paused",

        /**
         * 源行 ID 过滤
         * Filter by source row ID
         */
        @query sourceRowId?: string,

        /**
         * 目标行 ID 过滤
         * Filter by target row ID
         */
        @query targetRowId?: string,

        /**
         * 页码
         * Page number
         */
        @query page?: int32 = 1,

        /**
         * 每页数量
         * Page size
         */
        @query pageSize?: int32 = 20
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<LinkedRow>>;

    /**
     * 获取 LinkedRow 详情
     * Get linked row details
     *
     * 获取指定联动行的详细信息。
     * Get detailed information of specified linked row.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/connectors/connector-456/linked-rows/link-789' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/connectors/{connectorId}/linked-rows/{linkId}")
    @summary("获取联动行详情")
    getLinkedRow(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Connector ID
         * Connector ID
         */
        @path connectorId: string,

        /**
         * Link ID
         * Link ID
         */
        @path linkId: string
    ): NexusBook.Api.Common.ApiResponse<LinkedRow>;

    /**
     * 删除 LinkedRow
     * Delete linked row
     *
     * 删除指定的联动行记录,解除源行和目标行的联动关系。
     * Delete specified linked row record, remove linkage between source and target rows.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.app/api/v1/organizations/org-123/connectors/connector-456/linked-rows/link-789' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/api/v1/organizations/{organizationId}/connectors/{connectorId}/linked-rows/{linkId}")
    @summary("删除联动行")
    deleteLinkedRow(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Connector ID
         * Connector ID
         */
        @path connectorId: string,

        /**
         * Link ID
         * Link ID
         */
        @path linkId: string,

        /**
         * 是否删除目标行
         * Delete target row
         */
        @query deleteTargetRow?: boolean = false
    ): NexusBook.Api.Common.ApiResponse<unknown>;
}
