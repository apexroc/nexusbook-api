import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";
import "../types/metadata.tsp";
import "../types/views.tsp";
import "../types/data.tsp";
import "../types/comments.tsp";
import "../types/revisions.tsp";
import "../types/settings.tsp";

using TypeSpec.Http;
using OpenAPI;

namespace NexusBook.Api;

/** 文档标识（类型与ID）
 Document identifier (type & id) */
model DocIdent {
  docType: string;
  docId: string;
}

/** 聚合包：用于视图一次性渲染
 Aggregated payload for single-shot view rendering */
model DocBundle {
  @doc("文档元数据（字段/显示配置）。\nDocument metadata (fields/display settings).")
  metadata?: Metadata;
  @doc("视图列表。\nList of views.")
  views?: View[];
  @doc("数据分页结果。\nPaginated data.")
  data?: NexusBook.Common.Page<Row>;
  @doc("评论集合。\nComments list.")
  comments?: Comment[];
  @doc("修订记录。\nRevision entries.")
  revisions?: Revision[];
  @doc("文档设置。\nDocument settings.")
  settings?: Settings;
}

/** 获取聚合文档包（支持 include 选择与分页）
 Fetch aggregated doc bundle (supports include selection and pagination) */
@route("/doc/{docType}/{docId}")
@tag("Document")
@get
@summary("获取聚合文档包")
@doc("""
一次性获取文档的所需数据：通过 `include` 指定返回部分（如 `metadata,views,data,comments,revisions,settings`），支持视图分页（`page/pageSize`）与限制数量（`commentsLimit/revisionsLimit`）。

Fetch aggregated doc bundle with selective sections via `include` (e.g. `metadata,views,data,comments,revisions,settings`), supports view paging (`page/pageSize`) and limits (`commentsLimit/revisionsLimit`).
""")
op getDocBundle(
  @path docType: string,
  @path docId: string,
  @query include?: string,
  @query viewId?: string,
  @query page?: int32,
  @query pageSize?: int32,
  @query commentsLimit?: int32,
  @query revisionsLimit?: int32
): NexusBook.Common.ApiResponse<DocBundle>;
