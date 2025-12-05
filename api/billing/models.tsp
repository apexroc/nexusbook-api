/**
 * NexusBook Billing & Subscriptions - Data Models
 * NexusBook 商业化运营 - 数据模型
 *
 * 定义订阅计划、账单、支付方式、使用量等核心数据模型。
 * Defines core data models for subscription plans, invoices, payment methods, and usage metrics.
 *
 * Route Base: N/A (模型定义，无路由 / Model definitions, no routes)
 *
 * 主要内容 / Main Components:
 * - **订阅计划 Subscription Plans** - 计划类型、定价、配额和特性
 * - **讦阅管理 Subscriptions** - 订阅状态、周期和续费
 * - **账单系统 Invoicing** - 账单生成、支付和状态管理
 * - **支付方式 Payment Methods** - 多种支付方式支持
 * - **使用量跟踪 Usage Tracking** - 配额监控和超量预警
 */
import "@typespec/http";

import "../shared/common.tsp";

using TypeSpec.Http;

namespace NexusBook.Api.Billing;

/**
 * 枚举定义
 */

/** 计划类型 */
enum PlanType {
  /** 试用 */
  trial,
  /** 标准 */
  standard,
  /** 定制 */
  custom,
}

/** 计费周期 */
enum BillingCycle {
  /** 月付 */
  monthly,
  /** 年付 */
  yearly,
}

/** 计划状态 */
enum PlanStatus {
  /** 活跃 */
  active,
  /** 已归档 */
  archived,
}

/** 订阅状态 */
enum SubscriptionStatus {
  /** 试用中 */
  trialing,
  /** 活跃 */
  active,
  /** 逾期 */
  past_due,
  /** 已取消 */
  canceled,
  /** 已过期 */
  expired,
}

/** 账单状态 */
enum InvoiceStatus {
  /** 草稿 */
  draft,
  /** 待支付 */
  open,
  /** 已支付 */
  paid,
  /** 已作废 */
  void_status,
  /** 无法收款 */
  uncollectible,
}

/** 账单项类型 */
enum ItemType {
  /** 订阅 */
  subscription,
  /** 使用量 */
  usage,
  /** 附加项 */
  addon,
}

/** 支付方式类型 */
enum PaymentMethodType {
  /** 信用卡 */
  card,
  /** 支付宝 */
  alipay,
  /** 微信支付 */
  wechat,
  /** 银行转账 */
  bank_transfer,
}

/** 使用量指标类型 */
enum MetricType {
  /** 成员数 */
  members,
  /** 工作区数 */
  workspaces,
  /** 文档数 */
  documents,
  /** 存储空间(GB) */
  storage_gb,
  /** API 调用 */
  api_calls,
  /** 实时会话 */
  realtime_sessions,
}

/** 配额警告严重程度 */
enum QuotaSeverity {
  /** 警告 */
  warning,
  /** 严重 */
  critical,
}

/**
 * 数据模型
 */

/** 计划配额 */
model PlanQuota {
  /** 最大成员数（-1 表示无限制） */
  maxMembers: int32;

  /** 最大工作区数 */
  maxWorkspaces: int32;

  /** 最大文档数 */
  maxDocuments: int32;

  /** 最大存储空间(GB) */
  maxStorageGB: int32;

  /** 每月最大 API 调用量 */
  maxAPICallsPerMonth: int64;

  /** 最大实时协作会话数 */
  maxRealtimeSessions: int32;
}

/** 计划特性 */
model PlanFeature {
  /** 功能键 */
  featureKey: string;

  /** 功能名称（多语言） */
  featureName: NexusBook.Api.Common.Message;

  /** 是否启用 */
  enabled: boolean;

  /** 限制值（-1 表示无限制） */
  limit?: int32;
}

/** 订阅计划 */
model SubscriptionPlan {
  /** 计划唯一标识 */
  id: string;

  /** 计划名称 */
  name: string;

  /** 多语言显示名称 */
  displayName: NexusBook.Api.Common.Message;

  /** 多语言描述 */
  description: NexusBook.Api.Common.Message;

  /** 计划类型 */
  type: PlanType;

  /** 计费周期 */
  billingCycle: BillingCycle;

  /** 价格 */
  price: float64;

  /** 货币代码（CNY/USD） */
  currency: string;

  /** 试用天数 */
  trialDays?: int32;

  /** 功能特性列表 */
  features: PlanFeature[];

  /** 配额限制 */
  quotas: PlanQuota;

  /** 状态 */
  status: PlanStatus;

  /** 创建时间 */
  createdAt: string;

  /** 更新时间 */
  updatedAt: string;
}

/** 组织订阅 */
model OrganizationSubscription {
  /** 订阅唯一标识 */
  id: string;

  /** 组织 ID */
  organizationId: string;

  /** 订阅计划 ID */
  planId: string;

  /** 计划详情（可选） */
  plan?: SubscriptionPlan;

  /** 订阅状态 */
  status: SubscriptionStatus;

  /** 试用开始时间 */
  trialStart?: string;

  /** 试用结束时间 */
  trialEnd?: string;

  /** 当前计费周期开始 */
  currentPeriodStart: string;

  /** 当前计费周期结束 */
  currentPeriodEnd: string;

  /** 取消时间（计划取消时） */
  cancelAt?: string;

  /** 实际取消时间 */
  canceledAt?: string;

  /** 自定义元数据 */
  metadata?: Record<string>;

  /** 创建时间 */
  createdAt: string;

  /** 更新时间 */
  updatedAt: string;
}

/** 账单项 */
model InvoiceItem {
  /** 描述（多语言） */
  description: NexusBook.Api.Common.Message;

  /** 数量 */
  quantity: int32;

  /** 单价 */
  unitPrice: float64;

  /** 金额 */
  amount: float64;

  /** 类型 */
  type: ItemType;
}

/** 账单 */
model Invoice {
  /** 账单唯一标识 */
  id: string;

  /** 组织 ID */
  organizationId: string;

  /** 订阅 ID */
  subscriptionId: string;

  /** 账单编号 */
  invoiceNumber: string;

  /** 状态 */
  status: InvoiceStatus;

  /** 小计 */
  subtotal: float64;

  /** 税额 */
  tax: float64;

  /** 总计 */
  total: float64;

  /** 货币代码 */
  currency: string;

  /** 账单项 */
  items: InvoiceItem[];

  /** 计费周期开始 */
  periodStart: string;

  /** 计费周期结束 */
  periodEnd: string;

  /** 到期日期 */
  dueDate: string;

  /** 支付时间 */
  paidAt?: string;

  /** 支付意图 ID */
  paymentIntentId?: string;

  /** 账单 URL */
  invoiceUrl?: string;

  /** PDF 下载链接 */
  invoicePdfUrl?: string;

  /** 创建时间 */
  createdAt: string;
}

/** 支付方式 */
model PaymentMethod {
  /** 支付方式 ID */
  id: string;

  /** 组织 ID */
  organizationId: string;

  /** 类型 */
  type: PaymentMethodType;

  /** 是否默认 */
  isDefault: boolean;

  /** 卡号后4位（信用卡） */
  cardLast4?: string;

  /** 卡品牌（Visa/MasterCard） */
  cardBrand?: string;

  /** 过期月份 */
  expiryMonth?: int32;

  /** 过期年份 */
  expiryYear?: int32;

  /** 账单邮箱 */
  billingEmail?: string;

  /** 添加时间 */
  createdAt: string;
}

/** 使用量指标 */
model UsageMetric {
  /** 当前使用量 */
  current: int64;

  /** 配额限制（-1 无限制） */
  limit: int64;

  /** 使用百分比 */
  percentage: float64;

  /** 是否超额 */
  isOverQuota: boolean;
}

/** 组织使用量 */
model OrganizationUsage {
  /** 组织 ID */
  organizationId: string;

  /** 统计周期开始 */
  periodStart: string;

  /** 统计周期结束 */
  periodEnd: string;

  /** 成员使用量 */
  members: UsageMetric;

  /** 工作区使用量 */
  workspaces: UsageMetric;

  /** 文档使用量 */
  documents: UsageMetric;

  /** 存储使用量（GB） */
  storage: UsageMetric;

  /** API 调用量 */
  apiCalls: UsageMetric;

  /** 实时协作会话 */
  realtimeSessions: UsageMetric;

  /** 更新时间 */
  updatedAt: string;
}

/** 使用量数据点 */
model UsageDataPoint {
  /** 时间戳 */
  timestamp: string;

  /** 值 */
  value: int64;
}

/** 配额警告 */
model QuotaWarning {
  /** 指标类型 */
  metricType: MetricType;

  /** 当前使用量 */
  current: int64;

  /** 配额限制 */
  limit: int64;

  /** 使用百分比 */
  percentage: float64;

  /** 严重程度 */
  severity: QuotaSeverity;

  /** 警告消息（多语言） */
  message: NexusBook.Api.Common.Message;
}
