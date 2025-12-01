import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 评论模块
 *
 * 支持多层级的协作评论系统。
 *
 * 主要功能：
 * - **评论层级** - 文档级、字段级、行级和单元格级评论
 * - **富文本支持** - 支持格式化文本和 @提及功能
 * - **附件管理** - 评论中附加文件和图片
 * - **置顶管理** - 重要评论置顶展示
 * - **多用户协作** - 支持多用户协作讨论
 *
 * ## 评论类型
 *
 * ### 文档级评论
 * POST /doc/{docType}/{docId}/comments
 *
 * ### 字段级评论
 * POST /doc/{docType}/{docId}/metadata/{fieldId}/comments
 *
 * ### 行级评论
 * POST /doc/{docType}/{docId}/rows/{rowId}/comments
 *
 * ### 单元格级评论
 * POST /doc/{docType}/{docId}/rows/{rowId}/fields/{fieldId}/comments
 */
namespace NexusBook.Api;

model Comment {
  /**
   * 评论唯一标识
   * Unique identifier of the comment
   */
  id: string;

  /**
   * 评论内容（支持富文本）
   * Comment content (rich text supported)
   */
  content: string;

  /**
   * @提及用户集合
   * Mentioned users
   */
  mentions?: NexusBook.Common.UserRef[];

  /**
   * 附件集合
   * Attachments
   */
  attachments?: NexusBook.Common.Attachment[];

  /**
   * 创建时间
   * Created at
   */
  createdAt?: string;

  /**
   * 创建人
   * Created by
   */
  createdBy?: string;

  /**
   * 更新时间
   * Updated at
   */
  updatedAt?: string;

  /**
   * 更新人
   * Updated by
   */
  updatedBy?: string;

  /**
   * 是否置顶
   * Pinned flag
   */
  pinned?: boolean;
}

@route("/doc/{docType}/{docId}/comments")
@tag("Document")
interface DocCommentsApi {
  /**
   * 列出文档级别的评论。
   *
   * List doc-level comments.
   */
  @get
  @summary("列出文档评论")
  listDocComments(
    @path docType: string,
    @path docId: string,
  ): NexusBook.Common.ApiResponse<Comment[]>;

  /**
   * 创建文档级别的评论。
   *
   * Create doc-level comment.
   */
  @post
  @summary("创建文档评论")
  createDocComment(
    @path docType: string,
    @path docId: string,
    @body body: Comment,
  ): NexusBook.Common.ApiResponse<Comment>;
}

@route("/doc/{docType}/{docId}/metadata/{fieldId}/comments")
@tag("Document")
interface FieldCommentsApi {
  /**
   * 列出指定元字段的评论。
   *
   * List comments of specified metadata field.
   */
  @get
  @summary("列出元字段评论")
  listFieldComments(
    @path docType: string,
    @path docId: string,
    @path fieldId: string,
  ): NexusBook.Common.ApiResponse<Comment[]>;

  /**
   * 创建指定元字段的评论。
   *
   * Create comment on specified metadata field.
   */
  @post
  @summary("创建元字段评论")
  createFieldComment(
    @path docType: string,
    @path docId: string,
    @path fieldId: string,
    @body body: Comment,
  ): NexusBook.Common.ApiResponse<Comment>;
}

@route("/doc/{docType}/{docId}/rows/{rowId}/comments")
@tag("Document")
interface RowCommentsApi {
  /**
   * 列出指定数据行的评论。
   *
   * List comments of specified row.
   */
  @get
  @summary("列出数据行评论")
  listRowComments(
    @path docType: string,
    @path docId: string,
    @path rowId: string,
  ): NexusBook.Common.ApiResponse<Comment[]>;

  /**
   * 创建指定数据行的评论。
   *
   * Create comment on specified row.
   */
  @post
  @summary("创建数据行评论")
  createRowComment(
    @path docType: string,
    @path docId: string,
    @path rowId: string,
    @body body: Comment,
  ): NexusBook.Common.ApiResponse<Comment>;
}

@route("/doc/{docType}/{docId}/rows/{rowId}/fields/{fieldId}/comments")
@tag("Document")
interface RowFieldCommentsApi {
  /**
   * 列出指定行字段的评论。
   *
   * List comments of specified row field.
   */
  @get
  @summary("列出行字段评论")
  listRowFieldComments(
    @path docType: string,
    @path docId: string,
    @path rowId: string,
    @path fieldId: string,
  ): NexusBook.Common.ApiResponse<Comment[]>;

  /**
   * 创建指定行字段的评论。
   *
   * Create comment on specified row field.
   */
  @post
  @summary("创建行字段评论")
  createRowFieldComment(
    @path docType: string,
    @path docId: string,
    @path rowId: string,
    @path fieldId: string,
    @body body: Comment,
  ): NexusBook.Common.ApiResponse<Comment>;
}
