/**
 * 文档工作流模块 (Workflow Module)
 *
 * 提供文档变更工作流、审批流程和修订历史管理。
 *
 * 模块结构：
 * - approvals.tsp - 审批流程和决策
 * - requests.tsp - 变更请求（类似 Pull Request）
 * - revisions.tsp - 修订历史和版本追踪
 *
 * 依赖关系：
 * - shared/index.tsp - 基础共享类型
 */
import "./approvals.tsp";
import "./requests.tsp";
import "./revisions.tsp";
