/**
 * 文档核心模块 (Core Module)
 *
 * 提供文档的核心数据管理功能，包括元数据、数据行、属性、视图和设置。
 *
 * 模块结构：
 * - metadata.tsp - 字段定义和元数据管理
 * - data.tsp - 结构化数据行管理
 * - properties.tsp - 文档属性和元信息管理
 * - views.tsp - 多视图和展示配置
 * - settings.tsp - 文档和类型级设置
 *
 * 依赖关系：
 * - shared/index.tsp - 基础共享类型
 */
import "./metadata.tsp";
import "./data.tsp";
import "./properties.tsp";
import "./views.tsp";
import "./settings.tsp";
