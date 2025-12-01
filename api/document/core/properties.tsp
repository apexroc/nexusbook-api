import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 文档属性模块
 *
 * 管理文档本身的元信息，如订货单的时间、门店、金额、数量等。
 *
 * Manage document-level metadata such as purchase order's timestamp, store, amount, quantity, etc.
 *
 * ## 使用场景
 *
 * - **订货单** - 订单时间、门店、总金额、总数量
 * - **发票** - 发票号、开票时间、付款期限、税率
 * - **产品** - SKU、品牌、分类、供应商
 * - **项目** - 项目名称、负责人、预算、截止日期
 * - 等等...
 *
 * ## 特点
 *
 * - **灵活存储** - 支持任意键值对，适应不同文档类型
 * - **并发安全** - 版本号保证更新的安全性
 * - **审计追踪** - 记录每次修改的人和时间
 */
namespace NexusBook.Api;

/**
 * 文档属性模型
 * Document properties model
 *
 * 用于存储文档本身的元信息，如订货单的时间、门店、金额、数量等。
 * 支持灵活的键值对存储，以适应不同文档类型的需求。
 *
 * Used to store document-level metadata, such as purchase order's timestamp, store, amount, quantity, etc.
 * Supports flexible key-value storage to accommodate different document types.
 *
 * 示例 - 订货单属性:
 * ```json
 * {
 *   "id": "prop-123",
 *   "docId": "order-456",
 *   "docType": "purchaseOrder",
 *   "properties": {
 *     "orderTime": "2024-12-01T10:00:00Z",
 *     "store": "Beijing Branch",
 *     "amount": 5000.00,
 *     "quantity": 50,
 *     "status": "pending",
 *     "notes": "Urgent delivery required"
 *   },
 *   "version": 1,
 *   "createdAt": "2024-12-01T10:00:00Z",
 *   "updatedAt": "2024-12-01T10:00:00Z",
 *   "updatedBy": "user-123"
 * }
 * ```
 */
model DocumentProperties {
    /**
     * 属性ID
     * Property id
     *
     * 唯一标识。
     * Unique identifier.
     */
    id: string;

    /**
     * 文档ID
     * Document id
     *
     * 关联的文档ID。
     * Associated document id.
     */
    docId: string;

    /**
     * 文档类型
     * Document type
     *
     * 文档类型（如 purchaseOrder、invoice、product）。
     * Document type (e.g. purchaseOrder, invoice, product).
     */
    docType: string;

    /**
     * 属性集合
     * Properties
     *
     * 灵活的键值对集合，存储文档级别的元信息。
     * Flexible key-value pairs storing document-level metadata.
     *
     * 常见属性：
     * - `orderTime` - 订单时间
     * - `store` - 门店/地点
     * - `amount` - 总金额
     * - `quantity` - 总数量
     * - `status` - 状态
     * - `notes` - 备注
     * - `priority` - 优先级
     * - `department` - 部门
     * - `project` - 项目
     * - 等等...
     *
     * Common properties:
     * - `orderTime` - Order timestamp
     * - `store` - Store/location
     * - `amount` - Total amount
     * - `quantity` - Total quantity
     * - `status` - Status
     * - `notes` - Notes
     * - `priority` - Priority
     * - `department` - Department
     * - `project` - Project
     * - etc...
     */
    properties?: unknown;

    /**
     * 版本号
     * Version
     *
     * 用于并发控制。
     * For concurrency control.
     */
    version?: int64;

    /**
     * 创建时间
     * Created at
     *
     * 创建时间戳。
     * Created timestamp.
     */
    createdAt?: string;

    /**
     * 更新时间
     * Updated at
     *
     * 更新时间戳。
     * Updated timestamp.
     */
    updatedAt?: string;

    /**
     * 更新人
     * Updated by
     *
     * 最后更新的用户。
     * User who last updated.
     */
    updatedBy?: string;
}

@route("/doc/{docType}/{docId}/properties")
@tag("Document")
interface DocumentPropertiesApi {
    /**
     * 获取文档属性
     *
     * Get document properties
     *
     * 获取文档级别的所有元信息（订单时间、门店、金额等）。
     * Get all document-level metadata (order time, store, amount, etc).
     */
    @get
    @summary("获取文档属性")
    getProperties(
        @path docType: string,
        @path docId: string,
    ): NexusBook.Common.ApiResponse<DocumentProperties>;

    /**
     * 创建或初始化文档属性
     *
     * Create or initialize document properties
     *
     * 为新文档初始化属性。通常在文档创建时调用。
     * Initialize properties for new document. Typically called when document is created.
     */
    @post
    @summary("创建文档属性")
    createProperties(
        @path docType: string,
        @path docId: string,
        @body body: DocumentProperties,
    ): NexusBook.Common.ApiResponse<DocumentProperties>;

    /**
     * 完全替换文档属性
     *
     * Replace document properties completely
     *
     * 用新的属性集合完全替换现有属性。需要提供版本号以确保并发安全。
     * Replace existing properties with a new set. Version number required for concurrency safety.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X PUT 'https://open.nexusbook.com/api/v1/doc/purchaseOrder/order-123/properties' \\
     *   -H 'Authorization: Bearer TOKEN' \\
     *   -H 'Content-Type: application/json' \\
     *   -d '{
     *     "id": "prop-123",
     *     "docId": "order-123",
     *     "docType": "purchaseOrder",
     *     "version": 1,
     *     "properties": {
     *       "orderTime": "2024-12-01T10:00:00Z",
     *       "store": "Beijing Branch",
     *       "amount": 5000.00,
     *       "quantity": 50
     *     }
     *   }'
     * ```
     */
    @put
    @summary("替换文档属性")
    replaceProperties(
        @path docType: string,
        @path docId: string,
        @body body: DocumentProperties,
    ): NexusBook.Common.ApiResponse<DocumentProperties>;

    /**
     * 部分更新文档属性
     *
     * Partially update document properties
     *
     * 仅更新指定的属性字段，保留其他字段。支持合并或覆盖策略。
     * Update only specified property fields, preserve others. Supports merge or overwrite strategy.
     *
     * 查询参数:
     * - `merge=true` - 合并模式（默认）：新值与现有值合并
     * - `merge=false` - 覆盖模式：新值覆盖现有值
     * - `version` - 当前版本号（用于并发检查）
     *
     * Query parameters:
     * - `merge=true` - Merge mode (default): merge new values with existing
     * - `merge=false` - Overwrite mode: new values override existing
     * - `version` - Current version number (for concurrency check)
     *
     * 示例（cURL）- 仅更新订单金额和数量:
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.com/api/v1/doc/purchaseOrder/order-123/properties?merge=true&version=1' \\
     *   -H 'Authorization: Bearer TOKEN' \\
     *   -H 'Content-Type: application/json' \\
     *   -d '{
     *     "properties": {
     *       "amount": 6000.00,
     *       "quantity": 60
     *     }
     *   }'
     * ```
     */
    @patch(#{ implicitOptionality: true })
    @summary("部分更新文档属性")
    updateProperties(
        @path docType: string,
        @path docId: string,
        @body body: {
            /**
             * 要更新的属性
             * Properties to update
             */
            properties?: unknown;

            /**
             * 更新说明
             * Update note
             */
            note?: string;
        },
        @query merge?: boolean,
        @query version?: int64,
    ): NexusBook.Common.ApiResponse<DocumentProperties>;

    /**
     * 获取属性的修订历史
     *
     * Get properties revision history
     *
     * 查看属性的所有历史变更记录。
     * View all historical changes of properties.
     */
    @route("/history")
    @get
    @summary("查看属性历史")
    getPropertiesHistory(
        @path docType: string,
        @path docId: string,
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Common.ApiResponse<NexusBook.Common.Page<{
        /**
         * 变更版本
         * Change version
         */
        version: int64;

        /**
         * 属性快照
         * Properties snapshot
         */
        properties: unknown;

        /**
         * 变更时间
         * Changed at
         */
        changedAt: string;

        /**
         * 变更人
         * Changed by
         */
        changedBy: string;

        /**
         * 变更说明
         * Change note
         */
        note?: string;
    }>>;

    /**
     * 删除文档属性
     *
     * Delete document properties
     *
     * 删除文档的所有属性数据。此操作无法撤销，请谨慎。
     * Delete all property data of the document. This action cannot be undone, use with caution.
     */
    @delete
    @summary("删除文档属性")
    deleteProperties(
        @path docType: string,
        @path docId: string,
        @query version?: int64,
    ): NexusBook.Common.ApiResponse<unknown>;
}
