import "@typespec/http";
import "@typespec/openapi3";

import "./models.tsp";
import "./users.tsp";
import "./organizations.tsp";
import "./workspaces.tsp";
import "./invitations.tsp";

/**
 * NexusBook Tenant Management Module
 * NexusBook 租户管理模块
 *
 * 提供用户、组织、工作区等多租户管理功能。
 * Provides multi-tenant management features including users, organizations, and workspaces.
 *
 * 主要模块 / Main Modules:
 * - models.tsp - 核心数据模型定义 Core data model definitions
 * - users.tsp - 用户管理 API User management APIs
 * - organizations.tsp - 组织管理 API Organization management APIs
 * - workspaces.tsp - 工作区管理 API Workspace management APIs
 * - invitations.tsp - 邀请和加入申请 API Invitation and join request APIs
 */
