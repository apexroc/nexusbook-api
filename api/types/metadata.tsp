import "@typespec/http";
import "../types/common.tsp";
import "@typespec/openapi3";

using TypeSpec.Http;
using OpenAPI;

namespace NexusBook.Api.Document;

/// 字段类型（覆盖多维表格常见类型）
/// Field types aligned with multi-dimensional table SaaS
@doc("覆盖文本、数值、日期时间、选择、附件、用户、关联及计算型字段类型。\nCovers text, number, datetime, select, attachment, user, relation and computed field types.")
enum FieldType {
  text,
  long_text,
  number,
  currency,
  percent,
  date,
  datetime,
  boolean,
  single_select,
  multi_select,
  attachment,
  user,
  collaborator,
  relation,
  lookup,
  rollup,
  formula,
  auto_number,
  created_time,
  updated_time,
  created_by,
  updated_by,
}

/** 字段定义与校验配置
 Field definition with validation & compute configuration */
@doc("""
描述字段的类型、默认值、选项、只读/唯一/必填，以及公式/查找/汇总与校验规则。

- 计算：`formula` 表达式、`lookup`（关联字段+目标字段）、`rollup`（关联字段+目标字段+聚合函数）
- 校验：规则类型(`ruleType`) + 配置(`config`) + 多语言消息(`message`)

Describes type, default, options, readonly/unique/required, and formula/lookup/rollup with validations.
""")
model Field {
  /// 字段ID Field id
  id: string;
  /// 字段名 Field name
  name: string;
  /// 字段类型 Field type
  type: FieldType;
  /// 是否必填 Required
  required?: boolean;
  /// 是否唯一 Unique
  unique?: boolean;
  /// 是否只读 Read only
  readOnly?: boolean;
  /// 可选项（旧）Legacy options
  options?: string[];
  /// 默认值 Default value
  defaultValue?: unknown;
  /// 选择类字段的选项集合
  selectOptions?: NexusBook.Common.SelectOption[];
  /// 计算配置：公式/查找/汇总（字符串表达）
  formula?: string;
  lookup?: LookupConfig;
  rollup?: RollupConfig;
  /// 校验规则
  validations?: {
    /// 规则类型 Rule type
    ruleType: string;
    /// 配置 Config
    config?: unknown;
    /// 消息（多语言） Message
    message?: NexusBook.Common.Message;
  }[];
}

model LookupConfig {
  @doc("关联字段ID。\nRelation field id.")
  relationFieldId: string;
  @doc("目标字段ID。\nTarget field id.")
  targetFieldId: string;
}

model RollupConfig {
  @doc("关联字段ID。\nRelation field id.")
  relationFieldId: string;
  @doc("目标字段ID。\nTarget field id.")
  targetFieldId: string;
  @doc("聚合函数。\nAggregation function.")
  agg: NexusBook.Common.AggregationFn;
}

/** 文档元数据集合
 Document metadata collection */
@doc("字段集合与元设置。\nField collection and meta settings.")
model Metadata {
  fields: Field[];
}

@route("/doc/{docType}/{docId}/metadata")
@tag("Document")
interface MetadataApi {
  @get
  @summary("获取文档元数据")
  @doc("""
  返回字段定义与显示配置，供渲染与校验使用。

  Returns field definitions and display settings for rendering and validation.
  """
  )
  op getMetadata(@path docType: string, @path docId: string): NexusBook.Common.ApiResponse<Metadata>;

  @put
  @summary("更新文档元数据")
  @doc("""
  更新字段与显示配置，需具备管理权限。

  Update fields and display settings, requires manage permission.
  """
  )
  op putMetadata(@path docType: string, @path docId: string, @body body: Metadata): NexusBook.Common.ApiResponse<Metadata>;
}
