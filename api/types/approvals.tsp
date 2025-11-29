import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

namespace NexusBook.Api.Document;

model ApprovalInstance {
  /// 审批实例ID Approval instance id
  id: string;
  /// 审批状态 Approval status
  status: ApprovalStatus;
  /// 当前节点 Current node
  currentNode?: string;
  /// 历史记录 History entries
  history?: {
    /// 节点ID Node id
    nodeId: string;
    /// 操作人 Actor
    actor?: string;
    /// 决策 Decision
    decision?: ApprovalDecision;
    /// 备注 Comment
    comment?: string;
    /// 时间戳 Timestamp
    timestamp: string;
  }[];
}

enum ApprovalStatus {
  pending,
  approved,
  rejected,
  canceled,
}

enum ApprovalDecision {
  approved,
  rejected,
}

@route("/doc/{docType}/{docId}/approval")
@tag("Document")
interface ApprovalApi {
  @get
  @summary("获取审批")
  @doc("""
  获取审批流程定义或实例概览。

  Get approval flow definition or instance overview.
  """
  )
  op getApproval(@path docType: string, @path docId: string): NexusBook.Common.ApiResponse<unknown>;

  @route("/start")
  @post
  @summary("发起审批")
  @doc("""
  在文档上发起审批流程。

  Start approval flow on the document.
  """
  )
  op startApproval(@path docType: string, @path docId: string): NexusBook.Common.ApiResponse<ApprovalInstance>;
}

@route("/doc/{docType}/{docId}/approval/{instanceId}")
@tag("Document")
interface ApprovalInstanceApi {
  @get
  @summary("审批详情")
  @doc("""
  获取审批实例详情。

  Get approval instance detail.
  """
  )
  op getApprovalInstance(@path docType: string, @path docId: string, @path instanceId: string): NexusBook.Common.ApiResponse<ApprovalInstance>;

  @route("/decision")
  @post
  @summary("审批决策")
  @doc("""
  对审批实例进行通过或拒绝的决策。

  Decide approval (approve or reject).
  """
  )
  op decideApproval(@path docType: string, @path docId: string, @path instanceId: string, @query result: ApprovalDecision): NexusBook.Common.ApiResponse<ApprovalInstance>;
}
