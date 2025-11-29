import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

namespace NexusBook.Api.Document;

enum ViewType {
  grid,
  gallery,
  kanban,
  document,
}

model View {
  @doc("视图唯一标识。\nUnique identifier of the view.")
  /// 视图ID View id
  id: string;
  @doc("视图显示名称。\nDisplay name of the view.")
  /// 视图名称 View name
  name: string;
  @doc("视图类型（表格/相册/看板/文档）。\nView type (grid/gallery/kanban/document).")
  /// 视图类型 View type
  type?: ViewType;
  @doc("用于渲染的字段列表。\nField list used for rendering.")
  /// 显示字段 Display fields
  displayFields?: string[];
  @doc("过滤条件组合。\nFilter conditions group.")
  /// 过滤器 Filters
  filters?: NexusBook.Common.FilterGroup;
  @doc("排序条件。\nSort conditions.")
  /// 排序 Sorts
  sorts?: NexusBook.Common.Sort[];
  @doc("分组与聚合。\nGrouping and aggregations.")
  /// 分组 Grouping
  group?: NexusBook.Common.GroupBy;
  @doc("列展示配置（宽度/顺序/固定/隐藏）。\nColumn display configuration (width/order/pinned/hidden).")
  /// 列配置 Column config
  columnConfig?: {
    /// 列宽 Widths
    width?: { fieldId: string; width: int32 }[];
    /// 列顺序 Order
    order?: string[];
    /// 固定列 Pinned
    pinned?: string[];
    /// 隐藏列 Hidden
    hidden?: string[];
  };
}

@route("/doc/{docType}/{docId}/views")
@tag("Document")
interface ViewsApi {
  @get
  @summary("列出视图")
  @doc("""
  返回指定文档的视图列表。

  List all views of the document.
  """
  )
  op listViews(@path docType: string, @path docId: string): NexusBook.Common.ApiResponse<View[]>;

  @post
  @summary("创建视图")
  @doc("""
  创建新的视图定义。

  Create a new view.
  """
  )
  op createView(@path docType: string, @path docId: string, @body body: View): NexusBook.Common.ApiResponse<View>;

  @route("/{viewId}")
  @get
  @summary("获取视图详情")
  @doc("""
  获取视图配置与定义。

  Get view definition and configuration.
  """
  )
  op getView(@path docType: string, @path docId: string, @path viewId: string): NexusBook.Common.ApiResponse<View>;

  @route("/{viewId}")
  @put
  @summary("更新视图")
  @doc("""
  更新视图定义与配置。

  Update view definition and configuration.
  """
  )
  op updateView(@path docType: string, @path docId: string, @path viewId: string, @body body: View): NexusBook.Common.ApiResponse<View>;

  @route("/{viewId}")
  @delete
  @summary("删除视图")
  @doc("""
  删除指定视图。

  Delete specified view.
  """
  )
  op deleteView(@path docType: string, @path docId: string, @path viewId: string): NexusBook.Common.ApiResponse<unknown>;

  @route("/{viewId}/default")
  @post
  @summary("设为默认视图")
  @doc("""
  将指定视图设为默认视图。

  Set specified view as default.
  """
  )
  op setDefaultView(@path docType: string, @path docId: string, @path viewId: string): NexusBook.Common.ApiResponse<unknown>;
}
