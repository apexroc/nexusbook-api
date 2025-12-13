import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";
import "./models.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * Connection API 接口
 * Connection API Interface
 *
 * 提供跨组织的数据分享和传播功能。
 * Provides cross-organization data sharing and propagation.
 */
namespace NexusBook.Api.Document.Connection;

@tag("Connection")
interface ConnectionApi {
    /**
     * 创建 Connection
     * Create connection
     */
    @post
    @route("/api/v1/organizations/{organizationId}/connections")
    @summary("创建 Connection")
    createConnection(
        @path organizationId: string,
        @body body: CreateConnectionRequest
    ): NexusBook.Api.Common.ApiResponse<ConnectionDetails>;

    /**
     * 列出 Connection
     * List connections
     */
    @get
    @route("/api/v1/organizations/{organizationId}/connections")
    @summary("列出 Connection")
    listConnections(
        @path organizationId: string,
        @query sourceCatalogId?: string,
        @query shareMode?: ShareMode,
        @query status?: ConnectionStatus,
        @query search?: string,
        @query sort?: string = "createdAt",
        @query direction?: NexusBook.Api.Common.Direction = NexusBook.Api.Common.Direction.desc,
        @query page?: int32 = 1,
        @query pageSize?: int32 = 20
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<ConnectionSummary>>;

    /**
     * 获取 Connection 详情
     * Get connection details
     */
    @get
    @route("/api/v1/organizations/{organizationId}/connections/{connectionId}")
    @summary("获取 Connection 详情")
    getConnection(
        @path organizationId: string,
        @path connectionId: string
    ): NexusBook.Api.Common.ApiResponse<ConnectionDetails>;

    /**
     * 更新 Connection
     * Update connection
     */
    @patch
    @route("/api/v1/organizations/{organizationId}/connections/{connectionId}")
    @summary("更新 Connection")
    updateConnection(
        @path organizationId: string,
        @path connectionId: string,
        @body body: UpdateConnectionRequest
    ): NexusBook.Api.Common.ApiResponse<ConnectionDetails>;

    /**
     * 删除 Connection
     * Delete connection
     */
    @delete
    @route("/api/v1/organizations/{organizationId}/connections/{connectionId}")
    @summary("删除 Connection")
    deleteConnection(
        @path organizationId: string,
        @path connectionId: string,
        @query force?: boolean = false
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 列出 Connection 的 Binding
     * List connection bindings
     */
    @get
    @route("/api/v1/organizations/{organizationId}/connections/{connectionId}/bindings")
    @summary("列出 Binding")
    listConnectionBindings(
        @path organizationId: string,
        @path connectionId: string,
        @query bindingStatus?: BindingStatus,
        @query targetOrganizationId?: string,
        @query page?: int32 = 1,
        @query pageSize?: int32 = 20
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<ConnectionBindingSummary>>;

    /**
     * 创建 ConnectionBinding
     * Create connection binding
     */
    @post
    @route("/api/v1/organizations/{organizationId}/connections/{connectionId}/bind")
    @summary("关联 Connection")
    bindConnection(
        @path organizationId: string,
        @path connectionId: string,
        @body body: CreateConnectionBindingRequest
    ): NexusBook.Api.Common.ApiResponse<ConnectionBindingDetails>;

    /**
     * 审批 ConnectionBinding
     * Approve connection binding
     */
    @post
    @route("/api/v1/organizations/{organizationId}/connections/{connectionId}/bindings/{bindingId}/approve")
    @summary("审批 Binding")
    approveBinding(
        @path organizationId: string,
        @path connectionId: string,
        @path bindingId: string,
        @body body: {
            action: "approve" | "reject";
            comment?: string;
        }
    ): NexusBook.Api.Common.ApiResponse<ConnectionBindingDetails>;

    /**
     * 获取 Binding 详情
     * Get binding details
     */
    @get
    @route("/api/v1/organizations/{organizationId}/connections/{connectionId}/bindings/{bindingId}")
    @summary("获取 Binding 详情")
    getBinding(
        @path organizationId: string,
        @path connectionId: string,
        @path bindingId: string
    ): NexusBook.Api.Common.ApiResponse<ConnectionBindingDetails>;

    /**
     * 更新 ConnectionBinding
     * Update connection binding
     */
    @patch
    @route("/api/v1/organizations/{organizationId}/connections/{connectionId}/bindings/{bindingId}")
    @summary("更新 Binding")
    updateBinding(
        @path organizationId: string,
        @path connectionId: string,
        @path bindingId: string,
        @body body: UpdateConnectionBindingRequest
    ): NexusBook.Api.Common.ApiResponse<ConnectionBindingDetails>;

    /**
     * 删除 ConnectionBinding
     * Delete connection binding
     */
    @delete
    @route("/api/v1/organizations/{organizationId}/connections/{connectionId}/bindings/{bindingId}")
    @summary("删除 Binding")
    deleteBinding(
        @path organizationId: string,
        @path connectionId: string,
        @path bindingId: string
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 列出组织的 Inbound Binding
     * List organization's inbound bindings
     */
    @get
    @route("/api/v1/organizations/{organizationId}/bindings/inbound")
    @summary("列出 Inbound Binding")
    listInboundBindings(
        @path organizationId: string,
        @query targetOrderBookId?: string,
        @query bindingStatus?: BindingStatus,
        @query sourceOrganizationId?: string,
        @query page?: int32 = 1,
        @query pageSize?: int32 = 20
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<ConnectionBindingSummary>>;

    /**
     * 手动触发同步
     * Manually trigger sync
     */
    @post
    @route("/api/v1/organizations/{organizationId}/connections/{connectionId}/sync")
    @summary("手动触发同步")
    triggerSync(
        @path organizationId: string,
        @path connectionId: string,
        @body body: {
            forceFullSync?: boolean;
            bindingIds?: string[];
        }
    ): NexusBook.Api.Common.ApiResponse<{
        syncTaskId: string;
        affectedBindingCount: int32;
        startedAt: string;
    }>;

    /**
     * 获取同步状态
     * Get sync status
     */
    @get
    @route("/api/v1/organizations/{organizationId}/connections/{connectionId}/sync/status")
    @summary("获取同步状态")
    getSyncStatus(
        @path organizationId: string,
        @path connectionId: string
    ): NexusBook.Api.Common.ApiResponse<{
        connectionId: string;
        lastSyncTime?: string;
        totalBindingCount: int32;
        activeBindingCount: int32;
        syncStatusStats: {
            upToDate: int32;
            pending: int32;
            syncing: int32;
            failed: int32;
        };
        recentSyncTasks?: {
            taskId: string;
            startedAt: string;
            completedAt?: string;
            status: "running" | "completed" | "failed";
            affectedRows?: int32;
        }[];
    }>;
}
