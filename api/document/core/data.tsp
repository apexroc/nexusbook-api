import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";
import "../workflow/requests.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 数据行模块
 *
 * 管理文档中的结构化数据行，包括字段值、审计信息和版本控制。
 *
 * 主要功能：
 * - **行管理** - 创建、读取、更新、删除数据行
 * - **批量操作** - 批量创建/更新/删除多行数据
 * - **查询** - 支持简单分页和复杂结构化查询
 * - **版本控制** - 通过版本号实现乐观锁并发控制
 * - **变更请求** - 默认生成合并请求，支持直接应用
 *
 * ## 数据行结构
 *
 * ```json
 * {
 *   "id": "row-123",
 *   "values": [
 *     {"fieldId": "name", "value": {"text": "产品名称"}},
 *     {"fieldId": "price", "value": {"number": 99.99}}
 *   ],
 *   "createdAt": "2024-01-01T00:00:00Z",
 *   "createdBy": "user-1",
 *   "version": 1
 * }
 * ```
 *
 * ## 并发控制
 *
 * 更新行时需要提供当前版本号，系统使用乐观锁防止并发冲突。
 */
namespace NexusBook.Api;

/**
 * 数据行（包含字段值与审计信息）
 * Data row with field values and audit info
 *
 * 数据行包含字段值集合与审计信息（创建/更新/版本）。
 * Data row contains field values and audit info (created/updated/version).
 */
model Row {
    /**
     * 行ID
     * Row id
     *
     * 数据行唯一标识。
     * Unique identifier of the row.
     */
    id: string;

    /**
     * 字段值集合
     * Field values
     *
     * 字段ID与值的集合。
     * Collection of field ids and values.
     */
    values: NexusBook.Common.ValueEntry[];

    /**
     * 创建时间
     * Created at
     *
     * 创建时间戳。
     * Created timestamp.
     */
    createdAt?: string;

    /**
     * 创建人
     * Created by
     *
     * 创建者。
     * Author.
     */
    createdBy?: string;

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
     * 更新者。
     * Updater.
     */
    updatedBy?: string;

    /**
     * 版本（并发控制）
     * Version
     *
     * 版本号用于并发控制。
     * Version number for concurrency control.
     */
    version?: int64;
}

/// 结构化查询请求
/// Structured query request
/**
 * 包含过滤、排序、分组与分页参数，用于复杂查询。
 * Contains filters, sorts, group and pagination for complex queries.
 */
model QueryRequest {
    /**
     * 过滤
     * Filters
     *
     * 嵌套过滤组合。
     * Nested filter groups.
     */
    filters?: NexusBook.Common.FilterGroup;

    /**
     * 排序
     * Sorts
     *
     * 排序条件集合。
     * Sort conditions.
     */
    sorts?: NexusBook.Common.Sort[];

    /**
     * 分组与聚合
     * Group and aggregations
     *
     * 分组字段与聚合函数。
     * Group fields and aggregation functions.
     */
    group?: NexusBook.Common.GroupBy;

    /**
     * 页码
     * Page number
     *
     * 页码（默认1）。
     * Page number (default 1).
     */
    page?: int32;

    /**
     * 每页数量
     * Page size
     *
     * 每页数量（默认20，最大200）。
     * Page size (default 20, max 200).
     */
    pageSize?: int32;

    /**
     * 游标
     * Cursor
     *
     * 游标用于深分页。
     * Cursor for deep pagination.
     */
    cursor?: string;
}

@route("/doc/{docType}/{docId}/data")
@tag("Document - Data")
interface DataApi {
    /**
     * 以分页返回数据行，支持简单 DSL 查询参数（`page/pageSize/sort/filter/group/cursor`）。
     *
     * List rows with pagination, supports simple DSL query parameters
     * (`page/pageSize/sort/filter/group/cursor`).
     */
    @get
    @summary("列出数据")
    listRows(
        @path docType: string,
        @path docId: string,
        @query page?: int32,
        @query pageSize?: int32,
        @query sort?: string,
        @query filter?: string,
        @query group?: string,
        @query cursor?: string,
    ): NexusBook.Common.ApiResponse<NexusBook.Common.Page<Row>>;

    /**
     * 以结构化体进行复杂查询（嵌套过滤、排序、分组与聚合）。
     *
     * Perform complex query with structured body (nested filters, sorts, group/aggregations).
     */
    @route("/query")
    @post
    @summary("结构化查询数据")
    queryRows(
        @path docType: string,
        @path docId: string,
        @body body: QueryRequest,
    ): NexusBook.Common.ApiResponse<NexusBook.Common.Page<Row>>;

    /**
     * 默认生成合并请求，可用 `apply=true` 直接应用。
     *
     * Generates a merge-request by default, use `apply=true` to apply directly.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/doc/product/123/data?apply=true' \\
     *   -H 'Authorization: Bearer TOKEN' \\
     *   -H 'Content-Type: application/json' \\
     *   -d '{"id":"row-1","values":[{"fieldId":"name","value":{"text":"新产品"}}]}'
     * ```
     */
    @post
    @summary("创建数据行")
    createRow(
        @path docType: string,
        @path docId: string,
        @body body: Row,
        @query apply?: boolean,
    ): NexusBook.Common.ApiResponse<Request>;

    /**
     * 批量创建/更新/删除，默认生成合并请求，可用 `apply=true` 直接应用。
     *
     * Bulk create/update/delete, MR by default, use `apply=true` to apply directly.
     */
    @route("/bulk")
    @post
    @summary("批量操作数据")
    bulkRows(
        @path docType: string,
        @path docId: string,
        @body body: Row[],
        @query apply?: boolean,
    ): NexusBook.Common.ApiResponse<Request>;

    /**
     * 返回单条数据行详情。
     *
     * Return single row detail.
     */
    @route("/{rowId}")
    @get
    @summary("获取单行详情")
    getRow(
        @path docType: string,
        @path docId: string,
        @path rowId: string,
    ): NexusBook.Common.ApiResponse<Row>;

    /**
     * 默认生成合并请求，可用 `apply=true` 直接应用。
     *
     * Generates a merge-request by default, use `apply=true` to apply directly.
     */
    @route("/{rowId}")
    @put
    @summary("更新数据行")
    updateRow(
        @path docType: string,
        @path docId: string,
        @path rowId: string,
        @body body: Row,
        @query apply?: boolean,
    ): NexusBook.Common.ApiResponse<Request>;

    /**
     * 默认生成合并请求，可用 `apply=true` 直接应用。
     *
     * Generates a merge-request by default, use `apply=true` to apply directly.
     */
    @route("/{rowId}")
    @delete
    @summary("删除数据行")
    deleteRow(
        @path docType: string,
        @path docId: string,
        @path rowId: string,
        @query apply?: boolean,
    ): NexusBook.Common.ApiResponse<Request>;
}
