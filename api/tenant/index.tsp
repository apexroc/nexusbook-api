import "@typespec/http";
import "@typespec/openapi3";

import "./models.tsp";
import "./users.tsp";
import "./organizations.tsp";
import "./workspaces.tsp";
import "./invitations.tsp";

/**
 * 租户管理模块入口
 *
 * 提供用户、组织、工作区等多租户管理功能。
 *
 * 主要模块：
 * - models.tsp - 核心数据模型定义
 * - users.tsp - 用户管理 API
 * - organizations.tsp - 组织管理 API
 * - workspaces.tsp - 工作区管理 API
 * - invitations.tsp - 邀请和加入申请 API
 */
