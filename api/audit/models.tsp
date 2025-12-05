/**
 * NexusBook Audit & Compliance Models
 * 审计与合规数据模型
 */
import "@typespec/http";

import "../shared/common.tsp";

using TypeSpec.Http;

namespace NexusBook.Api.Audit;

/**
 * 枚举定义
 */

/** 操作者类型 */
enum ActorType {
  /** 用户 */
  user,
  /** API 密钥 */
  apikey,
  /** 系统 */
  system,
  /** Webhook */
  webhook,
}

/** 操作分类 */
enum ActionCategory {
  /** 认证 */
  authentication,
  /** 授权 */
  authorization,
  /** 数据访问 */
  data_access,
  /** 数据修改 */
  data_modification,
  /** 配置变更 */
  configuration,
  /** 用户管理 */
  user_management,
  /** 权限管理 */
  permission_management,
  /** 计费 */
  billing,
  /** 安全 */
  security,
  /** 合规 */
  compliance,
}

/** 资源类型 */
enum ResourceType {
  /** 用户 */
  user,
  /** 组织 */
  organization,
  /** 工作区 */
  workspace,
  /** 文档 */
  document,
  /** 数据行 */
  data_row,
  /** 视图 */
  view,
  /** 评论 */
  comment,
  /** API 密钥 */
  apikey,
  /** Webhook */
  webhook,
  /** 订阅 */
  subscription,
  /** 账单 */
  invoice,
}

/** 操作结果状态 */
enum ResultStatus {
  /** 成功 */
  success,
  /** 失败 */
  failure,
  /** 部分成功 */
  partial,
}

/** 变更类型 */
enum ChangeType {
  /** 创建 */
  create,
  /** 更新 */
  update,
  /** 删除 */
  delete,
}

/**
 * 数据模型
 */

/** 地理位置 */
model Location {
  /** 国家 */
  country?: string;

  /** 地区 */
  region?: string;

  /** 城市 */
  city?: string;

  /** 时区 */
  timezone?: string;
}

/** 审计上下文 */
model AuditContext {
  /** IP 地址 */
  ipAddress?: string;

  /** User Agent */
  userAgent?: string;

  /** 地理位置 */
  location?: Location;

  /** 会话 ID */
  sessionId?: string;

  /** 请求 ID */
  requestId?: string;
}

/** 操作者信息 */
model AuditActor {
  /** 类型 */
  type: ActorType;

  /** ID */
  id: string;

  /** 显示名称 */
  displayName?: string;

  /** 邮箱 */
  email?: string;

  /** 角色 */
  role?: string;
}

/** 审计操作 */
model AuditAction {
  /** 分类 */
  category: ActionCategory;

  /** 操作名称 */
  name: string;

  /** 描述（多语言） */
  description?: NexusBook.Api.Common.Message;
}

/** 审计资源 */
model AuditResource {
  /** 资源类型 */
  type: ResourceType;

  /** 资源 ID */
  id: string;

  /** 资源名称 */
  name?: string;

  /** 父资源类型 */
  parentType?: ResourceType;

  /** 父资源 ID */
  parentId?: string;
}

/** 审计结果 */
model AuditResult {
  /** 状态 */
  status: ResultStatus;

  /** 错误码 */
  errorCode?: NexusBook.Api.Common.ErrorCode;

  /** 错误消息（多语言） */
  errorMessage?: NexusBook.Api.Common.Message;
}

/** 审计变更 */
model AuditChange {
  /** 字段名 */
  field: string;

  /** 旧值 */
  oldValue?: unknown;

  /** 新值 */
  newValue?: unknown;

  /** 变更类型 */
  changeType: ChangeType;
}

/** 审计日志 */
model AuditLog {
  /** 日志唯一标识 */
  id: string;

  /** 组织 ID */
  organizationId?: string;

  /** 工作区 ID（可选） */
  workspaceId?: string;

  /** 操作者信息 */
  actor: AuditActor;

  /** 操作类型 */
  action: AuditAction;

  /** 资源信息 */
  resource: AuditResource;

  /** 操作结果 */
  result: AuditResult;

  /** 变更详情 */
  changes?: AuditChange[];

  /** 上下文信息 */
  context: AuditContext;

  /** 时间戳 */
  timestamp: string;

  /** 额外元数据 */
  metadata?: Record<string>;
}

/** 操作统计 */
model ActionStat {
  /** 操作名称 */
  actionName: string;

  /** 次数 */
  count: int64;
}

/** 操作者统计 */
model ActorStat {
  /** 操作者 ID */
  actorId: string;

  /** 操作者名称 */
  actorName: string;

  /** 次数 */
  count: int64;
}

/** 资源统计 */
model ResourceStat {
  /** 资源类型 */
  resourceType: ResourceType;

  /** 次数 */
  count: int64;
}

/** 时间线统计 */
model TimelineStat {
  /** 时间戳 */
  timestamp: string;

  /** 次数 */
  count: int64;
}

/** 数据访问日志 */
model DataAccessLog {
  /** 时间戳 */
  timestamp: string;

  /** 访问者 */
  accessor: AuditActor;

  /** 数据类型 */
  dataType: string;

  /** 数据 ID */
  dataId: string;

  /** 操作 */
  operation: string;

  /** 目的 */
  purpose?: string;
}

/** 数据保留策略 */
model RetentionPolicy {
  /** 数据类型 */
  dataType: string;

  /** 保留天数 */
  retentionDays: int32;

  /** 启用自动删除 */
  autoDeleteEnabled: boolean;

  /** 法律保留豁免 */
  legalHoldExempt: boolean;
}

/** 告警规则条件 */
model AlertRuleConditions {
  /** 操作分类 */
  actionCategory?: ActionCategory;

  /** 操作名称 */
  actionName?: string;

  /** 结果状态 */
  resultStatus?: ResultStatus;

  /** 阈值 */
  threshold: int32;

  /** 时间窗口（秒） */
  timeWindow: int32;
}

/** 告警规则动作 */
model AlertRuleActions {
  /** 邮件通知 */
  email?: string[];

  /** Webhook URL */
  webhook?: string;
}

/** 告警规则 */
model AlertRule {
  /** 规则 ID */
  ruleId: string;

  /** 规则名称 */
  name: string;

  /** 是否启用 */
  enabled: boolean;

  /** 条件 */
  conditions: AlertRuleConditions;

  /** 动作 */
  actions: AlertRuleActions;

  /** 创建时间 */
  createdAt: string;
}
