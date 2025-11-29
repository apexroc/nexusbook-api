import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

namespace NexusBook.Api;

model Revision {
  /// 修订ID Revision id
  id: string;
  /// 作者 Author
  author?: string;
  /// 创建时间 Created at
  createdAt?: string;
  /// 变更集合 Changes
  changes?: unknown[];
}

@route("/doc/{docType}/{docId}/revisions")
@tag("Document")
@get
@summary("列出修订记录")
@doc("""
列出文档的修订记录。

List revisions of the document.
""")
/// 列出修订记录（中文名：列出修订记录）
/// List revisions
op listRevisions(@path docType: string, @path docId: string): NexusBook.Common.ApiResponse<Revision[]>;

@route("/doc/{docType}/{docId}/revisions/{revId}")
@tag("Document")
@get
@summary("获取修订详情")
@doc("""
获取指定修订的详情。

Get detail of specified revision.
""")
/// 获取修订详情（中文名：获取修订详情）
/// Get revision detail
op getRevision(@path docType: string, @path docId: string, @path revId: string): NexusBook.Common.ApiResponse<Revision>;

@route("/doc/{docType}/{docId}/revisions/{revId}/diff")
@tag("Document")
@get
@summary("查看修订差异")
@doc("""
比较两个修订之间的差异。

Compare diffs between two revisions.
""")
/// 查看修订差异（中文名：查看修订差异）
/// View revision diff
op getRevisionDiff(@path docType: string, @path docId: string, @path revId: string, @query base?: string): NexusBook.Common.ApiResponse<unknown>;

@route("/doc/{docType}/{docId}/revisions/{revId}/revert")
@tag("Document")
@post
@summary("回滚修订")
@doc("""
回滚到指定修订，会创建新的修订记录。

Revert to specified revision, creates a new revision.
""")
/// 回滚到指定修订（中文名：回滚修订）
/// Revert to specified revision (creates new revision)
op revertRevision(@path docType: string, @path docId: string, @path revId: string): NexusBook.Common.ApiResponse<Revision>;
