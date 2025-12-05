import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 国际化数据模型
 * Internationalization data models
 *
 * 定义多语言支持相关的核心数据模型。
 * Defines core data models for multi-language support.
 */
namespace NexusBook.Api.I18n;

// ==================== 枚举定义 ====================

/**
 * 文本方向
 * Text direction
 */
enum TextDirection {
    /**
     * 从左到右
     * Left to right
     */
    ltr,

    /**
     * 从右到左
     * Right to left
     */
    rtl,
}

/**
 * 资源分类
 * Resource category
 */
enum ResourceCategory {
    /**
     * 界面文本
     * UI text
     */
    ui,

    /**
     * 字段标签
     * Field labels
     */
    field_label,

    /**
     * 验证消息
     * Validation messages
     */
    validation_message,

    /**
     * 通知模板
     * Notification templates
     */
    notification_template,

    /**
     * 邮件模板
     * Email templates
     */
    email_template,

    /**
     * 系统消息
     * System messages
     */
    system_message,
}

/**
 * 主题模式
 * Theme mode
 */
enum ThemeMode {
    /**
     * 浅色
     * Light
     */
    light,

    /**
     * 深色
     * Dark
     */
    dark,

    /**
     * 自动（跟随系统）
     * Auto (follow system)
     */
    auto,
}

/**
 * 字体大小
 * Font size
 */
enum FontSize {
    /**
     * 小
     * Small
     */
    small,

    /**
     * 中
     * Medium
     */
    medium,

    /**
     * 大
     * Large
     */
    large,

    /**
     * 特大
     * Extra large
     */
    extra_large,
}

/**
 * 界面密度
 * Interface density
 */
enum Density {
    /**
     * 紧凑
     * Compact
     */
    compact,

    /**
     * 舒适
     * Comfortable
     */
    comfortable,

    /**
     * 宽松
     * Spacious
     */
    spacious,
}

/**
 * 时间格式
 * Time format
 */
enum TimeFormat {
    /**
     * 12小时制
     * 12-hour format
     */
    `12h`,

    /**
     * 24小时制
     * 24-hour format
     */
    `24h`,
}

/**
 * 每周首日
 * First day of week
 */
enum DayOfWeek {
    /**
     * 周日
     * Sunday
     */
    sunday,

    /**
     * 周一
     * Monday
     */
    monday,

    /**
     * 周六
     * Saturday
     */
    saturday,
}

// ==================== 国际化模型 ====================

/**
 * 数字格式配置
 * Number format configuration
 */
model NumberFormat {
    /**
     * 小数分隔符
     * Decimal separator (e.g., "." or ",")
     */
    decimalSeparator: string;

    /**
     * 千分位分隔符
     * Thousand separator
     */
    thousandSeparator: string;

    /**
     * 小数位数
     * Decimal places
     */
    decimalPlaces: int32;
}

/**
 * 货币格式配置
 * Currency format configuration
 */
model CurrencyFormat {
    /**
     * 货币代码
     * Currency code (ISO 4217, e.g., CNY, USD)
     */
    currencyCode: string;

    /**
     * 货币符号
     * Currency symbol (e.g., ¥, $)
     */
    symbol: string;

    /**
     * 符号位置
     * Symbol position (before/after)
     */
    symbolPosition: "before" | "after";

    /**
     * 小数位数
     * Decimal places
     */
    decimalPlaces: int32;
}

/**
 * 语言配置
 * Language configuration
 */
model LanguageConfig {
    /**
     * 语言代码
     * Language code (ISO 639-1, e.g., zh, en, ja)
     */
    code: string;

    /**
     * 语言名称（多语言）
     * Language name (multi-language)
     */
    name: NexusBook.Api.Common.Message;

    /**
     * 本地语言名称
     * Native language name (e.g., "中文", "English")
     */
    nativeName: string;

    /**
     * 是否启用
     * Whether enabled
     */
    enabled: boolean;

    /**
     * 是否为默认语言
     * Whether it's the default language
     */
    isDefault: boolean;

    /**
     * 文本方向
     * Text direction
     */
    direction: TextDirection;

    /**
     * 日期格式
     * Date format (e.g., YYYY-MM-DD)
     */
    dateFormat: string;

    /**
     * 时间格式
     * Time format (e.g., HH:mm:ss)
     */
    timeFormat: string;

    /**
     * 数字格式配置
     * Number format configuration
     */
    numberFormat: NumberFormat;

    /**
     * 货币格式配置
     * Currency format configuration
     */
    currencyFormat: CurrencyFormat;

    /**
     * 排序顺序
     * Sort order
     */
    sortOrder: int32;
}

/**
 * 翻译资源
 * Translation resource
 */
model TranslationResource {
    /**
     * 资源唯一标识
     * Resource unique identifier
     */
    id: string;

    /**
     * 命名空间
     * Namespace (e.g., common, billing, notifications)
     */
    ns: string;

    /**
     * 翻译键
     * Translation key
     */
    key: string;

    /**
     * 各语言翻译
     * Translations for each language (language code -> translation text)
     */
    translations: Record<string>;

    /**
     * 上下文说明
     * Context description
     */
    context?: string;

    /**
     * 资源分类
     * Resource category
     */
    category: ResourceCategory;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt: string;

    /**
     * 更新者
     * Updated by
     */
    updatedBy: string;
}

/**
 * 语言检测结果
 * Language detection result
 */
model LanguageDetection {
    /**
     * 语言代码
     * Language code
     */
    language: string;

    /**
     * 置信度
     * Confidence (0.0 - 1.0)
     */
    confidence: float64;
}

/**
 * 语言覆盖率统计
 * Language coverage statistics
 */
model LanguageCoverage {
    /**
     * 语言代码
     * Language code
     */
    language: string;

    /**
     * 总键数
     * Total keys
     */
    totalKeys: int32;

    /**
     * 已翻译键数
     * Translated keys
     */
    translatedKeys: int32;

    /**
     * 缺失键数
     * Missing keys
     */
    missingKeys: int32;

    /**
     * 完整度百分比
     * Completeness percentage (0.0 - 1.0)
     */
    completeness: float64;

    /**
     * 最后更新时间
     * Last updated time
     */
    lastUpdated: string;
}

/**
 * 时区信息
 * Timezone information
 */
model Timezone {
    /**
     * 时区标识
     * Timezone identifier (IANA format)
     */
    id: string;

    /**
     * 时区名称
     * Timezone name
     */
    name: string;

    /**
     * UTC偏移量
     * UTC offset (e.g., +08:00)
     */
    offset: string;

    /**
     * 所属地区
     * Region
     */
    region: string;

    /**
     * 显示名称（多语言）
     * Display name (multi-language)
     */
    displayName: NexusBook.Api.Common.Message;
}

/**
 * 货币信息
 * Currency information
 */
model Currency {
    /**
     * 货币代码
     * Currency code (ISO 4217)
     */
    code: string;

    /**
     * 货币名称（多语言）
     * Currency name (multi-language)
     */
    name: NexusBook.Api.Common.Message;

    /**
     * 货币符号
     * Currency symbol
     */
    symbol: string;

    /**
     * 小数位数
     * Decimal places
     */
    decimalPlaces: int32;

    /**
     * 是否活跃
     * Whether active
     */
    active: boolean;
}

/**
 * 翻译结果
 * Translation result
 */
model TranslationResult {
    /**
     * 源文本
     * Source text
     */
    sourceText: string;

    /**
     * 翻译结果
     * Translations (language code -> translated text)
     */
    translations: Record<string>;

    /**
     * 置信度
     * Confidence scores (language code -> confidence)
     */
    confidence: Record<float64>;
}

/**
 * 翻译建议
 * Translation suggestion
 */
model TranslationSuggestion {
    /**
     * 翻译文本
     * Translation text
     */
    translation: string;

    /**
     * 置信度
     * Confidence (0.0 - 1.0)
     */
    confidence: float64;

    /**
     * 来源
     * Source (machine/memory/glossary)
     */
    source: "machine" | "memory" | "glossary";
}

/**
 * 术语表条目
 * Glossary entry
 */
model GlossaryEntry {
    /**
     * 条目唯一标识
     * Entry unique identifier
     */
    id: string;

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

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;
}

/**
 * 组织国际化配置
 * Organization i18n configuration
 */
model OrganizationI18nConfig {
    /**
     * 默认语言
     * Default language
     */
    defaultLanguage: string;

    /**
     * 支持的语言列表
     * Supported languages
     */
    supportedLanguages: string[];

    /**
     * 强制使用指定语言
     * Enforce specific language
     */
    enforceLanguage: boolean;

    /**
     * 自动检测语言
     * Auto detect language
     */
    autoDetectLanguage: boolean;

    /**
     * 备用语言
     * Fallback language
     */
    fallbackLanguage: string;

    /**
     * 默认时区
     * Default timezone
     */
    defaultTimezone: string;

    /**
     * 默认货币
     * Default currency
     */
    defaultCurrency: string;

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
     * 数字格式
     * Number format
     */
    numberFormat: NumberFormat;
}
