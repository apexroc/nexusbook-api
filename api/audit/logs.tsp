/**
 * NexusBook Audit - Logs API
 * 审计日志接口
 */
import "@typespec/http";

import "../shared/common.tsp";
import "./models.tsp";

using TypeSpec.Http;

namespace NexusBook.Api.Audit;

/**
 * 审计日志 API
 */
@tag("Audit Logs")
@route("/api/v1/organizations/{organizationId}/audit-logs")
interface AuditLogsApi {
  /**
   * 查询审计日志
   * @param organizationId 组织 ID
   * @param actorId 操作者 ID
   * @param actorType 操作者类型
   * @param actionCategory 操作分类
   * @param actionName 操作名称
   * @param resourceType 资源类型
   * @param resourceId 资源 ID
   * @param resultStatus 结果状态
   * @param startDate 开始时间
   * @param endDate 结束时间
   * @param ipAddress IP 地址
   * @param search 全文搜索
   * @param page 页码
   * @param pageSize 每页数量
   */
  @summary("查询审计日志")
  @get
  queryLogs(
    @path organizationId: string,
    @query actorId?: string,
    @query actorType?: ActorType,
    @query actionCategory?: ActionCategory,
    @query actionName?: string,
    @query resourceType?: ResourceType,
    @query resourceId?: string,
    @query resultStatus?: ResultStatus,
    @query startDate?: string,
    @query endDate?: string,
    @query ipAddress?: string,
    @query search?: string,
    @query page?: int32 = 1,
    @query pageSize?: int32 = 20
  ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<AuditLog>>;

  /**
   * 获取审计日志详情
   * @param organizationId 组织 ID
   * @param logId 日志 ID
   */
  @summary("获取审计日志详情")
  @get
  @route("/{logId}")
  getLog(
    @path organizationId: string,
    @path logId: string
  ): NexusBook.Api.Common.ApiResponse<AuditLog>;

  /**
   * 导出审计日志
   * @param organizationId 组织 ID
   * @param request 导出请求
   */
  @summary("导出审计日志")
  @post
  @route("/export")
  exportLogs(
    @path organizationId: string,
    @body request: {
      /** 导出格式 */
      format: "csv" | "json" | "pdf";
      /** 过滤条件 */
      filters?: {
        startDate?: string;
        endDate?: string;
        actionCategory?: ActionCategory;
      };
      /** 包含字段 */
      includeFields?: string[];
    }
  ): NexusBook.Api.Common.ApiResponse<{
    /** 导出任务 ID */
    exportId: string;
    /** 状态 */
    status: "processing" | "completed" | "failed";
    /** 下载链接 */
    downloadUrl?: string;
    /** 过期时间 */
    expiresAt?: string;
  }>;

  /**
   * 获取导出任务状态
   * @param organizationId 组织 ID
   * @param exportId 导出任务 ID
   */
  @summary("获取导出状态")
  @get
  @route("/exports/{exportId}")
  getExportStatus(
    @path organizationId: string,
    @path exportId: string
  ): NexusBook.Api.Common.ApiResponse<{
    /** 导出任务 ID */
    exportId: string;
    /** 状态 */
    status: string;
    /** 进度 */
    progress: float64;
    /** 下载链接 */
    downloadUrl?: string;
    /** 过期时间 */
    expiresAt?: string;
  }>;

  /**
   * 获取审计统计
   * @param organizationId 组织 ID
   * @param startDate 开始时间
   * @param endDate 结束时间
   * @param groupBy 分组维度
   */
  @summary("获取审计统计")
  @get
  @route("/statistics")
  getStatistics(
    @path organizationId: string,
    @query startDate?: string,
    @query endDate?: string,
    @query groupBy?: "action" | "actor" | "resource"
  ): NexusBook.Api.Common.ApiResponse<{
    /** 总事件数 */
    totalEvents: int64;
    /** 成功次数 */
    successCount: int64;
    /** 失败次数 */
    failureCount: int64;
    /** 热门操作 */
    topActions: ActionStat[];
    /** 热门操作者 */
    topActors: ActorStat[];
    /** 热门资源 */
    topResources: ResourceStat[];
    /** 时间线统计 */
    timeline: TimelineStat[];
  }>;

  /**
   * 创建审计日志告警规则
   * @param organizationId 组织 ID
   * @param request 告警规则请求
   */
  @summary("创建告警规则")
  @post
  @route("/alert-rules")
  createAlertRule(
    @path organizationId: string,
    @body request: {
      /** 规则名称 */
      name: string;
      /** 是否启用 */
      enabled: boolean;
      /** 条件 */
      conditions: AlertRuleConditions;
      /** 动作 */
      actions: AlertRuleActions;
    }
  ): NexusBook.Api.Common.ApiResponse<AlertRule>;

  /**
   * 列出告警规则
   * @param organizationId 组织 ID
   */
  @summary("列出告警规则")
  @get
  @route("/alert-rules")
  listAlertRules(
    @path organizationId: string
  ): NexusBook.Api.Common.ApiResponse<AlertRule[]>;

  /**
   * 删除告警规则
   * @param organizationId 组织 ID
   * @param ruleId 规则 ID
   */
  @summary("删除告警规则")
  @delete
  @route("/alert-rules/{ruleId}")
  deleteAlertRule(
    @path organizationId: string,
    @path ruleId: string
  ): NexusBook.Api.Common.ApiResponse<{}>;
}
