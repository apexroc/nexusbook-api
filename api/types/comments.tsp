import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

namespace NexusBook.Api.Document;

model Comment {
  @doc("评论唯一标识。\nUnique identifier of the comment.")
  id: string;
  @doc("评论内容（支持富文本）。\nComment content (rich text supported).")
  content: string;
  @doc("@提及用户集合。\nMentioned users.")
  mentions?: NexusBook.Common.UserRef[];
  @doc("附件集合。\nAttachments.")
  attachments?: NexusBook.Common.Attachment[];
  @doc("创建时间。\nCreated at.")
  createdAt?: string;
  @doc("创建人。\nCreated by.")
  createdBy?: string;
  @doc("更新时间。\nUpdated at.")
  updatedAt?: string;
  @doc("更新人。\nUpdated by.")
  updatedBy?: string;
  @doc("是否置顶。\nPinned flag.")
  pinned?: boolean;
}

@route("/doc/{docType}/{docId}/comments")
@tag("Document")
interface DocCommentsApi {
  @get
  @summary("列出文档评论")
  @doc("""
  列出文档级别的评论。

  List doc-level comments.
  """
  )
  op listDocComments(@path docType: string, @path docId: string): NexusBook.Common.ApiResponse<Comment[]>;

  @post
  @summary("创建文档评论")
  @doc("""
  创建文档级别的评论。

  Create doc-level comment.
  """
  )
  op createDocComment(@path docType: string, @path docId: string, @body body: Comment): NexusBook.Common.ApiResponse<Comment>;
}

@route("/doc/{docType}/{docId}/metadata/{fieldId}/comments")
@tag("Document")
interface FieldCommentsApi {
  @get
  @summary("列出元字段评论")
  @doc("""
  列出指定元字段的评论。

  List comments of specified metadata field.
  """
  )
  op listFieldComments(@path docType: string, @path docId: string, @path fieldId: string): NexusBook.Common.ApiResponse<Comment[]>;

  @post
  @summary("创建元字段评论")
  @doc("""
  创建指定元字段的评论。

  Create comment on specified metadata field.
  """
  )
  op createFieldComment(@path docType: string, @path docId: string, @path fieldId: string, @body body: Comment): NexusBook.Common.ApiResponse<Comment>;
}

@route("/doc/{docType}/{docId}/rows/{rowId}/comments")
@tag("Document")
interface RowCommentsApi {
  @get
  @summary("列出数据行评论")
  @doc("""
  列出指定数据行的评论。

  List comments of specified row.
  """
  )
  op listRowComments(@path docType: string, @path docId: string, @path rowId: string): NexusBook.Common.ApiResponse<Comment[]>;

  @post
  @summary("创建数据行评论")
  @doc("""
  创建指定数据行的评论。

  Create comment on specified row.
  """
  )
  op createRowComment(@path docType: string, @path docId: string, @path rowId: string, @body body: Comment): NexusBook.Common.ApiResponse<Comment>;
}

@route("/doc/{docType}/{docId}/rows/{rowId}/fields/{fieldId}/comments")
@tag("Document")
interface RowFieldCommentsApi {
  @get
  @summary("列出行字段评论")
  @doc("""
  列出指定行字段的评论。

  List comments of specified row field.
  """
  )
  op listRowFieldComments(@path docType: string, @path docId: string, @path rowId: string, @path fieldId: string): NexusBook.Common.ApiResponse<Comment[]>;

  @post
  @summary("创建行字段评论")
  @doc("""
  创建指定行字段的评论。

  Create comment on specified row field.
  """
  )
  op createRowFieldComment(@path docType: string, @path docId: string, @path rowId: string, @path fieldId: string, @body body: Comment): NexusBook.Common.ApiResponse<Comment>;
}
