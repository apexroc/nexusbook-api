import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";
import "./models.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * Catalog API 接口
 * Catalog API Interface
 *
 * 提供组织级别的 Catalog 管理功能。
 * Provides organization-level Catalog management.
 */
namespace NexusBook.Api.Document.Catalog;

@tag("Catalog")
interface CatalogApi {
    /**
     * 创建 Catalog
     * Create catalog
     *
     * 在组织下创建新的产品目录。需要组织管理员或有权限的成员。
     * Create a new product catalog under organization. Requires organization admin or authorized member.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "电子产品目录",
     *     "catalogType": "supplier",
     *     "sharingEnabled": true
     *   }'
     * ```
     */
    @post
    @route("/api/v1/organizations/{organizationId}/catalogs")
    @summary("创建 Catalog")
    createCatalog(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 创建请求
         * Create request
         */
        @body body: CreateCatalogRequest
    ): NexusBook.Api.Common.ApiResponse<CatalogDetails>;

    /**
     * 列出组织的 Catalog
     * List organization catalogs
     *
     * 获取组织下的所有 Catalog 列表。
     * Get list of all catalogs under organization.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs?catalogType=supplier&page=1&pageSize=20' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/catalogs")
    @summary("列出 Catalog")
    listCatalogs(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区 ID 过滤(可选)
         * Filter by workspace ID
         */
        @query workspaceId?: string,

        /**
         * Catalog 类型过滤
         * Filter by catalog type
         */
        @query catalogType?: CatalogType,

        /**
         * 搜索关键词
         * Search keyword
         */
        @query search?: string,

        /**
         * 仅显示启用分享的 Catalog
         * Show only sharing-enabled catalogs
         */
        @query sharingEnabled?: boolean,

        /**
         * 排序字段
         * Sort field
         */
        @query sort?: string = "updatedAt",

        /**
         * 排序方向
         * Sort direction
         */
        @query direction?: NexusBook.Api.Common.Direction = NexusBook.Api.Common.Direction.desc,

        /**
         * 页码
         * Page number
         */
        @query page?: int32 = 1,

        /**
         * 每页数量
         * Page size
         */
        @query pageSize?: int32 = 20
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<CatalogSummary>>;

    /**
     * 获取 Catalog 详情
     * Get catalog details
     *
     * 获取指定 Catalog 的详细信息。
     * Get detailed information of specified catalog.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs/catalog-456' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/catalogs/{catalogId}")
    @summary("获取 Catalog 详情")
    getCatalog(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Catalog ID
         * Catalog ID
         */
        @path catalogId: string
    ): NexusBook.Api.Common.ApiResponse<CatalogDetails>;

    /**
     * 更新 Catalog
     * Update catalog
     *
     * 更新 Catalog 的基本信息和设置。
     * Update catalog basic information and settings.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs/catalog-456' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "更新后的产品目录",
     *     "sharingEnabled": true
     *   }'
     * ```
     */
    @patch
    @route("/api/v1/organizations/{organizationId}/catalogs/{catalogId}")
    @summary("更新 Catalog")
    updateCatalog(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Catalog ID
         * Catalog ID
         */
        @path catalogId: string,

        /**
         * 更新请求
         * Update request
         */
        @body body: UpdateCatalogRequest
    ): NexusBook.Api.Common.ApiResponse<CatalogDetails>;

    /**
     * 删除 Catalog
     * Delete catalog
     *
     * 删除指定的 Catalog。如果 Catalog 有活跃的 Connection,需要先删除或禁用 Connection。
     * Delete specified catalog. If catalog has active connections, must delete or disable connections first.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs/catalog-456' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/api/v1/organizations/{organizationId}/catalogs/{catalogId}")
    @summary("删除 Catalog")
    deleteCatalog(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Catalog ID
         * Catalog ID
         */
        @path catalogId: string,

        /**
         * 强制删除(即使有活跃的 Connection)
         * Force delete (even if has active connections)
         */
        @query force?: boolean = false
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 获取 Catalog 的产品统计
     * Get catalog product statistics
     *
     * 获取 Catalog 中产品的统计信息。
     * Get product statistics of catalog.
     *
     * 示例（cURL）:
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs/catalog-456/stats' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/catalogs/{catalogId}/stats")
    @summary("获取产品统计")
    getCatalogStats(
        /**
         * 组织 ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * Catalog ID
         * Catalog ID
         */
        @path catalogId: string
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 总产品数
         * Total products
         */
        totalProducts: int32;

        /**
         * 活跃产品数
         * Active products
         */
        activeProducts: int32;

        /**
         * 分享中的产品数
         * Shared products
         */
        sharedProducts: int32;

        /**
         * Connection 数量
         * Connection count
         */
        connectionCount: int32;

        /**
         * 活跃 Connection 数量
         * Active connection count
         */
        activeConnectionCount: int32;

        /**
         * 按类别统计
         * Statistics by category
         */
        byCategory?: Record<{
            count: int32;
            percentage: float32;
        }>;

        /**
         * 最后更新时间
         * Last updated at
         */
        lastUpdatedAt: string;
    }>;

    /**
     * 获取 Catalog 字段定义
     * Get catalog field definitions
     *
     * 示例（cURL）:
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs/catalog-456/fields' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/catalogs/{catalogId}/fields")
    @summary("获取字段定义")
    getCatalogFields(
        @path organizationId: string,
        @path catalogId: string
    ): NexusBook.Api.Common.ApiResponse<CatalogFieldDefinition[]>;

    /**
     * 添加 Catalog 字段
     * Add catalog field
     *
     * 示例（cURL）:
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs/catalog-456/fields' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "name": "品牌",
     *     "type": "text",
     *     "required": true
     *   }'
     * ```
     */
    @post
    @route("/api/v1/organizations/{organizationId}/catalogs/{catalogId}/fields")
    @summary("添加字段")
    addCatalogField(
        @path organizationId: string,
        @path catalogId: string,
        @body body: CatalogFieldDefinition
    ): NexusBook.Api.Common.ApiResponse<CatalogFieldDefinition>;

    /**
     * 更新 Catalog 字段
     * Update catalog field
     *
     * 示例（cURL）:
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs/catalog-456/fields/field-789' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "required": false
     *   }'
     * ```
     */
    @patch
    @route("/api/v1/organizations/{organizationId}/catalogs/{catalogId}/fields/{fieldId}")
    @summary("更新字段")
    updateCatalogField(
        @path organizationId: string,
        @path catalogId: string,
        @path fieldId: string,
        @body body: CatalogFieldDefinition
    ): NexusBook.Api.Common.ApiResponse<CatalogFieldDefinition>;

    /**
     * 删除 Catalog 字段
     * Delete catalog field
     *
     * 示例（cURL）:
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.app/api/v1/organizations/org-123/catalogs/catalog-456/fields/field-789' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/api/v1/organizations/{organizationId}/catalogs/{catalogId}/fields/{fieldId}")
    @summary("删除字段")
    deleteCatalogField(
        @path organizationId: string,
        @path catalogId: string,
        @path fieldId: string,
        @query force?: boolean = false
    ): NexusBook.Api.Common.ApiResponse<unknown>;
}
