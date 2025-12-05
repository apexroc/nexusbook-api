import "@typespec/http";
import "../../shared/index.tsp";
import "@typespec/openapi3";

using TypeSpec.Http;
using OpenAPI;

/**
 * 元数据模块
 *
 * 管理文档的字段定义、类型和验证规则。
 *
 * 主要功能：
 * - **字段定义** - 定义字段类型、必填性、唯一性等属性
 * - **计算字段** - 支持公式、查找和汇总计算
 * - **验证规则** - 对字段值进行复杂验证
 * - **选项管理** - 为选择类字段定义可用选项
 * - **关联关系** - 定义字段间的关联和查找关系
 */
namespace NexusBook.Api;

/**
 * 字段类型（覆盖多维表格常见类型）
 * Field types aligned with multi-dimensional table SaaS
 *
 * 覆盖文本、数值、日期时间、选择、附件、用户、关联及计算型字段类型。
 * Covers text, number, datetime, select, attachment, user, relation and computed field types.
 */
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

/**
 * 字段定义与校验配置
 * Field definition with validation & compute configuration
 *
 * 描述字段的类型、默认值、选项、只读/唯一/必填，以及公式/查找/汇总与校验规则。
 *
 * - 计算：`formula` 表达式、`lookup`（关联字段+目标字段）、`rollup`（关联字段+目标字段+聚合函数）
 * - 校验：规则类型(`ruleType`) + 配置(`config`) + 多語言消息(`message`)
 *
 * Describes type, default, options, readonly/unique/required, and formula/lookup/rollup with validations.
 */
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
    /**
     * 关联字段ID
     * Relation field id
     */
    relationFieldId: string;

    /**
     * 目标字段ID
     * Target field id
     */
    targetFieldId: string;
}

model RollupConfig {
    /**
     * 关联字段ID
     * Relation field id
     */
    relationFieldId: string;

    /**
     * 目标字段ID
     * Target field id
     */
    targetFieldId: string;

    /**
     * 聚合函数
     * Aggregation function
     */
    agg: NexusBook.Common.AggregationFn;
}

/**
 * 文档元数据集合
 * Document metadata collection
 *
 * 包含数据行字段定义和文档属性定义。
 * Contains data row field definitions and document property definitions.
 *
 * - **fields** - 数据行的字段定义（表格列）
 * - **properties** - 文档级别的属性定义（文档元信息字段）
 *
 * Field collection and property definitions:
 * - **fields** - Field definitions for data rows (table columns)
 * - **properties** - Property field definitions for document-level metadata
 */
model Metadata {
    /**
     * 数据行字段定义
     * Data row field definitions
     *
     * 定义数据行（表格行）的字段结构。
     * Defines the field structure for data rows (table rows).
     */
    fields: Field[];

    /**
     * 文档属性字段定义
     * Document property field definitions
     *
     * 定义文档级别属性的字段结构（如订单时间、总金额等）。
     * Defines the field structure for document-level properties (e.g., order time, total amount).
     *
     * 这些字段定义用于 `DocumentProperties.properties` 中的值。
     * These field definitions are used for values in `DocumentProperties.properties`.
     */
    properties?: Field[];
}

@route("/doc/{docType}/{docId}/metadata")
@tag("Document - Core")
interface MetadataApi {
    /**
     * 返回字段定义与显示配置，供渲染与校验使用。
     *
     * Returns field definitions and display settings for rendering and validation.
     */
    @get
    @summary("获取文档元数据")
    getMetadata(
        @path docType: string,
        @path docId: string,
    ): NexusBook.Common.ApiResponse<Metadata>;

    /**
     * 更新字段与显示配置，需具备管理权限。
     *
     * Update fields and display settings, requires manage permission.
     */
    @put
    @summary("更新文档元数据")
    putMetadata(
        @path docType: string,
        @path docId: string,
        @body body: Metadata,
    ): NexusBook.Common.ApiResponse<Metadata>;
}
