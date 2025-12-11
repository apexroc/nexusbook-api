import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 文档关联模块 (Document Relations)
 *
 * 提供文档间的双向关联管理，支持多对多、一对多等关系类型。
 * Provides bidirectional document relation management, supporting many-to-many, one-to-many relationships.
 *
 * ## 核心功能
 *
 * - **双向关联** - 自动维护关系的两端
 * - **级联操作** - 支持级联删除策略
 * - **关系验证** - 防止循环引用和重复关联
 * - **批量关联** - 批量创建/删除关联关系
 *
 * ## 使用场景
 *
 * - **订单-产品** - 一对多关联
 * - **项目-成员** - 多对多关联
 * - **文档-标签** - 多对多关联
 * - **父子文档** - 树形层级结构
 *
 * ## 示例
 *
 * ### 创建双向关联
 * ```bash
 * curl -X POST 'https://open.nexusbook.app/api/v1/doc/order/123/relations' \
 *   -H 'Authorization: Bearer TOKEN' \
 *   -d '{
 *     "targetDocType": "product",
 *     "targetDocId": "456",
 *     "targetRowId": "row-1",
 *     "fieldId": "products",
 *     "reverseFieldId": "orders",
 *     "bidirectional": true
 *   }'
 * ```
 */
namespace NexusBook.Api.Document;

/**
 * 关联关系配置
 * Relation configuration
 */
model RelationConfig {
    /**
     * 配置ID
     * Config id
     */
    id: string;

    /**
     * 源文档类型
     * Source document type
     */
    sourceDocType: string;

    /**
     * 源文档ID
     * Source document id
     */
    sourceDocId: string;

    /**
     * 源字段ID
     * Source field id
     */
    fieldId: string;

    /**
     * 目标文档类型
     * Target document type
     */
    targetDocType: string;

    /**
     * 目标文档ID
     * Target document id
     */
    targetDocId: string;

    /**
     * 是否双向关联
     * Bidirectional linking
     */
    bidirectional?: boolean;

    /**
     * 反向字段ID（双向关联时使用）
     * Reverse field id (for bidirectional)
     */
    reverseFieldId?: string;

    /**
     * 级联删除策略
     * Cascade delete strategy
     */
    cascadeDelete?: CascadeDeleteStrategy;

    /**
     * 关联验证规则
     * Link validation rules
     */
    validation?: {
        /**
         * 允许重复关联
         * Allow duplicate links
         */
        allowDuplicates?: boolean;

        /**
         * 最大关联数
         * Max links
         */
        maxLinks?: int32;

        /**
         * 最小关联数
         * Min links
         */
        minLinks?: int32;

        /**
         * 防止循环引用
         * Prevent circular reference
         */
        preventCircular?: boolean;
    };

    /**
     * 创建时间
     * Created at
     */
    createdAt?: string;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt?: string;
}

/**
 * 级联删除策略
 * Cascade delete strategy
 */
enum CascadeDeleteStrategy {
    /**
     * 不级联
     * No cascade
     */
    none,

    /**
     * 仅删除关联关系
     * Delete relation only
     */
    unlink,

    /**
     * 软删除关联记录
     * Soft delete related records
     */
    soft,

    /**
     * 硬删除关联记录
     * Hard delete related records
     */
    hard,

    /**
     * 阻止删除（如果有关联）
     * Prevent delete if linked
     */
    prevent,
}

/**
 * 关联关系实例
 * Relation instance
 */
model Relation {
    /**
     * 关联ID
     * Relation id
     */
    id: string;

    /**
     * 源文档类型
     * Source document type
     */
    sourceDocType: string;

    /**
     * 源文档ID
     * Source document id
     */
    sourceDocId: string;

    /**
     * 源行ID
     * Source row id
     */
    sourceRowId: string;

    /**
     * 源字段ID
     * Source field id
     */
    fieldId: string;

    /**
     * 目标文档类型
     * Target document type
     */
    targetDocType: string;

    /**
     * 目标文档ID
     * Target document id
     */
    targetDocId: string;

    /**
     * 目标行ID
     * Target row id
     */
    targetRowId: string;

    /**
     * 关联元数据（可选的附加信息）
     * Relation metadata (optional additional info)
     */
    metadata?: unknown;

    /**
     * 创建时间
     * Created at
     */
    createdAt?: string;

    /**
     * 创建人
     * Created by
     */
    createdBy?: NexusBook.Api.Common.UserRef;
}

/**
 * 关联关系查询结果
 * Relation query result
 */
model RelationWithDetails {
    /**
     * 关联关系
     * Relation
     */
    relation: Relation;

    /**
     * 目标行数据（可选）
     * Target row data (optional)
     */
    targetRow?: unknown;

    /**
     * 目标文档元数据（可选）
     * Target document metadata (optional)
     */
    targetMetadata?: unknown;
}

@route("/doc/{docType}/{docId}/relations")
@tag("Document - Relations")
interface RelationsApi {
    /**
     * 获取文档的关联配置
     *
     * Get document relation configurations
     *
     * 返回该文档所有字段的关联配置。
     * Return all field relation configurations of the document.
     */
    @route("/configs")
    @get
    @summary("获取关联配置")
    getRelationConfigs(
        @path docType: string,
        @path docId: string,
    ): NexusBook.Api.Common.ApiResponse<RelationConfig[]>;

    /**
     * 创建或更新关联配置
     *
     * Create or update relation configuration
     *
     * 配置字段的关联规则，包括双向关联、级联策略等。
     * Configure field relation rules, including bidirectional, cascade strategy, etc.
     */
    @route("/configs")
    @post
    @summary("配置关联关系")
    createRelationConfig(
        @path docType: string,
        @path docId: string,
        @body body: RelationConfig,
    ): NexusBook.Api.Common.ApiResponse<RelationConfig>;

    /**
     * 列出所有关联关系
     *
     * List all relations
     *
     * 查询文档的所有关联关系，支持过滤。
     * Query all relations of the document, supports filtering.
     */
    @get
    @summary("列出关联关系")
    listRelations(
        @path docType: string,
        @path docId: string,
        @query fieldId?: string,
        @query targetDocType?: string,
        @query targetDocId?: string,
        @query includeDetails?: boolean,
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<RelationWithDetails>>;

    /**
     * 创建关联关系
     *
     * Create relation
     *
     * 在两个文档行之间创建关联。如果配置为双向关联，会自动在目标端创建反向关联。
     * Create relation between two document rows. If bidirectional, automatically creates reverse relation.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/doc/order/123/relations' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -d '{
     *     "sourceRowId": "row-1",
     *     "fieldId": "products",
     *     "targetDocType": "product",
     *     "targetDocId": "456",
     *     "targetRowId": "row-2",
     *     "metadata": {"quantity": 10}
     *   }'
     * ```
     */
    @post
    @summary("创建关联")
    createRelation(
        @path docType: string,
        @path docId: string,
        @body body: {
            /**
             * 源行ID
             * Source row id
             */
            sourceRowId: string;

            /**
             * 源字段ID
             * Source field id
             */
            fieldId: string;

            /**
             * 目标文档类型
             * Target document type
             */
            targetDocType: string;

            /**
             * 目标文档ID
             * Target document id
             */
            targetDocId: string;

            /**
             * 目标行ID
             * Target row id
             */
            targetRowId: string;

            /**
             * 关联元数据
             * Relation metadata
             */
            metadata?: unknown;
        },
    ): NexusBook.Api.Common.ApiResponse<Relation>;

    /**
     * 批量创建关联
     *
     * Batch create relations
     *
     * 一次性创建多个关联关系。
     * Create multiple relations at once.
     */
    @route("/batch")
    @post
    @summary("批量创建关联")
    batchCreateRelations(
        @path docType: string,
        @path docId: string,
        @body body: {
            sourceRowId: string;
            fieldId: string;
            targetDocType: string;
            targetDocId: string;
            targetRowId: string;
            metadata?: unknown;
        }[],
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 创建的关联数量
         * Number of created relations
         */
        created: int32;

        /**
         * 创建的关联列表
         * Created relations
         */
        relations: Relation[];

        /**
         * 失败的关联
         * Failed relations
         */
        failures?: {
            index: int32;
            reason: string;
        }[];
    }>;

    /**
     * 删除关联关系
     *
     * Delete relation
     *
     * 删除指定的关联关系。如果是双向关联，会同时删除反向关联。
     * Delete specified relation. If bidirectional, also deletes reverse relation.
     */
    @route("/{relationId}")
    @delete
    @summary("删除关联")
    deleteRelation(
        @path docType: string,
        @path docId: string,
        @path relationId: string,
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 批量删除关联
     *
     * Batch delete relations
     *
     * 根据条件批量删除关联关系。
     * Delete relations in batch by conditions.
     */
    @route("/batch")
    @delete
    @summary("批量删除关联")
    batchDeleteRelations(
        @path docType: string,
        @path docId: string,
        @query sourceRowId?: string,
        @query fieldId?: string,
        @query targetDocType?: string,
        @query targetRowId?: string,
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 删除的关联数量
         * Number of deleted relations
         */
        deleted: int32;
    }>;

    /**
     * 检查循环引用
     *
     * Check circular reference
     *
     * 检查创建关联是否会导致循环引用。
     * Check if creating relation would cause circular reference.
     */
    @route("/check-circular")
    @post
    @summary("检查循环引用")
    checkCircular(
        @path docType: string,
        @path docId: string,
        @body body: {
            sourceRowId: string;
            fieldId: string;
            targetDocType: string;
            targetDocId: string;
            targetRowId: string;
        },
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 是否存在循环
         * Has circular
         */
        hasCircular: boolean;

        /**
         * 循环路径（如果存在）
         * Circular path (if exists)
         */
        circularPath?: string[];
    }>;
}
