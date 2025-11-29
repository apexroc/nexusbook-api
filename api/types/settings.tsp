import "@typespec/http";
import "@typespec/openapi3";
import "../types/common.tsp";

using TypeSpec.Http;
using OpenAPI;

namespace NexusBook.Api.Document;

model Settings {
  /// 默认视图ID Default view id
  defaultViewId?: string;
  sharing?: {
    /// 公共链接开关 Public link enabled
    publicLinkEnabled?: boolean;
    /// 分享密码 Password
    password?: string;
  };
  /// 权限策略 Permissions policy
  permissions?: unknown;
  retention?: {
    revisions?: {
      /// 最大修订条数 Max revision count
      maxCount?: int32;
      /// 最大保留天数 Max retention days
      maxDays?: int32;
    };
  };
}

@route("/doc/{docType}/{docId}/settings")
@tag("Document")
interface DocSettingsApi {
  @get
  @summary("文档设置")
  @doc("""
  获取文档级设置。

  Get doc-level settings.
  """
  )
  op getDocSettings(@path docType: string, @path docId: string): NexusBook.Common.ApiResponse<Settings>;

  @put
  @summary("更新文档设置")
  @doc("""
  更新文档级设置。

  Update doc-level settings.
  """
  )
  op putDocSettings(@path docType: string, @path docId: string, @body body: Settings): NexusBook.Common.ApiResponse<Settings>;
}

@route("/doc/{docType}/setting")
@tag("Document")
interface TypeSettingsApi {
  @get
  @summary("类型设置")
  @doc("""
  获取文档类型公共设置。

  Get type-level settings.
  """
  )
  op getTypeSetting(@path docType: string): NexusBook.Common.ApiResponse<Settings>;

  @put
  @summary("更新类型设置")
  @doc("""
  更新文档类型公共设置。

  Update type-level settings.
  """
  )
  op putTypeSetting(@path docType: string, @body body: Settings): NexusBook.Common.ApiResponse<Settings>;
}
