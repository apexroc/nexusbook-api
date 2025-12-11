import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";
import "./models.tsp";

using TypeSpec.Http;
using OpenAPI;
using NexusBook.Api.I18n;

/**
 * 组织级国际化设置 API
 * Organization-level internationalization settings API
 */
namespace NexusBook.Api.I18n;

// ==================== API 接口定义 ====================

/**
 * 组织国际化 API 接口
 * Organization i18n API interface
 */
@tag("Internationalization")
@route("/api/v1/organizations/{organizationId}/i18n")
interface OrganizationI18nApi {
    /**
     * 获取组织国际化配置
     * Get organization i18n configuration
     *
     * 返回组织的国际化配置信息。
     * Returns organization's i18n configuration.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/i18n/config' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/config")
    @summary("获取组织国际化配置")
    getOrganizationI18nConfig(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string
    ): NexusBook.Api.Common.ApiResponse<OrganizationI18nConfig>;

    /**
     * 更新组织国际化配置
     * Update organization i18n configuration
     *
     * 更新组织的国际化配置。需要 owner 或 admin 权限。
     * Update organization's i18n configuration. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X PUT 'https://open.nexusbook.app/api/v1/organizations/org-123/i18n/config' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "defaultLanguage": "zh",
     *     "supportedLanguages": ["zh", "en", "ja"],
     *     "enforceLanguage": false,
     *     "autoDetectLanguage": true,
     *     "fallbackLanguage": "en",
     *     "defaultTimezone": "Asia/Shanghai",
     *     "defaultCurrency": "CNY",
     *     "dateFormat": "YYYY-MM-DD",
     *     "timeFormat": "24h"
     *   }'
     * ```
     */
    @put
    @route("/config")
    @summary("更新组织国际化配置")
    updateOrganizationI18nConfig(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        @body config: OrganizationI18nConfig
    ): NexusBook.Api.Common.ApiResponse<OrganizationI18nConfig>;

    /**
     * 获取组织自定义翻译
     * Get organization custom translations
     *
     * 获取组织自定义的翻译资源。
     * Get organization's custom translation resources.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/i18n/custom-translations?language=zh&namespace=custom' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/custom-translations")
    @summary("获取组织自定义翻译")
    getOrganizationCustomTranslations(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 语言代码
         * Language code
         */
        @query language?: string,

        /**
         * 命名空间
         * Namespace
         */
        @query ns?: string
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 自定义翻译
         * Custom translations
         */
        customTranslations: Record<string>;

        /**
         * 继承的翻译
         * Inherited translations
         */
        inheritedTranslations: Record<string>;
    }>;

    /**
     * 添加/更新组织自定义翻译
     * Add/update organization custom translations
     *
     * 添加或更新组织的自定义翻译。需要 owner 或 admin 权限。
     * Add or update organization's custom translations. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X PUT 'https://open.nexusbook.app/api/v1/organizations/org-123/i18n/custom-translations' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "language": "zh",
     *     "namespace": "custom",
     *     "translations": {
     *       "field.custom_status": "自定义状态",
     *       "label.department": "部门名称"
     *     }
     *   }'
     * ```
     */
    @put
    @route("/custom-translations")
    @summary("添加/更新组织自定义翻译")
    putOrganizationCustomTranslations(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        @body request: {
            /**
             * 语言代码
             * Language code
             */
            language: string;

            /**
             * 命名空间
             * Namespace
             */
            ns: string;

            /**
             * 翻译内容
             * Translations
             */
            translations: Record<string>;
        }
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 新增数量
         * Added count
         */
        added: int32;

        /**
         * 更新数量
         * Updated count
         */
        updated: int32;

        /**
         * 翻译结果
         * Translations
         */
        translations: Record<string>;
    }>;

    /**
     * 删除组织自定义翻译
     * Delete organization custom translations
     *
     * 删除组织的自定义翻译。需要 owner 或 admin 权限。
     * Delete organization's custom translations. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X DELETE 'https://open.nexusbook.app/api/v1/organizations/org-123/i18n/custom-translations?language=zh&keys=field.custom_status,label.department' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @delete
    @route("/custom-translations")
    @summary("删除组织自定义翻译")
    deleteOrganizationCustomTranslations(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 语言代码
         * Language code
         */
        @query language: string,

        /**
         * 要删除的键列表
         * Keys to delete
         */
        @query keys: string[]
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 删除数量
         * Deleted count
         */
        deleted: int32;
    }>;
}

/**
 * 翻译服务 API 接口
 * Translation service API interface
 */
@tag("Internationalization")
@route("/api/v1/i18n")
interface TranslationApi {
    /**
     * 翻译文本内容
     * Translate text content
     *
     * 将文本从源语言翻译到目标语言。
     * Translate text from source language to target languages.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/i18n/translate' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "sourceLanguage": "zh",
     *     "targetLanguages": ["en", "ja"],
     *     "texts": ["产品名称", "这是产品描述"],
     *     "context": "product_catalog"
     *   }'
     * ```
     */
    @post
    @route("/translate")
    @summary("翻译文本内容")
    translate(
        @body request: {
            /**
             * 源语言
             * Source language
             */
            sourceLanguage: string;

            /**
             * 目标语言列表
             * Target languages
             */
            targetLanguages: string[];

            /**
             * 待翻译文本列表
             * Texts to translate
             */
            texts: string[];

            /**
             * 上下文
             * Context
             */
            context?: string;
        }
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 翻译结果列表
         * Translation results
         */
        translations: TranslationResult[];
    }>;

    /**
     * 获取翻译建议
     * Get translation suggestions
     *
     * 获取文本的翻译建议。
     * Get translation suggestions for text.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/i18n/translation-suggestions' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "text": "产品",
     *     "sourceLanguage": "zh",
     *     "targetLanguage": "en",
     *     "context": "field_label",
     *     "maxSuggestions": 5
     *   }'
     * ```
     */
    @post
    @route("/translation-suggestions")
    @summary("获取翻译建议")
    getTranslationSuggestions(
        @body request: {
            /**
             * 待翻译文本
             * Text to translate
             */
            text: string;

            /**
             * 源语言
             * Source language
             */
            sourceLanguage: string;

            /**
             * 目标语言
             * Target language
             */
            targetLanguage: string;

            /**
             * 上下文
             * Context
             */
            context?: string;

            /**
             * 最大建议数
             * Maximum suggestions
             */
            maxSuggestions?: int32;
        }
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 翻译建议列表
         * Translation suggestions
         */
        suggestions: TranslationSuggestion[];
    }>;

    /**
     * 获取翻译术语表
     * Get translation glossary
     *
     * 获取组织的翻译术语表。
     * Get organization's translation glossary.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/organizations/org-123/i18n/glossary?sourceLanguage=zh&targetLanguage=en' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/organizations/{organizationId}/i18n/glossary")
    @summary("获取翻译术语表")
    getGlossary(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        /**
         * 源语言
         * Source language
         */
        @query sourceLanguage?: string,

        /**
         * 目标语言
         * Target language
         */
        @query targetLanguage?: string
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 术语表条目
         * Glossary entries
         */
        entries: GlossaryEntry[];
    }>;

    /**
     * 添加术语到翻译术语表
     * Add term to translation glossary
     *
     * 添加术语到组织的翻译术语表。需要 owner 或 admin 权限。
     * Add term to organization's translation glossary. Requires owner or admin permission.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/organizations/org-123/i18n/glossary' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "sourceLanguage": "zh",
     *     "targetLanguage": "en",
     *     "entries": [{
     *       "term": "订货单",
     *       "translation": "Purchase Order",
     *       "context": "business_document",
     *       "category": "general"
     *     }]
     *   }'
     * ```
     */
    @post
    @route("/organizations/{organizationId}/i18n/glossary")
    @summary("添加术语到翻译术语表")
    addGlossaryEntries(
        /**
         * 组织ID
         * Organization ID
         */
        @path organizationId: string,

        @body request: {
            /**
             * 源语言
             * Source language
             */
            sourceLanguage: string;

            /**
             * 目标语言
             * Target language
             */
            targetLanguage: string;

            /**
             * 术语条目列表
             * Glossary entries
             */
            entries: {
                /**
                 * 术语
                 * Term
                 */
                term: string;

                /**
                 * 翻译
                 * Translation
                 */
                translation: string;

                /**
                 * 上下文
                 * Context
                 */
                context?: string;

                /**
                 * 分类
                 * Category
                 */
                category?: string;
            }[];
        }
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 新增数量
         * Added count
         */
        added: int32;

        /**
         * 术语条目列表
         * Glossary entries
         */
        entries: GlossaryEntry[];
    }>;
}
