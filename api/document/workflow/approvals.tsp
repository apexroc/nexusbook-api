import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 审批工作流模块
 *
 * 支持自定义审批流程和权限控制。
 *
 * 主要功能：
 * - **审批流程** - 定义和执行审批工作流
 * - **多节点审批** - 支持多层级、多人审批
 * - **审批决策** - 通过/拒绝决策
 * - **审批历史** - 完整的审批记录和意见
 * - **权限控制** - 基于角色的审批权限
 *
 * ## 审批状态
 *
 * - `pending` - 待审批，流程进行中
 * - `approved` - 已通过，审批完成
 * - `rejected` - 已拒绝，需要修改重新提交
 * - `canceled` - 已取消，审批流程中止
 *
 * ## 审批决策
 *
 * - `approved` - 通过审批
 * - `rejected` - 拒绝审批
 *
 * ## 使用场景
 *
 * - 权限管理 - 关键操作需要审批
 * - 流程规范 - 确保操作合规
 * - 责任追踪 - 记录谁批准了什么
 */
namespace NexusBook.Api;

model ApprovalInstance {
    /**
     * 审批实例ID
     * Approval instance id
     */
    id: string;

    /**
     * 审批状态
     * Approval status
     */
    status: NexusBook.Common.ApprovalStatus;

    /**
     * 当前节点
     * Current node
     */
    currentNode?: string;

    /**
     * 历史记录
     * History entries
     */
    history?: {
        /**
         * 节点ID
         * Node id
         */
        nodeId: string;

        /**
         * 操作人
         * Actor
         */
        actor?: string;

        /**
         * 决策
         * Decision
         */
        decision?: NexusBook.Common.ApprovalDecision;

        /**
         * 备注
         * Comment
         */
        comment?: string;

        /**
         * 时间戳
         * Timestamp
         */
        timestamp: string;
    }[];
}

@route("/doc/{docType}/{docId}/approval")
@tag("Document - Workflow")
interface ApprovalApi {
    /**
     * 获取审批流程定义或实例概述。
     *
     * Get approval flow definition or instance overview.
     */
    @get
    @summary("获取审批")
    getApproval(
        @path docType: string,
        @path docId: string,
    ): NexusBook.Common.ApiResponse<unknown>;

    /**
     * 在文档上发起审批流程。
     *
     * Start approval flow on the document.
     */
    @route("/start")
    @post
    @summary("发起审批")
    startApproval(
        @path docType: string,
        @path docId: string,
    ): NexusBook.Common.ApiResponse<ApprovalInstance>;
}

@route("/doc/{docType}/{docId}/approval/{instanceId}")
@tag("Document - Workflow")
interface ApprovalInstanceApi {
    /**
     * 获取审批实例详情。
     *
     * Get approval instance detail.
     */
    @get
    @summary("审批详情")
    getApprovalInstance(
        @path docType: string,
        @path docId: string,
        @path instanceId: string,
    ): NexusBook.Common.ApiResponse<ApprovalInstance>;

    /**
     * 对审批实例进行通过或拒绝的决策。
     *
     * Decide approval (approve or reject).
     */
    @route("/decision")
    @post
    @summary("审批决策")
    decideApproval(
        @path docType: string,
        @path docId: string,
        @path instanceId: string,
        @query result: NexusBook.Common.ApprovalDecision,
    ): NexusBook.Common.ApiResponse<ApprovalInstance>;
}
