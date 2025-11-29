import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

namespace NexusBook.Api.Document;

model Request {
  /// 请求ID Request id
  @doc("合并请求的唯一标识。\nUnique identifier of the merge request.")
  id: string;
  /// 标题 Title
  @doc("合并请求标题。\nTitle of the merge request.")
  title?: string;
  /// 描述 Description
  @doc("合并请求描述。\nDescription of the merge request.")
  description?: string;
  /// 状态 Status
  @doc("当前状态：open/merged/closed。\nCurrent status: open/merged/closed.")
  status: RequestStatus;
  /// 作者 Author
  @doc("创建者。\nAuthor.")
  author?: string;
  /// 评审人 Reviewers
  @doc("评审人列表。\nList of reviewers.")
  reviewers?: string[];
  /// 变更集 Changes
  @doc("包含待合并的变更。\nContains changes to be merged.")
  changes?: unknown[];
  /// 创建时间 Created at
  @doc("创建时间戳。\nCreated timestamp.")
  createdAt?: string;
  /// 更新时间 Updated at
  @doc("更新时间戳。\nUpdated timestamp.")
  updatedAt?: string;
}

enum RequestStatus {
  open,
  merged,
  closed,
}

@route("/doc/{docType}/{docId}/requests")
@tag("Document")
interface RequestsApi {
  @get
  @summary("列出合并请求")
  @doc("""
  列出文档的未生效变更请求。

  List uncommitted merge requests of the document.
  """
  )
  op listRequests(@path docType: string, @path docId: string): NexusBook.Common.ApiResponse<Request[]>;

  @post
  @summary("创建合并请求")
  @doc("""
  创建新的合并请求以提交未生效变更。

  Create a new merge request for uncommitted changes.
  """
  )
  op createRequest(@path docType: string, @path docId: string, @body body: Request): NexusBook.Common.ApiResponse<Request>;

  @route("/{reqId}")
  @get
  @summary("获取合并请求详情")
  @doc("""
  获取合并请求的详细信息。

  Get merge request detail.
  """
  )
  op getRequest(@path docType: string, @path docId: string, @path reqId: string): NexusBook.Common.ApiResponse<Request>;

  @route("/{reqId}/merge")
  @post
  @summary("合并请求")
  @doc("""
  将合并请求的变更应用到文档。

  Apply merge request changes to the document.
  """
  )
  op mergeRequest(@path docType: string, @path docId: string, @path reqId: string): NexusBook.Common.ApiResponse<unknown>;

  @route("/{reqId}/close")
  @post
  @summary("关闭请求")
  @doc("""
  关闭指定合并请求。

  Close specified merge request.
  """
  )
  op closeRequest(@path docType: string, @path docId: string, @path reqId: string): NexusBook.Common.ApiResponse<unknown>;

  @route("/{reqId}/reopen")
  @post
  @summary("重新打开请求")
  @doc("""
  重新打开已关闭的合并请求。

  Reopen closed merge request.
  """
  )
  op reopenRequest(@path docType: string, @path docId: string, @path reqId: string): NexusBook.Common.ApiResponse<unknown>;

  @route("/{reqId}/conflicts")
  @get
  @summary("检查冲突")
  @doc("""
  检查合并请求与当前文档的冲突。

  Check conflicts between merge request and current document.
  """
  )
  op getRequestConflicts(@path docType: string, @path docId: string, @path reqId: string): NexusBook.Common.ApiResponse<unknown>;
}
