import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * Catalog 数据模型
 * Catalog Data Models
 *
 * Catalog 是基于 Document 的特化应用,用于供应链协作场景。
 * Catalog is a specialized application based on Document for supply chain collaboration.
 */
namespace NexusBook.Api.Document.Catalog;

/**
 * Catalog 类型枚举
 * Catalog type enum
 */
enum CatalogType {
    /**
     * 供应商目录
     * Supplier catalog
     */
    supplier,

    /**
     * 分销商目录
     * Distributor catalog
     */
    distributor,

    /**
     * 制造商目录
     * Manufacturer catalog
     */
    manufacturer,

    /**
     * 零售目录
     * Retail catalog
     */
    retail,
}

/**
 * Catalog 摘要信息
 * Catalog summary
 *
 * 用于列表展示的 Catalog 简要信息。
 * Brief Catalog information for list display.
 */
model CatalogSummary {
    /**
     * Catalog ID(docId)
     * Catalog ID
     */
    catalogId: string;

    /**
     * Catalog 名称
     * Catalog name
     */
    name: string;

    /**
     * Catalog 描述
     * Catalog description
     */
    description?: string;

    /**
     * Catalog 类型
     * Catalog type
     */
    catalogType: CatalogType;

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
     * 是否启用分享
     * Sharing enabled
     */
    sharingEnabled?: boolean;

    /**
     * 产品数量
     * Product count
     */
    productCount?: int32;

    /**
     * 活跃的 Connection 数量
     * Active connection count
     */
    activeConnectionCount?: int32;

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
     * 创建者
     * Created by
     */
    createdBy?: NexusBook.Api.Common.UserRef;
}

/**
 * Catalog 详细信息
 * Catalog details
 */
model CatalogDetails {
    /**
     * Catalog ID
     * Catalog ID
     */
    catalogId: string;

    /**
     * 文档类型(catalog 或具体类型如 product_catalog)
     * Document type
     */
    docType: string;

    /**
     * Catalog 名称
     * Catalog name
     */
    name: string;

    /**
     * Catalog 描述
     * Catalog description
     */
    description?: string;

    /**
     * Catalog 类型
     * Catalog type
     */
    catalogType: CatalogType;

    /**
     * 所属组织 ID
     * Organization ID
     */
    organizationId: string;

    /**
     * 所属工作区 ID(null 表示组织级别资源)
     * Workspace ID (null for organization-level resource)
     */
    workspaceId?: string;

    /**
     * 是否启用分享
     * Sharing enabled
     */
    sharingEnabled?: boolean;

    /**
     * 分享设置
     * Sharing settings
     */
    sharingSettings?: {
        /**
         * 允许的分享类型
         * Allowed sharing types
         */
        allowedTypes?: ("public" | "private" | "whitelist")[];

        /**
         * 默认分享范围
         * Default share scope
         */
        defaultShareScope?: string;
    };

    /**
     * 产品数量
     * Product count
     */
    productCount?: int32;

    /**
     * 活跃的 Connection 列表
     * Active connections
     */
    activeConnections?: string[];

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
     * 创建者
     * Created by
     */
    createdBy?: NexusBook.Api.Common.UserRef;

    /**
     * 最后修改者
     * Updated by
     */
    updatedBy?: NexusBook.Api.Common.UserRef;
}

/**
 * 字段定义(简化版)
 * Field definition (simplified)
 */
model CatalogFieldDefinition {
    /**
     * 字段 ID(可选,创建时不提供)
     * Field ID (optional, not provided on creation)
     */
    id?: string;

    /**
     * 字段名称
     * Field name
     */
    name: string;

    /**
     * 字段类型
     * Field type
     */
    type: "text" | "long_text" | "number" | "currency" | "percent" | "date" | "datetime" | "boolean" | "single_select" | "multi_select" | "attachment" | "user" | "relation";

    /**
     * 是否必填
     * Required
     */
    required?: boolean = false;

    /**
     * 是否唯一
     * Unique
     */
    unique?: boolean = false;

    /**
     * 是否只读
     * Read only
     */
    readOnly?: boolean = false;

    /**
     * 默认值
     * Default value
     */
    defaultValue?: unknown;

    /**
     * 选择类字段的选项(type=single_select 或 multi_select 时)
     * Select options (when type=single_select or multi_select)
     */
    selectOptions?: NexusBook.Api.Common.SelectOption[];

    /**
     * 字段描述
     * Field description
     */
    description?: string;
}

/**
 * 创建 Catalog 请求
 * Create catalog request
 */
model CreateCatalogRequest {
    /**
     * Catalog 名称
     * Catalog name
     */
    name: string;

    /**
     * Catalog 描述
     * Catalog description
     */
    description?: string;

    /**
     * Catalog 类型
     * Catalog type
     */
    catalogType: CatalogType;

    /**
     * 文档类型(默认为 "catalog")
     * Document type (default: "catalog")
     */
    docType?: string = "catalog";

    /**
     * 所属工作区 ID(可选,null 表示组织级别)
     * Workspace ID (optional, null for organization-level)
     */
    workspaceId?: string;

    /**
     * 是否启用分享
     * Enable sharing
     */
    sharingEnabled?: boolean = false;

    /**
     * 自定义字段定义
     * Custom field definitions
     *
     * 不同行业的商品字段可能不一样,例如:
     * - 电子产品: 品牌、型号、规格参数
     * - 服装: 尺码、颜色、材质
     * - 食品: 保质期、产地、配料
     *
     * Different industries have different product fields:
     * - Electronics: brand, model, specs
     * - Clothing: size, color, material
     * - Food: expiry date, origin, ingredients
     */
    fields?: CatalogFieldDefinition[];

    /**
     * 初始视图配置(可选)
     * Initial view configurations (optional)
     */
    views?: unknown[];
}

/**
 * 更新 Catalog 请求
 * Update catalog request
 */
model UpdateCatalogRequest {
    /**
     * Catalog 名称
     * Catalog name
     */
    name?: string;

    /**
     * Catalog 描述
     * Catalog description
     */
    description?: string;

    /**
     * Catalog 类型
     * Catalog type
     */
    catalogType?: CatalogType;

    /**
     * 是否启用分享
     * Enable sharing
     */
    sharingEnabled?: boolean;

    /**
     * 分享设置
     * Sharing settings
     */
    sharingSettings?: {
        allowedTypes?: ("public" | "private" | "whitelist")[];
        defaultShareScope?: string;
    };
}
