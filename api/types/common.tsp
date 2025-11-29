import "@typespec/http";
using TypeSpec.Http;

namespace NexusBook.Common;

model Message {
  /// 中文消息 Chinese message
  zh: string;
  /// 英文消息 English message
  en: string;
}

enum ErrorCode {
  BAD_USER_NAME,
  INVALID_CLIENT,
  INVALID_TOKEN,
  UNAUTHORIZED,
  FORBIDDEN,

  DOC_NOT_FOUND,
  DOC_TYPE_UNKNOWN,
  DOC_ACCESS_DENIED,

  VIEW_NOT_FOUND,
  VIEW_INVALID_DEFINITION,

  ROW_NOT_FOUND,
  FIELD_TYPE_MISMATCH,
  CONSTRAINT_VIOLATION,
  PAGE_OUT_OF_RANGE,

  COMMENT_NOT_FOUND,

  APPROVAL_NOT_FOUND,
  APPROVAL_INVALID_STATE,
  APPROVAL_DECISION_REQUIRED,

  REQUEST_NOT_FOUND,
  REQUEST_CONFLICT,
  REQUEST_ALREADY_CLOSED,
}

model ApiResponse<T> {
  /// 是否成功 Whether the request succeeded
  success: boolean;
  /// 错误码 Error code (when failed)
  code?: ErrorCode;
  /// 消息（多语言） Message (multi-language)
  message?: Message;
  /// 载荷 Payload
  payload?: T | null;
}

model Page<T> {
  /// 列表项 Items
  items: T[];
  /// 当前页 Page number
  page: int32;
  /// 每页数量 Page size
  pageSize: int32;
  /// 总数 Total count
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
  /// 字段 Field name
  field: string;
  /// 方向 Direction
  direction: Direction;
}

model Filter {
  /// 字段 Field name
  field: string;
  /// 操作符 Operator
  operator: FilterOp;
  /// 值（单值） Single value
  value?: unknown;
  /// 多值 Multiple values
  values?: unknown[];
  /// 区间起 Range start
  rangeStart?: unknown;
  /// 区间止 Range end
  rangeEnd?: unknown;
}

enum LogicOp {
  and,
  or,
}

model FilterGroup {
  /// 逻辑组合 AND/OR
  logic: LogicOp;
  /// 条件集合 Conditions
  conditions?: Filter[];
  /// 嵌套组合 Nested groups
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
  /// 聚合函数 Aggregation function
  kind: AggregationFn;
  /// 目标字段 Target field
  field: string;
}

model GroupBy {
  /// 分组字段 Group fields
  fields: string[];
  /// 聚合集合 Aggregations
  aggregations?: Aggregation[];
}

model SelectOption {
  /// 选项ID Option id
  id: string;
  /// 文本标签 Label
  label: string;
  /// 颜色 Color
  color?: string;
  /// 是否禁用 Disabled
  disabled?: boolean;
}

model Attachment {
  /// 附件ID Attachment id
  @doc("附件唯一标识。\nUnique identifier of the attachment.")
  id: string;
  /// 文件名 File name
  @doc("文件名。\nFile name.")
  fileName: string;
  /// URL 链接 URL
  @doc("可访问的下载URL。\nAccessible download URL.")
  url: string;
  /// 媒体类型 MIME type
  @doc("MIME类型。\nMIME type.")
  mimeType: string;
  /// 大小 Size
  @doc("文件大小（字节）。\nFile size in bytes.")
  size: int64;
  /// 校验和 Checksum
  @doc("完整性校验和。\nIntegrity checksum.")
  checksum?: string;
  /// 宽度 Width
  @doc("图像宽度（像素）。\nImage width in pixels.")
  width?: int32;
  /// 高度 Height
  @doc("图像高度（像素）。\nImage height in pixels.")
  height?: int32;
  /// 创建时间 Created at
  @doc("上传时间戳。\nUpload timestamp.")
  createdAt: string;
  /// 创建人 Created by
  @doc("上传者。\nUploader.")
  createdBy: string;
}

model UserRef {
  /// 用户ID User id
  @doc("用户唯一标识。\nUnique identifier of the user.")
  id: string;
  /// 展示名 Display name
  @doc("显示名称。\nDisplay name.")
  displayName: string;
  /// 邮箱 Email
  @doc("邮箱。\nEmail.")
  email?: string;
  /// 头像 Avatar URL
  @doc("头像URL。\nAvatar URL.")
  avatarUrl?: string;
}

model RelationRef {
  /// 目标文档类型 Target document type
  @doc("被关联的文档类型。\nTarget document type.")
  targetDocType: string;
  /// 目标文档ID Target document id
  @doc("被关联的文档ID。\nTarget document id.")
  targetDocId: string;
  /// 行ID Row id
  @doc("被关联的行ID。\nTarget row id.")
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
  collaborator: UserRef,
  relation: RelationRef[],
  rating: int32,
  duration: int64
}

model ValueEntry {
  /// 字段ID Field id
  fieldId: string;
  /// 字段值 Field value
  value?: Value;
}
