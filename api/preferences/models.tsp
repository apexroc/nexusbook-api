import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";
import "../i18n/models.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 用户偏好设置数据模型
 * User preferences data models
 *
 * 定义用户个性化设置相关的数据模型。
 * Defines data models for user personalization settings.
 */
namespace NexusBook.Api.Preferences;

// ==================== 用户偏好模型 ====================

/**
 * 通用偏好设置
 * General preferences
 */
model GeneralPreferences {
    /**
     * 默认组织ID
     * Default organization ID
     */
    defaultOrganizationId?: string;

    /**
     * 默认工作区ID
     * Default workspace ID
     */
    defaultWorkspaceId?: string;

    /**
     * 默认视图类型
     * Default view type
     */
    defaultView?: string;

    /**
     * 启动页URL
     * Start page URL
     */
    startPage?: string;

    /**
     * 每页显示数量
     * Items per page
     */
    itemsPerPage?: int32;

    /**
     * 启用快捷键
     * Enable keyboard shortcuts
     */
    enableKeyboardShortcuts?: boolean;

    /**
     * 启用动画效果
     * Enable animations
     */
    enableAnimations?: boolean;
}

/**
 * 外观偏好设置
 * Appearance preferences
 */
model AppearancePreferences {
    /**
     * 主题模式
     * Theme mode
     */
    theme?: NexusBook.Api.I18n.ThemeMode;

    /**
     * 强调色（HEX格式）
     * Accent color (HEX format)
     */
    accentColor?: string;

    /**
     * 字体系列
     * Font family
     */
    fontFamily?: string;

    /**
     * 字体大小
     * Font size
     */
    fontSize?: NexusBook.Api.I18n.FontSize;

    /**
     * 界面密度
     * Interface density
     */
    density?: NexusBook.Api.I18n.Density;

    /**
     * 侧边栏折叠状态
     * Sidebar collapsed state
     */
    sidebarCollapsed?: boolean;
}

/**
 * 数字格式偏好
 * Number format preference
 */
model NumberFormatPreference {
    /**
     * 小数分隔符
     * Decimal separator
     */
    decimalSeparator?: string;

    /**
     * 千分位分隔符
     * Thousand separator
     */
    thousandSeparator?: string;
}

/**
 * 地区偏好设置
 * Regional preferences
 */
model RegionalPreferences {
    /**
     * 界面语言
     * UI language
     */
    language?: string;

    /**
     * 内容语言偏好（优先顺序）
     * Content language preferences (priority order)
     */
    contentLanguages?: string[];

    /**
     * 时区（IANA格式）
     * Timezone (IANA format)
     */
    timezone?: string;

    /**
     * 日期格式
     * Date format
     */
    dateFormat?: string;

    /**
     * 时间格式
     * Time format
     */
    timeFormat?: NexusBook.Api.I18n.TimeFormat;

    /**
     * 每周首日
     * First day of week
     */
    firstDayOfWeek?: NexusBook.Api.I18n.DayOfWeek;

    /**
     * 默认货币
     * Default currency
     */
    currency?: string;

    /**
     * 数字格式偏好
     * Number format preference
     */
    numberFormat?: NumberFormatPreference;
}

/**
 * 辅助功能偏好设置
 * Accessibility preferences
 */
model AccessibilityPreferences {
    /**
     * 高对比度
     * High contrast
     */
    highContrast?: boolean;

    /**
     * 减少动画
     * Reduced motion
     */
    reducedMotion?: boolean;

    /**
     * 屏幕阅读器支持
     * Screen reader support
     */
    screenReader?: boolean;

    /**
     * 键盘导航优化
     * Keyboard navigation optimization
     */
    keyboardNavigation?: boolean;

    /**
     * 焦点指示器增强
     * Enhanced focus indicator
     */
    focusIndicator?: boolean;

    /**
     * 文本转语音
     * Text to speech
     */
    textToSpeech?: boolean;
}

/**
 * 隐私偏好设置
 * Privacy preferences
 */
model PrivacyPreferences {
    /**
     * 显示在线状态
     * Show presence status
     */
    showPresenceStatus?: boolean;

    /**
     * 允许分析数据收集
     * Allow analytics data collection
     */
    allowAnalytics?: boolean;

    /**
     * 允许营销通知
     * Allow marketing notifications
     */
    allowMarketing?: boolean;

    /**
     * 向他人显示个人资料
     * Show profile to others
     */
    showProfileToOthers?: boolean;

    /**
     * 分享活动状态
     * Share activity status
     */
    shareActivityStatus?: boolean;
}

/**
 * 用户偏好设置
 * User preferences
 */
model UserPreferences {
    /**
     * 用户ID
     * User ID
     */
    userId: string;

    /**
     * 通用偏好
     * General preferences
     */
    general?: GeneralPreferences;

    /**
     * 外观偏好
     * Appearance preferences
     */
    appearance?: AppearancePreferences;

    /**
     * 通知偏好（引用通知模块定义）
     * Notification preferences (reference notification module)
     */
    notifications?: {};

    /**
     * 地区偏好
     * Regional preferences
     */
    regional?: RegionalPreferences;

    /**
     * 辅助功能偏好
     * Accessibility preferences
     */
    accessibility?: AccessibilityPreferences;

    /**
     * 隐私偏好
     * Privacy preferences
     */
    privacy?: PrivacyPreferences;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt: string;
}

/**
 * 语言偏好设置
 * Language preferences
 */
model LanguagePreferences {
    /**
     * 主要语言
     * Primary language
     */
    primaryLanguage: string;

    /**
     * 内容语言列表
     * Content languages
     */
    contentLanguages: string[];

    /**
     * 自动检测语言
     * Auto detect language
     */
    autoDetect: boolean;

    /**
     * 备用语言
     * Fallback language
     */
    fallbackLanguage: string;
}
