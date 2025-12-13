/**
 * Connector 模块 (Connector Module)
 *
 * 提供组织内部文档联动功能。
 * Provides intra-organization document linkage.
 *
 * 模块结构:
 * - models.tsp - Connector 数据模型
 * - api.tsp - Connector API 接口
 *
 * 核心功能:
 * - Catalog 复制与联动
 * - OrderBook 转 Catalog
 * - 行级联动追踪
 * - 字段转换和聚合
 * - 同步触发管理
 */
import "./models.tsp";
import "./api.tsp";
