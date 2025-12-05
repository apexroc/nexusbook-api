/**
 * NexusBook Audit - Compliance API
 * 合规性报告接口
 */
import "@typespec/http";

import "../shared/common.tsp";
import "./models.tsp";

using TypeSpec.Http;

namespace NexusBook.Api.Audit;

/**
 * 合规性报告 API
 */
@tag("Compliance")
@route("/api/v1/organizations/{organizationId}/compliance")
interface ComplianceApi {
  /**
   * 生成合规性报告
   * @param organizationId 组织 ID
   * @param request 报告请求
   */
  @summary("生成合规性报告")
  @post
  @route("/reports")
  generateReport(
    @path organizationId: string,
    @body request: {
      /** 报告类型 */
      reportType: "gdpr" | "soc2" | "hipaa" | "custom";
      /** 周期开始 */
      periodStart: string;
      /** 周期结束 */
      periodEnd: string;
      /** 包含访问日志 */
      includeAccessLogs?: boolean;
      /** 包含数据变更 */
      includeDataChanges?: boolean;
      /** 包含权限变更 */
      includePermissionChanges?: boolean;
    }
  ): NexusBook.Api.Common.ApiResponse<{
    /** 报告 ID */
    reportId: string;
    /** 状态 */
    status: "generating" | "completed" | "failed";
    /** 下载链接 */
    downloadUrl?: string;
    /** 过期时间 */
    expiresAt?: string;
  }>;

  /**
   * 获取数据访问记录（GDPR）
   * @param organizationId 组织 ID
   * @param userId 用户 ID
   * @param dataType 数据类型
   * @param startDate 开始时间
   * @param endDate 结束时间
   * @param page 页码
   * @param pageSize 每页数量
   */
  @summary("获取数据访问记录（GDPR）")
  @get
  @route("/data-access")
  getDataAccess(
    @path organizationId: string,
    @query userId?: string,
    @query dataType?: string,
    @query startDate?: string,
    @query endDate?: string,
    @query page?: int32 = 1,
    @query pageSize?: int32 = 20
  ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<DataAccessLog>>;

  /**
   * 获取数据保留策略
   * @param organizationId 组织 ID
   */
  @summary("获取数据保留策略")
  @get
  @route("/retention-policies")
  getRetentionPolicies(
    @path organizationId: string
  ): NexusBook.Api.Common.ApiResponse<{
    /** 策略列表 */
    policies: RetentionPolicy[];
  }>;

  /**
   * 更新数据保留策略
   * @param organizationId 组织 ID
   * @param request 策略请求
   */
  @summary("更新数据保留策略")
  @put
  @route("/retention-policies")
  updateRetentionPolicies(
    @path organizationId: string,
    @body request: {
      /** 策略列表 */
      policies: RetentionPolicy[];
    }
  ): NexusBook.Api.Common.ApiResponse<{
    /** 策略列表 */
    policies: RetentionPolicy[];
  }>;
}
