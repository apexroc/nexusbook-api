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
 * ## 变更工作流
 *
 * 所有属性修改操作都会：
 * 1. 创建或追加到一个变更请求（Request）
 * 2. 多人可以协同编辑同一个 Request
 * 3. 通过审批流程后，Request 合并才真正生效
 * 4. 生效后创建修订记录（Revision）
 *
 * ## 批量更新属性
 *
 * 建议使用统一的批量更新接口 `POST /doc/{docType}/{docId}/data/bulk`：
 *
 * ```bash
 * # 修改单个属性
 * curl -X POST '.../data/bulk?requestId=req-1' -d '[
 *   {"target": {"property": "amount"}, "value": 5000.00}
 * ]'
 *
 * # 修改多个属性
 * curl -X POST '.../data/bulk?requestId=req-1' -d '[
 *   {
 *     "target": {"properties": true},
 *     "value": {"amount": 5000.00, "quantity": 100, "date": "2024-12-05"}
 *   }
 * ]'
 *
 * # 混合更新（数据 + 属性）
 * curl -X POST '.../data/bulk?requestId=req-1' -d '[
 *   {"target": {"row": "row-1", "field": "price"}, "value": 99.99},
 *   {"target": {"property": "amount"}, "value": 5000.00}
 * ]'
 * ```
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
 *   "properties": [
 *     {"fieldId": "orderTime", "value": {"datetime": "2024-12-01T10:00:00Z"}},
 *     {"fieldId": "store", "value": {"text": "Beijing Branch"}},
 *     {"fieldId": "amount", "value": {"currency": 5000.00}},
 *     {"fieldId": "quantity", "value": {"number": 50}},
 *     {"fieldId": "status", "value": {"single_select": {"id": "pending", "label": "待处理"}}}
 *   ],
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
     * 所属组织ID
     * Organization ID
     *
     * 文档所属的组织（可选，用于多租户隔离）。
     * Organization that owns this document (optional, for multi-tenancy isolation).
     */
    organizationId?: string;

    /**
     * 所属工作区ID
     * Workspace ID
     *
     * 文档所属的工作区（可选，为空表示组织级文档）。
     * Workspace that owns this document (optional, empty means organization-level document).
     */
    workspaceId?: string;

    /**
     * 属性值集合
     * Property values
     *
     * 使用类型化的值结构，与数据行的 cell 值设计一致。
     * Uses typed value structure, consistent with data row cell values.
     *
     * 每个属性都有字段ID和对应的类型化值。
     * Each property has a field ID and corresponding typed value.
     *
     * 示例:
     * ```json
     * [
     *   {"fieldId": "orderTime", "value": {"datetime": "2024-12-01T10:00:00Z"}},
     *   {"fieldId": "store", "value": {"text": "Beijing Branch"}},
     *   {"fieldId": "amount", "value": {"currency": 5000.00}},
     *   {"fieldId": "quantity", "value": {"number": 50}},
     *   {"fieldId": "coverImage", "value": {"attachment": [{"id": "att-123", "fileName": "cover.jpg", ...}]}}
     * ]
     * ```
     */
    properties?: NexusBook.Common.ValueEntry[];

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
@tag("Document - Properties")
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
     * 完全替换文档属性（进入变更请求）
     *
     * Replace document properties completely (goes into change request)
     *
     * 用新的属性集合完全替换现有属性。变更会添加到指定的变更请求中。
     * Replace existing properties with a new set. Changes will be added to the specified change request.
     *
     * - 如果指定 `requestId`，追加到该请求
     * - 如果不指定，创建新的请求或追加到默认请求
     * - 需要提供版本号以确保并发安全
     * - 请求合并后才真正生效
     *
     * 示例（cURL）:
     * ```bash
     * curl -X PUT 'https://open.nexusbook.com/api/v1/doc/purchaseOrder/order-123/properties?requestId=req-1' \\
     *   -H 'Authorization: Bearer TOKEN' \\
     *   -H 'Content-Type: application/json' \\
     *   -d '{
     *     "id": "prop-123",
     *     "docId": "order-123",
     *     "docType": "purchaseOrder",
     *     "version": 1,
     *     "properties": [
     *       {"fieldId": "orderTime", "value": {"datetime": "2024-12-01T10:00:00Z"}},
     *       {"fieldId": "store", "value": {"text": "Beijing Branch"}},
     *       {"fieldId": "amount", "value": {"currency": 5000.00}},
     *       {"fieldId": "quantity", "value": {"number": 50}}
     *     ]
     *   }'
     * ```
     */
    @put
    @summary("替换文档属性")
    replaceProperties(
        @path docType: string,
        @path docId: string,
        @body body: DocumentProperties,
        @query requestId?: string,
    ): NexusBook.Common.ApiResponse<Request>;

    /**
     * 部分更新文档属性（进入变更请求）
     *
     * Partially update document properties (goes into change request)
     *
     * 仅更新指定的属性字段，保留其他字段。变更会添加到指定的变更请求中。
     * Update only specified property fields, preserve others. Changes will be added to the specified change request.
     *
     * 简化提交方式：
     * - 只需指定字段ID和原始值
     * - 服务端根据 metadata 自动解析值类型
     * - 无需客户端了解字段类型细节
     *
     * Simplified submission:
     * - Only specify field id and raw value
     * - Server auto-parses value type based on metadata
     * - No need for client to know field type details
     *
     * 查询参数:
     * - `requestId` - 指定要追加到的请求ID（可选）
     * - `merge=true` - 合并模式（默认）：新值与现有值合并
     * - `merge=false` - 覆盖模式：新值覆盖现有值
     * - `version` - 当前版本号（用于并发检查）
     *
     * Query parameters:
     * - `requestId` - Specify which request to append to (optional)
     * - `merge=true` - Merge mode (default): merge new values with existing
     * - `merge=false` - Overwrite mode: new values override existing
     * - `version` - Current version number (for concurrency check)
     *
     * 示例（cURL）- 仅更新订单金额和数量：
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.com/api/v1/doc/purchaseOrder/order-123/properties?requestId=req-1&merge=true&version=1' \\
     *   -H 'Authorization: Bearer TOKEN' \\
     *   -H 'Content-Type: application/json' \\
     *   -d '{
     *     "updates": [
     *       {"fieldId": "amount", "value": 6000.00},
     *       {"fieldId": "quantity", "value": 60}
     *     ]
     *   }'
     * ```
     *
     * 服务端处理逻辑：
     * 1. 根据 docId 获取 metadata
     * 2. 对每个 fieldId，查找字段定义获取类型
     * 3. 将原始值转换为类型化值
     * 4. 验证值的有效性
     * 5. 添加到指定的 Request
     *
     * Server processing:
     * 1. Get metadata by docId
     * 2. For each fieldId, lookup field definition to get type
     * 3. Convert raw value to typed value
     * 4. Validate value
     * 5. Add to specified Request
     */
    @patch(#{ implicitOptionality: true })
    @summary("部分更新文档属性")
    updateProperties(
        @path docType: string,
        @path docId: string,
        @body body: {
            /**
             * 要更新的属性值数组（简化格式）
             * Property values to update (simplified format)
             *
             * 直接提供 fieldId 和原始值，服务端根据 metadata 自动解析类型。
             * Provide fieldId and raw value directly, server auto-parses type based on metadata.
             */
            updates?: {
                /**
                 * 字段ID
                 * Field id
                 */
                fieldId: string;

                /**
                 * 新值（原始格式）
                 * New value (raw format)
                 */
                value: unknown;
            }[];

            /**
             * 更新说明
             * Update note
             */
            note?: string;
        },
        @query requestId?: string,
        @query merge?: boolean,
        @query version?: int64,
    ): NexusBook.Common.ApiResponse<Request>;

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
         * 属性值快照
         * Properties snapshot
         */
        properties: NexusBook.Common.ValueEntry[];

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
