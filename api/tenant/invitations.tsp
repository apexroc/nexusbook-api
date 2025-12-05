import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";
import "./models.tsp";

using TypeSpec.Http;
using OpenAPI;
using NexusBook.Api.Tenant;

/**
 * NexusBook Tenant Management - Invitation & Join Request APIs
 * NexusBook 租户管理 - 邀请与加入申请 API
 *
 * 提供组织邀请和加入申请的管理功能。
 * Provides organization invitation and join request management features.
 *
 * Route Base: /api/v1/organizations/{organizationId}/invitations, /api/v1/organizations/{organizationId}/join-requests
 *
 * 主要接口 / Main Endpoints:
 * - POST /invitations - 创建邀请 Create invitation
 * - GET /invitations - 列出邀请 List invitations
 * - POST /invitations/{invitationId}/revoke - 撤销邀请 Revoke invitation
 * - POST /invitations/{invitationId}/accept - 接受邀请 Accept invitation
 * - POST /join-requests - 提交加入申请 Submit join request
 * - GET /join-requests - 列出加入申请 List join requests
 * - POST /join-requests/{requestId}/approve - 批准申请 Approve join request
 * - POST /join-requests/{requestId}/reject - 拒绝申请 Reject join request
 */
namespace NexusBook.Api.Tenant;

// ==================== 请求/响应模型 ====================

/**
 * 创建邀请请求
 * Create invitation request
 */
model CreateInvitationRequest {
    /**
     * 被邀请人邮箱（必填）
     * Invitee email (required)
     */
    email: string;

    /**
     * 邀请角色（默认 member）
     * Invited role (default: member)
     */
    role?: OrganizationRole = OrganizationRole.member;

    /**
     * 邀请留言
     * Invitation message
     */
    message?: string;

    /**
     * 有效期（天数，默认7天）
     * Expiration days (default: 7)
     */
    expiresInDays?: int32 = 7;
}

/**
 * 创建加入申请请求
 * Create join request
 */
model CreateJoinRequestRequest {
    /**
     * 申请说明
     * Application message
     */
    message?: string;
}

/**
 * 批准加入申请请求
 * Approve join request
 */
model ApproveJoinRequestRequest {
    /**
     * 授予的角色（默认使用组织默认角色）
     * Granted role (default: use organization default role)
     */
    role?: OrganizationRole;

    /**
     * 审核备注
     * Review note
     */
    reviewNote?: string;
}

/**
 * 拒绝加入申请请求
 * Reject join request
 */
model RejectJoinRequestRequest {
    /**
     * 拒绝原因
     * Rejection reason
     */
    reviewNote: string;
}

// ==================== API 接口定义 ====================

/**
 * 邀请 API 接口
 * Invitation API interface
 */
@tag("Invitations")
interface InvitationApi {
    /**
     * 创建邀请
     * Create invitation
     *
     * 邀请用户加入组织。需要 owner 或 admin 权限。
     * Invite a user to join the organization. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/organizations/org-123/invitations' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "email": "user@example.com",
     *     "role": "member",
     *     "message": "欢迎加入我们的团队！",
     *     "expiresInDays": 7
     *   }'
     * ```
     */
    @post
    @route("/api/v1/organizations/{organizationId}/invitations")
    @summary("创建邀请")
    createInvitation(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 创建邀请请求
         * Create invitation request
         */
        @body request: CreateInvitationRequest
    ): NexusBook.Api.Common.ApiResponse<Invitation>;

    /**
     * 列出组织邀请
     * List organization invitations
     *
     * 获取组织的所有邀请列表。需要 owner 或 admin 权限。
     * Get the list of all invitations of the organization. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/invitations?status=pending' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/invitations")
    @summary("列出组织邀请")
    listInvitations(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 页码
         * Page number
         */
        @query page?: int32 = 1,

        /**
         * 每页数量
         * Page size
         */
        @query pageSize?: int32 = 20,

        /**
         * 按状态过滤
         * Filter by status
         */
        @query status?: InvitationStatus
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<Invitation>>;

    /**
     * 获取邀请详情
     * Get invitation detail
     *
     * 获取指定邀请的详细信息。
     * Get detailed information of a specified invitation.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/invitations/inv-456' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/invitations/{invitationId}")
    @summary("获取邀请详情")
    getInvitation(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 邀请ID
         * Invitation ID
         */
        @path invitationId: string
    ): NexusBook.Api.Common.ApiResponse<Invitation>;

    /**
     * 撤销邀请
     * Revoke invitation
     *
     * 撤销未接受的邀请。需要 owner 或 admin 权限，或是邀请创建者。
     * Revoke an unaccepted invitation. Requires owner or admin permission, or being the inviter.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.com/api/v1/organizations/org-123/invitations/inv-456' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/api/v1/organizations/{organizationId}/invitations/{invitationId}")
    @summary("撤销邀请")
    revokeInvitation(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 邀请ID
         * Invitation ID
         */
        @path invitationId: string
    ): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 接受邀请
     * Accept invitation
     *
     * 通过邀请令牌接受邀请加入组织。验证邮箱匹配后创建成员记录。
     * Accept an invitation to join the organization using invitation token. Creates member record after email verification.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/invitations/TOKEN_STRING/accept' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @post
    @route("/api/v1/invitations/{token}/accept")
    @summary("接受邀请")
    acceptInvitation(
        /**
         * 邀请令牌
         * Invitation token
         */
        @path token: string
    ): NexusBook.Api.Common.ApiResponse<OrganizationMember>;

    /**
     * 拒绝邀请
     * Decline invitation
     *
     * 拒绝邀请加入组织。
     * Decline an invitation to join the organization.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/invitations/TOKEN_STRING/decline' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @post
    @route("/api/v1/invitations/{token}/decline")
    @summary("拒绝邀请")
    declineInvitation(
        /**
         * 邀请令牌
         * Invitation token
         */
        @path token: string
    ): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 通过令牌获取邀请信息
     * Get invitation by token
     *
     * 使用邀请令牌获取邀请详情（用于邀请接受页面展示）。
     * Get invitation details using invitation token (for invitation acceptance page display).
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/invitations/TOKEN_STRING' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/invitations/{token}")
    @summary("通过令牌获取邀请信息")
    getInvitationByToken(
        /**
         * 邀请令牌
         * Invitation token
         */
        @path token: string
    ): NexusBook.Api.Common.ApiResponse<Invitation>;
}

/**
 * 加入申请 API 接口
 * Join Request API interface
 */
@tag("Join Requests")
interface JoinRequestApi {
    /**
     * 申请加入组织
     * Apply to join organization
     *
     * 提交加入组织的申请。前置条件：用户未加入该组织，组织允许申请加入。
     * Submit an application to join the organization. Prerequisites: user is not a member, organization allows join requests.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/organizations/org-123/join-requests' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "message": "我希望加入贵团队，我有5年相关经验..."
     *   }'
     * ```
     */
    @post
    @route("/api/v1/organizations/{organizationId}/join-requests")
    @summary("申请加入组织")
    createJoinRequest(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 创建申请请求
         * Create request
         */
        @body request: CreateJoinRequestRequest
    ): NexusBook.Api.Common.ApiResponse<JoinRequest>;

    /**
     * 列出加入申请
     * List join requests
     *
     * 获取组织的所有加入申请列表。需要 owner 或 admin 权限。
     * Get the list of all join requests of the organization. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/join-requests?status=pending' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/join-requests")
    @summary("列出加入申请")
    listJoinRequests(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 页码
         * Page number
         */
        @query page?: int32 = 1,

        /**
         * 每页数量
         * Page size
         */
        @query pageSize?: int32 = 20,

        /**
         * 按状态过滤
         * Filter by status
         */
        @query status?: JoinRequestStatus
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<JoinRequest>>;

    /**
     * 获取加入申请详情
     * Get join request detail
     *
     * 获取指定加入申请的详细信息。
     * Get detailed information of a specified join request.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/join-requests/req-789' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/join-requests/{requestId}")
    @summary("获取加入申请详情")
    getJoinRequest(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 申请ID
         * Request ID
         */
        @path requestId: string
    ): NexusBook.Api.Common.ApiResponse<JoinRequest>;

    /**
     * 批准加入申请
     * Approve join request
     *
     * 批准用户的加入申请，创建组织成员记录并发送通知。需要 owner 或 admin 权限。
     * Approve user's join request, create member record and send notification. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/organizations/org-123/join-requests/req-789/approve' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "role": "member",
     *     "reviewNote": "欢迎加入！"
     *   }'
     * ```
     */
    @post
    @route("/api/v1/organizations/{organizationId}/join-requests/{requestId}/approve")
    @summary("批准加入申请")
    approveJoinRequest(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 申请ID
         * Request ID
         */
        @path requestId: string,

        /**
         * 批准请求
         * Approve request
         */
        @body request: ApproveJoinRequestRequest
    ): NexusBook.Api.Common.ApiResponse<OrganizationMember>;

    /**
     * 拒绝加入申请
     * Reject join request
     *
     * 拒绝用户的加入申请并发送通知。需要 owner 或 admin 权限。
     * Reject user's join request and send notification. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/organizations/org-123/join-requests/req-789/reject' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "reviewNote": "很抱歉，暂时不符合我们的要求"
     *   }'
     * ```
     */
    @post
    @route("/api/v1/organizations/{organizationId}/join-requests/{requestId}/reject")
    @summary("拒绝加入申请")
    rejectJoinRequest(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 申请ID
         * Request ID
         */
        @path requestId: string,

        /**
         * 拒绝请求
         * Reject request
         */
        @body request: RejectJoinRequestRequest
    ): NexusBook.Api.Common.ApiResponse<JoinRequest>;

    /**
     * 取消加入申请（用户主动）
     * Cancel join request (user initiated)
     *
     * 用户取消自己的加入申请。仅申请创建者本人可操作。
     * User cancels their own join request. Only the applicant can perform this action.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.com/api/v1/organizations/org-123/join-requests/req-789' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/api/v1/organizations/{organizationId}/join-requests/{requestId}")
    @summary("取消加入申请")
    cancelJoinRequest(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 申请ID
         * Request ID
         */
        @path requestId: string
    ): NexusBook.Api.Common.ApiResponse<{}>;
}
