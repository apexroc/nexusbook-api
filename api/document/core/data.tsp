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
 * - **批量更新** - 批量更新指定行、指定字段的值
 * - **查询** - 支持简单分页和复杂结构化查询
 * - **版本控制** - 通过版本号实现乐观锁并发控制
 * - **变更请求工作流** - 所有修改先进入 Request，通过审批后生效
 *
 * ## 变更工作流
 *
 * 所有数据修改操作（创建、更新、删除）都会：
 * 1. 创建或追加到一个变更请求（Request）
 * 2. 多人可以协同编辑同一个 Request
 * 3. 通过审批流程后，Request 合并才真正生效
 * 4. 生效后创建修订记录（Revision）
 *
 * ## 批量更新设计
 *
 * 批量更新采用简化的数据提交方式：
 * - 客户端只需提供目标（行ID + 字段ID）和原始值
 * - 服务端根据 metadata 自动解析值的类型
 * - 无需客户端了解字段类型细节
 *
 * 示例：
 * ```json
 * [
 *   {"target": "row-1.price", "value": 99.99},
 *   {"target": "row-2.name", "value": "iPhone 15"},
 *   {"target": "row-3.date", "value": "2024-12-05"}
 * ]
 * ```
 *
 * 服务端会根据字段定义自动转换：
 * - price（currency 类型）→ {"currency": 99.99}
 * - name（text 类型）→ {"text": "iPhone 15"}
 * - date（date 类型）→ {"date": "2024-12-05"}
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
namespace NexusBook.Api.Document;

/**
 * 批量更新项
 * Bulk update entry
 *
 * 灵活的更新结构，支持多种更新场景。
 * Flexible update structure supporting multiple update scenarios.
 *
 * ## Target 结构说明
 *
 * target 是一个灵活的结构，可以指定：
 * - 行ID：`{row: "row-1"}`
 * - 行ID + 字段ID：`{row: "row-1", field: "price"}`
 * - 属性字段：`{property: "amount"}`
 * - 多个目标：`{rows: ["row-1", "row-2"], field: "status"}`
 * - 删除行：`{row: "row-1", delete: true}`
 * - 按条件更新：`{condition: {...}, field: "status"}`
 * - 按条件删除：`{condition: {...}, delete: true}`
 *
 * ## Value 说明
 *
 * value 可以是：
 * - 单个原始值：`99.99`、`"iPhone 15"`、`true`
 * - 对象（多个字段）：`{price: 99.99, name: "iPhone 15"}`
 * - 数组（批量值）：`[99.99, 88.88, 77.77]`
 *
 * ## 使用示例
 *
 * ### 1. 修改单个字段
 * ```json
 * {
 *   "target": {"row": "row-1", "field": "price"},
 *   "value": 99.99
 * }
 * ```
 *
 * ### 2. 修改整行（多个字段）
 * ```json
 * {
 *   "target": {"row": "row-1"},
 *   "value": {
 *     "price": 99.99,
 *     "name": "iPhone 15",
 *     "stock": 50
 *   }
 * }
 * ```
 *
 * ### 3. 修改多行的同一字段
 * ```json
 * {
 *   "target": {"rows": ["row-1", "row-2", "row-3"], "field": "status"},
 *   "value": "active"
 * }
 * ```
 *
 * ### 4. 修改多行的同一字段（不同值）
 * ```json
 * {
 *   "target": {"rows": ["row-1", "row-2", "row-3"], "field": "price"},
 *   "value": [99.99, 88.88, 77.77]
 * }
 * ```
 *
 * ### 5. 修改文档属性
 * ```json
 * {
 *   "target": {"property": "amount"},
 *   "value": 5000.00
 * }
 * ```
 *
 * ### 6. 修改多个文档属性
 * ```json
 * {
 *   "target": {"properties": true},
 *   "value": {
 *     "amount": 5000.00,
 *     "quantity": 100,
 *     "date": "2024-12-05"
 *   }
 * }
 * ```
 *
 * ### 7. 删除单行
 * ```json
 * {
 *   "target": {"row": "row-1", "delete": true}
 * }
 * ```
 * 注意：删除操作不需要提供 value 字段。
 *
 * ### 8. 按条件删除
 * ```json
 * {
 *   "target": {
 *     "condition": {
 *       "logic": "and",
 *       "conditions": [{"field": "status", "operator": "eq", "value": "inactive"}]
 *     },
 *     "delete": true
 *   }
 * }
 * ```
 *
 * ### 9. 按条件更新
 * ```json
 * {
 *   "target": {
 *     "condition": {
 *       "logic": "and",
 *       "conditions": [{"field": "status", "operator": "eq", "value": "pending"}]
 *     },
 *     "field": "reviewStatus"
 *   },
 *   "value": "reviewing"
 * }
 * ```
 */
model BulkUpdate {
    /**
     * 目标（灵活结构）
     * Target (flexible structure)
     *
     * 支持多种目标指定方式：
     * - {row: "row-1"} - 单行
     * - {row: "row-1", field: "price"} - 单行单字段
     * - {rows: ["row-1", "row-2"], field: "status"} - 多行同一字段
     * - {property: "amount"} - 单个属性
     * - {properties: true} - 多个属性
     * - {row: "row-1", delete: true} - 删除单行
     * - {rows: ["row-1", "row-2"], delete: true} - 删除多行
     * - {condition: {...}, field: "status"} - 按条件更新
     * - {condition: {...}, delete: true} - 按条件删除
     *
     * Supports multiple target specification methods:
     * - {row: "row-1"} - Single row
     * - {row: "row-1", field: "price"} - Single row single field
     * - {rows: ["row-1", "row-2"], field: "status"} - Multiple rows same field
     * - {property: "amount"} - Single property
     * - {properties: true} - Multiple properties
     * - {row: "row-1", delete: true} - Delete single row
     * - {rows: ["row-1", "row-2"], delete: true} - Delete multiple rows
     * - {condition: {...}, field: "status"} - Conditional update
     * - {condition: {...}, delete: true} - Conditional delete
     */
    target: {};

    /**
     * 值（原始格式，可以是单值、对象或数组）
     * Value (raw format, can be single value, object or array)
     *
     * 根据 target 的不同，value 可以是：
     * - 单个原始值：99.99, "text", true
     * - 对象（多个字段）：{price: 99.99, name: "iPhone"}
     * - 数组（多行不同值）：[99.99, 88.88, 77.77]
     *
     * Depending on target, value can be:
     * - Single raw value: 99.99, "text", true
     * - Object (multiple fields): {price: 99.99, name: "iPhone"}
     * - Array (different values for multiple rows): [99.99, 88.88, 77.77]
     *
     * 服务端根据 metadata 自动解析值的类型。
     * Server auto-parses value type based on metadata.
     *
     * 注意：删除操作（delete: true）不需要提供 value。
     * Note: Delete operations (delete: true) do not require value.
     */
    value?: unknown;
}

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
    values: NexusBook.Api.Common.ValueEntry[];

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
    createdBy?: NexusBook.Api.Common.UserRef;

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
    updatedBy?: NexusBook.Api.Common.UserRef;

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
    filters?: NexusBook.Api.Common.FilterGroup;

    /**
     * 排序
     * Sorts
     *
     * 排序条件集合。
     * Sort conditions.
     */
    sorts?: NexusBook.Api.Common.Sort[];

    /**
     * 分组与聚合
     * Group and aggregations
     *
     * 分组字段与聚合函数。
     * Group fields and aggregation functions.
     */
    group?: NexusBook.Api.Common.GroupBy;

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
     *
     * ## 数据叠加读取
     *
     * 如果提供 `requestId` 参数，返回的数据将是：
     * **生产数据 + Request 变更**的叠加视图。
     *
     * If `requestId` is provided, the returned data will be:
     * **Production data + Request changes** merged view.
     *
     * 示例：
     * ```bash
     * # 查看生产数据
     * GET /api/v1/doc/product/123/data
     *
     * # 预览变更效果（叠加 Request 变更）
     * GET /api/v1/doc/product/123/data?requestId=req-abc
     *
     * # 查看变更详情（包含变更标记）
     * GET /api/v1/doc/product/123/data?requestId=req-abc&includeChanges=true
     * ```
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
        @query requestId?: string,
        @query includeChanges?: boolean,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<Row>>;

    /**
     * 以结构化体进行复杂查询（嵌套过滤、排序、分页）。
     *
     * Perform complex query with structured body (nested filters, sorts, pagination).
     *
     * 注意：如果需要分组查询，请使用 `/query/group` 接口。
     * Note: For group queries, use `/query/group` endpoint.
     *
     * ## 数据叠加读取
     *
     * 支持通过 `requestId` 查询参数获取叠加后的数据视图。
     * Supports `requestId` query parameter for merged data view.
     */
    @route("/query")
    @post
    @summary("结构化查询数据")
    queryRows(
        @path docType: string,
        @path docId: string,
        @body body: QueryRequest,
        @query requestId?: string,
        @query includeChanges?: boolean,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<Row>>;

    /**
     * 分组查询接口（支持多级分组与聚合）
     *
     * Group query endpoint (supports multi-level grouping and aggregations)
     *
     * 该接口专门用于分组查询，返回树状结构的分组结果。
     * This endpoint is specifically for grouped queries, returning tree-structured group results.
     *
     * ## 多级分组示例
     *
     * ### 单级分组 (Single-level grouping)
     * ```json
     * {
     *   "filters": {...},
     *   "group": {
     *     "fields": ["category"],
     *     "aggregations": [
     *       {"kind": "count", "field": "*"},
     *       {"kind": "sum", "field": "amount"}
     *     ]
     *   }
     * }
     * ```
     *
     * ### 二级分组 (Two-level grouping)
     * ```json
     * {
     *   "group": {
     *     "fields": ["region", "category"],
     *     "aggregations": [
     *       {"kind": "count", "field": "*"},
     *       {"kind": "sum", "field": "revenue"}
     *     ]
     *   }
     * }
     * ```
     *
     * ### 三级分组 (Three-level grouping)
     * ```json
     * {
     *   "group": {
     *     "fields": ["region", "category", "status"],
     *     "aggregations": [{"kind": "count", "field": "*"}]
     *   }
     * }
     * ```
     *
     * ## 返回结构示例
     *
     * ```json
     * {
     *   "groups": [
     *     {
     *       "key": "North",
     *       "field": "region",
     *       "count": 100,
     *       "aggregations": {"count_*": 100, "sum_revenue": 50000},
     *       "children": [
     *         {
     *           "key": "Electronics",
     *           "field": "category",
     *           "count": 60,
     *           "aggregations": {"count_*": 60, "sum_revenue": 30000}
     *         },
     *         {
     *           "key": "Clothing",
     *           "field": "category",
     *           "count": 40,
     *           "aggregations": {"count_*": 40, "sum_revenue": 20000}
     *         }
     *       ]
     *     }
     *   ],
     *   "total": 100,
     *   "groupBy": {...}
     * }
     * ```
     *
     * ## 数据叠加读取
     *
     * 支持通过 `requestId` 查询参数获取叠加后的数据视图。
     * Supports `requestId` query parameter for merged data view.
     */
    @route("/query/group")
    @post
    @summary("分组查询数据")
    queryGroupedRows(
        @path docType: string,
        @path docId: string,
        @body body: QueryRequest,
        @query requestId?: string,
        @query includeChanges?: boolean,
        @query includeRows?: boolean,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.GroupedResult>;

    /**
     * 创建数据行（进入变更请求）
     *
     * Create data row (goes into change request)
     *
     * 创建的数据行会添加到指定的变更请求中，不会立即生效。
     * Created row will be added to the specified change request, not applied immediately.
     *
     * - 如果指定 `requestId`，追加到该请求
     * - 如果不指定，创建新的请求或追加到默认请求
     * - 多人可以编辑同一个请求
     * - 请求合并后才真正生效
     *
     * Request workflow:
     * - If `requestId` specified, append to that request
     * - If not specified, create new request or append to default request
     * - Multiple users can edit the same request
     * - Changes apply only after request is merged
     *
     * 示例（cURL）:
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/doc/product/123/data?requestId=req-1' \\
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
        @query requestId?: string,
    ): NexusBook.Api.Common.ApiResponse<Request>;

    /**
     * 批量更新数据和属性（进入变更请求）
     *
     * Bulk update data and properties (goes into change request)
     *
     * 灵活的批量更新接口，支持：
     * - 修改单个/多个字段
     * - 修改单行/多行
     * - 修改单个/多个属性
     * - 值始终保持简单（原始格式）
     *
     * Flexible bulk update interface supporting:
     * - Update single/multiple fields
     * - Update single/multiple rows
     * - Update single/multiple properties
     * - Values always stay simple (raw format)
     *
     * 示例（cURL）：
     * ```bash
     * # 1. 修改单个字段
     * curl -X POST '.../data/bulk?requestId=req-1' -d '[
     *   {"target": {"row": "row-1", "field": "price"}, "value": 99.99}
     * ]'
     *
     * # 2. 修改整行
     * curl -X POST '.../data/bulk?requestId=req-1' -d '[
     *   {
     *     "target": {"row": "row-1"},
     *     "value": {"price": 99.99, "name": "iPhone 15", "stock": 50}
     *   }
     * ]'
     *
     * # 3. 修改多行的同一字段
     * curl -X POST '.../data/bulk?requestId=req-1' -d '[
     *   {
     *     "target": {"rows": ["row-1", "row-2", "row-3"], "field": "status"},
     *     "value": "active"
     *   }
     * ]'
     *
     * # 4. 修改多行的同一字段（不同值）
     * curl -X POST '.../data/bulk?requestId=req-1' -d '[
     *   {
     *     "target": {"rows": ["row-1", "row-2", "row-3"], "field": "price"},
     *     "value": [99.99, 88.88, 77.77]
     *   }
     * ]'
     *
     * # 5. 修改单个属性
     * curl -X POST '.../data/bulk?requestId=req-1' -d '[
     *   {"target": {"property": "amount"}, "value": 5000.00}
     * ]'
     *
     * # 6. 修改多个属性
     * curl -X POST '.../data/bulk?requestId=req-1' -d '[
     *   {
     *     "target": {"properties": true},
     *     "value": {"amount": 5000.00, "quantity": 100, "date": "2024-12-05"}
     *   }
     * ]'
     *
     * # 7. 混合更新（数据 + 属性）
     * curl -X POST '.../data/bulk?requestId=req-1' -d '[
     *   {"target": {"row": "row-1", "field": "price"}, "value": 99.99},
     *   {"target": {"property": "amount"}, "value": 5000.00}
     * ]'
     * ```
     *
     * 服务端处理逻辑：
     * 1. 根据 docId 获取 metadata
     * 2. 对每个 target，解析目标类型（行/属性）
     * 3. 查找字段定义获取类型
     * 4. 将原始值转换为类型化值
     * 5. 验证值的有效性
     * 6. 添加到指定的 Request
     *
     * Server processing:
     * 1. Get metadata by docId
     * 2. For each target, parse target type (row/property)
     * 3. Lookup field definition to get type
     * 4. Convert raw value to typed value
     * 5. Validate value
     * 6. Add to specified Request
     */
    @route("/bulk")
    @post
    @summary("批量更新")
    bulkUpdate(
        @path docType: string,
        @path docId: string,
        @body body: BulkUpdate[],
        @query requestId?: string,
    ): NexusBook.Api.Common.ApiResponse<Request>;

    /**
     * 返回单条数据行详情。
     *
     * Return single row detail.
     *
     * ## 数据叠加读取
     *
     * 支持通过 `requestId` 查询参数获取叠加后的数据视图。
     * Supports `requestId` query parameter for merged data view.
     */
    @route("/{rowId}")
    @get
    @summary("获取单行详情")
    getRow(
        @path docType: string,
        @path docId: string,
        @path rowId: string,
        @query requestId?: string,
        @query includeChanges?: boolean,
    ): NexusBook.Api.Common.ApiResponse<Row>;

    /**
     * 更新数据行（进入变更请求）
     *
     * Update data row (goes into change request)
     *
     * 更新的数据行会添加到指定的变更请求中，不会立即生效。
     * Updated row will be added to the specified change request, not applied immediately.
     */
    @route("/{rowId}")
    @put
    @summary("更新数据行")
    updateRow(
        @path docType: string,
        @path docId: string,
        @path rowId: string,
        @body body: Row,
        @query requestId?: string,
    ): NexusBook.Api.Common.ApiResponse<Request>;

    /**
     * 删除数据行（进入变更请求）
     *
     * Delete data row (goes into change request)
     *
     * 删除操作会添加到指定的变更请求中，不会立即生效。
     * Delete operation will be added to the specified change request, not applied immediately.
     */
    @route("/{rowId}")
    @delete
    @summary("删除数据行")
    deleteRow(
        @path docType: string,
        @path docId: string,
        @path rowId: string,
        @query requestId?: string,
    ): NexusBook.Api.Common.ApiResponse<Request>;
}
