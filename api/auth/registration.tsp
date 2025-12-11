import "@typespec/http";
import "@typespec/openapi3";
import "../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 用户注册与登录模块
 *
 * User Registration and Authentication Module
 *
 * 提供完整的用户认证功能：
 * - 用户注册（邮箱/手机）
 * - 登录（邮箱/手机/OAuth）
 * - 密码管理（找回/重置/修改）
 * - 两步验证（2FA/MFA）
 * - 会话管理
 *
 * Features:
 * - User registration (email/phone)
 * - Login (email/phone/OAuth)
 * - Password management (recovery/reset/change)
 * - Two-factor authentication (2FA/MFA)
 * - Session management
 */
namespace NexusBook.Api.Auth;

// ==================== 枚举和常量 ====================

/**
 * 登录方式
 * Authentication method
 */
enum AuthMethod {
    /**
     * 邮箱 + 密码
     * Email + password
     */
    email,

    /**
     * 手机号 + 验证码
     * Phone + verification code
     */
    phone,

    /**
     * OAuth 第三方登录
     * OAuth third-party login
     */
    oauth,

    /**
     * 魔法链接（无密码）
     * Magic link (passwordless)
     */
    magicLink,
}

/**
 * 两步验证方式
 * Two-factor method
 */
enum TwoFactorMethod {
    /**
     * TOTP (Google Authenticator 等)
     * TOTP (Google Authenticator, etc.)
     */
    totp,

    /**
     * 短信验证码
     * SMS code
     */
    sms,

    /**
     * 邮件验证码
     * Email code
     */
    email,

    /**
     * 备用码
     * Backup codes
     */
    backupCode,
}

/**
 * 会话状态
 * Session status
 */
enum SessionStatus {
    /**
     * 活跃
     * Active
     */
    active,

    /**
     * 已过期
     * Expired
     */
    expired,

    /**
     * 已吊销
     * Revoked
     */
    revoked,
}

// ==================== 核心模型 ====================

/**
 * 用户注册请求
 * User registration request
 */
model RegisterRequest {
    /**
     * 邮箱
     * Email
     */
    email?: string;

    /**
     * 手机号
     * Phone number
     */
    phone?: string;

    /**
     * 密码（邮箱注册时必填）
     * Password (required for email registration)
     */
    password?: string;

    /**
     * 显示名称
     * Display name
     */
    displayName: string;

    /**
     * 邀请码（可选）
     * Invitation code (optional)
     */
    invitationCode?: string;

    /**
     * 同意服务条款
     * Agree to terms of service
     */
    agreeToTerms: boolean;
}

/**
 * 登录请求
 * Login request
 */
model LoginRequest {
    /**
     * 邮箱
     * Email
     */
    email?: string;

    /**
     * 手机号
     * Phone number
     */
    phone?: string;

    /**
     * 密码
     * Password
     */
    password?: string;

    /**
     * 验证码（手机登录时使用）
     * Verification code (for phone login)
     */
    verificationCode?: string;

    /**
     * OAuth 授权码（OAuth 登录时使用）
     * OAuth authorization code (for OAuth login)
     */
    authorizationCode?: string;

    /**
     * OAuth 提供商（OAuth 登录时使用）
     * OAuth provider (for OAuth login)
     */
    provider?: string;

    /**
     * 两步验证码（如果启用了 2FA）
     * Two-factor code (if 2FA enabled)
     */
    twoFactorCode?: string;

    /**
     * 记住我（延长会话时间）
     * Remember me (extend session)
     */
    rememberMe?: boolean;
}

/**
 * 登录响应
 * Login response
 */
model LoginResponse {
    /**
     * 访问令牌
     * Access token
     */
    accessToken: string;

    /**
     * 刷新令牌
     * Refresh token
     */
    refreshToken: string;

    /**
     * 令牌类型
     * Token type
     */
    tokenType: "Bearer";

    /**
     * 过期时间（秒）
     * Expires in seconds
     */
    expiresIn: int32;

    /**
     * 用户信息
     * User info
     */
    user: {
        id: string;
        email?: string;
        phone?: string;
        displayName: string;
        avatarUrl?: string;
    };

    /**
     * 是否需要两步验证
     * Requires two-factor authentication
     */
    requiresTwoFactor?: boolean;
}

/**
 * 发送验证码请求
 * Send verification code request
 */
model SendVerificationCodeRequest {
    /**
     * 邮箱或手机号
     * Email or phone number
     */
    target: string;

    /**
     * 验证码类型
     * Code type
     */
    type: "login" | "register" | "resetPassword" | "enableTwoFactor";
}

/**
 * 密码重置请求
 * Password reset request
 */
model ResetPasswordRequest {
    /**
     * 邮箱或手机号
     * Email or phone number
     */
    target: string;

    /**
     * 验证码
     * Verification code
     */
    verificationCode: string;

    /**
     * 新密码
     * New password
     */
    newPassword: string;
}

/**
 * 修改密码请求
 * Change password request
 */
model ChangePasswordRequest {
    /**
     * 当前密码
     * Current password
     */
    currentPassword: string;

    /**
     * 新密码
     * New password
     */
    newPassword: string;
}

/**
 * 启用两步验证请求
 * Enable two-factor request
 */
model EnableTwoFactorRequest {
    /**
     * 两步验证方式
     * Two-factor method
     */
    method: TwoFactorMethod;

    /**
     * 验证码（用于确认）
     * Verification code (for confirmation)
     */
    code: string;
}

/**
 * 两步验证设置响应
 * Two-factor setup response
 */
model TwoFactorSetupResponse {
    /**
     * 方式
     * Method
     */
    method: TwoFactorMethod;

    /**
     * TOTP 密钥（仅当 method 为 totp 时）
     * TOTP secret (only when method is totp)
     */
    secret?: string;

    /**
     * TOTP 二维码 URL（仅当 method 为 totp 时）
     * TOTP QR code URL (only when method is totp)
     */
    qrCodeUrl?: string;

    /**
     * 备用码列表（仅当 method 为 backupCode 时）
     * Backup codes (only when method is backupCode)
     */
    backupCodes?: string[];
}

/**
 * 会话信息
 * Session info
 */
model Session {
    /**
     * 会话ID
     * Session ID
     */
    id: string;

    /**
     * 用户ID
     * User ID
     */
    userId: string;

    /**
     * 设备信息
     * Device info
     */
    device: {
        /**
         * 设备类型
         * Device type
         */
        type: string;

        /**
         * 操作系统
         * Operating system
         */
        os?: string;

        /**
         * 浏览器
         * Browser
         */
        browser?: string;
    };

    /**
     * IP 地址
     * IP address
     */
    ipAddress: string;

    /**
     * 地理位置
     * Location
     */
    location?: {
        /**
         * 国家
         * Country
         */
        country?: string;

        /**
         * 城市
         * City
         */
        city?: string;
    };

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 最后活跃时间
     * Last active at
     */
    lastActiveAt: string;

    /**
     * 过期时间
     * Expires at
     */
    expiresAt: string;

    /**
     * 状态
     * Status
     */
    status: SessionStatus;

    /**
     * 是否为当前会话
     * Is current session
     */
    isCurrent: boolean;
}

// ==================== API 接口 ====================

@route("/api/v1/auth")
@tag("Authentication")
interface AuthenticationApi {
    /**
     * 用户注册
     * User registration
     *
     * 支持邮箱注册和手机号注册。
     * Supports email and phone registration.
     *
     * 示例（邮箱注册）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/auth/register' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "email": "user@example.com",
     *     "password": "SecurePassword123!",
     *     "displayName": "张三",
     *     "agreeToTerms": true
     *   }'
     * ```
     */
    @post
    @route("/register")
    @summary("用户注册")
    register(@body request: RegisterRequest): NexusBook.Api.Common.ApiResponse<LoginResponse>;

    /**
     * 用户登录
     * User login
     *
     * 支持多种登录方式：邮箱+密码、手机+验证码、OAuth。
     * Supports multiple login methods: email+password, phone+code, OAuth.
     *
     * 示例（邮箱登录）：
     * ```bash
     * curl -X POST 'https://open.nexusbook.app/api/v1/auth/login' \
     *   -H 'Content-Type: application/json' \
     *   -d '{
     *     "email": "user@example.com",
     *     "password": "SecurePassword123!",
     *     "rememberMe": true
     *   }'
     * ```
     */
    @post
    @route("/login")
    @summary("用户登录")
    login(@body request: LoginRequest): NexusBook.Api.Common.ApiResponse<LoginResponse>;

    /**
     * 退出登录
     * Logout
     *
     * 吊销当前访问令牌和刷新令牌。
     * Revoke current access and refresh tokens.
     */
    @post
    @route("/logout")
    @summary("退出登录")
    logout(): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 刷新令牌
     * Refresh token
     *
     * 使用刷新令牌获取新的访问令牌。
     * Use refresh token to get new access token.
     */
    @post
    @route("/refresh")
    @summary("刷新令牌")
    refreshToken(@body request: {
        /**
         * 刷新令牌
         * Refresh token
         */
        refreshToken: string;
    }): NexusBook.Api.Common.ApiResponse<{
        accessToken: string;
        refreshToken: string;
        expiresIn: int32;
    }>;

    /**
     * 发送验证码
     * Send verification code
     *
     * 发送验证码到邮箱或手机号。
     * Send verification code to email or phone.
     */
    @post
    @route("/verification-code")
    @summary("发送验证码")
    sendVerificationCode(
        @body request: SendVerificationCodeRequest
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 发送成功
         * Send success
         */
        sent: boolean;

        /**
         * 过期时间（秒）
         * Expires in seconds
         */
        expiresIn: int32;
    }>;

    /**
     * 请求密码重置
     * Request password reset
     *
     * 发送密码重置验证码。
     * Send password reset verification code.
     */
    @post
    @route("/forgot-password")
    @summary("忘记密码")
    forgotPassword(@body request: {
        /**
         * 邮箱或手机号
         * Email or phone number
         */
        target: string;
    }): NexusBook.Api.Common.ApiResponse<{
        sent: boolean;
        expiresIn: int32;
    }>;

    /**
     * 重置密码
     * Reset password
     *
     * 使用验证码重置密码。
     * Reset password using verification code.
     */
    @post
    @route("/reset-password")
    @summary("重置密码")
    resetPassword(@body request: ResetPasswordRequest): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 修改密码
     * Change password
     *
     * 修改当前用户的密码（需要认证）。
     * Change current user's password (requires authentication).
     */
    @post
    @route("/change-password")
    @summary("修改密码")
    changePassword(@body request: ChangePasswordRequest): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 设置两步验证
     * Setup two-factor authentication
     *
     * 初始化两步验证设置，返回 TOTP 密钥或备用码。
     * Initialize two-factor setup, returns TOTP secret or backup codes.
     */
    @post
    @route("/two-factor/setup")
    @summary("设置两步验证")
    setupTwoFactor(@body request: {
        /**
         * 两步验证方式
         * Two-factor method
         */
        method: TwoFactorMethod;
    }): NexusBook.Api.Common.ApiResponse<TwoFactorSetupResponse>;

    /**
     * 启用两步验证
     * Enable two-factor authentication
     *
     * 确认并启用两步验证。
     * Confirm and enable two-factor authentication.
     */
    @post
    @route("/two-factor/enable")
    @summary("启用两步验证")
    enableTwoFactor(@body request: EnableTwoFactorRequest): NexusBook.Api.Common.ApiResponse<{
        enabled: boolean;
        backupCodes?: string[];
    }>;

    /**
     * 禁用两步验证
     * Disable two-factor authentication
     *
     * 禁用当前用户的两步验证。
     * Disable two-factor authentication for current user.
     */
    @post
    @route("/two-factor/disable")
    @summary("禁用两步验证")
    disableTwoFactor(@body request: {
        /**
         * 当前密码或验证码
         * Current password or verification code
         */
        password: string;
    }): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 列出活跃会话
     * List active sessions
     *
     * 获取当前用户的所有活跃会话。
     * Get all active sessions of current user.
     */
    @get
    @route("/sessions")
    @summary("列出会话")
    listSessions(): NexusBook.Api.Common.ApiResponse<Session[]>;

    /**
     * 吊销会话
     * Revoke session
     *
     * 吊销指定的会话。
     * Revoke specified session.
     */
    @delete
    @route("/sessions/{sessionId}")
    @summary("吊销会话")
    revokeSession(@path sessionId: string): NexusBook.Api.Common.ApiResponse<{}>;

    /**
     * 吊销所有其他会话
     * Revoke all other sessions
     *
     * 吊销除当前会话外的所有会话。
     * Revoke all sessions except the current one.
     */
    @post
    @route("/sessions/revoke-all")
    @summary("吊销所有其他会话")
    revokeAllOtherSessions(): NexusBook.Api.Common.ApiResponse<{
        revokedCount: int32;
    }>;
}
