/**
 * 文档模块 (Document Module)
 *
 * 提供完整的文档管理功能，包括核心数据模型、内容协作、工作流和聚合查询。
 *
 * 模块结构：
 * - core/ - 核心数据模型（元数据、数据行、属性、视图、设置）
 * - content/ - 内容协作（评论）
 * - workflow/ - 工作流管理（审批、变更请求、修订历史）
 * - aggregate/ - 聚合查询
 * - relations/ - 文档间双向关联
 * - attachments/ - 附件管理
 * - sync/ - 数据同步
 * - realtime/ - 实时协作 (Yjs)
 * - tenant-document.tsp - 组织和工作区级文档支持
 *
 * 依赖关系：
 * - shared/index.tsp - 基础共享类型
 * - auth/index.tsp - 认证模型（可选）
 * - tenant/index.tsp - 租户模型
 */
import "./core/index.tsp";
import "./content/index.tsp";
import "./workflow/index.tsp";
import "./aggregate/index.tsp";
import "./relations/index.tsp";
import "./attachments/index.tsp";
import "./sync/index.tsp";
import "./realtime/index.tsp";
import "./tenant-document.tsp";
