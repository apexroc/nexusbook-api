import "@typespec/http";
using TypeSpec.Http;

/**
 * NexusBook Common API Types
 * NexusBook 通用 API 类型
 *
 * 定义所有 API 中使用的通用数据结构、错误码、查询和过滤机制。
 * Defines common data structures, error codes, query and filter mechanisms used across all APIs.
 *
 * Route Base: N/A (共享类型，无路由 / Shared types, no routes)
 *
 * 主要内容 / Main Components:
 * - **响应格式 Response Format** - ApiResponse, Page 等标准响应结构
 * - **错误管理 Error Management** - 统一的错误码定义和多语言消息
 * - **查询引擎 Query Engine** - 支持过滤、排序、分组和聚合的查询模型
 * - **数据模型 Data Models** - 通用的值类型、附件、用户引用等
 *
 * ## 查询示例 Query Examples
 *
 * ### 简单查询 Simple Query
 * GET /doc/product/123/data?page=1&pageSize=20
 *
 * ### 高级查询 Advanced Query
 * POST /doc/product/123/data/query
 * {
 *   "filters": {
 *     "logic": "and",
 *     "conditions": [
 *       {"field": "status", "operator": "eq", "value": "active"}
 *     ]
 *   },
 *   "sorts": [{"field": "created_at", "direction": "desc"}],
 *   "page": 1,
 *   "pageSize": 20
 * }
 */
namespace NexusBook.Api.Common;

/**
 * 多语言消息
 * Multi-language message
 *
 * 使用语言代码作为键的动态对象，支持任意语言。
 * Dynamic object using language codes as keys, supporting any language.
 *
 * 常用语言代码示例 (Common language codes):
 * - zh: 中文 (Chinese)
 * - en: English
 * - ja: 日本語 (Japanese)
 * - ko: 한국어 (Korean)
 * - es: Español (Spanish)
 * - fr: Français (French)
 * - de: Deutsch (German)
 * - pt: Português (Portuguese)
 * - ru: Русский (Russian)
 * - ar: العربية (Arabic)
 *
 * 示例 (Example):
 * ```json
 * {
 *   "zh": "用户未找到",
 *   "en": "User not found",
 *   "ja": "ユーザーが見つかりません",
 *   "es": "Usuario no encontrado"
 * }
 * ```
 */
model Message {
    /**
     * 语言代码到消息文本的映射
     * Mapping from language code to message text
     *
     * 键为 ISO 639-1 语言代码（如 zh, en, ja 等）。
     * Keys are ISO 639-1 language codes (e.g., zh, en, ja).
     */
    ...Record<string>;
}

enum ErrorCode {
    // 认证相关
    BAD_USER_NAME,
    INVALID_CLIENT,
    INVALID_TOKEN,
    UNAUTHORIZED,
    FORBIDDEN,
    
    // 文档相关
    DOC_NOT_FOUND,
    DOC_TYPE_UNKNOWN,
    DOC_ACCESS_DENIED,
    
    // 视图相关
    VIEW_NOT_FOUND,
    VIEW_INVALID_DEFINITION,
    
    // 数据相关
    ROW_NOT_FOUND,
    FIELD_TYPE_MISMATCH,
    CONSTRAINT_VIOLATION,
    PAGE_OUT_OF_RANGE,
    
    // 评论相关
    COMMENT_NOT_FOUND,
    
    // 审批相关
    APPROVAL_NOT_FOUND,
    APPROVAL_INVALID_STATE,
    APPROVAL_DECISION_REQUIRED,
    
    // 请求相关
    REQUEST_NOT_FOUND,
    REQUEST_CONFLICT,
    REQUEST_ALREADY_CLOSED,
    
    // 用户相关
    USER_NOT_FOUND,
    USER_ALREADY_EXISTS,
    EMAIL_ALREADY_USED,
    OAUTH_PROVIDER_NOT_SUPPORTED,
    OAUTH_PROVIDER_ALREADY_LINKED,
    OAUTH_PROVIDER_NOT_LINKED,
    
    // 组织相关
    ORG_NOT_FOUND,
    ORG_SLUG_ALREADY_EXISTS,
    ORG_PERMISSION_DENIED,
    ORG_ALREADY_MEMBER,
    ORG_NOT_MEMBER,
    ORG_CANNOT_LEAVE_AS_OWNER,
    ORG_MEMBER_NOT_FOUND,
    
    // 工作区相关
    WORKSPACE_NOT_FOUND,
    WORKSPACE_SLUG_ALREADY_EXISTS,
    WORKSPACE_PERMISSION_DENIED,
    WORKSPACE_NOT_MEMBER,
    WORKSPACE_MEMBER_NOT_FOUND,
    
    // 邀请相关
    INVITATION_NOT_FOUND,
    INVITATION_EXPIRED,
    INVITATION_ALREADY_ACCEPTED,
    INVITATION_EMAIL_MISMATCH,
    INVITATION_ALREADY_REVOKED,
    
    // 加入申请相关
    JOIN_REQUEST_NOT_FOUND,
    JOIN_REQUEST_ALREADY_EXISTS,
    JOIN_REQUEST_ALREADY_PROCESSED,
}

model ApiResponse<T> {
    /**
     * 是否成功
     * Whether the request succeeded
     */
    success: boolean;

    /**
     * 错误码
     * Error code (when failed)
     */
    code?: ErrorCode;

    /**
     * 消息（多语言）
     * Message (multi-language)
     */
    message?: Message;

    /**
     * 载荷
     * Payload
     */
    payload?: T | null;
}

model Page<T> {
    /**
     * 列表项
     * Items
     */
    items: T[];

    /**
     * 当前页
     * Page number
     */
    page: int32;

    /**
     * 每页数量
     * Page size
     */
    pageSize: int32;

    /**
     * 总数
     * Total count
     */
    total: int64;
}

enum Direction {
    asc,
    desc,
}

enum FilterOp {
    eq,
    ne,
    in,
    range,
    contains,
    is_empty,
    is_not_empty,
}

model Sort {
    /**
     * 字段
     * Field name
     */
    field: string;

    /**
     * 方向
     * Direction
     */
    direction: Direction;
}

model Filter {
    /**
     * 字段
     * Field name
     */
    field: string;

    /**
     * 操作符
     * Operator
     */
    operator: FilterOp;

    /**
     * 值（单值）
     * Single value
     */
    value?: unknown;

    /**
     * 多值
     * Multiple values
     */
    values?: unknown[];

    /**
     * 区间起
     * Range start
     */
    rangeStart?: unknown;

    /**
     * 区间止
     * Range end
     */
    rangeEnd?: unknown;
}

enum LogicOp {
    and,
    or,
}

model FilterGroup {
    /**
     * 逻辑组合
     * AND/OR logic
     */
    logic: LogicOp;

    /**
     * 条件集合
     * Conditions
     */
    conditions?: Filter[];

    /**
     * 嵌套组合
     * Nested groups
     */
    groups?: FilterGroup[];
}

enum AggregationFn {
    count,
    sum,
    avg,
    min,
    max,
}

model Aggregation {
    /**
     * 聚合函数
     * Aggregation function
     */
    kind: AggregationFn;

    /**
     * 目标字段
     * Target field
     */
    field: string;
}

/**
 * 分组定义（支持多级分组）
 * Group-by definition (supports multi-level grouping)
 *
 * 示例 / Example:
 * ```json
 * {
 *   "fields": ["category", "status"],
 *   "aggregations": [
 *     {"kind": "count", "field": "*"},
 *     {"kind": "sum", "field": "amount"}
 *   ]
 * }
 * ```
 */
model GroupBy {
    /**
     * 分组字段列表（按顺序定义分组层级）
     * Group fields (defines grouping levels in order)
     *
     * 第一个字段为第一级分组，第二个字段为第二级分组，以此类推。
     * First field is the first level, second field is the second level, and so on.
     *
     * 示例 / Example:
     * - ["category"] - 单级分组 / Single-level grouping
     * - ["category", "status"] - 二级分组 / Two-level grouping
     * - ["region", "category", "status"] - 三级分组 / Three-level grouping
     */
    fields: string[];

    /**
     * 聚合函数集合
     * Aggregations
     *
     * 聚合计算会应用到每个分组层级。
     * Aggregations are applied to each grouping level.
     */
    aggregations?: Aggregation[];
}

/**
 * 分组结果节点（支持树状结构）
 * Grouped result node (supports tree structure)
 *
 * 用于表示多级分组的结果，每个节点代表一个分组。
 * Represents multi-level grouping results, each node represents a group.
 *
 * 示例 / Example (单级分组 / Single-level):
 * ```json
 * {
 *   "key": "Electronics",
 *   "count": 150,
 *   "aggregations": {
 *     "total_amount": 45000,
 *     "avg_price": 300
 *   }
 * }
 * ```
 *
 * 示例 / Example (多级分组 / Multi-level):
 * ```json
 * {
 *   "key": "Electronics",
 *   "count": 150,
 *   "aggregations": {
 *     "total_amount": 45000
 *   },
 *   "children": [
 *     {
 *       "key": "Active",
 *       "count": 120,
 *       "aggregations": {"total_amount": 40000}
 *     },
 *     {
 *       "key": "Inactive",
 *       "count": 30,
 *       "aggregations": {"total_amount": 5000}
 *     }
 *   ]
 * }
 * ```
 */
model GroupNode {
    /**
     * 分组键值
     * Group key
     *
     * 当前层级的分组字段值。
     * The value of the grouping field at current level.
     */
    key: unknown;

    /**
     * 分组字段名
     * Group field name
     *
     * 当前层级的分组字段名称。
     * The name of the grouping field at current level.
     */
    field: string;

    /**
     * 数据行数
     * Row count
     *
     * 当前分组包含的数据行数量。
     * Number of rows in this group.
     */
    count: int64;

    /**
     * 聚合结果
     * Aggregation results
     *
     * 键为聚合名称（如 "sum_amount", "avg_price"），值为聚合结果。
     * Keys are aggregation names (e.g., "sum_amount", "avg_price"), values are results.
     *
     * 命名规则：{function}_{field}
     * Naming convention: {function}_{field}
     */
    aggregations?: Record<unknown>;

    /**
     * 子分组
     * Child groups
     *
     * 下一级分组的结果列表。如果是最后一级分组，则为空。
     * List of next-level grouping results. Empty if this is the last level.
     */
    children?: GroupNode[];

    /**
     * 数据行（可选）
     * Data rows (optional)
     *
     * 如果请求包含数据行，则此字段包含当前分组的实际数据。
     * If data rows are requested, this field contains the actual data in this group.
     *
     * 注意：通常只在最后一级分组或明确请求时返回。
     * Note: Usually only returned at the last level or when explicitly requested.
     */
    rows?: Record<unknown>[];
}

/**
 * 分组查询结果
 * Grouped query result
 *
 * 包含分组树和元信息。
 * Contains grouping tree and metadata.
 */
model GroupedResult {
    /**
     * 分组树
     * Group tree
     *
     * 顶层分组节点列表。
     * Top-level group nodes.
     */
    groups: GroupNode[];

    /**
     * 总行数
     * Total row count
     *
     * 所有分组的总数据行数。
     * Total number of rows across all groups.
     */
    total: int64;

    /**
     * 分组定义
     * Group-by definition
     *
     * 返回使用的分组定义，便于客户端理解结果结构。
     * Returns the grouping definition used, helping clients understand the result structure.
     */
    groupBy: GroupBy;
}

model SelectOption {
    /**
     * 选项ID
     * Option id
     */
    id: string;

    /**
     * 文本标签
     * Label
     */
    label: string;

    /**
     * 颜色
     * Color
     */
    color?: string;

    /**
     * 是否禁用
     * Disabled
     */
    disabled?: boolean;
}

model Attachment {
    /**
     * 附件ID
     * Attachment id
     *
     * 附件唯一标识。
     * Unique identifier of the attachment.
     */
    id: string;

    /**
     * 文件名
     * File name
     *
     * 文件名。
     * File name.
     */
    fileName: string;

    /**
     * URL 链接
     * URL
     *
     * 可访问的下载URL。
     * Accessible download URL.
     */
    url: string;

    /**
     * 媒体类型
     * MIME type
     *
     * MIME类型。
     * MIME type.
     */
    mimeType: string;

    /**
     * 大小
     * Size
     *
     * 文件大小（字节）。
     * File size in bytes.
     */
    size: int64;

    /**
     * 校验和
     * Checksum
     *
     * 完整性校验和。
     * Integrity checksum.
     */
    checksum?: string;

    /**
     * 宽度
     * Width
     *
     * 图像宽度（像素）。
     * Image width in pixels.
     */
    width?: int32;

    /**
     * 高度
     * Height
     *
     * 图像高度（像素）。
     * Image height in pixels.
     */
    height?: int32;

    /**
     * 创建时间
     * Created at
     *
     * 上传时间戳。
     * Upload timestamp.
     */
    createdAt: string;

    /**
     * 创建人
     * Created by
     *
     * 上传者。
     * Uploader.
     */
    createdBy: UserRef;
}

model UserRef {
    /**
     * 用户ID
     * User id
     *
     * 用户唯一标识。
     * Unique identifier of the user.
     */
    id: string;

    /**
     * 展示名
     * Display name
     *
     * 显示名称。
     * Display name.
     */
    displayName: string;

    /**
     * 邮箱
     * Email
     *
     * 邮箱。
     * Email.
     */
    email?: string;

    /**
     * 头像
     * Avatar URL
     *
     * 头像URL。
     * Avatar URL.
     */
    avatarUrl?: string;
}

model CollaboratorRef {
    /**
     * 参与者ID
     * Collaborator id
     */
    id: string;

    /**
     * 展示名
     * Display name
     */
    displayName: string;

    /**
     * 邮箱
     * Email
     */
    email?: string;

    /**
     * 头像
     * Avatar URL
     */
    avatarUrl?: string;
}

model RelationRef {
    /**
     * 目标文档类型
     * Target document type
     *
     * 被关联的文档类型。
     * Target document type.
     */
    targetDocType: string;

    /**
     * 目标文档ID
     * Target document id
     *
     * 被关联的文档ID。
     * Target document id.
     */
    targetDocId: string;

    /**
     * 行ID
     * Row id
     *
     * 被关联的行ID。
     * Target row id.
     */
    rowId: string;
}

union Value {
    text: string,
    long_text: string,
    number: float64,
    currency: float64,
    percent: float64,
    boolean: boolean,
    date: string,
    datetime: string,
    single_select: SelectOption,
    multi_select: SelectOption[],
    attachment: Attachment[],
    user: UserRef,
    collaborator: CollaboratorRef,
    relation: RelationRef[],
    rating: int32,
    duration: int64,
}

model ValueEntry {
    /**
     * 字段ID
     * Field id
     */
    fieldId: string;

    /**
     * 字段值
     * Field value
     */
    value?: Value;
}
