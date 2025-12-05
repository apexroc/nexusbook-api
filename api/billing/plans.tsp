/**
 * NexusBook Billing - Subscription Plans API
 * 订阅计划管理接口
 */
import "@typespec/http";

import "../shared/common.tsp";
import "./models.tsp";

using TypeSpec.Http;

namespace NexusBook.Api.Billing;

/**
 * 订阅计划 API
 */
@tag("Subscription Plans")
@route("/api/v1/billing/plans")
interface SubscriptionPlansApi {
  /**
   * 列出可用订阅计划
   * @param includeArchived 是否包含已归档计划
   */
  @summary("列出订阅计划")
  @get
  listPlans(
    @query includeArchived?: boolean = false
  ): NexusBook.Api.Common.ApiResponse<SubscriptionPlan[]>;

  /**
   * 获取订阅计划详情
   * @param planId 计划 ID
   */
  @summary("获取订阅计划详情")
  @get
  @route("/{planId}")
  getPlan(
    @path planId: string
  ): NexusBook.Api.Common.ApiResponse<SubscriptionPlan>;
}
