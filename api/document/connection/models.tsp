import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * Connection 数据模型
 * Connection Data Models
 *
 * Connection 是跨组织的数据分享通道,连接供应商的 Catalog 和采购商的 OrderBook。
 * Connection is a cross-organization data sharing channel, connecting supplier's Catalog and buyer's OrderBook.
 */
namespace NexusBook.Api.Document.Connection;

/**
 * 分享模式枚举
 * Share mode enum
 */
enum ShareMode {
    /**
     * 单一采购商
     * Single buyer
     */
    single,

    /**
     * 多个采购商
     * Multiple buyers
     */
    multiple,

    /**
     * 公开分享
     * Public sharing
     */
    `public`,
}

/**
 * Connection 状态枚举
 * Connection status enum
 */
enum ConnectionStatus {
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
 * 分享范围模式
 * Share scope mode
 */
enum ShareScopeMode {
    /**
     * 全部商品
     * All products
     */
    all,

    /**
     * 特定视图
     * Specific view
     */
    view,

    /**
     * 过滤条件
     * Filter conditions
     */
    filter,

    /**
     * 指定行
     * Specific rows
     */
    rows,
}

/**
 * 字段传播模式
 * Field propagation mode
 */
enum PropagationMode {
    /**
     * 双向同步
     * Bidirectional sync
     */
    sync,

    /**
     * 单向传播
     * One-way propagation
     */
    oneway,

    /**
     * 仅初始传播
     * Initial only
     */
    initial,

    /**
     * 禁用传播
     * Disabled
     */
    disabled,
}

/**
 * 冲突解决策略
 * Conflict resolution strategy
 */
enum ConflictStrategy {
    /**
     * 保留上游值
     * Keep upstream value
     */
    keep_upstream,

    /**
     * 保留本地值
     * Keep local value
     */
    keep_local,

    /**
     * 合并值
     * Merge values
     */
    merge,

    /**
     * 询问用户
     * Ask user
     */
    ask_user,

    /**
     * 最新值优先
     * Latest wins
     */
    latest_wins,
}

/**
 * 访问控制模式
 * Access control mode
 */
enum AccessControlMode {
    /**
     * 白名单
     * Whitelist
     */
    whitelist,

    /**
     * 黑名单
     * Blacklist
     */
    blacklist,

    /**
     * 需要审批
     * Approval required
     */
    approval,
}

/**
 * 分享范围配置
 * Share scope configuration
 */
model ShareScope {
    /**
     * 分享模式
     * Share mode
     */
    mode: ShareScopeMode;

    /**
     * 视图 ID(mode=view 时使用)
     * View ID (used when mode=view)
     */
    viewId?: string;

    /**
     * 过滤条件(mode=filter 时使用)
     * Filter conditions (used when mode=filter)
     */
    filterGroup?: unknown;

    /**
     * 行 ID 列表(mode=rows 时使用)
     * Row ID list (used when mode=rows)
     */
    rowIds?: string[];
}

/**
 * 字段类型转换枚举
 * Field type transformation enum
 */
enum FieldTransformType {
    /**
     * 直接映射(无转换)
     * Direct mapping (no transformation)
     */
    direct,

    /**
     * 类型转换(text to number, date to string 等)
     * Type conversion (text to number, date to string, etc.)
     */
    type_convert,

    /**
     * 单位转换(货币汇率、度量衡单位等)
     * Unit conversion (currency exchange, measurement units, etc.)
     */
    unit_convert,

    /**
     * 选项映射(single_select/multi_select 选项对应)
     * Option mapping (single_select/multi_select option correspondence)
     */
    option_mapping,

    /**
     * 公式转换(自定义计算)
     * Formula transformation (custom calculation)
     */
    formula,

    /**
     * 字符串格式化
     * String formatting
     */
    format,

    /**
     * 合并字段(concat 多个源字段)
     * Merge fields (concat multiple source fields)
     */
    merge,

    /**
     * 拆分字段(split 一个源字段到多个目标字段)
     * Split field (split one source field to multiple target fields)
     */
    split,
}

/**
 * 选项映射配置
 * Option mapping configuration
 */
model OptionMappingConfig {
    /**
     * 源选项到目标选项的映射
     * Source option to target option mapping
     *
     * 例如: { "red": "红色", "blue": "蓝色" }
     * Example: { "red": "红色", "blue": "蓝色" }
     */
    mappings: Record<string>;

    /**
     * 未映射选项的处理方式
     * Handling of unmapped options
     */
    unmappedStrategy: "ignore" | "keep_original" | "use_default" | "error";

    /**
     * 默认值(当 unmappedStrategy=use_default 时)
     * Default value (when unmappedStrategy=use_default)
     */
    defaultValue?: string;
}

/**
 * 单位转换配置
 * Unit conversion configuration
 */
model UnitConversionConfig {
    /**
     * 源单位
     * Source unit
     */
    sourceUnit: string;

    /**
     * 目标单位
     * Target unit
     */
    targetUnit: string;

    /**
     * 转换类型
     * Conversion type
     */
    conversionType: "currency" | "length" | "weight" | "volume" | "temperature" | "custom";

    /**
     * 自定义转换率(当 conversionType=custom 时)
     * Custom conversion rate (when conversionType=custom)
     */
    customRate?: float64;

    /**
     * 货币汇率源(当 conversionType=currency 时)
     * Exchange rate source (when conversionType=currency)
     */
    exchangeRateSource?: "fixed" | "realtime" | "daily";

    /**
     * 固定汇率(当 exchangeRateSource=fixed 时)
     * Fixed rate (when exchangeRateSource=fixed)
     */
    fixedRate?: float64;
}

/**
 * 字符串格式化配置
 * String formatting configuration
 */
model FormatConfig {
    /**
     * 格式化模板
     * Format template
     *
     * 例如: "${value} USD", "SKU-${value}"
     * Example: "${value} USD", "SKU-${value}"
     */
    template?: string;

    /**
     * 日期格式(type=date/datetime 时)
     * Date format (when type=date/datetime)
     */
    dateFormat?: string;

    /**
     * 数值精度(type=number/currency 时)
     * Number precision (when type=number/currency)
     */
    precision?: int32;

    /**
     * 大小写转换
     * Case conversion
     */
    caseConversion?: "upper" | "lower" | "title" | "none";
}

/**
 * 合并字段配置
 * Merge fields configuration
 */
model MergeFieldsConfig {
    /**
     * 源字段 ID 列表
     * Source field IDs
     */
    sourceFieldIds: string[];

    /**
     * 分隔符
     * Separator
     */
    separator?: string = " ";

    /**
     * 合并模板
     * Merge template
     *
     * 例如: "${field1} - ${field2}"
     * Example: "${field1} - ${field2}"
     */
    template?: string;
}

/**
 * 拆分字段配置
 * Split field configuration
 */
model SplitFieldConfig {
    /**
     * 分隔符
     * Separator
     */
    separator: string;

    /**
     * 目标字段索引(0-based)
     * Target field index (0-based)
     */
    targetIndex: int32;

    /**
     * 正则表达式(可选,替代 separator)
     * Regex pattern (optional, replaces separator)
     */
    regex?: string;
}

/**
 * 字段映射规则
 * Field mapping rule
 */
model FieldMappingRule {
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
    transformType: FieldTransformType = FieldTransformType.direct;

    /**
     * 选项映射配置(transformType=option_mapping 时)
     * Option mapping config (when transformType=option_mapping)
     */
    optionMapping?: OptionMappingConfig;

    /**
     * 单位转换配置(transformType=unit_convert 时)
     * Unit conversion config (when transformType=unit_convert)
     */
    unitConversion?: UnitConversionConfig;

    /**
     * 格式化配置(transformType=format 时)
     * Format config (when transformType=format)
     */
    formatConfig?: FormatConfig;

    /**
     * 合并字段配置(transformType=merge 时)
     * Merge fields config (when transformType=merge)
     */
    mergeConfig?: MergeFieldsConfig;

    /**
     * 拆分字段配置(transformType=split 时)
     * Split field config (when transformType=split)
     */
    splitConfig?: SplitFieldConfig;

    /**
     * 自定义公式(transformType=formula 时)
     * Custom formula (when transformType=formula)
     */
    formula?: string;

    /**
     * 传播模式
     * Propagation mode
     */
    propagationMode: PropagationMode = PropagationMode.oneway;

    /**
     * 是否启用此规则
     * Whether this rule is enabled
     */
    enabled?: boolean = true;

    /**
     * 规则描述
     * Rule description
     */
    description?: string;
}

/**
 * 字段映射配置
 * Field mapping configuration
 */
model FieldMapping {
    /**
     * 映射规则列表
     * Mapping rules
     */
    rules: FieldMappingRule[];

    /**
     * 未映射字段的处理方式
     * Unmapped fields handling
     */
    unmappedFields: "ignore" | "create" | "error";
}

/**
 * 字段级冲突策略
 * Field-level conflict strategy
 */
model FieldConflictStrategy {
    /**
     * 冲突策略
     * Conflict strategy
     */
    strategy: ConflictStrategy;

    /**
     * 合并规则(strategy=merge 时使用)
     * Merge rules (used when strategy=merge)
     */
    mergeRules?: {
        /**
         * 合并类型
         * Merge type
         */
        type: "sum" | "max" | "min" | "custom";

        /**
         * 自定义逻辑
         * Custom logic
         */
        customLogic?: string;
    };
}

/**
 * 冲突解决配置
 * Conflict resolution configuration
 */
model ConflictResolution {
    /**
     * 默认策略
     * Default strategy
     */
    defaultStrategy: ConflictStrategy;

    /**
     * 字段级策略覆盖
     * Field-level strategy override
     */
    fieldStrategies?: Record<FieldConflictStrategy>;
}

/**
 * 默认接收方配置
 * Default receiver configuration
 */
model DefaultReceiverConfig {
    /**
     * 建议的字段映射
     * Suggested field mapping
     */
    suggestedFieldMapping?: FieldMapping;

    /**
     * 建议的冲突策略
     * Suggested conflict resolution
     */
    suggestedConflictResolution?: ConflictResolution;

    /**
     * 建议的接受模式
     * Suggested accept mode
     */
    suggestedAcceptMode?: "auto" | "manual" | "selective";
}

/**
 * 传播事件配置
 * Propagation events configuration
 */
model PropagationEvents {
    /**
     * 订阅的事件类型
     * Subscribed event types
     */
    eventTypes: string[];

    /**
     * 是否启用批量合并
     * Enable batch merge
     */
    batchMerge?: boolean;

    /**
     * 批量窗口时间(秒)
     * Batch window seconds
     */
    batchWindowSeconds?: int32;
}

/**
 * 访问控制配置
 * Access control configuration
 */
model AccessControl {
    /**
     * 访问模式
     * Access mode
     */
    mode: AccessControlMode;

    /**
     * 允许的组织列表(mode=whitelist 时)
     * Allowed organizations (when mode=whitelist)
     */
    allowedOrganizations?: string[];

    /**
     * 允许的用户列表(mode=whitelist 时)
     * Allowed users (when mode=whitelist)
     */
    allowedUsers?: string[];

    /**
     * 禁止的组织列表(mode=blacklist 时)
     * Denied organizations (when mode=blacklist)
     */
    deniedOrganizations?: string[];

    /**
     * 是否需要审批(mode=approval 时)
     * Require approval (when mode=approval)
     */
    requireApproval?: boolean;

    /**
     * 审批人列表
     * Approvers
     */
    approvers?: NexusBook.Api.Common.UserRef[];
}

/**
 * Connection 摘要
 * Connection summary
 */
model ConnectionSummary {
    /**
     * Connection ID
     * Connection ID
     */
    id: string;

    /**
     * Connection 名称
     * Connection name
     */
    name: string;

    /**
     * Connection 描述
     * Connection description
     */
    description?: string;

    /**
     * 源 Catalog ID
     * Source catalog ID
     */
    sourceCatalogId: string;

    /**
     * 源 Catalog 名称
     * Source catalog name
     */
    sourceCatalogName?: string;

    /**
     * 源组织 ID
     * Source organization ID
     */
    sourceOrganizationId: string;

    /**
     * 分享模式
     * Share mode
     */
    shareMode: ShareMode;

    /**
     * Connection 状态
     * Connection status
     */
    status: ConnectionStatus;

    /**
     * 活跃的 Binding 数量
     * Active binding count
     */
    activeBindingCount?: int32;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 最后同步时间
     * Last sync at
     */
    lastSyncAt?: string;
}

/**
 * Connection 详情
 * Connection details
 */
model ConnectionDetails {
    /**
     * Connection ID
     * Connection ID
     */
    id: string;

    /**
     * Connection 名称
     * Connection name
     */
    name: string;

    /**
     * Connection 描述
     * Connection description
     */
    description?: string;

    /**
     * 源 Catalog ID
     * Source catalog ID
     */
    sourceCatalogId: string;

    /**
     * 源 Catalog 类型
     * Source catalog type
     */
    sourceCatalogType: string;

    /**
     * 源组织 ID
     * Source organization ID
     */
    sourceOrganizationId: string;

    /**
     * 分享模式
     * Share mode
     */
    shareMode: ShareMode;

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
     * Connection 状态
     * Connection status
     */
    status: ConnectionStatus;

    /**
     * 访问控制配置
     * Access control
     */
    accessControl: AccessControl;

    /**
     * 分享范围配置
     * Share scope
     */
    shareScope: ShareScope;

    /**
     * 默认接收方配置
     * Default receiver config
     */
    defaultReceiverConfig?: DefaultReceiverConfig;

    /**
     * 传播事件配置
     * Propagation events
     */
    propagationEvents: PropagationEvents;

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
     * Last sync at
     */
    lastSyncAt?: string;

    /**
     * 创建者
     * Created by
     */
    createdBy?: NexusBook.Api.Common.UserRef;

    /**
     * 活跃的 Binding 列表
     * Active bindings
     */
    activeBindings?: ConnectionBindingSummary[];
}

/**
 * 创建 Connection 请求
 * Create connection request
 */
model CreateConnectionRequest {
    /**
     * Connection 名称
     * Connection name
     */
    name: string;

    /**
     * Connection 描述
     * Connection description
     */
    description?: string;

    /**
     * 源 Catalog ID
     * Source catalog ID
     */
    sourceCatalogId: string;

    /**
     * 分享模式
     * Share mode
     */
    shareMode: ShareMode;

    /**
     * 访问控制配置
     * Access control
     */
    accessControl: AccessControl;

    /**
     * 分享范围配置
     * Share scope
     */
    shareScope: ShareScope;

    /**
     * 默认接收方配置
     * Default receiver config
     */
    defaultReceiverConfig?: DefaultReceiverConfig;

    /**
     * 传播事件配置
     * Propagation events
     */
    propagationEvents?: PropagationEvents;
}

/**
 * 更新 Connection 请求
 * Update connection request
 */
model UpdateConnectionRequest {
    /**
     * Connection 名称
     * Connection name
     */
    name?: string;

    /**
     * Connection 描述
     * Connection description
     */
    description?: string;

    /**
     * Connection 状态
     * Connection status
     */
    status?: ConnectionStatus;

    /**
     * 访问控制配置
     * Access control
     */
    accessControl?: AccessControl;

    /**
     * 分享范围配置
     * Share scope
     */
    shareScope?: ShareScope;

    /**
     * 默认接收方配置
     * Default receiver config
     */
    defaultReceiverConfig?: DefaultReceiverConfig;

    /**
     * 传播事件配置
     * Propagation events
     */
    propagationEvents?: PropagationEvents;
}

/**
 * ConnectionBinding 状态枚举
 * ConnectionBinding status enum
 */
enum BindingStatus {
    /**
     * 待审批
     * Pending
     */
    pending,

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
     * 已拒绝
     * Rejected
     */
    rejected,
}

/**
 * Binding 方向枚举
 * Binding direction enum
 */
enum BindingDirection {
    /**
     * Outbound(供应商视角,分享出去)
     * Outbound (supplier perspective, sharing out)
     */
    outbound,

    /**
     * Inbound(采购商视角,接收数据)
     * Inbound (buyer perspective, receiving data)
     */
    inbound,
}

/**
 * 过滤条件组(支持嵌套)
 * Filter condition group (supports nesting)
 */
model FilterConditionGroup {
    /**
     * 逻辑运算符
     * Logical operator
     */
    operator: "AND" | "OR";

    /**
     * 过滤条件列表
     * Filter conditions
     */
    conditions: FilterCondition[];

    /**
     * 嵌套的子组(可选)
     * Nested sub-groups (optional)
     */
    groups?: FilterConditionGroup[];
}

/**
 * 过滤条件
 * Filter condition
 */
model FilterCondition {
    /**
     * 字段 ID
     * Field ID
     */
    fieldId: string;

    /**
     * 比较运算符
     * Comparison operator
     */
    operator: "eq" | "ne" | "gt" | "gte" | "lt" | "lte" | "in" | "not_in" | "contains" | "not_contains" | "starts_with" | "ends_with" | "is_null" | "is_not_null" | "regex";

    /**
     * 比较值
     * Comparison value
     */
    value?: unknown;

    /**
     * 值列表(operator=in/not_in 时使用)
     * Value list (used when operator=in/not_in)
     */
    values?: unknown[];
}

/**
 * 接收方过滤配置
 * Receiver filter configuration
 */
model ReceiverFilter {
    /**
     * 过滤条件组
     * Filter condition group
     *
     * 仅接收满足条件的数据行。
     * Only accept data rows that meet the conditions.
     *
     * 示例:
     * {
     *   "operator": "AND",
     *   "conditions": [
     *     { "fieldId": "price", "operator": "gte", "value": 100 },
     *     { "fieldId": "stock", "operator": "gt", "value": 0 }
     *   ],
     *   "groups": [
     *     {
     *       "operator": "OR",
     *       "conditions": [
     *         { "fieldId": "category", "operator": "in", "values": ["electronics", "computers"] },
     *         { "fieldId": "brand", "operator": "eq", "value": "Apple" }
     *       ]
     *     }
     *   ]
     * }
     */
    filterGroup?: FilterConditionGroup;

    /**
     * 接受模式
     * Accept mode
     */
    acceptMode: "auto" | "manual" | "selective";

    /**
     * 手动接受规则
     * Manual accept rules
     */
    manualAcceptRules?: ManualAcceptRules;

    /**
     * 最大接收数量(可选)
     * Max accept count (optional)
     */
    maxAcceptCount?: int32;

    /**
     * 去重策略
     * Deduplication strategy
     */
    deduplicationStrategy?: "none" | "by_field" | "by_fields";

    /**
     * 去重字段 ID(当 deduplicationStrategy=by_field/by_fields 时)
     * Deduplication field IDs (when deduplicationStrategy=by_field/by_fields)
     */
    deduplicationFieldIds?: string[];
}

/**
 * 手动接受规则
 * Manual accept rules
 */
model ManualAcceptRules {
    /**
     * 需要人工确认的条件
     * Require approval if
     */
    requireApprovalIf?: FilterConditionGroup;

    /**
     * 自动拒绝的条件
     * Auto reject if
     */
    autoRejectIf?: FilterConditionGroup;

    /**
     * 自动接受的条件(在 acceptMode=selective 时使用)
     * Auto accept if (used when acceptMode=selective)
     */
    autoAcceptIf?: FilterConditionGroup;

    /**
     * 默认动作(当无匹配规则时)
     * Default action (when no matching rule)
     */
    defaultAction?: "accept" | "reject" | "manual";
}

/**
 * ConnectionBinding 摘要
 * ConnectionBinding summary
 */
model ConnectionBindingSummary {
    /**
     * Binding ID
     * Binding ID
     */
    id: string;

    /**
     * Connection ID
     * Connection ID
     */
    connectionId: string;

    /**
     * Binding 方向
     * Binding direction
     */
    bindingDirection: BindingDirection;

    /**
     * 目标组织 ID
     * Target organization ID
     */
    targetOrganizationId: string;

    /**
     * 目标 OrderBook ID
     * Target OrderBook ID
     */
    targetOrderBookId: string;

    /**
     * Binding 状态
     * Binding status
     */
    bindingStatus: BindingStatus;

    /**
     * 申请时间
     * Requested at
     */
    requestedAt: string;

    /**
     * 激活时间
     * Activated at
     */
    activatedAt?: string;

    /**
     * 最后同步时间
     * Last sync time
     */
    lastSyncTime?: string;

    /**
     * 同步状态
     * Sync status
     */
    syncStatus?: "up_to_date" | "pending" | "syncing" | "failed";
}

/**
 * ConnectionBinding 详情
 * ConnectionBinding details
 */
model ConnectionBindingDetails {
    /**
     * Binding ID
     * Binding ID
     */
    id: string;

    /**
     * Connection ID
     * Connection ID
     */
    connectionId: string;

    /**
     * Binding 方向
     * Binding direction
     */
    bindingDirection: BindingDirection;

    /**
     * 目标组织 ID
     * Target organization ID
     */
    targetOrganizationId: string;

    /**
     * 目标 OrderBook ID
     * Target OrderBook ID
     */
    targetOrderBookId: string;

    /**
     * 目标 OrderBook 类型
     * Target OrderBook type
     */
    targetOrderBookType: string;

    /**
     * Binding 状态
     * Binding status
     */
    bindingStatus: BindingStatus;

    /**
     * 接收方过滤配置(Inbound 配置)
     * Receiver filter (Inbound config)
     */
    receiverFilter?: ReceiverFilter;

    /**
     * 字段映射配置(Inbound 配置)
     * Field mapping (Inbound config)
     */
    fieldMapping?: FieldMapping;

    /**
     * 冲突解决配置(Inbound 配置)
     * Conflict resolution (Inbound config)
     */
    conflictResolution?: ConflictResolution;

    /**
     * 申请时间
     * Requested at
     */
    requestedAt: string;

    /**
     * 申请人
     * Requested by
     */
    requestedBy?: NexusBook.Api.Common.UserRef;

    /**
     * 批准时间
     * Approved at
     */
    approvedAt?: string;

    /**
     * 批准人
     * Approved by
     */
    approvedBy?: NexusBook.Api.Common.UserRef;

    /**
     * 激活时间
     * Activated at
     */
    activatedAt?: string;

    /**
     * 最后同步时间
     * Last sync time
     */
    lastSyncTime?: string;

    /**
     * 最后同步 Revision ID
     * Last sync revision ID
     */
    lastSyncRevisionId?: string;

    /**
     * 同步状态
     * Sync status
     */
    syncStatus: "up_to_date" | "pending" | "syncing" | "failed";
}

/**
 * 创建 ConnectionBinding 请求
 * Create connection binding request
 */
model CreateConnectionBindingRequest {
    /**
     * Connection ID
     * Connection ID
     */
    connectionId: string;

    /**
     * 目标 OrderBook ID
     * Target OrderBook ID
     */
    targetOrderBookId: string;

    /**
     * 接收方过滤配置(Inbound 配置)
     * Receiver filter (Inbound config)
     */
    receiverFilter?: ReceiverFilter;

    /**
     * 字段映射配置(Inbound 配置)
     * Field mapping (Inbound config)
     */
    fieldMapping?: FieldMapping;

    /**
     * 冲突解决配置(Inbound 配置)
     * Conflict resolution (Inbound config)
     */
    conflictResolution?: ConflictResolution;
}

/**
 * 更新 ConnectionBinding 请求
 * Update connection binding request
 */
model UpdateConnectionBindingRequest {
    /**
     * Binding 状态
     * Binding status
     */
    bindingStatus?: BindingStatus;

    /**
     * 接收方过滤配置
     * Receiver filter
     */
    receiverFilter?: ReceiverFilter;

    /**
     * 字段映射配置
     * Field mapping
     */
    fieldMapping?: FieldMapping;

    /**
     * 冲突解决配置
     * Conflict resolution
     */
    conflictResolution?: ConflictResolution;
}
