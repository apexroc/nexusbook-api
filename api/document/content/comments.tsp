import "@typespec/http";
import "@typespec/openapi3";
import "../../shared/index.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 评论模块
 *
 * 统一的协作评论系统，支持在文档任何位置进行评论和讨论。
 *
 * 主要功能：
 * - **统一评论结构** - 单一模型支持所有位置的评论
 * - **精确位置定位** - 使用 target 对象精确记录评论位置（文档/字段/行/单元格）
 * - **评论关联** - 支持评论回复和讨论树
 * - **富文本支持** - 支持格式化文本和 @提及功能
 * - **附件管理** - 评论中附加文件和图片
 * - **置顶管理** - 重要评论置顶展示
 * - **反应表情** - 支持表情反应和讨论增强
 *
 * ## 评论位置类型
 *
 * ### 文档级评论
 * target: { scope: "document" }
 *
 * ### 字段级评论
 * target: { scope: "field", fieldId: "field-123" }
 *
 * ### 行级评论
 * target: { scope: "row", rowId: "row-456" }
 *
 * ### 单元格级评论
 * target: { scope: "cell", rowId: "row-456", fieldId: "field-123" }
 *
 * ## 评论回复树
 *
 * 评论可以通过 parentId 指向另一条评论，形成讨论线程。
 * Replies chain via parentId, forming discussion threads.
 */
namespace NexusBook.Api.Document;

/**
 * 评论位置定位器
 * Comment target locator
 *
 * 精确记录评论所在的位置。支持多层级定位：文档/字段/行/单元格。
 * Precisely records where the comment is located. Supports multi-level targeting.
 */
model CommentTarget {
    /**
     * 评论作用域
     * Comment scope
     *
     * - "document" - 文档级评论
     * - "field" - 字段级评论（需要 fieldId）
     * - "row" - 行级评论（需要 rowId）
     * - "cell" - 单元格评论（需要 rowId 和 fieldId）
     *
     * Scope types: "document", "field", "row", "cell"
     */
    scope: string;

    /**
     * 字段ID（当 scope 为 field 或 cell 时）
     * Field id (when scope is field or cell)
     */
    fieldId?: string;

    /**
     * 行ID（当 scope 为 row 或 cell 时）
     * Row id (when scope is row or cell)
     */
    rowId?: string;
}

/**
 * 表情反应
 * Emoji reaction
 */
model Reaction {
    /**
     * 表情代码
     * Emoji code (e.g., "+1", "heart", "laugh")
     */
    emoji: string;

    /**
     * 反应人集合
     * Users who reacted
     */
    users: NexusBook.Api.Common.UserRef[];

    /**
     * 反应数量
     * Count of reactions
     */
    count: int32;
}

/**
 * 统一评论模型
 * Unified comment model
 *
 * 支持在文档任何位置进行评论，包括嵌套回复。
 * Supports commenting at any location in document, including nested replies.
 */
model Comment {
    /**
     * 评论唯一标识
     * Unique identifier of the comment
     */
    id: string;

    /**
     * 评论位置定位
     * Comment target location
     *
     * 指定评论在文档中的确切位置。
     * Specifies the exact location of the comment in the document.
     */
    target: CommentTarget;

    /**
     * 父评论ID（如果是回复）
     * Parent comment id (if this is a reply)
     *
     * 如果此评论是对另一条评论的回复，记录父评论ID。
     * If this comment is a reply to another, record the parent comment id.
     */
    parentId?: string;

    /**
     * 评论内容（支持富文本）
     * Comment content (rich text supported)
     *
     * 支持 Markdown 格式和 HTML 标签。
     * Supports Markdown format and HTML tags.
     */
    content: string;

    /**
     * @提及用户集合
     * Mentioned users
     *
     * 在评论中被 @提及的用户列表。
     * List of users mentioned in the comment.
     */
    mentions?: NexusBook.Api.Common.UserRef[];

    /**
     * 附件集合
     * Attachments
     *
     * 评论中附加的文件。
     * Files attached to the comment.
     */
    attachments?: NexusBook.Api.Common.Attachment[];

    /**
     * 表情反应集合
     * Emoji reactions
     *
     * 其他用户对此评论的表情反应。
     * Emoji reactions from other users to this comment.
     */
    reactions?: Reaction[];

    /**
     * 是否已解决
     * Resolved flag
     *
     * 标记此评论（及其讨论线程）是否已解决。
     * Mark if this comment (and its thread) is resolved.
     */
    resolved?: boolean;

    /**
     * 解决时间
     * Resolved at
     *
     * 评论解决的时间戳。
     * Timestamp when comment was resolved.
     */
    resolvedAt?: string;

    /**
     * 解决人
     * Resolved by
     *
     * 解决此评论的人。
     * Who resolved this comment.
     */
    resolvedBy?: NexusBook.Api.Common.UserRef;

    /**
     * 是否置顶
     * Pinned flag
     *
     * 重要评论可以置顶展示。
     * Important comments can be pinned.
     */
    pinned?: boolean;

    /**
     * 创建时间
     * Created at
     */
    createdAt?: string;

    /**
     * 创建人
     * Created by
     */
    createdBy?: NexusBook.Api.Common.UserRef;

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
     * 回复数量
     * Reply count
     *
     * 此评论下的直接回复数（不包括递归回复）。
     * Direct reply count to this comment (not recursive).
     */
    replyCount?: int32;
}

/**
 * 统一评论 API
 * Unified Comments API
 *
 * 支持在文档任何位置进行评论和讨论。通过 target 对象指定评论位置。
 * Supports commenting at any location in document. Specify location via target object.
 */
@route("/doc/{docType}/{docId}/comments")
@tag("Document - Collaboration")
interface CommentsApi {
    /**
     * 列出指定位置的评论
     *
     * List comments at specified location
     *
     * 支持按位置（文档/字段/行/单元格）过滤评论。
     * Supports filtering by location (document/field/row/cell).
     *
     * 查询参数示例:
     * - `scope=document` - 文档级评论
     * - `scope=field&fieldId=field-123` - 指定字段的评论
     * - `scope=row&rowId=row-456` - 指定行的评论
     * - `scope=cell&rowId=row-456&fieldId=field-123` - 指定单元格的评论
     * - `parentId=comment-789` - 指定评论的回复
     *
     * Query examples:
     * - `scope=document` - Document-level comments
     * - `scope=field&fieldId=field-123` - Comments on specific field
     * - `scope=row&rowId=row-456` - Comments on specific row
     * - `scope=cell&rowId=row-456&fieldId=field-123` - Comments on specific cell
     * - `parentId=comment-789` - Replies to specific comment
     */
    @get
    @summary("列出评论")
    listComments(
        @path docType: string,
        @path docId: string,
        @query scope?: string,
        @query fieldId?: string,
        @query rowId?: string,
        @query parentId?: string,
        @query page?: int32,
        @query pageSize?: int32,
    ): NexusBook.Api.Common.ApiResponse<NexusBook.Api.Common.Page<Comment>>;

    /**
     * 创建新评论
     *
     * Create new comment
     *
     * 在指定位置创建评论。如果是回复，需指定 parentId。
     * Create a comment at specified location. Specify parentId if it's a reply.
     *
     * 示例 - 创建文档级评论 (Document-level comment):
     * ```json
     * {
     *   "target": { "scope": "document" },
     *   "content": "这是一条文档级评论"
     * }
     * ```
     *
     * 示例 - 创建单元格评论 (Cell comment):
     * ```json
     * {
     *   "target": { "scope": "cell", "rowId": "row-1", "fieldId": "name" },
     *   "content": "这个单元格的数据看起来不对"
     * }
     * ```
     *
     * 示例 - 创建回复 (Reply to comment):
     * ```json
     * {
     *   "target": { "scope": "cell", "rowId": "row-1", "fieldId": "name" },
     *   "parentId": "comment-original-1",
     *   "content": "我同意，需要修正这个数据"
     * }
     * ```
     */
    @post
    @summary("创建评论")
    createComment(
        @path docType: string,
        @path docId: string,
        @body body: Comment,
    ): NexusBook.Api.Common.ApiResponse<Comment>;

    /**
     * 获取评论详情
     *
     * Get comment detail
     *
     * 包括所有回复和反应信息。
     * Includes all replies and reactions.
     */
    @route("/{commentId}")
    @get
    @summary("获取评论详情")
    getComment(
        @path docType: string,
        @path docId: string,
        @path commentId: string,
    ): NexusBook.Api.Common.ApiResponse<Comment>;

    /**
     * 更新评论
     *
     * Update comment
     *
     * 只有创建者或管理员可以编辑评论。
     * Only creator or admin can edit comment.
     */
    @route("/{commentId}")
    @put
    @summary("更新评论")
    updateComment(
        @path docType: string,
        @path docId: string,
        @path commentId: string,
        @body body: Comment,
    ): NexusBook.Api.Common.ApiResponse<Comment>;

    /**
     * 删除评论
     *
     * Delete comment
     *
     * 删除评论会同时删除其所有回复。
     * Deleting comment also deletes all its replies.
     */
    @route("/{commentId}")
    @delete
    @summary("删除评论")
    deleteComment(
        @path docType: string,
        @path docId: string,
        @path commentId: string,
    ): NexusBook.Api.Common.ApiResponse<unknown>;

    /**
     * 置顶评论
     *
     * Pin comment
     *
     * 将评论置顶，重要评论可以固定在顶部。
     * Pin important comments to the top.
     */
    @route("/{commentId}/pin")
    @post
    @summary("置顶评论")
    pinComment(
        @path docType: string,
        @path docId: string,
        @path commentId: string,
    ): NexusBook.Api.Common.ApiResponse<Comment>;

    /**
     * 取消置顶
     *
     * Unpin comment
     */
    @route("/{commentId}/unpin")
    @post
    @summary("取消置顶")
    unpinComment(
        @path docType: string,
        @path docId: string,
        @path commentId: string,
    ): NexusBook.Api.Common.ApiResponse<Comment>;

    /**
     * 标记为已解决
     *
     * Mark comment as resolved
     *
     * 标记评论及其讨论线程为已解决。
     * Mark comment and its discussion thread as resolved.
     */
    @route("/{commentId}/resolve")
    @post
    @summary("标记已解决")
    resolveComment(
        @path docType: string,
        @path docId: string,
        @path commentId: string,
    ): NexusBook.Api.Common.ApiResponse<Comment>;

    /**
     * 取消解决标记
     *
     * Unresolved comment
     */
    @route("/{commentId}/unresolve")
    @post
    @summary("取消已解决标记")
    unresolveComment(
        @path docType: string,
        @path docId: string,
        @path commentId: string,
    ): NexusBook.Api.Common.ApiResponse<Comment>;

    /**
     * 添加表情反应
     *
     * Add emoji reaction
     *
     * 在评论上添加表情反应（如 👍、❤️ 等）。
     * Add emoji reaction to comment (e.g. 👍, ❤️).
     */
    @route("/{commentId}/reactions")
    @post
    @summary("添加表情反应")
    addReaction(
        @path docType: string,
        @path docId: string,
        @path commentId: string,
        @query emoji: string,
    ): NexusBook.Api.Common.ApiResponse<Comment>;

    /**
     * 移除表情反应
     *
     * Remove emoji reaction
     */
    @route("/{commentId}/reactions/{emoji}")
    @delete
    @summary("移除表情反应")
    removeReaction(
        @path docType: string,
        @path docId: string,
        @path commentId: string,
        @path emoji: string,
    ): NexusBook.Api.Common.ApiResponse<Comment>;
}
