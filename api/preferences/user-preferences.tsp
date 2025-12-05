import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";
import "./models.tsp";

using TypeSpec.Http;
using OpenAPI;
using NexusBook.Api.Preferences;

/**
 * 用户偏好设置 API
 * User preferences API
 */
namespace NexusBook.Api.Preferences;

// ==================== API 接口定义 ====================

/**
 * 用户偏好 API 接口
 * User preferences API interface
 */
@tag("User Preferences")
@route("/api/v1/users/me/preferences")
interface UserPreferencesApi {
    /**
     * 获取当前用户偏好设置
     * Get current user preferences
     *
     * 返回当前用户的完整偏好设置或指定部分。
     * Returns complete preferences or specified section for current user.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/users/me/preferences?section=regional' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @summary("获取当前用户偏好设置")
    getUserPreferences(
        /**
         * 获取特定部分
         * Get specific section (general/appearance/notifications/regional/accessibility/privacy)
         */
        @query section?: string
    ): NexusBook.Api.Common.ApiResponse<UserPreferences>;

    /**
     * 更新用户偏好设置
     * Update user preferences
     *
     * 更新当前用户的偏好设置（部分更新）。
     * Update current user's preferences (partial update).
     *
     * 示例（cURL）：
     * ```bash
     * curl -X PATCH 'https://open.nexusbook.com/api/v1/users/me/preferences' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "regional": {
     *       "language": "zh",
     *       "timezone": "Asia/Shanghai",
     *       "dateFormat": "YYYY-MM-DD",
     *       "timeFormat": "24h",
     *       "firstDayOfWeek": "monday",
     *       "currency": "CNY"
     *     }
     *   }'
     * ```
     */
    @patch
    @summary("更新用户偏好设置")
    updateUserPreferences(
        @body request: {
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
        }
    ): NexusBook.Api.Common.ApiResponse<UserPreferences>;

    /**
     * 重置用户偏好为默认值
     * Reset user preferences to defaults
     *
     * 将指定部分或全部偏好设置重置为默认值。
     * Reset specified sections or all preferences to defaults.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.com/api/v1/users/me/preferences/reset' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "sections": ["appearance", "notifications"],
     *     "resetAll": false
     *   }'
     * ```
     */
    @post
    @route("/reset")
    @summary("重置用户偏好为默认值")
    resetUserPreferences(
        @body request: {
            /**
             * 要重置的部分列表
             * Sections to reset
             */
            sections?: string[];

            /**
             * 重置全部
             * Reset all
             */
            resetAll?: boolean;
        }
    ): NexusBook.Api.Common.ApiResponse<UserPreferences>;

    /**
     * 获取用户语言偏好
     * Get user language preferences
     *
     * 获取当前用户的语言相关偏好设置。
     * Get language-related preferences for current user.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X GET 'https://open.nexusbook.com/api/v1/users/me/preferences/language' \
     *   -H 'Authorization: Bearer TOKEN'
     * ```
     */
    @get
    @route("/language")
    @summary("获取用户语言偏好")
    getLanguagePreferences(): NexusBook.Api.Common.ApiResponse<LanguagePreferences>;

    /**
     * 更新用户语言偏好
     * Update user language preferences
     *
     * 更新当前用户的语言相关偏好设置。
     * Update language-related preferences for current user.
     *
     * 示例（cURL）：
     * ```bash
     * curl -X PUT 'https://open.nexusbook.com/api/v1/users/me/preferences/language' \
     *   -H 'Authorization: Bearer TOKEN' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "primaryLanguage": "zh",
     *     "contentLanguages": ["zh", "en", "ja"],
     *     "autoDetect": true,
     *     "fallbackLanguage": "en"
     *   }'
     * ```
     */
    @put
    @route("/language")
    @summary("更新用户语言偏好")
    updateLanguagePreferences(
        @body preferences: LanguagePreferences
    ): NexusBook.Api.Common.ApiResponse<LanguagePreferences>;
}
