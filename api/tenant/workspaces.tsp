import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";
import "./models.tsp";

using TypeSpec.Http;
using OpenAPI;
using NexusBook.Api.Tenant;

/**
 * NexusBook Tenant Management - Workspace APIs
 * NexusBook 租户管理 - 工作区 API
 *
 * 提供工作区创建、管理、成员管理等功能。
 * Provides workspace creation, management, member management and other features.
 *
 * Route Base: /api/v1/organizations/{organizationId}/workspaces
 *
 * 主要接口 / Main Endpoints:
 * - POST / - 创建工作区 Create workspace
 * - GET / - 列出工作区 List workspaces
 * - GET /{workspaceId} - 获取工作区详情 Get workspace detail
 * - PATCH /{workspaceId} - 更新工作区 Update workspace
 * - POST /{workspaceId}/archive - 归档工作区 Archive workspace
 * - POST /{workspaceId}/restore - 恢复工作区 Restore workspace
 * - DELETE /{workspaceId} - 删除工作区 Delete workspace
 * - GET /{workspaceId}/members - 列出成员 List members
 * - POST /{workspaceId}/members - 添加成员 Add member
 * - PATCH /{workspaceId}/members/{userId} - 更新成员 Update member
 * - DELETE /{workspaceId}/members/{userId} - 移除成员 Remove member
 */
namespace NexusBook.Api.Tenant;

// ==================== 请求/响应模型 ====================

/**
 * 创建工作区请求
 * Create workspace request
 */
model CreateWorkspaceRequest {
    /**
     * 工作区名称（必填）
     * Workspace name (required)
     */
    name: string;

    /**
     * URL标识（组织内唯一，必填）
     * URL slug (unique within organization, required)
     */
    slug: string;

    /**
     * 工作区描述
     * Workspace description
     */
    description?: string;

    /**
     * 工作区图标
     * Workspace icon
     */
    icon?: string;

    /**
     * 主题颜色
     * Theme color
     */
    color?: string;

    /**
     * 可见性（默认 private）
     * Visibility (default: private)
     */
    visibility?: WorkspaceVisibility = WorkspaceVisibility.private;
}

/**
 * 更新工作区请求
 * Update workspace request
 */
model UpdateWorkspaceRequest {
    /**
     * 工作区名称
     * Workspace name
     */
    name?: string;

    /**
     * 工作区描述
     * Workspace description
     */
    description?: string;

    /**
     * 工作区图标
     * Workspace icon
     */
    icon?: string;

    /**
     * 主题颜色
     * Theme color
     */
    color?: string;

    /**
     * 可见性
     * Visibility
     */
    visibility?: WorkspaceVisibility;
}

/**
 * 工作区详情
 * Workspace detail
 *
 * 扩展的工作区信息，包含当前用户角色。
 * Extended workspace info including current user's role.
 */
model WorkspaceDetail extends Workspace {
    /**
     * 当前用户的角色
     * Current user's role
     */
    currentUserRole?: WorkspaceRole;

    /**
     * 负责人信息
     * Owner info
     */
    owner?: User;
}

/**
 * 添加工作区成员请求
 * Add workspace member request
 */
model AddWorkspaceMemberRequest {
    /**
     * 用户ID（必填，必须是组织成员）
     * User ID (required, must be organization member)
     */
    userId: string;

    /**
     * 角色（默认 editor）
     * Role (default: editor)
     */
    role?: WorkspaceRole = WorkspaceRole.editor;
}

/**
 * 更新工作区成员请求
 * Update workspace member request
 */
model UpdateWorkspaceMemberRequest {
    /**
     * 新角色
     * New role
     */
    role?: WorkspaceRole;

    /**
     * 状态
     * Status
     */
    status?: MemberStatus;
}

// ==================== API 接口定义 ====================

/**
 * 工作区 API 接口
 * Workspace API interface
 */
@tag("Workspaces")
@route("/api/v1/organizations/{organizationId}/workspaces")
interface WorkspaceApi {
    /**
     * 创建工作区
     * Create workspace
     *
     * 在组织下创建新工作区。需要 organization.owner 或 organization.admin 权限。
     * Create a new workspace under the organization. Requires organization.owner or organization.admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "产品团队",
     *     "slug": "product-team",
     *     "description": "产品开发工作区",
     *     "visibility": "private"
     *   }'
     * ```
     */
    @post
    @summary("创建工作区")
    create(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 创建请求
         * Create request
         */
        @body request: CreateWorkspaceRequest
    ): NexusBook.Api.Common.ApiResponse<Workspace>;

    /**
     * 列出组织的工作区
     * List organization's workspaces
     *
     * 获取组织下所有工作区列表，仅返回用户有权限访问的工作区。
     * Get the list of all workspaces under the organization. Only returns workspaces the user has permission to access.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces?page=1&pageSize=20' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @summary("列出组织的工作区")
    list(
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
         * 过滤可见性
         * Filter by visibility
         */
        @query visibility?: WorkspaceVisibility,

        /**
         * 是否包含归档的工作区
         * Whether to include archived workspaces
         */
        @query includeArchived?: boolean = false
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<Workspace>>;

    /**
     * 获取工作区详情
     * Get workspace detail
     *
     * 返回工作区的详细信息。需要是工作区成员。
     * Returns detailed workspace information. Requires workspace membership.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/{workspaceId}")
    @summary("获取工作区详情")
    get(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string
    ): NexusBook.Api.Common.ApiResponse<WorkspaceDetail>;

    /**
     * 更新工作区信息
     * Update workspace info
     *
     * 更新工作区的基本信息。需要 workspace.owner 权限。
     * Update workspace's basic information. Requires workspace.owner permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "新的工作区名称",
     *     "description": "更新后的描述"
     *   }'
     * ```
     */
    @patch
    @route("/{workspaceId}")
    @summary("更新工作区信息")
    update(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string,

        /**
         * 更新请求
         * Update request
         */
        @body request: UpdateWorkspaceRequest
    ): NexusBook.Api.Common.ApiResponse<Workspace>;

    /**
     * 归档工作区
     * Archive workspace
     *
     * 归档工作区。需要 workspace.owner 或 organization.owner/admin 权限。
     * Archive workspace. Requires workspace.owner or organization.owner/admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456/archive' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @post
    @route("/{workspaceId}/archive")
    @summary("归档工作区")
    archive(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string
    ): NexusBook.Api.Common.ApiResponse<Workspace>;

    /**
     * 恢复归档的工作区
     * Restore archived workspace
     *
     * 恢复已归档的工作区。需要 workspace.owner 或 organization.owner/admin 权限。
     * Restore an archived workspace. Requires workspace.owner or organization.owner/admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456/restore' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @post
    @route("/{workspaceId}/restore")
    @summary("恢复归档的工作区")
    restore(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string
    ): NexusBook.Api.Common.ApiResponse<Workspace>;

    /**
     * 删除工作区
     * Delete workspace
     *
     * 软删除工作区。需要 workspace.owner 或 organization.owner 权限。
     * Soft delete workspace. Requires workspace.owner or organization.owner permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/{workspaceId}")
    @summary("删除工作区")
    delete(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string
    ): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 列出工作区成员
     * List workspace members
     *
     * 获取工作区的所有成员列表。需要是工作区成员。
     * Get the list of all workspace members. Requires workspace membership.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456/members' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/{workspaceId}/members")
    @summary("列出工作区成员")
    listMembers(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string,

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
         * 按角色过滤
         * Filter by role
         */
        @query role?: WorkspaceRole
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<WorkspaceMember>>;

    /**
     * 添加工作区成员
     * Add workspace member
     *
     * 将用户添加为工作区成员。需要 workspace.owner 权限。用户必须是组织成员。
     * Add a user as workspace member. Requires workspace.owner permission. User must be organization member.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456/members' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "userId": "user-789",
     *     "role": "editor"
     *   }'
     * ```
     */
    @post
    @route("/{workspaceId}/members")
    @summary("添加工作区成员")
    addMember(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string,

        /**
         * 添加成员请求
         * Add member request
         */
        @body request: AddWorkspaceMemberRequest
    ): NexusBook.Api.Common.ApiResponse<WorkspaceMember>;

    /**
     * 获取工作区成员详情
     * Get workspace member detail
     *
     * 获取指定成员的详细信息。
     * Get detailed information of a specified member.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456/members/member-999' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/{workspaceId}/members/{memberId}")
    @summary("获取工作区成员详情")
    getMember(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string,

        /**
         * 成员ID
         * Member ID
         */
        @path memberId: string
    ): NexusBook.Api.Common.ApiResponse<WorkspaceMember>;

    /**
     * 更新工作区成员角色
     * Update workspace member role
     *
     * 更新工作区成员的角色或状态。需要 workspace.owner 权限。
     * Update workspace member's role or status. Requires workspace.owner permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456/members/member-999' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "role": "viewer"
     *   }'
     * ```
     */
    @patch
    @route("/{workspaceId}/members/{memberId}")
    @summary("更新工作区成员角色")
    updateMember(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string,

        /**
         * 成员ID
         * Member ID
         */
        @path memberId: string,

        /**
         * 更新请求
         * Update request
         */
        @body request: UpdateWorkspaceMemberRequest
    ): NexusBook.Api.Common.ApiResponse<WorkspaceMember>;

    /**
     * 移除工作区成员
     * Remove workspace member
     *
     * 从工作区移除成员。需要 workspace.owner 权限。
     * Remove a member from the workspace. Requires workspace.owner permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456/members/member-999' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/{workspaceId}/members/{memberId}")
    @summary("移除工作区成员")
    removeMember(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string,

        /**
         * 成员ID
         * Member ID
         */
        @path memberId: string
    ): NexusBook.Api.Common.ApiResponse<{}>;
}
