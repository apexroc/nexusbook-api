import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";
import "./models.tsp";

using TypeSpec.Http;
using OpenAPI;
using NexusBook.Tenant;

/**
 * 组织管理模块
 *
 * 提供组织创建、管理、成员管理等功能。
 *
 * 主要接口：
 * - 创建和管理组织
 * - 组织成员管理（添加、移除、角色变更）
 * - 用户离开组织
 */
namespace NexusBook.Api;

// ==================== 请求/响应模型 ====================

/**
 * 创建组织请求
 * Create organization request
 */
model CreateOrganizationRequest {
    /**
     * 组织名称（必填）
     * Organization name (required)
     */
    name: string;

    /**
     * URL标识（必填，全局唯一）
     * URL slug (required, globally unique)
     */
    slug: string;

    /**
     * 显示名称
     * Display name
     */
    displayName?: string;

    /**
     * 组织描述
     * Organization description
     */
    description?: string;

    /**
     * 组织类型
     * Organization type
     */
    type: OrganizationType;

    /**
     * 组织设置
     * Organization settings
     */
    settings?: OrganizationSettings;
}

/**
 * 更新组织请求
 * Update organization request
 */
model UpdateOrganizationRequest {
    /**
     * 组织名称
     * Organization name
     */
    name?: string;

    /**
     * 显示名称
     * Display name
     */
    displayName?: string;

    /**
     * 组织描述
     * Organization description
     */
    description?: string;

    /**
     * Logo URL
     * Logo URL
     */
    logoUrl?: string;

    /**
     * 组织设置
     * Organization settings
     */
    settings?: OrganizationSettings;
}

/**
 * 组织详情
 * Organization detail
 *
 * 扩展的组织信息，包含当前用户角色和所有者信息。
 * Extended organization info including current user's role and owner info.
 */
model OrganizationDetail extends Organization {
    /**
     * 当前用户的角色
     * Current user's role
     */
    currentUserRole?: OrganizationRole;

    /**
     * 所有者信息
     * Owner info
     */
    owner?: User;
}

/**
 * 添加组织成员请求
 * Add organization member request
 */
model AddOrganizationMemberRequest {
    /**
     * 用户ID（必填）
     * User ID (required)
     */
    userId: string;

    /**
     * 角色（默认 member）
     * Role (default: member)
     */
    role?: OrganizationRole = OrganizationRole.member;
}

/**
 * 更新组织成员请求
 * Update organization member request
 */
model UpdateOrganizationMemberRequest {
    /**
     * 新角色
     * New role
     */
    role?: OrganizationRole;

    /**
     * 状态
     * Status
     */
    status?: MemberStatus;
}

// ==================== API 接口定义 ====================

/**
 * 组织 API 接口
 * Organization API interface
 */
@tag("Organizations")
@route("/api/v1/organizations")
interface OrganizationApi {
    /**
     * 创建组织
     * Create organization
     *
     * 创建一个新组织，创建者自动成为 owner，并自动创建一个默认工作区。
     * Create a new organization. The creator automatically becomes the owner, and a default workspace is created automatically.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/organizations' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "我的团队",
     *     "slug": "my-team",
     *     "type": "team",
     *     "description": "团队描述"
     *   }'
     * ```
     */
    @post
    @summary("创建组织")
    create(@body request: CreateOrganizationRequest): NexusBook.Common.ApiResponse<Organization>;

    /**
     * 获取组织详情
     * Get organization detail
     *
     * 返回组织的详细信息，包括当前用户的角色和统计数据。
     * Returns detailed organization information including current user's role and statistics.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/{organizationId}")
    @summary("获取组织详情")
    get(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string
    ): NexusBook.Common.ApiResponse<OrganizationDetail>;

    /**
     * 更新组织信息
     * Update organization info
     *
     * 更新组织的基本信息和设置。需要 owner 或 admin 权限。
     * Update organization's basic information and settings. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.com/api/v1/organizations/org-123' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "displayName": "新的显示名称",
     *     "description": "更新后的描述"
     *   }'
     * ```
     */
    @patch
    @route("/{organizationId}")
    @summary("更新组织信息")
    update(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 更新请求
         * Update request
         */
        @body request: UpdateOrganizationRequest
    ): NexusBook.Common.ApiResponse<Organization>;

    /**
     * 删除组织
     * Delete organization
     *
     * 软删除组织（标记为 archived）。仅 owner 可以执行此操作。
     * Soft delete organization (mark as archived). Only owner can perform this action.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.com/api/v1/organizations/org-123' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/{organizationId}")
    @summary("删除组织")
    delete(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string
    ): NexusBook.Common.ApiResponse<{}>;

    /**
     * 列出组织成员
     * List organization members
     *
     * 获取组织的所有成员列表，支持按角色、状态过滤和搜索。
     * Get the list of all organization members, supporting filtering by role, status and search.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/members?page=1&pageSize=20&role=admin' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/{organizationId}/members")
    @summary("列出组织成员")
    listMembers(
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
         * 按角色过滤
         * Filter by role
         */
        @query role?: OrganizationRole,

        /**
         * 按状态过滤
         * Filter by status
         */
        @query status?: MemberStatus,

        /**
         * 搜索成员（名称、邮箱）
         * Search members (name, email)
         */
        @query search?: string
    ): NexusBook.Common.ApiResponse<NexusBook.Common.Page<OrganizationMember>>;

    /**
     * 添加组织成员（直接添加）
     * Add organization member (direct add)
     *
     * 直接将用户添加为组织成员。需要 owner 或 admin 权限。
     * Directly add a user as an organization member. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/organizations/org-123/members' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "userId": "user-456",
     *     "role": "member"
     *   }'
     * ```
     */
    @post
    @route("/{organizationId}/members")
    @summary("添加组织成员")
    addMember(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 添加成员请求
         * Add member request
         */
        @body request: AddOrganizationMemberRequest
    ): NexusBook.Common.ApiResponse<OrganizationMember>;

    /**
     * 获取组织成员详情
     * Get organization member detail
     *
     * 获取指定成员的详细信息。
     * Get detailed information of a specified member.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/members/member-789' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/{organizationId}/members/{memberId}")
    @summary("获取组织成员详情")
    getMember(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 成员ID
         * Member ID
         */
        @path memberId: string
    ): NexusBook.Common.ApiResponse<OrganizationMember>;

    /**
     * 更新成员角色
     * Update member role
     *
     * 更新组织成员的角色或状态。需要 owner 或 admin 权限。
     * Update organization member's role or status. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.com/api/v1/organizations/org-123/members/member-789' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "role": "admin"
     *   }'
     * ```
     */
    @patch
    @route("/{organizationId}/members/{memberId}")
    @summary("更新成员角色")
    updateMember(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 成员ID
         * Member ID
         */
        @path memberId: string,

        /**
         * 更新请求
         * Update request
         */
        @body request: UpdateOrganizationMemberRequest
    ): NexusBook.Common.ApiResponse<OrganizationMember>;

    /**
     * 移除组织成员
     * Remove organization member
     *
     * 从组织中移除成员。需要 owner 或 admin 权限，不能移除 owner。
     * Remove a member from the organization. Requires owner or admin permission. Cannot remove owner.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.com/api/v1/organizations/org-123/members/member-789' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/{organizationId}/members/{memberId}")
    @summary("移除组织成员")
    removeMember(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 成员ID
         * Member ID
         */
        @path memberId: string
    ): NexusBook.Common.ApiResponse<{}>;

    /**
     * 离开组织（用户主动）
     * Leave organization (user initiated)
     *
     * 用户主动离开组织。owner 不能离开，需先转让所有权。
     * User leaves the organization voluntarily. Owner cannot leave without transferring ownership first.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/organizations/org-123/leave' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @post
    @route("/{organizationId}/leave")
    @summary("离开组织")
    leave(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string
    ): NexusBook.Common.ApiResponse<{}>;
}
