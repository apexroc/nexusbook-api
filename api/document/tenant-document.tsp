import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";
import "../tenant/models.tsp";
import "./aggregate/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 租户文档模块
 *
 * 提供组织级和工作区级的文档访问接口。
 *
 * 文档层级：
 * - 组织级文档 - 组织内所有成员可访问的公共文档（如政策、模板等）
 * - 工作区级文档 - 特定工作区内的业务文档（如订货单、采购单等）
 *
 * Document hierarchy:
 * - Organization-level documents - Public documents accessible to all organization members (e.g., policies, templates)
 * - Workspace-level documents - Business documents within specific workspaces (e.g., purchase orders, sales orders)
 */
namespace NexusBook.Api.Document;

/**
 * 文档作用域枚举
 * Document scope enum
 */
enum DocumentScope {
    /**
     * 组织级（公共）
     * Organization-level (public)
     */
    organization,

    /**
     * 工作区级（业务）
     * Workspace-level (business)
     */
    workspace,
}

/**
 * 文档摘要模型
 * Document summary model
 *
 * 用于列表展示的文档简要信息。
 * Brief document information for list display.
 */
model DocumentSummary {
    /**
     * 文档ID
     * Document ID
     */
    docId: string;

    /**
     * 文档类型
     * Document type
     */
    docType: string;

    /**
     * 文档标题
     * Document title
     */
    title?: string;

    /**
     * 文档描述
     * Document description
     */
    description?: string;

    /**
     * 作用域
     * Scope
     */
    scope: DocumentScope;

    /**
     * 所属组织ID
     * Organization ID
     */
    organizationId: string;

    /**
     * 所属工作区ID（组织级文档为空）
     * Workspace ID (empty for organization-level documents)
     */
    workspaceId?: string;

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
 * 组织文档 API 接口
 * Organization Document API interface
 */
@tag("Organization Documents")
interface OrganizationDocumentApi {
    /**
     * 获取组织级文档聚合数据
     * Get organization document aggregate
     *
     * 一次性获取组织级文档的多种数据。需要是组织成员。
     * Get multiple types of data for organization-level document in one request. Requires organization membership.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/doc/policy/doc-456?include=metadata,views,data' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/doc/{docType}/{docId}")
    @summary("获取组织文档聚合数据")
    getOrganizationDocumentAggregate(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 文档类型
         * Document type
         */
        @path docType: string,

        /**
         * 文档ID
         * Document ID
         */
        @path docId: string,

        /**
         * 包含的数据部分（逗号分隔）
         * Included data parts (comma-separated)
         *
         * 可选值: properties, metadata, views, data, comments, revisions, settings
         * Options: properties, metadata, views, data, comments, revisions, settings
         */
        @query include?: string,

        /**
         * 视图ID
         * View ID
         */
        @query viewId?: string,

        /**
         * 页码
         * Page number
         */
        @query page?: int32,

        /**
         * 每页数量
         * Page size
         */
        @query pageSize?: int32,

        /**
         * 评论数量限制
         * Comments limit
         */
        @query commentsLimit?: int32,

        /**
         * 修订数量限制
         * Revisions limit
         */
        @query revisionsLimit?: int32
    ): NexusBook.Api.Common.ApiResponse<DocBundle>;

    /**
     * 列出组织文档
     * List organization documents
     *
     * 获取组织下的所有文档列表。需要是组织成员。
     * Get the list of all documents under the organization. Requires organization membership.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/documents?docType=policy&page=1&pageSize=20' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/documents")
    @summary("列出组织文档")
    listOrganizationDocuments(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 文档类型过滤
         * Filter by document type
         */
        @query docType?: string,

        /**
         * 搜索关键词
         * Search keyword
         */
        @query search?: string,

        /**
         * 创建者过滤
         * Filter by creator
         */
        @query createdBy?: string,

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
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<DocumentSummary>>;
}

/**
 * 工作区文档 API 接口
 * Workspace Document API interface
 */
@tag("Workspace Documents")
interface WorkspaceDocumentApi {
    /**
     * 获取工作区级文档聚合数据
     * Get workspace document aggregate
     *
     * 一次性获取工作区级文档的多种数据。需要是工作区成员。
     * Get multiple types of data for workspace-level document in one request. Requires workspace membership.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456/doc/purchaseOrder/doc-789?include=metadata,views,data' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/workspaces/{workspaceId}/doc/{docType}/{docId}")
    @summary("获取工作区文档聚合数据")
    getWorkspaceDocumentAggregate(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string,

        /**
         * 文档类型
         * Document type
         */
        @path docType: string,

        /**
         * 文档ID
         * Document ID
         */
        @path docId: string,

        /**
         * 包含的数据部分（逗号分隔）
         * Included data parts (comma-separated)
         *
         * 可选值: properties, metadata, views, data, comments, revisions, settings
         * Options: properties, metadata, views, data, comments, revisions, settings
         */
        @query include?: string,

        /**
         * 视图ID
         * View ID
         */
        @query viewId?: string,

        /**
         * 页码
         * Page number
         */
        @query page?: int32,

        /**
         * 每页数量
         * Page size
         */
        @query pageSize?: int32,

        /**
         * 评论数量限制
         * Comments limit
         */
        @query commentsLimit?: int32,

        /**
         * 修订数量限制
         * Revisions limit
         */
        @query revisionsLimit?: int32
    ): NexusBook.Api.Common.ApiResponse<DocBundle>;

    /**
     * 列出工作区文档
     * List workspace documents
     *
     * 获取工作区下的所有文档列表。需要是工作区成员。
     * Get the list of all documents under the workspace. Requires workspace membership.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/organizations/org-123/workspaces/ws-456/documents?docType=purchaseOrder&page=1&pageSize=20' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/api/v1/organizations/{organizationId}/workspaces/{workspaceId}/documents")
    @summary("列出工作区文档")
    listWorkspaceDocuments(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 工作区ID
         * Workspace ID
         */
        @path workspaceId: string,

        /**
         * 文档类型过滤
         * Filter by document type
         */
        @query docType?: string,

        /**
         * 搜索关键词
         * Search keyword
         */
        @query search?: string,

        /**
         * 创建者过滤
         * Filter by creator
         */
        @query createdBy?: string,

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
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<DocumentSummary>>;
}
