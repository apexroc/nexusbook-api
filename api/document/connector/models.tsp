import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * Connector 数据模型
 * Connector Data Models
 *
 * Connector 是组织内部文档之间的联动机制。
 * Connector is a linkage mechanism between documents within the same organization.
 */
namespace NexusBook.Api.Document.Connector;

/**
 * Connector 类型枚举
 * Connector type enum
 */
enum ConnectorType {
    /**
     * Catalog 复制与联动
     * Catalog clone and linkage
     */
    catalog_clone,

    /**
     * OrderBook 转 Catalog
     * OrderBook to Catalog
     */
    orderbook_to_catalog,
}

/**
 * Connector 状态枚举
 * Connector status enum
 */
enum ConnectorStatus {
    /**
     * 活跃
     * Active
     */
    active,

    /**
     * 暂停
     * Paused
     */
    paused,

    /**
     * 已禁用
     * Disabled
     */
    disabled,
}

/**
 * 同步模式枚举
 * Sync mode enum
 */
enum SyncMode {
    /**
     * 完全同步
     * Full sync
     */
    full,

    /**
     * 部分同步
     * Partial sync
     */
    partial,
}

/**
 * 同步方向枚举
 * Sync direction enum
 */
enum SyncDirection {
    /**
     * 单向同步
     * One-way sync
     */
    one_way,

    /**
     * 双向同步
     * Bidirectional sync
     */
    bi_directional,
}

/**
 * 联动范围模式
 * Linked scope mode
 */
enum LinkedScopeMode {
    /**
     * 全部
     * All
     */
    all,

    /**
     * 过滤条件
     * Filter
     */
    filter,

    /**
     * 指定行
     * Specific rows
     */
    rows,
}

/**
 * 转换类型枚举
 * Transform type enum
 */
enum TransformType {
    /**
     * 直接复制
     * Copy
     */
    copy,

    /**
     * 公式计算
     * Formula
     */
    formula,

    /**
     * 查找表
     * Lookup
     */
    lookup,

    /**
     * 常量值
     * Constant
     */
    constant,
}

/**
 * 聚合类型枚举
 * Aggregation type enum
 */
enum AggregationType {
    /**
     * 求和
     * Sum
     */
    sum,

    /**
     * 平均值
     * Average
     */
    avg,

    /**
     * 最小值
     * Minimum
     */
    min,

    /**
     * 最大值
     * Maximum
     */
    max,

    /**
     * 第一个值
     * First
     */
    first,
}

/**
 * 同步触发模式
 * Sync trigger mode
 */
enum SyncTriggerMode {
    /**
     * 手动触发
     * Manual
     */
    manual,

    /**
     * 自动触发
     * Auto
     */
    auto,

    /**
     * 定时触发
     * Scheduled
     */
    scheduled,
}

/**
 * 联动范围配置
 * Linked scope configuration
 */
model LinkedScope {
    /**
     * 联动模式
     * Linked mode
     */
    mode: LinkedScopeMode;

    /**
     * 过滤条件(mode=filter 时)
     * Filter conditions (when mode=filter)
     */
    filterGroup?: unknown;

    /**
     * 行 ID 列表(mode=rows 时)
     * Row IDs (when mode=rows)
     */
    rowIds?: string[];
}

/**
 * 本地增强配置
 * Local enhancements configuration
 */
model LocalEnhancements {
    /**
     * 允许本地新增
     * Allow local add
     */
    allowLocalAdd: boolean;

    /**
     * 允许本地删除
     * Allow local delete
     */
    allowLocalDelete: boolean;

    /**
     * 允许本地修改
     * Allow local modify
     */
    allowLocalModify: boolean;

    /**
     * 非联动字段列表
     * Non-linked fields
     */
    nonLinkedFields?: string[];
}

/**
 * Catalog 复制配置
 * Catalog clone configuration
 */
model CatalogCloneConfig {
    /**
     * 同步模式
     * Sync mode
     */
    syncMode: SyncMode;

    /**
     * 同步方向
     * Sync direction
     */
    syncDirection: SyncDirection;

    /**
     * 联动范围
     * Linked scope
     */
    linkedScope: LinkedScope;

    /**
     * 本地增强
     * Local enhancements
     */
    localEnhancements: LocalEnhancements;

    /**
     * 字段映射(可选,默认 1:1 映射)
     * Field mapping (optional, default 1:1)
     */
    fieldMapping?: unknown;

    /**
     * 冲突策略
     * Conflict resolution
     */
    conflictResolution: unknown;
}

/**
 * 字段转换配置
 * Field transform configuration
 */
model FieldTransform {
    /**
     * 源字段 ID
     * Source field ID
     */
    sourceFieldId: string;

    /**
     * 目标字段 ID
     * Target field ID
     */
    targetFieldId: string;

    /**
     * 转换类型
     * Transform type
     */
    transformType: TransformType;

    /**
     * 转换配置
     * Transform config
     */
    transformConfig?: {
        /**
         * 公式(transformType=formula 时)
         * Formula (when transformType=formula)
         */
        formula?: string;

        /**
         * 查找表(transformType=lookup 时)
         * Lookup table (when transformType=lookup)
         */
        lookupTable?: Record<unknown>;

        /**
         * 常量值(transformType=constant 时)
         * Constant value (when transformType=constant)
         */
        constantValue?: unknown;
    };
}

/**
 * 聚合规则
 * Aggregation rule
 */
model AggregationRule {
    /**
     * 字段 ID
     * Field ID
     */
    fieldId: string;

    /**
     * 聚合类型
     * Aggregation type
     */
    aggregationType: AggregationType;

    /**
     * 分组字段
     * Group by field
     */
    groupByField?: string;
}

/**
 * 转换规则
 * Transform rules
 */
model TransformRules {
    /**
     * 过滤条件
     * Filter conditions
     */
    filterGroup?: unknown;

    /**
     * 字段转换列表
     * Field transforms
     */
    fieldTransforms: FieldTransform[];

    /**
     * 聚合规则
     * Aggregation rules
     */
    aggregationRules?: AggregationRule[];
}

/**
 * 同步触发配置
 * Sync trigger configuration
 */
model SyncTrigger {
    /**
     * 触发模式
     * Trigger mode
     */
    mode: SyncTriggerMode;

    /**
     * 自动触发事件(mode=auto 时)
     * Auto trigger events (when mode=auto)
     */
    autoTriggerOn?: string[];

    /**
     * 定时表达式(mode=scheduled 时)
     * Schedule expression (when mode=scheduled)
     */
    schedule?: string;
}

/**
 * OrderBook 转 Catalog 配置
 * OrderBook to Catalog configuration
 */
model OrderbookToCatalogConfig {
    /**
     * 转换规则
     * Transform rules
     */
    transformRules: TransformRules;

    /**
     * 同步触发配置
     * Sync trigger
     */
    syncTrigger: SyncTrigger;

    /**
     * 冲突策略
     * Conflict resolution
     */
    conflictResolution: unknown;
}

/**
 * Connector 摘要
 * Connector summary
 */
model ConnectorSummary {
    /**
     * Connector ID
     * Connector ID
     */
    id: string;

    /**
     * Connector 名称
     * Connector name
     */
    name: string;

    /**
     * Connector 描述
     * Connector description
     */
    description?: string;

    /**
     * Connector 类型
     * Connector type
     */
    connectorType: ConnectorType;

    /**
     * 源文档 ID
     * Source document ID
     */
    sourceDocId: string;

    /**
     * 目标文档 ID
     * Target document ID
     */
    targetDocId: string;

    /**
     * 所属组织 ID
     * Organization ID
     */
    organizationId: string;

    /**
     * 所属工作区 ID
     * Workspace ID
     */
    workspaceId?: string;

    /**
     * Connector 状态
     * Connector status
     */
    status: ConnectorStatus;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 最后同步时间
     * Last synced at
     */
    lastSyncAt?: string;
}

/**
 * Connector 详情
 * Connector details
 */
model ConnectorDetails {
    /**
     * Connector ID
     * Connector ID
     */
    id: string;

    /**
     * Connector 名称
     * Connector name
     */
    name: string;

    /**
     * Connector 描述
     * Connector description
     */
    description?: string;

    /**
     * Connector 类型
     * Connector type
     */
    connectorType: ConnectorType;

    /**
     * 源文档 ID
     * Source document ID
     */
    sourceDocId: string;

    /**
     * 源文档类型
     * Source document type
     */
    sourceDocType: string;

    /**
     * 目标文档 ID
     * Target document ID
     */
    targetDocId: string;

    /**
     * 目标文档类型
     * Target document type
     */
    targetDocType: string;

    /**
     * 所属组织 ID
     * Organization ID
     */
    organizationId: string;

    /**
     * 所属工作区 ID(null 表示组织级别)
     * Workspace ID (null for organization-level)
     */
    workspaceId?: string;

    /**
     * Connector 状态
     * Connector status
     */
    status: ConnectorStatus;

    /**
     * Catalog 复制配置(connectorType=catalog_clone 时)
     * Catalog clone config (when connectorType=catalog_clone)
     */
    catalogCloneConfig?: CatalogCloneConfig;

    /**
     * OrderBook 转 Catalog 配置(connectorType=orderbook_to_catalog 时)
     * OrderBook to Catalog config (when connectorType=orderbook_to_catalog)
     */
    orderbookToCatalogConfig?: OrderbookToCatalogConfig;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt: string;

    /**
     * 最后同步时间
     * Last synced at
     */
    lastSyncAt?: string;

    /**
     * 创建者
     * Created by
     */
    createdBy?: NexusBook.Api.Common.UserRef;
}

/**
 * 创建 Connector 请求
 * Create connector request
 */
model CreateConnectorRequest {
    /**
     * Connector 名称
     * Connector name
     */
    name: string;

    /**
     * Connector 描述
     * Connector description
     */
    description?: string;

    /**
     * Connector 类型
     * Connector type
     */
    connectorType: ConnectorType;

    /**
     * 源文档 ID
     * Source document ID
     */
    sourceDocId: string;

    /**
     * 目标文档 ID
     * Target document ID
     */
    targetDocId: string;

    /**
     * 所属工作区 ID(可选,null 表示组织级别)
     * Workspace ID (optional, null for organization-level)
     */
    workspaceId?: string;

    /**
     * Catalog 复制配置(connectorType=catalog_clone 时)
     * Catalog clone config (when connectorType=catalog_clone)
     */
    catalogCloneConfig?: CatalogCloneConfig;

    /**
     * OrderBook 转 Catalog 配置(connectorType=orderbook_to_catalog 时)
     * OrderBook to Catalog config (when connectorType=orderbook_to_catalog)
     */
    orderbookToCatalogConfig?: OrderbookToCatalogConfig;
}

/**
 * 更新 Connector 请求
 * Update connector request
 */
model UpdateConnectorRequest {
    /**
     * Connector 名称
     * Connector name
     */
    name?: string;

    /**
     * Connector 描述
     * Connector description
     */
    description?: string;

    /**
     * Connector 状态
     * Connector status
     */
    status?: ConnectorStatus;

    /**
     * Catalog 复制配置
     * Catalog clone config
     */
    catalogCloneConfig?: CatalogCloneConfig;

    /**
     * OrderBook 转 Catalog 配置
     * OrderBook to Catalog config
     */
    orderbookToCatalogConfig?: OrderbookToCatalogConfig;
}

/**
 * LinkedRow 数据模型
 * LinkedRow data model
 *
 * 跟踪源文档与目标文档之间的行级联动关系。
 * Track row-level linkage between source and target documents.
 */
model LinkedRow {
    /**
     * 联动记录 ID
     * Link ID
     */
    id: string;

    /**
     * Connector ID
     * Connector ID
     */
    connectorId: string;

    /**
     * 源文档 ID
     * Source document ID
     */
    sourceDocId: string;

    /**
     * 源行 ID
     * Source row ID
     */
    sourceRowId: string;

    /**
     * 目标文档 ID
     * Target document ID
     */
    targetDocId: string;

    /**
     * 目标行 ID
     * Target row ID
     */
    targetRowId: string;

    /**
     * 联动状态
     * Link status
     */
    linkStatus: "active" | "broken" | "paused";

    /**
     * 最后同步时间
     * Last synced at
     */
    lastSyncedAt?: string;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt: string;
}
