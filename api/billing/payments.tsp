/**
 * NexusBook Billing - Payment Methods API
 * 支付方式管理接口
 */
import "@typespec/http";

import "../shared/common.tsp";
import "./models.tsp";

using TypeSpec.Http;

namespace NexusBook.Api.Billing;

/**
 * 支付方式管理 API
 */
@tag("Payment Methods")
@route("/api/v1/organizations/{organizationId}/payment-methods")
interface PaymentMethodsApi {
  /**
   * 列出支付方式
   * @param organizationId 组织 ID
   */
  @summary("列出支付方式")
  @get
  listPaymentMethods(
    @path organizationId: string
  ): NexusBook.Api.Common.ApiResponse<PaymentMethod[]>;

  /**
   * 添加支付方式
   * @param organizationId 组织 ID
   * @param request 添加请求
   */
  @summary("添加支付方式")
  @post
  addPaymentMethod(
    @path organizationId: string,
    @body request: {
      /** 支付类型 */
      type: PaymentMethodType;
      /** 支付 Token（由支付网关生成） */
      paymentToken: string;
      /** 设为默认 */
      setAsDefault?: boolean;
    }
  ): NexusBook.Api.Common.ApiResponse<PaymentMethod>;

  /**
   * 删除支付方式
   * @param organizationId 组织 ID
   * @param paymentMethodId 支付方式 ID
   */
  @summary("删除支付方式")
  @delete
  @route("/{paymentMethodId}")
  deletePaymentMethod(
    @path organizationId: string,
    @path paymentMethodId: string
  ): NexusBook.Api.Common.ApiResponse<{}>;

  /**
   * 设置默认支付方式
   * @param organizationId 组织 ID
   * @param paymentMethodId 支付方式 ID
   */
  @summary("设置默认支付方式")
  @post
  @route("/{paymentMethodId}/set-default")
  setDefaultPaymentMethod(
    @path organizationId: string,
    @path paymentMethodId: string
  ): NexusBook.Api.Common.ApiResponse<PaymentMethod>;
}
