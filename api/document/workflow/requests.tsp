import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 变更请求模块
 *
 * 支持变更工作流，类似 Git Pull Request 的合并请求机制。
 *
 * 主要功能：
 * - **变更请求** - 记录待合并的变更
 * - **工作流管理** - open/merged/closed 三态流转
 * - **评审机制** - 指定评审人和权限控制
 * - **冲突检测** - 检测合并冲突
 * - **直接应用** - 支持 apply=true 直接应用变更
 *
 * ## 工作流状态
 *
 * - `open` - 开放状态，待审核或直接应用
 * - `merged` - 已合并，变更已生效
 * - `closed` - 已关闭，变更已拒绝或取消
 *
 * ## 使用场景
 *
 * - 审批工作流 - 需要审批的重要变更
 * - 草稿保存 - 未生效变更的保存
 * - 批量操作 - 一次性提交多行变更
 */
namespace NexusBook.Api;

model Request {
    /**
     * 请求ID
     * Request id
     *
     * 合并请求的唯一标识。
     * Unique identifier of the merge request.
     */
    id: string;

    /**
     * 标题
     * Title
     *
     * 合并请求标题。
     * Title of the merge request.
     */
    title?: string;

    /**
     * 描述
     * Description
     *
     * 合并请求描述。
     * Description of the merge request.
     */
    description?: string;

    /**
     * 状态
     * Status
     *
     * 当前状态：open/merged/closed。
     * Current status: open/merged/closed.
     */
    status: NexusBook.Common.RequestStatus;

    /**
     * 作者
     * Author
     *
     * 创建者。
     * Author.
     */
    author?: string;

    /**
     * 评审人
     * Reviewers
     *
     * 评审人列表。
     * List of reviewers.
     */
    reviewers?: string[];

    /**
     * 贡献者
     * Contributors
     *
     * 对该请求添加或修改变更的所有用户。
     * All users who added or modified changes in this request.
     */
    contributors?: string[];

    /**
     * 变更集
     * Changes
     *
     * 包含待合并的变更。
     * Contains changes to be merged.
     */
    changes?: unknown[];

    /**
     * 生成的修订ID
     * Generated revision id
     *
     * 当请求合并后，系统生成的修订ID。
     * Revision id generated when the request is merged.
     */
    generatedRevisionId?: string;

    /**
     * 创建时间
     * Created at
     *
     * 创建时间戳。
     * Created timestamp.
     */
    createdAt?: string;

    /**
     * 更新时间
     * Updated at
     *
     * 更新时间戳。
     * Updated timestamp.
     */
    updatedAt?: string;

    /**
     * 合并时间
     * Merged at
     *
     * 请求被合并的时间戳。
     * Timestamp when the request was merged.
     */
    mergedAt?: string;

    /**
     * 合并者
     * Merged by
     *
     * 执行合并操作的用户。
     * User who performed the merge.
     */
    mergedBy?: string;
}

@route("/doc/{docType}/{docId}/requests")
@tag("Document")
interface RequestsApi {
    /**
     * 列出文档的未生效变更请求。
     *
     * List uncommitted merge requests of the document.
     */
    @get
    @summary("列出合并请求")
    listRequests(
        @path docType: string,
        @path docId: string,
    ): NexusBook.Common.ApiResponse<Request[]>;

    /**
     * 创建新的合并请求以提交未生效变更。
     *
     * Create a new merge request for uncommitted changes.
     */
    @post
    @summary("创建合并请求")
    createRequest(
        @path docType: string,
        @path docId: string,
        @body body: Request,
    ): NexusBook.Common.ApiResponse<Request>;

    /**
     * 获取合并请求的详细信息。
     *
     * Get merge request detail.
     */
    @route("/{reqId}")
    @get
    @summary("获取合并请求详情")
    getRequest(
        @path docType: string,
        @path docId: string,
        @path reqId: string,
    ): NexusBook.Common.ApiResponse<Request>;

    /**
     * 将合并请求的变更应用到文档并生成修订。
     *
     * Apply merge request changes to the document and generate revision.
     *
     * 当请求被合并时：
     * 1. 系统冻结该请求中的所有变更
     * 2. 应用变更到文档
     * 3. 创建新的修订记录整个变更历史
     * 4. 记录所有贡献者（对请求做过修改的人）
     * 5. 返回生成的修订ID
     *
     * When request is merged:
     * 1. System freezes all changes in the request
     * 2. Apply changes to document
     * 3. Create new revision recording the entire change history
     * 4. Record all contributors (users who modified the request)
     * 5. Return generated revision id
     *
     * 请求体支持以下选项:
     * - `squash` - 是否合并为单一变更（true/false）
     * - `message` - 合并消息
     * - `deleteBranch` - 合并后是否删除关联分支
     *
     * Request body supports:
     * - `squash` - Whether to squash into single change
     * - `message` - Merge message
     * - `deleteBranch` - Delete associated branch after merge
     *
     * 响应包含:
     * - `revisionId` - 生成的修订ID
     * - `version` - 修订版本号
     * - `changesApplied` - 应用的变更数量
     * - `contributors` - 所有贡献者列表
     *
     * Response includes:
     * - `revisionId` - Generated revision id
     * - `version` - Revision version number
     * - `changesApplied` - Number of applied changes
     * - `contributors` - List of all contributors
     */
    @route("/{reqId}/merge")
    @post
    @summary("合并请求")
    mergeRequest(
        @path docType: string,
        @path docId: string,
        @path reqId: string,
        @body body?: {
            /**
             * 合并消息
             * Merge message
             */
            message?: string;

            /**
             * 是否合并为单一变更
             * Squash into single change
             */
            squash?: boolean;

            /**
             * 合并后是否删除关联分支
             * Delete branch after merge
             */
            deleteBranch?: boolean;
        },
    ): NexusBook.Common.ApiResponse<{
        /**
         * 生成的修订ID
         * Generated revision id
         */
        revisionId: string;

        /**
         * 修订版本号
         * Revision version number
         */
        version: int64;

        /**
         * 应用的变更数量
         * Number of changes applied
         */
        changesApplied: int32;

        /**
         * 所有贡献者
         * All contributors
         */
        contributors: string[];

        /**
         * 合并时间
         * Merge timestamp
         */
        mergedAt: string;

        /**
         * 合并者
         * User who merged
         */
        mergedBy: string;
    }>;

    /**
     * 关闭指定合并请求。
     *
     * Close specified merge request.
     */
    @route("/{reqId}/close")
    @post
    @summary("关闭请求")
    closeRequest(
        @path docType: string,
        @path docId: string,
        @path reqId: string,
    ): NexusBook.Common.ApiResponse<unknown>;

    /**
     * 重新打开已关闭的合并请求。
     *
     * Reopen closed merge request.
     */
    @route("/{reqId}/reopen")
    @post
    @summary("重新打开请求")
    reopenRequest(
        @path docType: string,
        @path docId: string,
        @path reqId: string,
    ): NexusBook.Common.ApiResponse<unknown>;

    /**
     * 检查合并请求与当前文档的冲突。
     *
     * Check conflicts between merge request and current document.
     */
    @route("/{reqId}/conflicts")
    @get
    @summary("检查冲突")
    getRequestConflicts(
        @path docType: string,
        @path docId: string,
        @path reqId: string,
    ): NexusBook.Common.ApiResponse<unknown>;
}
