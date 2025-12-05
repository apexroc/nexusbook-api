/**
 * NexusBook Billing - Subscriptions API
 * 订阅管理接口
 */
import "@typespec/http";

import "../shared/common.tsp";
import "./models.tsp";

using TypeSpec.Http;

namespace NexusBook.Api.Billing;

/**
 * 订阅管理 API
 */
@tag("Subscription Management")
@route("/api/v1/organizations/{organizationId}/subscription")
interface OrganizationSubscriptionApi {
  /**
   * 获取当前组织订阅信息
   * @param organizationId 组织 ID
   */
  @summary("获取组织订阅信息")
  @get
  getSubscription(
    @path organizationId: string
  ): NexusBook.Api.Common.ApiResponse<OrganizationSubscription>;

  /**
   * 创建或更新组织订阅
   * @param organizationId 组织 ID
   * @param request 订阅请求
   */
  @summary("创建或更新订阅")
  @post
  createSubscription(
    @path organizationId: string,
    @body request: {
      /** 计划 ID */
      planId: string;
      /** 计费周期 */
      billingCycle: BillingCycle;
      /** 支付方式 ID */
      paymentMethodId?: string;
    }
  ): NexusBook.Api.Common.ApiResponse<OrganizationSubscription>;

  /**
   * 升级/降级订阅
   * @param organizationId 组织 ID
   * @param request 变更计划请求
   */
  @summary("变更订阅计划")
  @post
  @route("/change-plan")
  changePlan(
    @path organizationId: string,
    @body request: {
      /** 目标计划 ID */
      targetPlanId: string;
      /** 计费周期 */
      billingCycle: BillingCycle;
      /** 生效日期 */
      effectiveDate: "immediate" | "next_billing_cycle";
    }
  ): NexusBook.Api.Common.ApiResponse<{
    /** 订阅信息 */
    subscription: OrganizationSubscription;
    /** 按比例计费金额 */
    prorationAmount: float64;
    /** 下次账单日期 */
    nextBillingDate: string;
  }>;

  /**
   * 取消订阅
   * @param organizationId 组织 ID
   * @param request 取消请求
   */
  @summary("取消订阅")
  @post
  @route("/cancel")
  cancelSubscription(
    @path organizationId: string,
    @body request: {
      /** 是否立即取消 */
      cancelImmediately: boolean;
      /** 取消原因 */
      reason?: string;
      /** 反馈意见 */
      feedback?: string;
    }
  ): NexusBook.Api.Common.ApiResponse<OrganizationSubscription>;

  /**
   * 恢复已取消的订阅
   * @param organizationId 组织 ID
   */
  @summary("恢复订阅")
  @post
  @route("/resume")
  resumeSubscription(
    @path organizationId: string
  ): NexusBook.Api.Common.ApiResponse<OrganizationSubscription>;
}
