import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * OrderBook 数据模型
 * OrderBook Data Models
 *
 * OrderBook 是基于 Document 的特化应用,用于采购商订货管理。
 * OrderBook is a specialized application based on Document for buyer order management.
 */
namespace NexusBook.Api.Document.OrderBook;

/**
 * OrderBook 摘要信息
 * OrderBook summary
 */
model OrderBookSummary {
    /**
     * OrderBook ID(docId)
     * OrderBook ID
     */
    orderBookId: string;

    /**
     * OrderBook 名称
     * OrderBook name
     */
    name: string;

    /**
     * OrderBook 描述
     * OrderBook description
     */
    description?: string;

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
     * 产品数量
     * Product count
     */
    productCount?: int32;

    /**
     * 活跃的 Connection 数量(Inbound)
     * Active connection count (Inbound)
     */
    activeConnectionCount?: int32;

    /**
     * 来源供应商数量
     * Source supplier count
     */
    sourceSupplierCount?: int32;

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
 * OrderBook 详细信息
 * OrderBook details
 */
model OrderBookDetails {
    /**
     * OrderBook ID
     * OrderBook ID
     */
    orderBookId: string;

    /**
     * 文档类型(orderbook 或具体类型)
     * Document type
     */
    docType: string;

    /**
     * OrderBook 名称
     * OrderBook name
     */
    name: string;

    /**
     * OrderBook 描述
     * OrderBook description
     */
    description?: string;

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
     * 产品数量
     * Product count
     */
    productCount?: int32;

    /**
     * 活跃的 Connection 列表(Inbound)
     * Active connections (Inbound)
     */
    activeConnections?: string[];

    /**
     * 来源供应商列表
     * Source suppliers
     */
    sourceSuppliers?: {
        /**
         * 供应商组织 ID
         * Supplier organization ID
         */
        organizationId: string;

        /**
         * 供应商名称
         * Supplier name
         */
        name?: string;

        /**
         * Connection ID
         * Connection ID
         */
        connectionId: string;

        /**
         * 产品数量
         * Product count
         */
        productCount?: int32;
    }[];

    /**
     * 能否作为 Catalog 分享
     * Can be shared as catalog
     */
    canShareAsCatalog?: boolean;

    /**
     * 作为 Catalog 的 Connection 数量
     * Connection count as catalog
     */
    catalogConnectionCount?: int32;

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
 * 创建 OrderBook 请求
 * Create orderbook request
 */
model CreateOrderBookRequest {
    /**
     * OrderBook 名称
     * OrderBook name
     */
    name: string;

    /**
     * OrderBook 描述
     * OrderBook description
     */
    description?: string;

    /**
     * 文档类型(默认为 "orderbook")
     * Document type (default: "orderbook")
     */
    docType?: string = "orderbook";

    /**
     * 所属工作区 ID(可选,null 表示组织级别)
     * Workspace ID (optional, null for organization-level)
     */
    workspaceId?: string;

    /**
     * 基于已连接的 Connection 创建
     * Create based on connected connections
     *
     * 如果提供,将从这些 Connection 的源 Catalog 自动生成字段定义和初始数据。
     * If provided, will auto-generate field definitions and initial data from source Catalogs.
     */
    sourceConnectionIds?: string[];

    /**
     * 自定义字段定义(可选)
     * Custom field definitions (optional)
     *
     * 如果提供 sourceConnectionIds,会与源字段合并。
     * If sourceConnectionIds provided, will merge with source fields.
     */
    fields?: OrderBookFieldDefinition[];

    /**
     * 初始视图配置(可选)
     * Initial view configurations (optional)
     */
    views?: unknown[];
}

/**
 * OrderBook 字段定义
 * OrderBook field definition
 */
model OrderBookFieldDefinition {
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
     * 选择类字段的选项
     * Select options
     */
    selectOptions?: NexusBook.Api.Common.SelectOption[];

    /**
     * 字段描述
     * Field description
     */
    description?: string;

    /**
     * 源字段映射(如果从 Catalog 字段派生)
     * Source field mapping (if derived from Catalog field)
     */
    sourceFieldId?: string;

    /**
     * 源 Catalog ID(如果从 Catalog 字段派生)
     * Source catalog ID (if derived from Catalog field)
     */
    sourceCatalogId?: string;
}

/**
 * 更新 OrderBook 请求
 * Update orderbook request
 */
model UpdateOrderBookRequest {
    /**
     * OrderBook 名称
     * OrderBook name
     */
    name?: string;

    /**
     * OrderBook 描述
     * OrderBook description
     */
    description?: string;

    /**
     * 能否作为 Catalog 分享
     * Can be shared as catalog
     */
    canShareAsCatalog?: boolean;
}

/**
 * 行来源信息
 * Row source information
 */
model RowSource {
    /**
     * 来源类型
     * Source type
     */
    sourceType: "connection" | "manual" | "merged";

    /**
     * 来源 Connection ID
     * Source connection ID
     */
    sourceConnectionId?: string;

    /**
     * 源 Catalog ID
     * Source catalog ID
     */
    sourceCatalogId?: string;

    /**
     * 源行 ID
     * Source row ID
     */
    sourceRowId?: string;

    /**
     * 源组织 ID
     * Source organization ID
     */
    sourceOrganizationId?: string;

    /**
     * 合并的多个源(sourceType=merged 时)
     * Merged sources (when sourceType=merged)
     */
    mergedSourceIds?: string[];

    /**
     * 最后同步时间
     * Last synced at
     */
    lastSyncedAt?: string;
}
