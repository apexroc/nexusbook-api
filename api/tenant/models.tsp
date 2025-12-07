import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * NexusBook Tenant Management - Data Models
 * NexusBook 租户管理 - 数据模型
 *
 * 定义用户、组织、工作区等核心数据模型和枚举类型。
 * Defines core data models and enumerations for users, organizations, and workspaces.
 *
 * Route Base: N/A (模型定义，无路由 / Model definitions, no routes)
 *
 * 主要内容 / Main Components:
 * - **用户模型 User Models** - 用户信息、状态、OAuth 连接
 * - **组织模型 Organization Models** - 组织信息、成员、设置
 * - **工作区模型 Workspace Models** - 工作区信息、成员、权限
 * - **邀请模型 Invitation Models** - 邀请和加入申请
 */
namespace NexusBook.Api.Tenant;

// ==================== 用户相关模型 ====================

/**
 * 用户状态枚举
 * User status enum
 */
enum UserStatus {
    /**
     * 活跃
     * Active
     */
    active,

    /**
     * 已暂停
     * Suspended
     */
    suspended,

    /**
     * 已删除
     * Deleted
     */
    deleted,
}

/**
 * 用户模型
 * User model
 *
 * 用户是系统中最基础的身份实体，支持多种登录方式。
 * User is the fundamental identity entity in the system, supporting multiple login methods.
 */
model User {
    /**
     * 用户唯一标识
     * User unique identifier
     */
    id: string;

    /**
     * 用户名（可用于登录）
     * Username (can be used for login)
     */
    username?: string;

    /**
     * 邮箱地址（主要标识）
     * Email address (primary identifier)
     */
    email: string;

    /**
     * 邮箱是否已验证
     * Whether email is verified
     */
    emailVerified?: boolean;

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
     * 语言偏好（zh-CN, en-US等）
     * Language preference (zh-CN, en-US, etc.)
     */
    locale?: string;

    /**
     * 时区
     * Timezone
     */
    timezone?: string;

    /**
     * 用户状态
     * User status
     */
    status: UserStatus;

    /**
     * 默认组织ID
     * Default organization ID
     */
    defaultOrganizationId?: string;

    /**
     * 当前活动工作区ID
     * Current active workspace ID
     */
    defaultWorkspaceId?: string;

    /**
     * 创建时间（ISO 8601）
     * Created at (ISO 8601)
     */
    createdAt: string;

    /**
     * 更新时间（ISO 8601）
     * Updated at (ISO 8601)
     */
    updatedAt: string;

    /**
     * 最后登录时间
     * Last login at
     */
    lastLoginAt?: string;
}

/**
 * OAuth 提供商枚举
 * OAuth provider enum
 */
enum OAuthProvider {
    /**
     * Google
     */
    google,

    /**
     * GitHub
     */
    github,

    /**
     * 微信
     * WeChat
     */
    wechat,

    /**
     * 钉钉
     * DingTalk
     */
    dingtalk,

    /**
     * 飞书
     * Feishu/Lark
     */
    feishu,
}

/**
 * OAuth 连接信息
 * OAuth connection info
 *
 * 存储用户与第三方身份提供商的关联信息。
 * Stores the association between user and third-party identity providers.
 */
model OAuthConnection {
    /**
     * 关联的用户ID
     * Associated user ID
     */
    userId: string;

    /**
     * 提供商
     * Provider
     */
    provider: OAuthProvider;

    /**
     * 提供商的用户ID
     * Provider's user ID
     */
    providerId: string;

    /**
     * 提供商的邮箱
     * Provider's email
     */
    providerEmail?: string;

    /**
     * 关联时间
     * Linked at
     */
    linkedAt: string;
}

// ==================== 组织相关模型 ====================

/**
 * 组织类型枚举
 * Organization type enum
 */
enum OrganizationType {
    /**
     * 个人组织
     * Personal organization
     */
    personal,

    /**
     * 团队
     * Team
     */
    team,

    /**
     * 企业
     * Enterprise
     */
    enterprise,
}

/**
 * 组织状态枚举
 * Organization status enum
 */
enum OrganizationStatus {
    /**
     * 活跃
     * Active
     */
    active,

    /**
     * 已暂停
     * Suspended
     */
    suspended,

    /**
     * 已归档
     * Archived
     */
    archived,
}

/**
 * 组织设置
 * Organization settings
 */
model OrganizationSettings {
    /**
     * 是否允许公开加入
     * Whether to allow public join
     */
    allowPublicJoin?: boolean;

    /**
     * 加入是否需要审批
     * Whether join requires approval
     */
    requireApproval?: boolean;

    /**
     * 邀请链接有效期（天）
     * Invitation link expiration days
     */
    inviteExpireDays?: int32;

    /**
     * 新成员默认角色
     * Default role for new members
     */
    defaultRole?: OrganizationRole;

    /**
     * 允许的邮箱域名白名单
     * Allowed email domains whitelist
     */
    allowedDomains?: string[];
}

/**
 * 组织模型
 * Organization model
 *
 * 组织是用户协作的基本单元，每个用户注册后自动创建一个个人组织。
 * Organization is the basic unit of user collaboration. Each user automatically creates a personal organization upon registration.
 */
model Organization {
    /**
     * 组织唯一标识
     * Organization unique identifier
     */
    id: string;

    /**
     * 组织名称
     * Organization name
     */
    name: string;

    /**
     * 显示名称
     * Display name
     */
    displayName?: string;

    /**
     * URL友好的唯一标识
     * URL-friendly unique identifier
     */
    slug: string;

    /**
     * 组织描述
     * Organization description
     */
    description?: string;

    /**
     * 组织Logo
     * Organization logo
     */
    logoUrl?: string;

    /**
     * 组织类型
     * Organization type
     */
    type: OrganizationType;

    /**
     * 组织所有者用户ID
     * Organization owner user ID
     */
    ownerId: NexusBook.Api.Common.UserRef;

    /**
     * 状态
     * Status
     */
    status: OrganizationStatus;

    /**
     * 组织设置
     * Organization settings
     */
    settings?: OrganizationSettings;

    /**
     * 成员数量
     * Member count
     */
    memberCount?: int32;

    /**
     * 工作区数量
     * Workspace count
     */
    workspaceCount?: int32;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt: string;
}

/**
 * 组织角色枚举
 * Organization role enum
 */
enum OrganizationRole {
    /**
     * 组织拥有者，拥有所有权限，包括删除组织
     * Organization owner, has all permissions including deleting the organization
     */
    owner,

    /**
     * 管理员，可管理成员、工作区、组织设置
     * Admin, can manage members, workspaces, and organization settings
     */
    admin,

    /**
     * 普通成员，可访问被授权的工作区
     * Regular member, can access authorized workspaces
     */
    member,

    /**
     * 访客，仅能访问特定资源
     * Guest, can only access specific resources
     */
    guest,
}

/**
 * 成员状态枚举
 * Member status enum
 */
enum MemberStatus {
    /**
     * 活跃
     * Active
     */
    active,

    /**
     * 已暂停
     * Suspended
     */
    suspended,
}

/**
 * 组织成员模型
 * Organization member model
 *
 * 表示用户在组织中的成员关系和权限。
 * Represents user's membership and permissions in an organization.
 */
model OrganizationMember {
    /**
     * 成员记录唯一标识
     * Member record unique identifier
     */
    id: string;

    /**
     * 所属组织ID
     * Organization ID
     */
    organizationId: string;

    /**
     * 用户ID
     * User ID
     */
    userId: string;

    /**
     * 用户信息（可选包含）
     * User info (optionally included)
     */
    user?: User;

    /**
     * 角色
     * Role
     */
    role: OrganizationRole;

    /**
     * 状态
     * Status
     */
    status: MemberStatus;

    /**
     * 加入时间
     * Joined at
     */
    joinedAt: string;

    /**
     * 邀请人用户ID
     * Inviter user ID
     */
    invitedBy?: NexusBook.Api.Common.UserRef;

    /**
     * 批准人用户ID
     * Approver user ID
     */
    approvedBy?: NexusBook.Api.Common.UserRef;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt: string;
}

// ==================== 工作区相关模型 ====================

/**
 * 工作区可见性枚举
 * Workspace visibility enum
 */
enum WorkspaceVisibility {
    /**
     * 组织内所有成员可见
     * Visible to all organization members
     */
    `public`,

    /**
     * 仅成员可见
     * Visible to members only
     */
    `private`,
}

/**
 * 工作区模型
 * Workspace model
 *
 * 工作区是实际业务开展的容器，大部分文档操作在工作区内进行。
 * Workspace is the container for actual business operations. Most document operations are performed within workspaces.
 */
model Workspace {
    /**
     * 工作区唯一标识
     * Workspace unique identifier
     */
    id: string;

    /**
     * 所属组织ID
     * Organization ID
     */
    organizationId: string;

    /**
     * 工作区名称
     * Workspace name
     */
    name: string;

    /**
     * URL友好标识（组织内唯一）
     * URL-friendly identifier (unique within organization)
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
     * 是否为默认工作区
     * Whether it's the default workspace
     */
    isDefault: boolean;

    /**
     * 可见性
     * Visibility
     */
    visibility: WorkspaceVisibility;

    /**
     * 工作区负责人
     * Workspace owner
     */
    ownerId: NexusBook.Api.Common.UserRef;

    /**
     * 工作区设置
     * Workspace settings
     */
    settings?: {};

    /**
     * 成员数量
     * Member count
     */
    memberCount?: int32;

    /**
     * 文档数量
     * Document count
     */
    documentCount?: int32;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt: string;

    /**
     * 归档时间
     * Archived at
     */
    archivedAt?: string;
}

/**
 * 工作区角色枚举
 * Workspace role enum
 */
enum WorkspaceRole {
    /**
     * 工作区负责人，可管理工作区和成员
     * Workspace owner, can manage workspace and members
     */
    owner,

    /**
     * 编辑者，可创建和编辑文档
     * Editor, can create and edit documents
     */
    editor,

    /**
     * 查看者，只读权限
     * Viewer, read-only permission
     */
    viewer,
}

/**
 * 工作区成员模型
 * Workspace member model
 *
 * 表示用户在特定工作区中的访问权限。
 * Represents user's access permissions in a specific workspace.
 */
model WorkspaceMember {
    /**
     * 成员记录唯一标识
     * Member record unique identifier
     */
    id: string;

    /**
     * 工作区ID
     * Workspace ID
     */
    workspaceId: string;

    /**
     * 用户ID
     * User ID
     */
    userId: string;

    /**
     * 用户信息（可选包含）
     * User info (optionally included)
     */
    user?: User;

    /**
     * 角色
     * Role
     */
    role: WorkspaceRole;

    /**
     * 状态
     * Status
     */
    status: MemberStatus;

    /**
     * 加入时间
     * Joined at
     */
    joinedAt: string;

    /**
     * 添加者用户ID
     * Added by user ID
     */
    addedBy?: NexusBook.Api.Common.UserRef;
}

// ==================== 邀请相关模型 ====================

/**
 * 邀请状态枚举
 * Invitation status enum
 */
enum InvitationStatus {
    /**
     * 待处理
     * Pending
     */
    pending,

    /**
     * 已接受
     * Accepted
     */
    accepted,

    /**
     * 已过期
     * Expired
     */
    expired,

    /**
     * 已撤销
     * Revoked
     */
    revoked,
}

/**
 * 邀请模型
 * Invitation model
 *
 * 用于邀请用户加入组织。
 * Used to invite users to join an organization.
 */
model Invitation {
    /**
     * 邀请唯一标识
     * Invitation unique identifier
     */
    id: string;

    /**
     * 目标组织ID
     * Target organization ID
     */
    organizationId: string;

    /**
     * 被邀请人邮箱
     * Invitee email
     */
    email: string;

    /**
     * 邀请人用户ID
     * Inviter user ID
     */
    inviterUserId: NexusBook.Api.Common.UserRef;

    /**
     * 邀请人信息（可选包含）
     * Inviter info (optionally included)
     */
    inviter?: User;

    /**
     * 邀请角色
     * Invited role
     */
    role: OrganizationRole;

    /**
     * 邀请令牌（用于链接）
     * Invitation token (for link)
     */
    token: string;

    /**
     * 邀请留言
     * Invitation message
     */
    message?: string;

    /**
     * 状态
     * Status
     */
    status: InvitationStatus;

    /**
     * 过期时间
     * Expires at
     */
    expiresAt: string;

    /**
     * 接受时间
     * Accepted at
     */
    acceptedAt?: string;

    /**
     * 接受者用户ID
     * Acceptor user ID
     */
    acceptedByUserId?: string;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;
}

/**
 * 加入申请状态枚举
 * Join request status enum
 */
enum JoinRequestStatus {
    /**
     * 待处理
     * Pending
     */
    pending,

    /**
     * 已批准
     * Approved
     */
    approved,

    /**
     * 已拒绝
     * Rejected
     */
    rejected,

    /**
     * 已取消
     * Cancelled
     */
    cancelled,
}

/**
 * 加入申请模型
 * Join request model
 *
 * 用户申请加入组织的记录。
 * Record of user's request to join an organization.
 */
model JoinRequest {
    /**
     * 申请唯一标识
     * Request unique identifier
     */
    id: string;

    /**
     * 目标组织ID
     * Target organization ID
     */
    organizationId: string;

    /**
     * 申请人用户ID
     * Applicant user ID
     */
    userId: string;

    /**
     * 申请人信息（可选包含）
     * Applicant info (optionally included)
     */
    user?: User;

    /**
     * 申请说明
     * Application message
     */
    message?: string;

    /**
     * 状态
     * Status
     */
    status: JoinRequestStatus;

    /**
     * 审核人用户ID
     * Reviewer user ID
     */
    reviewedBy?: string;

    /**
     * 审核人信息（可选包含）
     * Reviewer info (optionally included)
     */
    reviewer?: User;

    /**
     * 审核备注
     * Review note
     */
    reviewNote?: string;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 审核时间
     * Reviewed at
     */
    reviewedAt?: string;
}
