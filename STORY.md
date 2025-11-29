# 一个基于 TypeSpec 的 API 接口定义

## 背景

一个供应链 SaaS 平台
* 支持 OAuth 2.0 认证
* 支持 RESTful API 接口
* 支持作为 OIDC 提供方
* 有一个抽象的文档概念用于处理核心的业务，包括
    * 元数据，可以理解为该文档的属性，比如一个订购单，就是订货单明细
    * 多视图
        * 过滤条件
        * 展示字段
        * 排序
        * 分组
    * 数据
        * 支持多种字段类型，参考现在的多维表格平台
        * 支持分页
        * 该文档的详细数据，可以 10 条，也可以 100 万条
    * 协同
        * 评论，可以在不同地方发生
            * 文档
            * 元数据字段
            * 数据行
            * 指定数据行的字段
        * 修订记录
        * 请求合并
        * 数据审批流（针对关键数据，可配置）
    * 多种呈现
        * 表格
        * 相册
        * 看板
        * 文档


# 技术需求
* 使用 TypeSpec 定义 API 接口
* 支持 OpenAPI 3.0 规范
* 支持 API 查看器
* 详细的文档注释支持中英语
* 所有的 API 都 /api/v1 开头

# 域名与路由约定

* API 基址：`https://open.nexusbook.com/api/v1`
* 认证基址：`https://auth.nexusbook.com`
* OIDC 发现：`https://auth.nexusbook.com/.well-known/openid-configuration`
* JWKS：`https://auth.nexusbook.com/jwks.json`

# 生成要求
* 命名空间为 NexusBook.Api 与 NexusBook.Auth
* 尽量按照模块设计，拆分成不同的文件
* 每个文件对应一个模块，文件名就是模块名
* 统一的 ApiResponse，基本上返回 200 状态码，在返回字段里定义

```json
{
    "success": false,
    "code": "BAD_USER_NAME",
    "message": {
        "zh": "错误消息",
        "en": "error message"
    },
    "payload": null
}
```
message 是一个多语言的错误消息，可以支持更多的语言，一般来说是根据 code 在后台翻译


payload 可以是实际业务的任何结构，对象、数组、数字、字符串等

* 所有的代码定义放在 api 目录下，入口为 main.tsp，业务定义放在 api/types 下，必要时候可以多级目录
* TypeSpec 模块建议拆分：common、auth、doc、metadata、views、data、comments、revisions、requests、approvals、settings
* 提供 makefile 
    * 生成 OpenAPI 文档（`dist/openapi.api.yaml` 与 `dist/openapi.auth.yaml`）
    * 查看 API 文档（预览查看器）
## Doc的设计思路

文档是一个业务逻辑的抽象，并不是一个真正的文档，比如
* 产品列表
* 采购订单列表
* 订货单列表

这是对于业务类型的基本抽象，也可以是一个
* 订购单
* 盘点单
* 收货单

所有的文档请求都是 /api/v1/doc 根据不同的 doc-type 来区分，不同的 `doc-type`应该是路由给不同的 Provider 来决定真正的文档如何加载，因此所有业务都是
* `/api/v1/doc/{doc-type}/{doc-id}` 作为 api
* 在这个 url 下会有
    * revision
    * views
    * comments
    * approval: 审批工作流
    * request: 未生效的合并请求
    * metadata: 文档元数据
    * settings: 该文档的个性化设置
    
* `/api/v1/doc/{doc-type}/setting` 是针对这个业务文档类型的公共配置