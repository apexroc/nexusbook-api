import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

namespace NexusBook.Api;

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
@get
@summary("列出文档评论")
@doc("""
列出文档级别的评论。

List doc-level comments.
""")
/// 列出文档级评论（中文名：列出文档评论）
/// List doc-level comments
op listDocComments(@path docType: string, @path docId: string): NexusBook.Common.ApiResponse<Comment[]>;

@route("/doc/{docType}/{docId}/comments")
@tag("Document")
@post
@summary("创建文档评论")
@doc("""
创建文档级别的评论。

Create doc-level comment.
""")
/// 创建文档级评论（中文名：创建文档评论）
/// Create doc-level comment
op createDocComment(@path docType: string, @path docId: string, @body body: Comment): NexusBook.Common.ApiResponse<Comment>;

@route("/doc/{docType}/{docId}/metadata/{fieldId}/comments")
@tag("Document")
@get
@summary("列出元字段评论")
@doc("""
列出指定元字段的评论。

List comments of specified metadata field.
""")
/// 列出元字段评论（中文名：列出元字段评论）
/// List metadata field comments
op listFieldComments(@path docType: string, @path docId: string, @path fieldId: string): NexusBook.Common.ApiResponse<Comment[]>;

@route("/doc/{docType}/{docId}/metadata/{fieldId}/comments")
@tag("Document")
@post
@summary("创建元字段评论")
@doc("""
创建指定元字段的评论。

Create comment on specified metadata field.
""")
/// 创建元字段评论（中文名：创建元字段评论）
/// Create metadata field comment
op createFieldComment(@path docType: string, @path docId: string, @path fieldId: string, @body body: Comment): NexusBook.Common.ApiResponse<Comment>;

@route("/doc/{docType}/{docId}/rows/{rowId}/comments")
@tag("Document")
@get
@summary("列出数据行评论")
@doc("""
列出指定数据行的评论。

List comments of specified row.
""")
/// 列出数据行评论（中文名：列出数据行评论）
/// List row comments
op listRowComments(@path docType: string, @path docId: string, @path rowId: string): NexusBook.Common.ApiResponse<Comment[]>;

@route("/doc/{docType}/{docId}/rows/{rowId}/comments")
@tag("Document")
@post
@summary("创建数据行评论")
@doc("""
创建指定数据行的评论。

Create comment on specified row.
""")
/// 创建数据行评论（中文名：创建数据行评论）
/// Create row comment
op createRowComment(@path docType: string, @path docId: string, @path rowId: string, @body body: Comment): NexusBook.Common.ApiResponse<Comment>;

@route("/doc/{docType}/{docId}/rows/{rowId}/fields/{fieldId}/comments")
@tag("Document")
@get
@summary("列出行字段评论")
@doc("""
列出指定行字段的评论。

List comments of specified row field.
""")
/// 列出行字段评论（中文名：列出行字段评论）
/// List row field comments
op listRowFieldComments(@path docType: string, @path docId: string, @path rowId: string, @path fieldId: string): NexusBook.Common.ApiResponse<Comment[]>;

@route("/doc/{docType}/{docId}/rows/{rowId}/fields/{fieldId}/comments")
@tag("Document")
@post
@summary("创建行字段评论")
@doc("""
创建指定行字段的评论。

Create comment on specified row field.
""")
/// 创建行字段评论（中文名：创建行字段评论）
/// Create row field comment
op createRowFieldComment(@path docType: string, @path docId: string, @path rowId: string, @path fieldId: string, @body body: Comment): NexusBook.Common.ApiResponse<Comment>;
