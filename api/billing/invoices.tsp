/**
 * NexusBook Billing - Invoices API
 * 账单管理接口
 */
import "@typespec/http";

import "../shared/common.tsp";
import "./models.tsp";

using TypeSpec.Http;

namespace NexusBook.Api.Billing;

/**
 * 账单管理 API
 */
@tag("Invoices")
@route("/api/v1/organizations/{organizationId}/invoices")
interface InvoicesApi {
  /**
   * 列出组织账单
   * @param organizationId 组织 ID
   * @param status 按状态过滤
   * @param page 页码
   * @param pageSize 每页数量
   */
  @summary("列出账单")
  @get
  listInvoices(
    @path organizationId: string,
    @query status?: InvoiceStatus,
    @query page?: int32 = 1,
    @query pageSize?: int32 = 20
  ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<Invoice>>;

  /**
   * 获取账单详情
   * @param organizationId 组织 ID
   * @param invoiceId 账单 ID
   */
  @summary("获取账单详情")
  @get
  @route("/{invoiceId}")
  getInvoice(
    @path organizationId: string,
    @path invoiceId: string
  ): NexusBook.Api.Common.ApiResponse<Invoice>;

  /**
   * 支付账单
   * @param organizationId 组织 ID
   * @param invoiceId 账单 ID
   * @param request 支付请求
   */
  @summary("支付账单")
  @post
  @route("/{invoiceId}/pay")
  payInvoice(
    @path organizationId: string,
    @path invoiceId: string,
    @body request: {
      /** 支付方式 ID */
      paymentMethodId: string;
    }
  ): NexusBook.Api.Common.ApiResponse<{
    /** 账单信息 */
    invoice: Invoice;
    /** 支付状态 */
    paymentStatus: string;
    /** 是否需要进一步操作 */
    requiresAction: boolean;
    /** 客户端密钥（用于 3D Secure） */
    clientSecret?: string;
  }>;
}
