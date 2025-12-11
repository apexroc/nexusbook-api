import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";
import "./models.tsp";

using TypeSpec.Http;
using OpenAPI;
using NexusBook.Api.I18n;

/**
 * 多语言资源管理 API
 * Multi-language resource management API
 */
namespace NexusBook.Api.I18n;

// ==================== API 接口定义 ====================

/**
 * 国际化 API 接口
 * Internationalization API interface
 */
@tag("Internationalization")
@route("/api/v1/i18n")
interface I18nApi {
    /**
     * 获取支持的语言列表
     * Get supported languages list
     *
     * 返回系统支持的所有语言配置列表。
     * Returns list of all supported language configurations.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/i18n/languages?enabledOnly=true' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/languages")
    @summary("获取支持的语言列表")
    listLanguages(
        /**
         * 仅返回已启用的语言
         * Only return enabled languages
         */
        @query enabledOnly?: boolean = false
    ): NexusBook.Api.Common.ApiResponse<LanguageConfig[]>;

    /**
     * 获取语言详细配置
     * Get language detailed configuration
     *
     * 返回指定语言的详细配置信息。
     * Returns detailed configuration for specified language.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/i18n/languages/zh' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/languages/{languageCode}")
    @summary("获取语言详细配置")
    getLanguage(
        /**
         * 语言代码
         * Language code
         */
        @path languageCode: string
    ): NexusBook.Api.Common.ApiResponse<LanguageConfig>;

    /**
     * 获取翻译资源
     * Get translation resources
     *
     * 获取指定语言的翻译资源。
     * Get translation resources for specified language.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/i18n/translations?language=zh&namespace=common' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/translations")
    @summary("获取翻译资源")
    getTranslations(
        /**
         * 语言代码（必填）
         * Language code (required)
         */
        @query language: string,

        /**
         * 命名空间过滤
         * Namespace filter
         */
        @query ns?: string,

        /**
         * 指定键列表
         * Specified keys
         */
        @query keys?: string[],

        /**
         * 资源分类
         * Resource category
         */
        @query category?: ResourceCategory
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 语言代码
         * Language code
         */
        language: string;

        /**
         * 翻译资源
         * Translations
         */
        translations: Record<string>;

        /**
         * 备用语言
         * Fallback language
         */
        fallbackLanguage: string;

        /**
         * 完整度
         * Completeness
         */
        completeness: float64;
    }>;

    /**
     * 批量获取多语言翻译
     * Batch get multi-language translations
     *
     * 一次性获取多个语言的翻译资源。
     * Get translation resources for multiple languages at once.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/i18n/translations/batch' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "languages": ["zh", "en", "ja"],
     *     "namespace": "common",
     *     "keys": ["button.save", "button.cancel"]
     *   }'
     * ```
     */
    @post
    @route("/translations/batch")
    @summary("批量获取多语言翻译")
    batchGetTranslations(
        @body request: {
            /**
             * 语言列表
             * Languages
             */
            languages: string[];

            /**
             * 命名空间
             * Namespace
             */
            ns?: string;

            /**
             * 键列表
             * Keys
             */
            keys?: string[];
        }
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 翻译结果
         * Translations (language -> key -> translation)
         */
        translations: Record<Record<string>>;
    }>;

    /**
     * 检测文本语言
     * Detect text language
     *
     * 自动检测给定文本的语言。
     * Automatically detect language of given text.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/i18n/detect-language' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{"text": "这是一段测试文本"}'
     * ```
     */
    @post
    @route("/detect-language")
    @summary("检测文本语言")
    detectLanguage(
        @body request: {
            /**
             * 待检测文本
             * Text to detect
             */
            text: string;
        }
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 检测到的语言
         * Detected language
         */
        detectedLanguage: string;

        /**
         * 置信度
         * Confidence
         */
        confidence: float64;

        /**
         * 备选语言
         * Alternative languages
         */
        alternatives: LanguageDetection[];
    }>;

    /**
     * 获取翻译完整度统计
     * Get translation coverage statistics
     *
     * 获取各语言的翻译完整度统计信息。
     * Get translation coverage statistics for each language.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/i18n/translation-coverage?namespace=common' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/translation-coverage")
    @summary("获取翻译完整度统计")
    getTranslationCoverage(
        /**
         * 命名空间过滤
         * Namespace filter
         */
        @query ns?: string
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 语言覆盖率列表
         * Language coverage list
         */
        languages: LanguageCoverage[];
    }>;

    /**
     * 获取时区列表
     * Get timezone list
     *
     * 获取系统支持的时区列表。
     * Get list of supported timezones.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/i18n/timezones?region=Asia' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/timezones")
    @summary("获取时区列表")
    listTimezones(
        /**
         * 按地区过滤
         * Filter by region
         */
        @query region?: string
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 时区列表
         * Timezones
         */
        timezones: Timezone[];
    }>;

    /**
     * 获取货币列表
     * Get currency list
     *
     * 获取系统支持的货币列表。
     * Get list of supported currencies.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.app/api/v1/i18n/currencies' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/currencies")
    @summary("获取货币列表")
    listCurrencies(
        /**
         * 是否包含不活跃的货币
         * Whether to include inactive currencies
         */
        @query includeInactive?: boolean = false
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 货币列表
         * Currencies
         */
        currencies: Currency[];
    }>;

    /**
     * 格式化数据预览
     * Format data preview
     *
     * 根据指定的语言和格式设置预览格式化结果。
     * Preview formatting results based on specified language and format settings.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/i18n/format-preview' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "language": "zh",
     *     "timezone": "Asia/Shanghai",
     *     "dateFormat": "YYYY-MM-DD",
     *     "timeFormat": "24h",
     *     "currency": "CNY",
     *     "samples": {
     *       "date": "2024-12-06T10:30:00Z",
     *       "number": 1234567.89,
     *       "currency": 9999.99
     *     }
     *   }'
     * ```
     */
    @post
    @route("/format-preview")
    @summary("格式化数据预览")
    formatPreview(
        @body request: {
            /**
             * 语言代码
             * Language code
             */
            language: string;

            /**
             * 时区
             * Timezone
             */
            timezone: string;

            /**
             * 日期格式
             * Date format
             */
            dateFormat: string;

            /**
             * 时间格式
             * Time format
             */
            timeFormat: string;

            /**
             * 货币代码
             * Currency code
             */
            currency: string;

            /**
             * 示例数据
             * Sample data
             */
            samples: {
                /**
                 * 日期示例
                 * Date sample
                 */
                date: string;

                /**
                 * 数字示例
                 * Number sample
                 */
                number: float64;

                /**
                 * 货币示例
                 * Currency sample
                 */
                currency: float64;
            };
        }
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 格式化结果
         * Formatted results
         */
        formatted: {
            /**
             * 格式化的日期
             * Formatted date
             */
            date: string;

            /**
             * 格式化的时间
             * Formatted time
             */
            time: string;

            /**
             * 格式化的日期时间
             * Formatted datetime
             */
            datetime: string;

            /**
             * 格式化的数字
             * Formatted number
             */
            number: string;

            /**
             * 格式化的货币
             * Formatted currency
             */
            currency: string;
        };
    }>;
}
