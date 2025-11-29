import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";
import "../types/requests.tsp";

using TypeSpec.Http;
using OpenAPI;

namespace NexusBook.Api;

/// 数据行（包含字段值与审计信息）
/// Data row with field values and audit info
@doc("数据行包含字段值集合与审计信息（创建/更新/版本）。\nData row contains field values and audit info (created/updated/version).")
model Row {
  /// 行ID Row id
  @doc("数据行唯一标识。\nUnique identifier of the row.")
  id: string;
  /// 字段值集合 Field values
  @doc("字段ID与值的集合。\nCollection of field ids and values.")
  values: NexusBook.Common.ValueEntry[];
  /// 创建时间 Created at
  @doc("创建时间戳。\nCreated timestamp.")
  createdAt?: string;
  /// 创建人 Created by
  @doc("创建者。\nAuthor.")
  createdBy?: string;
  /// 更新时间 Updated at
  @doc("更新时间戳。\nUpdated timestamp.")
  updatedAt?: string;
  /// 更新人 Updated by
  @doc("更新者。\nUpdater.")
  updatedBy?: string;
  /// 版本（并发控制） Version
  @doc("版本号用于并发控制。\nVersion number for concurrency control.")
  version?: int64;
}

/// 结构化查询请求
/// Structured query request
@doc("包含过滤、排序、分组与分页参数，用于复杂查询。\nContains filters, sorts, group and pagination for complex queries.")
model QueryRequest {
  /// 过滤 Filters
  @doc("嵌套过滤组合。\nNested filter groups.")
  filters?: NexusBook.Common.FilterGroup;
  /// 排序 Sorts
  @doc("排序条件集合。\nSort conditions.")
  sorts?: NexusBook.Common.Sort[];
  /// 分组与聚合 Group and aggregations
  @doc("分组字段与聚合函数。\nGroup fields and aggregation functions.")
  group?: NexusBook.Common.GroupBy;
  /// 页码 Page number
  @doc("页码（默认1）。\nPage number (default 1).")
  page?: int32;
  /// 每页数量 Page size
  @doc("每页数量（默认20，最大200）。\nPage size (default 20, max 200).")
  pageSize?: int32;
  /// 游标 Cursor
  @doc("游标用于深分页。\nCursor for deep pagination.")
  cursor?: string;
}

@route("/doc/{docType}/{docId}/data")
@tag("Document")
@get
@summary("列出数据")
@doc("""
以分页返回数据行，支持简单 DSL 查询参数（`page/pageSize/sort/filter/group/cursor`）。

List rows with pagination, supports simple DSL query parameters (`page/pageSize/sort/filter/group/cursor`).
""")
/// 列出数据（中文名：列出数据）
/// List data with pagination and query parameters DSL
op listRows(
  @path docType: string,
  @path docId: string,
  @query page?: int32,
  @query pageSize?: int32,
  @query sort?: string,
  @query filter?: string,
  @query group?: string,
  @query cursor?: string
): NexusBook.Common.ApiResponse<NexusBook.Common.Page<Row>>;

@route("/doc/{docType}/{docId}/data/query")
@tag("Document")
@post
@summary("结构化查询数据")
@doc("""
以结构化体进行复杂查询（嵌套过滤、排序、分组与聚合）。

Perform complex query with structured body (nested filters, sorts, group/aggregations).
""")
/// 结构化查询端点（中文名：结构化查询数据）
/// Structured query endpoint (nested filters, sorts and group/aggregations)
op queryRows(
  @path docType: string,
  @path docId: string,
  @body body: QueryRequest
): NexusBook.Common.ApiResponse<NexusBook.Common.Page<Row>>;

@route("/doc/{docType}/{docId}/data")
@tag("Document")
@post
@summary("创建数据行")
@doc("""
默认生成合并请求，可用 `apply=true` 直接应用。

Generates a merge-request by default, use `apply=true` to apply directly.
""")
/// 创建数据行（中文名：创建数据行）默认生成合并请求，可用 apply 直接应用
/// Create a row (MR by default, apply to bypass)
op createRow(
  @path docType: string,
  @path docId: string,
  @body body: Row,
  @query apply?: boolean
): NexusBook.Common.ApiResponse<Request>;

@route("/doc/{docType}/{docId}/data/bulk")
@tag("Document")
@post
@summary("批量操作数据")
@doc("""
批量创建/更新/删除，默认生成合并请求，可用 `apply=true` 直接应用。

Bulk create/update/delete, MR by default, use `apply=true` to apply directly.
""")
/// 批量操作（中文名：批量操作数据）默认生成合并请求，可用 apply 直接应用
/// Bulk operations (MR by default, apply to bypass)
op bulkRows(
  @path docType: string,
  @path docId: string,
  @body body: Row[],
  @query apply?: boolean
): NexusBook.Common.ApiResponse<Request>;

@route("/doc/{docType}/{docId}/data/{rowId}")
@tag("Document")
@get
@summary("获取单行详情")
@doc("""
返回单条数据行详情。

Return single row detail.
""")
/// 获取单行详情（中文名：获取单行详情）
/// Get row detail
op getRow(@path docType: string, @path docId: string, @path rowId: string): NexusBook.Common.ApiResponse<Row>;

@route("/doc/{docType}/{docId}/data/{rowId}")
@tag("Document")
@put
@summary("更新数据行")
@doc("""
默认生成合并请求，可用 `apply=true` 直接应用。

Generates a merge-request by default, use `apply=true` to apply directly.
""")
/// 更新数据行（中文名：更新数据行）默认生成合并请求，可用 apply 直接应用
/// Update a row (MR by default, apply to bypass)
op updateRow(
  @path docType: string,
  @path docId: string,
  @path rowId: string,
  @body body: Row,
  @query apply?: boolean
): NexusBook.Common.ApiResponse<Request>;

@route("/doc/{docType}/{docId}/data/{rowId}")
@tag("Document")
@delete
@summary("删除数据行")
@doc("""
默认生成合并请求，可用 `apply=true` 直接应用。

Generates a merge-request by default, use `apply=true` to apply directly.
""")
/// 删除数据行（中文名：删除数据行）默认生成合并请求，可用 apply 直接应用
/// Delete a row (MR by default, apply to bypass)
op deleteRow(
  @path docType: string,
  @path docId: string,
  @path rowId: string,
  @query apply?: boolean
): NexusBook.Common.ApiResponse<Request>;
