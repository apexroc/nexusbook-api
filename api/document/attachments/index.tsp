import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 附件管理模块 (Attachments)
 *
 * 提供完整的附件存储和管理功能，支持在数据行和文档属性中使用。
 * Provides complete attachment storage and management, supporting usage in data rows and document properties.
 *
 * ## 核心功能
 *
 * - **文件上传** - 支持多种文件格式，自动生成缩略图
 * - **版本管理** - 附件版本历史追踪
 * - **安全扫描** - 病毒和恶意内容检测
 * - **存储配额** - 组织级别的存储限额管理
 * - **访问控制** - 基于权限的附件访问
 * - **预览生成** - 图片、PDF等文件的预览
 *
 * ## 使用场景
 *
 * - **数据行附件** - 订单附件、产品图片、发票文件
 * - **属性附件** - 文档级别的封面图、Logo、合同文件
 * - **头像上传** - 用户头像、团队Logo
 * - **批量上传** - 一次性上传多个文件
 *
 * ## 示例
 *
 * ### 上传附件
 * ```bash
 * curl -X POST 'https://open.nexusbook.app/api/v1/attachments/upload' \
 *   -H 'Authorization: Bearer TOKEN' \
 *   -F 'file=@image.png' \
 *   -F 'scanForVirus=true' \
 *   -F 'generateThumbnail=true'
 * ```
 */
namespace NexusBook.Api.Document;

/**
 * 附件详情（扩展版本）
 * Attachment details (extended)
 */
model AttachmentDetail {
    /**
     * 附件ID
     * Attachment id
     */
    id: string;

    /**
     * 文件名
     * File name
     */
    fileName: string;

    /**
     * 原始文件名
     * Original file name
     */
    originalFileName?: string;

    /**
     * URL 链接
     * URL
     */
    url: string;

    /**
     * 缩略图URL
     * Thumbnail URL
     */
    thumbnailUrl?: string;

    /**
     * 预览URL
     * Preview URL
     */
    previewUrl?: string;

    /**
     * 下载URL
     * Download URL
     */
    downloadUrl?: string;

    /**
     * 媒体类型
     * MIME type
     */
    mimeType: string;

    /**
     * 文件大小（字节）
     * Size in bytes
     */
    size: int64;

    /**
     * 文件扩展名
     * File extension
     */
    extension?: string;

    /**
     * 校验和（SHA256）
     * Checksum (SHA256)
     */
    checksum?: string;

    /**
     * 图片宽度（像素）
     * Width in pixels
     */
    width?: int32;

    /**
     * 图片高度（像素）
     * Height in pixels
     */
    height?: int32;

    /**
     * 持续时间（毫秒，用于音视频）
     * Duration in milliseconds (for audio/video)
     */
    duration?: int64;

    /**
     * 版本号
     * Version number
     */
    version?: int32;

    /**
     * 父版本ID（如果是新版本）
     * Parent version id (if this is a new version)
     */
    parentVersionId?: string;

    /**
     * 存储位置
     * Storage location
     */
    storageLocation?: string;

    /**
     * 存储提供商
     * Storage provider
     */
    storageProvider?: StorageProvider;

    /**
     * 扫描状态
     * Scan status
     */
    scanStatus?: ScanStatus;

    /**
     * 扫描结果
     * Scan result
     */
    scanResult?: {
        /**
         * 是否安全
         * Is safe
         */
        isSafe: boolean;

        /**
         * 检测到的威胁
         * Detected threats
         */
        threats?: string[];

        /**
         * 扫描时间
         * Scanned at
         */
        scannedAt?: string;
    };

    /**
     * 所属组织ID
     * Organization id
     */
    organizationId?: string;

    /**
     * 所属工作区ID
     * Workspace id
     */
    workspaceId?: string;

    /**
     * 关联文档类型
     * Related document type
     */
    relatedDocType?: string;

    /**
     * 关联文档ID
     * Related document id
     */
    relatedDocId?: string;

    /**
     * 关联行ID
     * Related row id
     */
    relatedRowId?: string;

    /**
     * 关联字段ID
     * Related field id
     */
    relatedFieldId?: string;

    /**
     * 标签
     * Tags
     */
    tags?: string[];

    /**
     * 元数据
     * Metadata
     */
    metadata?: unknown;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 创建人
     * Created by
     */
    createdBy: NexusBook.Api.Common.UserRef;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt?: string;

    /**
     * 更新人
     * Updated by
     */
    updatedBy?: NexusBook.Api.Common.UserRef;

    /**
     * 过期时间（可选）
     * Expires at (optional)
     */
    expiresAt?: string;

    /**
     * 是否公开
     * Is public
     */
    isPublic?: boolean;
}

/**
 * 存储提供商
 * Storage provider
 */
enum StorageProvider {
    /**
     * 本地存储
     * Local storage
     */
    local,

    /**
     * AWS S3
     */
    s3,

    /**
     * 阿里云OSS
     * Aliyun OSS
     */
    oss,

    /**
     * 腾讯云COS
     * Tencent COS
     */
    cos,

    /**
     * 七牛云
     * Qiniu
     */
    qiniu,

    /**
     * Azure Blob
     */
    azure,

    /**
     * Google Cloud Storage
     */
    gcs,
}

/**
 * 扫描状态
 * Scan status
 */
enum ScanStatus {
    /**
     * 待扫描
     * Pending
     */
    pending,

    /**
     * 扫描中
     * Scanning
     */
    scanning,

    /**
     * 已完成
     * Completed
     */
    completed,

    /**
     * 失败
     * Failed
     */
    failed,

    /**
     * 跳过
     * Skipped
     */
    skipped,
}

/**
 * 附件版本
 * Attachment version
 */
model AttachmentVersion {
    /**
     * 版本ID
     * Version id
     */
    id: string;

    /**
     * 附件ID
     * Attachment id
     */
    attachmentId: string;

    /**
     * 版本号
     * Version number
     */
    version: int32;

    /**
     * 文件大小
     * File size
     */
    size: int64;

    /**
     * 校验和
     * Checksum
     */
    checksum: string;

    /**
     * URL
     */
    url: string;

    /**
     * 创建时间
     * Created at
     */
    createdAt: string;

    /**
     * 创建人
     * Created by
     */
    createdBy: NexusBook.Api.Common.UserRef;

    /**
     * 变更说明
     * Change note
     */
    note?: string;
}

/**
 * 存储配额
 * Storage quota
 */
model StorageQuota {
    /**
     * 组织ID
     * Organization id
     */
    organizationId: string;

    /**
     * 总配额（字节）
     * Total quota in bytes
     */
    totalQuota: int64;

    /**
     * 已使用（字节）
     * Used in bytes
     */
    usedQuota: int64;

    /**
     * 剩余（字节）
     * Remaining in bytes
     */
    remainingQuota: int64;

    /**
     * 文件数量
     * File count
     */
    fileCount: int64;

    /**
     * 更新时间
     * Updated at
     */
    updatedAt: string;
}

@route("/attachments")
@tag("Attachments")
interface AttachmentsApi {
    /**
     * 上传附件
     *
     * Upload attachment
     *
     * 上传文件并返回附件信息。支持自动扫描和缩略图生成。
     * Upload file and return attachment info. Supports automatic scanning and thumbnail generation.
     *
     * 支持的参数:
     * - `file` - 文件（必需）
     * - `scanForVirus` - 是否扫描病毒
     * - `generateThumbnail` - 是否生成缩略图
     * - `generatePreview` - 是否生成预览
     * - `tags` - 标签（逗号分隔）
     * - `isPublic` - 是否公开访问
     * - `expiresIn` - 过期时间（秒）
     */
    @route("/upload")
    @post
    @summary("上传附件")
    uploadAttachment(
        @body body: bytes,
    ): NexusBook.Api.Common.ApiResponse<AttachmentDetail>;

    /**
     * 批量上传附件
     *
     * Batch upload attachments
     *
     * 一次性上传多个文件。
     * Upload multiple files at once.
     */
    @route("/upload/batch")
    @post
    @summary("批量上传附件")
    batchUploadAttachments(
        @body body: bytes,
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 上传成功的附件
         * Successfully uploaded
         */
        uploaded: AttachmentDetail[];

        /**
         * 上传失败的文件
         * Failed uploads
         */
        failures?: {
            fileName: string;
            reason: string;
        }[];
    }>;

    /**
     * 列出附件
     *
     * List attachments
     *
     * 查询附件列表，支持过滤和分页。
     * Query attachments with filtering and pagination.
     */
    @get
    @summary("列出附件")
    listAttachments(
        @query organizationId?: string,
        @query workspaceId?: string,
        @query relatedDocType?: string,
        @query relatedDocId?: string,
        @query relatedRowId?: string,
        @query mimeType?: string,
        @query tags?: string,
        @query createdBy?: string,
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<AttachmentDetail>>;

    /**
     * 获取附件详情
     *
     * Get attachment details
     *
     * 返回附件的完整信息。
     * Return complete attachment information.
     */
    @route("/{attachmentId}")
    @get
    @summary("获取附件详情")
    getAttachment(
        @path attachmentId: string,
    ): NexusBook.Api.Common.ApiResponse<AttachmentDetail>;

    /**
     * 更新附件元数据
     *
     * Update attachment metadata
     *
     * 更新附件的标签、名称等元数据。
     * Update attachment tags, name and other metadata.
     */
    @route("/{attachmentId}")
    @patch
    @summary("更新附件元数据")
    updateAttachment(
        @path attachmentId: string,
        @body body: {
            fileName?: string;
            tags?: string[];
            metadata?: unknown;
            isPublic?: boolean;
        },
    ): NexusBook.Api.Common.ApiResponse<AttachmentDetail>;

    /**
     * 删除附件
     *
     * Delete attachment
     *
     * 删除附件及其所有版本。此操作不可恢复。
     * Delete attachment and all its versions. This action is irreversible.
     */
    @route("/{attachmentId}")
    @delete
    @summary("删除附件")
    deleteAttachment(
        @path attachmentId: string,
        @query permanent?: boolean,
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 获取附件版本列表
     *
     * Get attachment versions
     *
     * 返回附件的所有历史版本。
     * Return all historical versions of the attachment.
     */
    @route("/{attachmentId}/versions")
    @get
    @summary("获取附件版本")
    getAttachmentVersions(
        @path attachmentId: string,
    ): NexusBook.Api.Common.ApiResponse<AttachmentVersion[]>;

    /**
     * 创建附件新版本
     *
     * Create attachment version
     *
     * 为现有附件上传新版本。
     * Upload new version for existing attachment.
     */
    @route("/{attachmentId}/versions")
    @post
    @summary("创建新版本")
    createAttachmentVersion(
        @path attachmentId: string,
        @body body: bytes,
    ): NexusBook.Api.Common.ApiResponse<AttachmentVersion>;

    /**
     * 获取预览URL
     *
     * Get preview URL
     *
     * 生成附件的预览URL（支持图片、PDF等）。
     * Generate preview URL for attachment (supports images, PDF, etc).
     */
    @route("/{attachmentId}/preview")
    @get
    @summary("获取预览")
    getAttachmentPreview(
        @path attachmentId: string,
        @query size?: PreviewSize,
        @query page?: int32,
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 预览URL
         * Preview URL
         */
        previewUrl: string;

        /**
         * 过期时间
         * Expires at
         */
        expiresAt: string;
    }>;

    /**
     * 获取下载URL
     *
     * Get download URL
     *
     * 生成附件的临时下载URL。
     * Generate temporary download URL for attachment.
     */
    @route("/{attachmentId}/download")
    @get
    @summary("获取下载链接")
    getAttachmentDownloadUrl(
        @path attachmentId: string,
        @query expiresIn?: int64,
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 下载URL
         * Download URL
         */
        downloadUrl: string;

        /**
         * 过期时间
         * Expires at
         */
        expiresAt: string;
    }>;

    /**
     * 获取存储配额
     *
     * Get storage quota
     *
     * 查询组织的存储配额使用情况。
     * Query organization storage quota usage.
     */
    @route("/quota/{organizationId}")
    @get
    @summary("获取存储配额")
    getStorageQuota(
        @path organizationId: string,
    ): NexusBook.Api.Common.ApiResponse<StorageQuota>;

    /**
     * 清理过期附件
     *
     * Clean expired attachments
     *
     * 清理已过期的临时附件。
     * Clean up expired temporary attachments.
     */
    @route("/cleanup")
    @post
    @summary("清理过期附件")
    cleanupExpiredAttachments(
        @query organizationId?: string,
        @query dryRun?: boolean,
    ): NexusBook.Api.Common.ApiResponse<{
        /**
         * 清理数量
         * Cleaned count
         */
        cleanedCount: int32;

        /**
         * 释放空间（字节）
         * Freed space in bytes
         */
        freedSpace: int64;

        /**
         * 清理的附件列表（仅 dryRun=true 时返回）
         * Cleaned attachments (only when dryRun=true)
         */
        cleanedAttachments?: string[];
    }>;
}

/**
 * 预览尺寸
 * Preview size
 */
enum PreviewSize {
    /**
     * 小尺寸 (200px)
     * Small (200px)
     */
    small,

    /**
     * 中尺寸 (600px)
     * Medium (600px)
     */
    medium,

    /**
     * 大尺寸 (1200px)
     * Large (1200px)
     */
    large,

    /**
     * 原始尺寸
     * Original
     */
    original,
}
