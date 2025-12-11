import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";
import "./models.tsp";

using TypeSpec.Http;
using OpenAPI;
using NexusBook.Api.Tenant;

/**
 * NexusBook Tenant Management - User APIs
 * NexusBook 租户管理 - 用户 API
 *
 * 提供用户信息查询、更新、OAuth 绑定等功能。
 * Provides user info retrieval, updates, OAuth binding and other features.
 *
 * Route Base: /api/v1/users
 *
 * 主要接口 / Main Endpoints:
 * - GET /me - 获取当前用户信息 Get current user info
 * - PATCH /me - 更新用户信息 Update user info
 * - POST /me/oauth/{provider} - 绑定 OAuth Bind OAuth provider
 * - DELETE /me/oauth/{provider} - 解绑 OAuth Unbind OAuth provider
 * - GET /me/organizations - 列出加入的组织 List joined organizations
 */
namespace NexusBook.Api.Tenant;

// ==================== 请求/响应模型 ====================

/**
 * 更新用户请求
 * Update user request
 */
model UpdateUserRequest {
    /**
     * 显示名称
     * Display name
     */
    displayName?: string;

    /**
     * 头像URL
     * Avatar URL
     */
    avatarUrl?: string;

    /**
     * 语言偏好
     * Language preference
     */
    locale?: string;

    /**
     * 时区
     * Timezone
     */
    timezone?: string;

    /**
     * 默认组织ID
     * Default organization ID
     */
    defaultOrganizationId?: string;

    /**
     * 默认工作区ID
     * Default workspace ID
     */
    defaultWorkspaceId?: string;
}

/**
 * 绑定 OAuth 请求
 * Bind OAuth request
 */
model BindOAuthRequest {
    /**
     * OAuth 授权码
     * OAuth authorization code
     */
    authorizationCode: string;

    /**
     * 重定向 URI
     * Redirect URI
     */
    redirectUri?: string;
}

/**
 * 用户组织成员信息
 * User organization membership
 *
 * 包含用户在组织中的角色和状态信息。
 * Includes user's role and status in the organization.
 */
model UserOrganizationMembership {
    /**
     * 组织信息
     * Organization info
     */
    organization: Organization;

    /**
     * 成员信息
     * Membership info
     */
    membership: OrganizationMember;
}

// ==================== API 接口定义 ====================

/**
 * 用户 API 接口
 * User API interface
 */
@tag("Users")
@route("/api/v1/users")
interface UserApi {
    /**
     * 获取当前用户信息
     * Get current user info
     *
     * 返回当前登录用户的完整信息，包括默认组织和工作区。
     * Returns complete info of the current logged-in user, including default organization and workspace.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/users/me' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/me")
    @summary("获取当前用户信息")
    getCurrentUser(): NexusBook.Api.Common.ApiResponse<User>;

    /**
     * 更新当前用户信息
     * Update current user info
     *
     * 更新当前用户的个人信息和偏好设置。
     * Update personal information and preferences of the current user.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.app/api/v1/users/me' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "displayName": "张三",
     *     "locale": "zh-CN",
     *     "timezone": "Asia/Shanghai"
     *   }'
     * ```
     */
    @patch
    @route("/me")
    @summary("更新当前用户信息")
    updateCurrentUser(@body request: UpdateUserRequest): NexusBook.Api.Common.ApiResponse<User>;

    /**
     * 绑定 OAuth 提供商
     * Bind OAuth provider
     *
     * 将第三方 OAuth 提供商与当前用户账号关联。
     * Associate a third-party OAuth provider with the current user account.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/users/me/oauth/github' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "authorizationCode": "AUTH_CODE_FROM_GITHUB"
     *   }'
     * ```
     */
    @post
    @route("/me/oauth/{provider}")
    @summary("绑定 OAuth 提供商")
    bindOAuthProvider(
        /**
         * OAuth 提供商名称
         * OAuth provider name
         */
        @path provider: OAuthProvider,

        /**
         * 绑定请求
         * Bind request
         */
        @body request: BindOAuthRequest
    ): NexusBook.Api.Common.ApiResponse<OAuthConnection>;

    /**
     * 解绑 OAuth 提供商
     * Unbind OAuth provider
     *
     * 移除当前用户与指定 OAuth 提供商的关联。
     * Remove the association between current user and specified OAuth provider.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.app/api/v1/users/me/oauth/github' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/me/oauth/{provider}")
    @summary("解绑 OAuth 提供商")
    unbindOAuthProvider(
        /**
         * OAuth 提供商名称
         * OAuth provider name
         */
        @path provider: OAuthProvider
    ): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 列出当前用户的 OAuth 连接
     * List current user's OAuth connections
     *
     * 获取当前用户已绑定的所有 OAuth 提供商列表。
     * Get the list of all OAuth providers bound to the current user.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/users/me/oauth' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/me/oauth")
    @summary("列出 OAuth 连接")
    listOAuthConnections(): NexusBook.Api.Common.ApiResponse<OAuthConnection[]>;

    /**
     * 列出用户加入的组织
     * List user's organizations
     *
     * 返回用户作为成员的所有组织列表，包含角色信息。
     * Returns the list of all organizations where the user is a member, including role information.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/users/me/organizations?page=1&pageSize=20' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/me/organizations")
    @summary("列出用户加入的组织")
    listUserOrganizations(
        /**
         * 页码（从1开始）
         * Page number (starts from 1)
         */
        @query page?: int32 = 1,

        /**
         * 每页数量
         * Page size
         */
        @query pageSize?: int32 = 20
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<UserOrganizationMembership>>;
}
