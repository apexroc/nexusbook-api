import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 设置模块
 *
 * 管理文档级和类型级的配置设置。
 *
 * 主要功能：
 * - **文档设置** - 单个文档的配置
 * - **类型设置** - 文档类型的全局配置
 * - **共享设置** - 公开链接和访问权限
 * - **分享管理** - 密码保护和访问控制
 * - **保留政策** - 修订记录和备份保留策略
 * - **权限管理** - 基于角色的权限配置
 *
 * ## 设置层级
 *
 * ### 文档级设置 (Document-level)
 * 只影响单个文档
 * GET/PUT /doc/{docType}/{docId}/settings
 *
 * ### 类型级设置 (Type-level)
 * 为该类型的所有文档提供默认配置
 * GET/PUT /doc/{docType}/setting
 */
namespace NexusBook.Api;

model Settings {
    /**
     * 默认视图ID
     * Default view id
     */
    defaultViewId?: string;

    /**
     * 分享配置
     */
    sharing?: {
        /**
         * 公共链接开关
         * Public link enabled
         */
        publicLinkEnabled?: boolean;

        /**
         * 分享密码
         * Password
         */
        password?: string;
    };

    /**
     * 权限策略
     * Permissions policy
     */
    permissions?: unknown;

    /**
     * 保留策略
     */
    retention?: {
        /**
         * 修订特性
         */
        revisions?: {
            /**
             * 最大修订条数
             * Max revision count
             */
            maxCount?: int32;

            /**
             * 最大保留天数
             * Max retention days
             */
            maxDays?: int32;
        };
    };
}

@route("/doc/{docType}/{docId}/settings")
@tag("Document")
interface DocSettingsApi {
    /**
     * 获取文档级设置。
     *
     * Get doc-level settings.
     */
    @get
    @summary("文档设置")
    getDocSettings(
        @path docType: string,
        @path docId: string,
    ): NexusBook.Common.ApiResponse<Settings>;

    /**
     * 更新文档级设置。
     *
     * Update doc-level settings.
     */
    @put
    @summary("更新文档设置")
    putDocSettings(
        @path docType: string,
        @path docId: string,
        @body body: Settings,
    ): NexusBook.Common.ApiResponse<Settings>;
}

@route("/doc/{docType}/setting")
@tag("Document")
interface TypeSettingsApi {
    /**
     * 获取文档类型公共设置。
     *
     * Get type-level settings.
     */
    @get
    @summary("类型设置")
    getTypeSetting(
        @path docType: string,
    ): NexusBook.Common.ApiResponse<Settings>;

    /**
     * 更新文档类型公共设置。
     *
     * Update type-level settings.
     */
    @put
    @summary("更新类型设置")
    putTypeSetting(
        @path docType: string,
        @body body: Settings,
    ): NexusBook.Common.ApiResponse<Settings>;
}
