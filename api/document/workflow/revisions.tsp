import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";
import "./requests.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 修订历史模块
 *
 * 完整的变更追踪和版本控制系统，与请求系统相关联。
 *
 * 核心特性：
 * - **完整变更记录** - 记录文档的所有增删改操作
 * - **请求关联** - 修订由合并请求生成，记录源请求 ID
 * - **多人协作** - 同一修订中的变更由多人共同更改（在请求阶段）
 * - **变更追踪** - 记录行级、字段级别的具体变更
 * - **版本对比** - 比较任意两个修订之间的差异
 * - **回滚功能** - 支持回滚到任意历史版本
 * - **审计追踪** - 完整的操作人和操作时间记录
 *
 * ## 工作流
 *
 * 1. 用户创建 Request - 提交待合并的变更
 * 2. 多人协作编辑 - 多个人在请求中不断添加/修改变更
 * 3. 评审和合并 - 评审通过后合并请求
 * 4. 生成 Revision - 合并时自动生成修订记录，包含所有变更
 * 5. 历史追踪 - 可查看修订详情、对比、回滚等
 *
 * ## 变更类型
 *
 * - `row-create` - 创建数据行
 * - `row-update` - 更新数据行
 * - `row-delete` - 删除数据行
 * - `field-create` - 添加字段
 * - `field-update` - 修改字段配置
 * - `field-delete` - 删除字段
 * - `metadata-update` - 元数据更新
 * - `settings-update` - 设置更新
 */
namespace NexusBook.Api.Document;

/**
 * 变更操作记录
 * Change operation record
 *
 * 记录单一的增删改操作。多个操作合并形成一个修订。
 * Records a single create/update/delete operation. Multiple operations form a revision.
 */
model ChangeOperation {
    /**
     * 操作ID
     * Operation id
     *
     * 变更操作的唯一标识。
     * Unique identifier of the operation.
     */
    id: string;

    /**
     * 操作类型
     * Operation type
     *
     * - "row-create" - 创建行
     * - "row-update" - 更新行
     * - "row-delete" - 删除行
     * - "field-create" - 创建字段
     * - "field-update" - 更新字段
     * - "field-delete" - 删除字段
     * - "metadata-update" - 元数据更新
     * - "settings-update" - 设置更新
     *
     * Operation types: row-create/update/delete, field-create/update/delete, etc.
     */
    type: string;

    /**
     * 变更目标
     * Change target
     *
     * 标识变更作用于哪个对象（行/字段/元数据等）。
     * Identifies what object the change applies to (row/field/metadata).
     */
    target: {
        /**
         * 目标类型
         * Target type (row/field/metadata/settings)
         */
        kind: string;

        /**
         * 行ID（当目标是行时）
         * Row id (for row operations)
         */
        rowId?: string;

        /**
         * 字段ID（当目标是字段时）
         * Field id (for field operations)
         */
        fieldId?: string;
    };

    /**
     * 旧值（更新和删除时）
     * Old value (for update and delete)
     *
     * 操作前的值，用于对比和回滚。
     * Value before operation, used for diff and revert.
     */
    oldValue?: unknown;

    /**
     * 新值（创建和更新时）
     * New value (for create and update)
     *
     * 操作后的值。
     * Value after operation.
     */
    newValue?: unknown;

    /**
     * 操作人
     * Operator
     *
     * 执行此操作的用户。
     * User who performed this operation.
     */
    operator?: string;

    /**
     * 操作时间
     * Operation timestamp
     *
     * 操作的时间戳。
     * Timestamp of the operation.
     */
    timestamp?: string;

    /**
     * 备注
     * Note
     *
     * 操作的备注说明。
     * Note about this operation.
     */
    note?: string;
}

/**
 * 修订记录
 * Revision record
 *
 * 一次完整的变更集合，通常由合并请求生成。
 * A complete set of changes, typically generated from merging a request.
 */
model Revision {
    /**
     * 修订ID
     * Revision id
     *
     * 修订的唯一标识。
     * Unique identifier of the revision.
     */
    id: string;

    /**
     * 修订版本号
     * Revision version
     *
     * 递增的版本号，用于排序和快速比较。
     * Incremental version number for sorting and quick comparison.
     */
    version: int64;

    /**
     * 源请求ID
     * Source request id
     *
     * 生成此修订的合并请求 ID。
     * The merge request ID that generated this revision.
     */
    requestId: string;

    /**
     * 修订标题
     * Revision title
     *
     * 来自源请求的标题。
     * Title from source request.
     */
    title?: string;

    /**
     * 修订描述
     * Revision description
     *
     * 来自源请求的描述。
     * Description from source request.
     */
    description?: string;

    /**
     * 主要贡献者
     * Main contributors
     *
     * 在请求中贡献变更的所有用户。
     * All users who contributed changes in the request.
     */
    contributors?: NexusBook.Api.Common.UserRef[];

    /**
     * 合并者
     * Merged by
     *
     * 执行合并操作的用户。
     * User who performed the merge.
     */
    mergedBy?: NexusBook.Api.Common.UserRef;

    /**
     * 变更操作集合
     * Change operations
     *
     * 此修订包含的所有操作，按时间顺序排列。
     * All operations in this revision, in chronological order.
     */
    changes: ChangeOperation[];

    /**
     * 变更统计
     * Change statistics
     *
     * 此修订中各类型变更的数量统计。
     * Statistics of change types in this revision.
     */
    stats?: {
        /**
         * 创建的行数
         * Rows created
         */
        rowsCreated?: int32;

        /**
         * 修改的行数
         * Rows updated
         */
        rowsUpdated?: int32;

        /**
         * 删除的行数
         * Rows deleted
         */
        rowsDeleted?: int32;

        /**
         * 创建的字段数
         * Fields created
         */
        fieldsCreated?: int32;

        /**
         * 修改的字段数
         * Fields updated
         */
        fieldsUpdated?: int32;

        /**
         * 删除的字段数
         * Fields deleted
         */
        fieldsDeleted?: int32;

        /**
         * 元数据变更数
         * Metadata changes
         */
        metadataChanges?: int32;

        /**
         * 设置变更数
         * Settings changes
         */
        settingsChanges?: int32;
    };

    /**
     * 创建时间
     * Created at
     *
     * 修订生成的时间戳。
     * Timestamp when revision was created.
     */
    createdAt?: string;

    /**
     * 更新时间
     * Updated at
     *
     * 修订最后更新的时间。
     * Timestamp when revision was last updated.
     */
    updatedAt?: string;

    /**
     * 前置修订ID
     * Previous revision id
     *
     * 此修订之前的修订 ID，用于快速链接历史。
     * ID of previous revision, for quick history linking.
     */
    previousRevisionId?: string;
}

/**
 * 修订历史 API
 * Revisions API
 *
 * 查看、对比和管理文档的修订历史。
 * View, compare, and manage document revision history.
 */
@route("/doc/{docType}/{docId}/revisions")
@tag("Document - Workflow")
interface RevisionsApi {
    /**
     * 列出文档的修订历史
     *
     * List document revisions
     *
     * 按时间逆序返回修订列表，支持分页。
     * Returns revisions in reverse chronological order, supports pagination.
     *
     * 查询参数:
     * - `page` - 页码（默认1）
     * - `pageSize` - 每页数量（默认20）
     * - `contributor` - 按贡献者过滤
     * - `search` - 按标题或描述搜索
     *
     * Query parameters:
     * - `page` - Page number (default 1)
     * - `pageSize` - Items per page (default 20)
     * - `contributor` - Filter by contributor
     * - `search` - Search by title or description
     */
    @get
    @summary("列出修订历史")
    listRevisions(
        @path docType: string,
        @path docId: string,
        @query page?: int32,
        @query pageSize?: int32,
        @query contributor?: string,
        @query search?: string,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<Revision>>;

    /**
     * 获取指定修订的完整详情
     *
     * Get revision detail
     *
     * 返回修订的完整信息，包含所有操作和统计数据。
     * Returns complete revision information including all operations and statistics.
     */
    @route("/{revId}")
    @get
    @summary("获取修订详情")
    getRevision(
        @path docType: string,
        @path docId: string,
        @path revId: string,
    ): NexusBook.Api.Common.ApiResponse<Revision>;

    /**
     * 查看修订的变更操作列表
     *
     * List operations in revision
     *
     * 分页返回修订中的所有变更操作，支持按操作类型过滤。
     * Returns all change operations in the revision, supports filtering by operation type.
     */
    @route("/{revId}/operations")
    @get
    @summary("查看修订操作列表")
    listOperations(
        @path docType: string,
        @path docId: string,
        @path revId: string,
        @query type?: string,
        @query targetKind?: string,
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<ChangeOperation>>;

    /**
     * 比较两个修订之间的差异
     *
     * Compare revisions
     *
     * 返回两个修订之间的所有差异，支持按目标类型过滤。
     * Returns all differences between two revisions, supports filtering by target type.
     *
     * 示例（cURL）:
     * ```bash
     * # 比较 rev-2 与 rev-1（base）的差异
     * curl 'https://open.nexusbook.app/api/v1/doc/product/123/revisions/rev-2/diff?base=rev-1' \\
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @route("/{revId}/diff")
    @get
    @summary("对比修订差异")
    getRevisionDiff(
        @path docType: string,
        @path docId: string,
        @path revId: string,
        @query base?: string,
        @query targetKind?: string,
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 源修订ID
         * Base revision id
         */
        baseRevisionId?: string;

        /**
         * 目标修订ID
         * Target revision id
         */
        targetRevisionId?: string;

        /**
         * 变更操作差异
         * Changed operations
         */
        changes?: ChangeOperation[];

        /**
         * 统计信息
         * Statistics
         */
        stats?: {
            added?: int32;
            modified?: int32;
            deleted?: int32;
        };
    }>;

    /**
     * 查询特定目标的变更历史
     *
     * Query change history for specific target
     *
     * 查看某个特定对象（行/字段）在所有修订中的变更历史。
     * View change history of a specific object (row/field) across all revisions.
     *
     * 示例 - 查询某行的变更历史:
     * ```bash
     * curl 'https://open.nexusbook.app/api/v1/doc/product/123/revisions/history?targetKind=row&rowId=row-1' \\
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @route("/history")
    @get
    @summary("查询变更历史")
    queryChangeHistory(
        @path docType: string,
        @path docId: string,
        @query targetKind: string,
        @query rowId?: string,
        @query fieldId?: string,
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<ChangeOperation>>;

    /**
     * 回滚到指定修订
     *
     * Revert to revision
     *
     * 将文档回滚到指定修订的状态，创建一个新的修订记录此操作。
     * Revert document to specified revision state, creates a new revision recording this action.
     *
     * 注意：回滚操作本身会生成新的修订（类型为 "revert"）。
     * Note: The revert action itself generates a new revision (type "revert").
     */
    @route("/{revId}/revert")
    @post
    @summary("回滚到指定修订")
    revertRevision(
        @path docType: string,
        @path docId: string,
        @path revId: string,
        @body body?: {
            /**
             * 回滚原因
             * Revert reason
             */
            reason?: string;

            /**
             * 选择性回滚
             * Selective revert
             *
             * 只回滚特定类型的变更（如只回滚行的变更，保留字段变更）。
             * Only revert specific types of changes (e.g., only row changes, keep field changes).
             */
            selectiveTypes?: string[];
        },
    ): NexusBook.Api.Common.ApiResponse<Revision>;

    /**
     * 获取修订的源请求
     *
     * Get source request of revision
     *
     * 获取生成此修订的原始合并请求。
     * Get the original merge request that generated this revision.
     */
    @route("/{revId}/request")
    @get
    @summary("获取源请求")
    getSourceRequest(
        @path docType: string,
        @path docId: string,
        @path revId: string,
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 导出修订数据
     *
     * Export revision
     *
     * 导出修订的完整数据为 JSON、CSV 等格式。
     * Export revision data in JSON, CSV, or other formats.
     */
    @route("/{revId}/export")
    @get
    @summary("导出修订")
    exportRevision(
        @path docType: string,
        @path docId: string,
        @path revId: string,
        @query format?: string,
    ): void;
}
