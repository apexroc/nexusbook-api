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

namespace NexusBook.Api.Document;

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
  metadata?: NexusBook.Api.Document.Metadata;
  @doc("视图列表。\nList of views.")
  views?: NexusBook.Api.Document.View[];
  @doc("数据分页结果。\nPaginated data.")
  data?: NexusBook.Common.Page<NexusBook.Api.Document.Row>;
  @doc("评论集合。\nComments list.")
  comments?: NexusBook.Api.Document.Comment[];
  @doc("修订记录。\nRevision entries.")
  revisions?: NexusBook.Api.Document.Revision[];
  @doc("文档设置。\nDocument settings.")
  settings?: NexusBook.Api.Document.Settings;
}

/** 获取聚合文档包（支持 include 选择与分页）
 Fetch aggregated doc bundle (supports include selection and pagination) */
@route("/doc/{docType}/{docId}")
@tag("Document")
interface DocumentAggregateApi {
  @get
  @summary("获取聚合文档包")
  @doc("""
  一次性获取文档的所需数据：通过 `include` 指定返回部分（如 `metadata,views,data,comments,revisions,settings`），支持视图分页（`page/pageSize`）与限制数量（`commentsLimit/revisionsLimit`）。

  Fetch aggregated doc bundle with selective sections via `include` (e.g. `metadata,views,data,comments,revisions,settings`), supports view paging (`page/pageSize`) and limits (`commentsLimit/revisionsLimit`).

  示例（cURL）:
  ```bash
  curl -H 'Authorization: Bearer TOKEN' 'https://open.nexusbook.com/api/v1/doc/product/123?include=metadata,views,data&page=1&pageSize=20'
  ```
  """
  )
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
}
