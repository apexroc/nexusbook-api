/**
 * OrderBook 模块 (OrderBook Module)
 *
 * 提供采购商订货本管理功能。
 * Provides buyer orderbook management.
 *
 * 模块结构:
 * - models.tsp - OrderBook 数据模型
 * - api.tsp - OrderBook API 接口
 *
 * 核心功能:
 * - 组织级别的 OrderBook 创建和管理
 * - 支持多 Workspace 共享
 * - 接收多个 Connection 的数据
 * - 可作为 Catalog 继续分享
 * - 行级来源追踪
 */
import "./models.tsp";
import "./api.tsp";
