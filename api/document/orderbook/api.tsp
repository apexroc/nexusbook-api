import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";
import "./models.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * OrderBook API 接口
 * OrderBook API Interface
 *
 * 提供组织级别的 OrderBook 管理功能。
 * Provides organization-level OrderBook management.
 */
namespace NexusBook.Api.Document.OrderBook;

@tag("OrderBook")
interface OrderBookApi {
    /**
     * 创建 OrderBook
     * Create orderbook
     *
     * 可以基于已连接的 Connection 创建,自动生成字段定义和初始数据。
     * Can create based on connected Connections, auto-generating field definitions and initial data.
     *
     * 示例（cURL）:
     * ```bash
     * # 基于 Connection 创建
     * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-123/orderbooks' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "我的订货本",
     *     "sourceConnectionIds": ["conn-456", "conn-789"]
     *   }'
     * ```
     */
    @post
    @route("/api/v1/organizations/{organizationId}/orderbooks")
    @summary("创建 OrderBook")
    createOrderBook(
        @path organizationId: string,
        @body body: CreateOrderBookRequest
    ): NexusBook.Api.Common.ApiResponse<OrderBookDetails>;

    /**
     * 列出 OrderBook
     * List orderbooks
     */
    @get
    @route("/api/v1/organizations/{organizationId}/orderbooks")
    @summary("列出 OrderBook")
    listOrderBooks(
        @path organizationId: string,
        @query workspaceId?: string,
        @query search?: string,
        @query canShareAsCatalog?: boolean,
        @query sort?: string = "updatedAt",
        @query direction?: NexusBook.Api.Common.Direction = NexusBook.Api.Common.Direction.desc,
        @query page?: int32 = 1,
        @query pageSize?: int32 = 20
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<OrderBookSummary>>;

    /**
     * 获取 OrderBook 详情
     * Get orderbook details
     */
    @get
    @route("/api/v1/organizations/{organizationId}/orderbooks/{orderBookId}")
    @summary("获取 OrderBook 详情")
    getOrderBook(
        @path organizationId: string,
        @path orderBookId: string
    ): NexusBook.Api.Common.ApiResponse<OrderBookDetails>;

    /**
     * 更新 OrderBook
     * Update orderbook
     */
    @patch
    @route("/api/v1/organizations/{organizationId}/orderbooks/{orderBookId}")
    @summary("更新 OrderBook")
    updateOrderBook(
        @path organizationId: string,
        @path orderBookId: string,
        @body body: UpdateOrderBookRequest
    ): NexusBook.Api.Common.ApiResponse<OrderBookDetails>;

    /**
     * 删除 OrderBook
     * Delete orderbook
     */
    @delete
    @route("/api/v1/organizations/{organizationId}/orderbooks/{orderBookId}")
    @summary("删除 OrderBook")
    deleteOrderBook(
        @path organizationId: string,
        @path orderBookId: string,
        @query force?: boolean = false
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 获取 OrderBook 统计
     * Get orderbook statistics
     */
    @get
    @route("/api/v1/organizations/{organizationId}/orderbooks/{orderBookId}/stats")
    @summary("获取 OrderBook 统计")
    getOrderBookStats(
        @path organizationId: string,
        @path orderBookId: string
    ): NexusBook.Api.Common.ApiResponse<{
        totalProducts: int32;
        activeProducts: int32;
        sourceSupplierCount: int32;
        connectionCount: int32;
        activeConnectionCount: int32;
        bySource?: Record<{
            count: int32;
            percentage: float32;
        }>;
        lastUpdatedAt: string;
    }>;

    /**
     * 获取行来源信息
     * Get row source information
     */
    @get
    @route("/api/v1/organizations/{organizationId}/orderbooks/{orderBookId}/rows/{rowId}/source")
    @summary("获取行来源")
    getRowSource(
        @path organizationId: string,
        @path orderBookId: string,
        @path rowId: string
    ): NexusBook.Api.Common.ApiResponse<RowSource>;

    /**
     * 预览字段映射
     * Preview field mapping
     *
     * 根据源 Catalog 和目标 OrderBook 的字段,生成建议的字段映射规则。
     * Generate suggested field mapping rules based on source Catalog and target OrderBook fields.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-123/orderbooks/orderbook-456/field-mapping/preview' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "connectionId": "conn-789"
     *   }'
     * ```
     */
    @post
    @route("/api/v1/organizations/{organizationId}/orderbooks/{orderBookId}/field-mapping/preview")
    @summary("预览字段映射")
    previewFieldMapping(
        @path organizationId: string,
        @path orderBookId: string,
        @body body: {
            /**
             * Connection ID
             * Connection ID
             */
            connectionId: string;
        }
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 建议的字段映射规则
         * Suggested field mapping rules
         */
        suggestedMappings: NexusBook.Api.Document.Connection.FieldMappingRule[];

        /**
         * 源 Catalog 字段
         * Source catalog fields
         */
        sourceFields: {
            id: string;
            name: string;
            type: string;
        }[];

        /**
         * 目标 OrderBook 字段
         * Target orderbook fields
         */
        targetFields: {
            id: string;
            name: string;
            type: string;
        }[];

        /**
         * 未映射的源字段
         * Unmapped source fields
         */
        unmappedSourceFields: string[];

        /**
         * 未映射的目标字段
         * Unmapped target fields
         */
        unmappedTargetFields: string[];
    }>;

    /**
     * 创建 Connection Binding
     * Create connection binding
     *
     * 将 OrderBook 与 Connection 建立 Binding 关系,配置字段映射和过滤条件。
     * Establish a Binding relationship between OrderBook and Connection, configuring field mapping and filter conditions.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-123/orderbooks/orderbook-456/bindings' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "connectionId": "conn-789",
     *     "fieldMapping": {
     *       "rules": [
     *         {
     *           "sourceFieldId": "src-field-1",
     *           "targetFieldId": "tgt-field-1",
     *           "transformType": "direct"
     *         }
     *       ],
     *       "unmappedFields": "create"
     *     },
     *     "receiverFilter": {
     *       "acceptMode": "auto"
     *     }
     *   }'
     * ```
     */
    @post
    @route("/api/v1/organizations/{organizationId}/orderbooks/{orderBookId}/bindings")
    @summary("创建 Binding")
    createBinding(
        @path organizationId: string,
        @path orderBookId: string,
        @body body: NexusBook.Api.Document.Connection.CreateConnectionBindingRequest
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Document.Connection.ConnectionBindingDetails>;

    /**
     * 列出 OrderBook 的 Binding
     * List orderbook bindings
     *
     * 示例（cURL）:
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/orderbooks/orderbook-456/bindings' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/orderbooks/{orderBookId}/bindings")
    @summary("列出 Binding")
    listBindings(
        @path organizationId: string,
        @path orderBookId: string,
        @query status?: NexusBook.Api.Document.Connection.BindingStatus,
        @query page?: int32 = 1,
        @query pageSize?: int32 = 20
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<NexusBook.Api.Document.Connection.ConnectionBindingSummary>>;

    /**
     * 更新 Binding
     * Update binding
     *
     * 示例（cURL）:
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.app/api/v1/organizations/org-123/orderbooks/orderbook-456/bindings/binding-999' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "bindingStatus": "active"
     *   }'
     * ```
     */
    @patch
    @route("/api/v1/organizations/{organizationId}/orderbooks/{orderBookId}/bindings/{bindingId}")
    @summary("更新 Binding")
    updateBinding(
        @path organizationId: string,
        @path orderBookId: string,
        @path bindingId: string,
        @body body: NexusBook.Api.Document.Connection.UpdateConnectionBindingRequest
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Document.Connection.ConnectionBindingDetails>;

    /**
     * 删除 Binding
     * Delete binding
     *
     * 示例（cURL）:
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.app/api/v1/organizations/org-123/orderbooks/orderbook-456/bindings/binding-999' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/api/v1/organizations/{organizationId}/orderbooks/{orderBookId}/bindings/{bindingId}")
    @summary("删除 Binding")
    deleteBinding(
        @path organizationId: string,
        @path orderBookId: string,
        @path bindingId: string
    ): NexusBook.Api.Common.ApiResponse<unknown>;
}
