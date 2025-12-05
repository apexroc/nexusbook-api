/**
 * NexusBook Billing - Usage & Quota API
 * 使用量与配额管理接口
 */
import "@typespec/http";

import "../shared/common.tsp";
import "./models.tsp";

using TypeSpec.Http;

namespace NexusBook.Api.Billing;

/**
 * 使用量与配额管理 API
 */
@tag("Usage & Quota")
@route("/api/v1/organizations/{organizationId}/usage")
interface UsageApi {
  /**
   * 获取组织当前使用量
   * @param organizationId 组织 ID
   */
  @summary("获取当前使用量")
  @get
  getUsage(
    @path organizationId: string
  ): NexusBook.Api.Common.ApiResponse<OrganizationUsage>;

  /**
   * 获取使用量历史趋势
   * @param organizationId 组织 ID
   * @param metricType 指标类型
   * @param startDate 开始日期
   * @param endDate 结束日期
   * @param granularity 粒度（hour/day/month）
   */
  @summary("获取使用量历史")
  @get
  @route("/history")
  getUsageHistory(
    @path organizationId: string,
    @query metricType: MetricType,
    @query startDate: string,
    @query endDate: string,
    @query granularity: "hour" | "day" | "month" = "day"
  ): NexusBook.Api.Common.ApiResponse<{
    /** 指标类型 */
    metricType: MetricType;
    /** 数据点 */
    dataPoints: UsageDataPoint[];
  }>;

  /**
   * 获取配额警告
   * @param organizationId 组织 ID
   */
  @summary("获取配额警告")
  @get
  @route("/warnings")
  getQuotaWarnings(
    @path organizationId: string
  ): NexusBook.Api.Common.ApiResponse<{
    /** 警告列表 */
    warnings: QuotaWarning[];
  }>;
}
