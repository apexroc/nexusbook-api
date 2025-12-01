import "@typespec/http";
using TypeSpec.Http;

/**
 * 通用模块
 *
 * 定义所有 API 中使用的通用数据结构、错误码、查询和过滤机制。
 *
 * 主要内容：
 * - **响应格式** - ApiResponse, Page 等标准响应结构
 * - **错误管理** - 统一的错误码定义和多语言消息
 * - **查询引擎** - 支持过滤、排序、分组和聚合的查询模型
 * - **数据模型** - 通用的值类型、附件、用户引用等
 *
 * ## 查询示例
 *
 * ### 简单查询
 * GET /doc/product/123/data?page=1&pageSize=20
 *
 * ### 高级查询
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
namespace NexusBook.Common;

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

model GroupBy {
    /**
     * 分组字段
     * Group fields
     */
    fields: string[];

    /**
     * 聚合集合
     * Aggregations
     */
    aggregations?: Aggregation[];
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
    createdBy: string;
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
