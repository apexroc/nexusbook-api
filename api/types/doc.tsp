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

/**
 * 文档集成模块
 *
 * 提供文档的聚合查询接口，允许一次性获取文档所需的多种数据。
 *
 * 主要功能：
 * - **聚合查询** - 一次性获取文档的元数据、视图、数据、评论等
 * - **按需加载** - 通过 include 参数选择返回的数据部分
 * - **分页支持** - 支持数据分页和评论/修订数量限制
 * - **视图切换** - 可指定特定视图进行数据查询
 *
 * ## 聚合查询示例
 *
 * GET /doc/product/123?include=metadata,views,data,comments,revisions,settings
 * GET /doc/product/123?include=metadata,views&viewId=view-123
 * GET /doc/product/123?include=data&page=1&pageSize=50
 * GET /doc/product/123?include=comments,revisions&commentsLimit=10&revisionsLimit=5
 */
namespace NexusBook.Api;

/**
 * 文档标识（类型与ID）
 * Document identifier (type & id)
 */
model DocIdent {
  docType: string;
  docId: string;
}

/**
 * 聚合包：用于视图一次性渲染
 * Aggregated payload for single-shot view rendering
 */
model DocBundle {
  /**
   * 文档元数据（字段/显示配置）
   * Document metadata (fields/display settings)
   */
  metadata?: NexusBook.Api.Metadata;

  /**
   * 视图列表
   * List of views
   */
  views?: NexusBook.Api.View[];

  /**
   * 数据分页结果
   * Paginated data
   */
  data?: NexusBook.Common.Page<NexusBook.Api.Row>;

  /**
   * 评论集合
   * Comments list
   */
  comments?: NexusBook.Api.Comment[];

  /**
   * 修订记录
   * Revision entries
   */
  revisions?: NexusBook.Api.Revision[];

  /**
   * 文档设置
   * Document settings
   */
  settings?: NexusBook.Api.Settings;
}

/** 获取聚合文档包（支持 include 选择与分页）
 * Fetch aggregated doc bundle (supports include selection and pagination) */
@route("/doc/{docType}/{docId}")
@tag("Document")
interface DocumentAggregateApi {
  /**
   * 获取聚合文档包（支持 include 选择与分页）
   *
   * Fetch aggregated doc bundle (supports include selection and pagination)
   *
   * 一次性获取文档的所需数据：通过 `include` 指定返回部分（如 `metadata,views,data,comments,revisions,settings`），
   * 支持视图分页（`page/pageSize`）与限制数量（`commentsLimit/revisionsLimit`）。
   *
   * Fetch aggregated doc bundle with selective sections via `include` (e.g. `metadata,views,data,comments,revisions,settings`),
   * supports view paging (`page/pageSize`) and limits (`commentsLimit/revisionsLimit`).
   *
   * 示例（cURL）:
   * ```bash
   * curl -H 'Authorization: Bearer TOKEN' \
   *   'https://open.nexusbook.com/api/v1/doc/product/123?include=metadata,views,data&page=1&pageSize=20'
   * ```
   */
  @get
  @summary("获取聚合文档包")
  getDocBundle(
    @path docType: string,
    @path docId: string,
    @query include?: string,
    @query viewId?: string,
    @query page?: int32,
    @query pageSize?: int32,
    @query commentsLimit?: int32,
    @query revisionsLimit?: int32,
  ): NexusBook.Common.ApiResponse<DocBundle>;
}
