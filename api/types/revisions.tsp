import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 修订历史模块
 *
 * 完整的版本控制和变更追踪功能。
 *
 * 主要功能：
 * - **修订记录** - 记录所有文档变更
 * - **版本对比** - 比较不同版本之间的差异
 * - **回滚操作** - 回滚到任意历史版本
 * - **审计追踪** - 完整的操作记录和操作人信息
 * - **变更详情** - 详细的变更内容和时间戳
 *
 * ## 使用场景
 *
 * - 审计合规 - 完整的变更记录满足审计要求
 * - 错误恢复 - 快速回滚错误操作
 * - 变更追踪 - 追踪特定字段或行的变更历史
 * - 版本管理 - 支持多版本并行管理
 */
namespace NexusBook.Api;

model Revision {
  /**
   * 修订ID
   * Revision id
   */
  id: string;

  /**
   * 作者
   * Author
   */
  author?: string;

  /**
   * 创建时间
   * Created at
   */
  createdAt?: string;

  /**
   * 变更集合
   * Changes
   */
  changes?: unknown[];
}

@route("/doc/{docType}/{docId}/revisions")
@tag("Document")
interface RevisionsApi {
  /**
   * 列出文档的修订记录。
   *
   * List revisions of the document.
   */
  @get
  @summary("列出修订记录")
  listRevisions(
    @path docType: string,
    @path docId: string,
  ): NexusBook.Common.ApiResponse<Revision[]>;

  /**
   * 获取指定修订的详情。
   *
   * Get detail of specified revision.
   */
  @route("/{revId}")
  @get
  @summary("获取修订详情")
  getRevision(
    @path docType: string,
    @path docId: string,
    @path revId: string,
  ): NexusBook.Common.ApiResponse<Revision>;

  /**
   * 比较两个修订之间的差异。
   *
   * Compare diffs between two revisions.
   */
  @route("/{revId}/diff")
  @get
  @summary("查看修订差异")
  getRevisionDiff(
    @path docType: string,
    @path docId: string,
    @path revId: string,
    @query base?: string,
  ): NexusBook.Common.ApiResponse<unknown>;

  /**
   * 回滚到指定修订，会创建新的修订记录。
   *
   * Revert to specified revision, creates a new revision.
   */
  @route("/{revId}/revert")
  @post
  @summary("回滚修订")
  revertRevision(
    @path docType: string,
    @path docId: string,
    @path revId: string,
  ): NexusBook.Common.ApiResponse<Revision>;
}
