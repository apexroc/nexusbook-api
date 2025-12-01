import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 视图模块
 *
 * 支持多种数据展示方式和视图配置。
 *
 * 主要功能：
 * - **视图类型** - 表格（Grid）、相册（Gallery）、看板（Kanban）、文档（Document）
 * - **视图配置** - 字段显示、过滤、排序、分组设置
 * - **列配置** - 列宽、顺序、固定和隐藏设置
 * - **视图管理** - 创建、编辑、删除和设置默认视图
 *
 * ## 视图类型
 *
 * - `grid` - 表格视图，适合数据浏览和编辑
 * - `gallery` - 相册视图，适合图片类数据展示
 * - `kanban` - 看板视图，适合工作流和进度管理
 * - `document` - 文档视图，适合详细内容查看
 */
namespace NexusBook.Api;

enum ViewType {
  grid,
  gallery,
  kanban,
  document,
}

model View {
  /**
   * 视图唱一标识
   * Unique identifier of the view
   */
  id: string;

  /**
   * 视图显示名称
   * Display name of the view
   */
  name: string;

  /**
   * 视图类型（表格/相册/看板/文档）
   * View type (grid/gallery/kanban/document)
   */
  type?: ViewType;

  /**
   * 用于渲染的字段列表
   * Field list used for rendering
   */
  displayFields?: string[];

  /**
   * 过滤条件组合
   * Filter conditions group
   */
  filters?: NexusBook.Common.FilterGroup;

  /**
   * 排序条件
   * Sort conditions
   */
  sorts?: NexusBook.Common.Sort[];

  /**
   * 分组与聚合
   * Grouping and aggregations
   */
  group?: NexusBook.Common.GroupBy;

  /**
   * 列展示配置（宽度/顺序/固定/隐藏）
   * Column display configuration (width/order/pinned/hidden)
   */
  columnConfig?: {
    width?: {
      fieldId: string;
      width: int32;
    }[];
    order?: string[];
    pinned?: string[];
    hidden?: string[];
  };
}

@route("/doc/{docType}/{docId}/views")
@tag("Document")
interface ViewsApi {
  /**
   * 返回指定文档的视图列表。
   *
   * List all views of the document.
   */
  @get
  @summary("列出视图")
  listViews(
    @path docType: string,
    @path docId: string,
  ): NexusBook.Common.ApiResponse<View[]>;

  /**
   * 创建新的视图定义。
   *
   * Create a new view.
   */
  @post
  @summary("创建视图")
  createView(
    @path docType: string,
    @path docId: string,
    @body body: View,
  ): NexusBook.Common.ApiResponse<View>;

  /**
   * 获取视图配置与定义。
   *
   * Get view definition and configuration.
   */
  @route("/{viewId}")
  @get
  @summary("获取视图详情")
  getView(
    @path docType: string,
    @path docId: string,
    @path viewId: string,
  ): NexusBook.Common.ApiResponse<View>;

  /**
   * 更新视图定义与配置。
   *
   * Update view definition and configuration.
   */
  @route("/{viewId}")
  @put
  @summary("更新视图")
  updateView(
    @path docType: string,
    @path docId: string,
    @path viewId: string,
    @body body: View,
  ): NexusBook.Common.ApiResponse<View>;

  /**
   * 删除指定视图。
   *
   * Delete specified view.
   */
  @route("/{viewId}")
  @delete
  @summary("删除视图")
  deleteView(
    @path docType: string,
    @path docId: string,
    @path viewId: string,
  ): NexusBook.Common.ApiResponse<unknown>;

  /**
   * 将指定视图设为默认视图。
   *
   * Set specified view as default.
   */
  @route("/{viewId}/default")
  @post
  @summary("设为默认视图")
  setDefaultView(
    @path docType: string,
    @path docId: string,
    @path viewId: string,
  ): NexusBook.Common.ApiResponse<unknown>;
}
