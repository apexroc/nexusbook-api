# 开发指南

本文档介绍如何使用 TypeSpec 开发和扩展 NexusBook API。

## 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| **TypeSpec** | 1.6.0 | API 定义语言 |
| **OpenAPI** | 3.0 | API 规范标准 |
| **Redocly** | 2.12.0 | API 文档生成 |
| **oapi-codegen** | latest | Go 代码生成 |
| **Go** | 1.21+ | 后端实现 |

## 前置要求

- Node.js 16+
- Go 1.21+ (可选，用于生成 Go 代码)
- Make

## 快速开始

### 安装依赖

```bash
# 安装 npm 依赖
make deps

# 或者手动安装
npm install
```

### 生成文档

```bash
# 生成 OpenAPI 规范
make openapi

# 构建 API 文档
make build-docs

# 构建完整文档站点
make docs

# 预览文档（浏览器访问 http://localhost:8091）
make serve
```

### 输出文件

| 文件 | 说明 |
|------|------|
| `dist/openapi/@typespec/openapi3/*.yaml` | OpenAPI 规范文件 |
| `dist/redoc/index.html` | Redoc 静态文档 |
| `docs/` | 完整文档站点（生成） |
| `docs-src/` | 文档源文件（Markdown） |
| `server/apigen/apigen.gen.go` | Go 服务端代码 |

## 项目命令

```bash
# 开发相关
make deps          # 安装依赖
make openapi       # 生成 OpenAPI 规范
make build-docs    # 构建 Redoc 文档
make serve-docs    # 预览 Redoc 文档（端口 8091）

# 文档站点
make docs          # 构建完整文档站点
make serve         # 启动文档服务器（端口 8091）
make clean-docs    # 清理生成的文档

# Go 相关
make generate-go   # 生成 Go 代码
make serve-go      # 启动 Go 服务器

# 清理
make clean         # 清理生成的文件
```

## 添加新模块

### 1. 创建模块目录

```bash
mkdir -p api/extensions/webhooks
```

### 2. 创建 TypeSpec 文件

```typescript
// api/extensions/webhooks/models.tsp
import "@typespec/http";
import "../../shared/index.tsp";

namespace NexusBook.Extensions.Webhooks {
  model Webhook {
    id: string;
    url: string;
    events: string[];
  }
  
  @route("/webhooks")
  interface WebhooksApi {
    @get list(): ApiResponse<Webhook[]>;
    @post create(@body webhook: Webhook): ApiResponse<Webhook>;
  }
}
```

### 3. 创建模块入口

```typescript
// api/extensions/webhooks/index.tsp
import "./models.tsp";
```

### 4. 在主入口引入

```typescript
// api/main.tsp
import "./extensions/webhooks/index.tsp";
```

### 5. 重新生成

```bash
make openapi
make docs
```

## 修改现有模块

1. **编辑对应的 .tsp 文件**
2. **运行 `make openapi` 重新生成 OpenAPI**
3. **运行 `make docs` 重新生成文档站点**
4. **运行 `make serve` 预览变更**

## 编辑文档

### 文档结构

```
docs-src/              # 文档源文件（提交到 Git）
├── guides/           # 开发指南
├── references/       # 参考文档
├── styles/           # 样式文件
├── README.md         # 文档说明
└── CONTRIBUTING.md   # 贡献指南

docs/                 # 生成的文档（不提交到 Git）
├── guides/           # 生成的指南 HTML
├── references/       # 生成的参考 HTML
├── styles/           # 复制的样式
├── api/              # Redoc API 文档
└── index.html        # 文档主页
```

### 添加新文档

1. **在 `docs-src/guides/` 或 `docs-src/references/` 创建 Markdown 文件**
2. **编辑 `scripts/build-docs.js`，添加文件到对应数组**
3. **运行 `make docs` 生成 HTML**

示例：

```javascript
// scripts/build-docs.js
const guides = [
  // ... 现有文档
  { file: 'my-new-guide', title: '新指南标题' }
];
```

## 代码生成

### 生成 Go 服务端代码

```bash
make generate-go
```

生成的代码位于 `server/apigen/apigen.gen.go`，包含：
- 所有数据模型的 Go 结构体
- Gin 路由处理器接口
- 请求/响应绑定

### 实现服务端

```go
// server/apigen/impl.go
package apigen

import "github.com/gin-gonic/gin"

type ServerImpl struct{}

func (s *ServerImpl) GetMetadata(c *gin.Context, docType string, docId string) {
  // 实现逻辑
  c.JSON(200, ApiResponse{
    Success: true,
    Payload: metadata,
  })
}
```

## 文档注释规范

### 使用中英文双语注释

```typescript
/**
 * 获取文档元数据
 *
 * Get document metadata
 *
 * 返回字段定义与显示配置，供渲染与校验使用。
 * Returns field definitions and display settings for rendering and validation.
 */
@get
@summary("获取文档元数据")
getMetadata(...): ApiResponse<Metadata>;
```

### 添加示例

```typescript
/**
 * 创建数据行
 *
 * Create data row
 *
 * 示例（cURL）:
 * ```bash
 * curl -X POST 'https://open.nexusbook.com/api/v1/doc/product/123/data?apply=true' \
 *   -H 'Authorization: Bearer TOKEN' \
 *   -H 'Content-Type: application/json' \
 *   -d '{"id":"row-1","values":[{"fieldId":"name","value":{"text":"新产品"}}]}'
 * ```
 */
```

## 测试 API

### 使用 curl

```bash
# 设置环境变量
export API_BASE="https://open.nexusbook.com/api/v1"
export TOKEN="your_access_token"

# 测试端点
curl -H "Authorization: Bearer $TOKEN" \
  "$API_BASE/doc/product/123/metadata"
```

### 使用 Postman

1. 导入生成的 OpenAPI 文件
2. 配置环境变量（base_url, token）
3. 测试各个端点

## 调试技巧

### 查看生成的 OpenAPI

```bash
# 查看 API 规范
cat dist/openapi/@typespec/openapi3/openapi.NexusBook.Api.yaml

# 使用 yq 格式化查看
yq eval dist/openapi/@typespec/openapi3/openapi.NexusBook.Api.yaml
```

### 验证 TypeSpec 语法

```bash
npx tsp compile api/main.tsp --no-emit
```

### 查看编译错误

TypeSpec 编译器会提供详细的错误信息，包括：
- 文件位置
- 错误类型
- 修复建议

## 常见问题

### Q: 如何添加新的错误码？

在 `api/shared/common.tsp` 中的 `ErrorCode` 枚举添加：

```typescript
enum ErrorCode {
  // ... 现有错误码
  NEW_ERROR_CODE,  // 新错误码
}
```

### Q: 如何添加新的字段类型？

1. 在 `api/shared/constants.tsp` 的 `FieldType` 枚举添加
2. 在 `api/shared/common.tsp` 的 `Value` union 添加对应类型
3. 重新生成 OpenAPI

### Q: 如何修改响应格式？

修改 `api/shared/common.tsp` 中的 `ApiResponse` 模型，但建议保持向后兼容。

### Q: 生成的 Go 代码如何使用？

参考 `server/apigen/impl.go` 和 `cmd/server/main.go` 中的示例实现。

### Q: 如何调试 TypeSpec 编译错误？

1. 检查导入路径是否正确
2. 确认所有引用的类型都已定义
3. 使用 `--trace` 选项查看详细信息：
   ```bash
   npx tsp compile api/main.tsp --trace
   ```

### Q: 如何优化 OpenAPI 文档生成？

1. 添加详细的 `@summary` 和 `@doc` 注释
2. 使用 `@example` 提供示例
3. 为模型字段添加描述
4. 使用 `@deprecated` 标记废弃的 API

### Q: 文档站点样式丢失怎么办？

确保 `docs-src/styles/main.css` 存在，然后运行：
```bash
make docs
```

## TypeSpec 最佳实践

### 1. 模块组织

- 按功能划分模块（core, content, workflow）
- 每个模块有独立的 `index.tsp` 入口
- 相关的模型和接口放在一起

### 2. 命名规范

- **Model 名称**: PascalCase（如 `DataRow`, `Metadata`）
- **Interface 名称**: PascalCase + Api 后缀（如 `DataApi`, `ViewsApi`）
- **字段名称**: camelCase（如 `fieldId`, `createdAt`）
- **枚举值**: UPPER_SNAKE_CASE（如 `DOC_NOT_FOUND`）

### 3. 类型复用

```typescript
// 定义可复用的类型
model PageRequest {
  page?: int32 = 1;
  pageSize?: int32 = 20;
}

// 在接口中使用
@get list(...PageRequest): ApiResponse<DataRow[]>;
```

### 4. 错误处理

所有接口统一返回 `ApiResponse<T>` 类型：

```typescript
@get
getMetadata(): ApiResponse<Metadata>;
```

### 5. 版本控制

- 在路径中包含版本号：`/api/v1`
- 重大变更时增加版本号
- 保持向后兼容性

### 6. 文档注释

```typescript
/**
 * 中文说明
 * 
 * English description
 */
@summary("简短摘要")
@doc("详细说明")
```

## 扩展建议

### 添加新的文档类型

1. 实现对应的 Provider 接口
2. 注册到路由系统
3. 无需修改 TypeSpec 定义

### 添加新的字段类型

1. 在 `FieldType` 枚举添加新类型
2. 在 `Value` union 添加对应的值类型
3. 更新字段类型文档

### 添加新的视图类型

1. 在 `ViewType` 枚举添加新类型
2. 定义视图配置模型
3. 实现前端渲染逻辑

### 添加新的事件类型

1. 在 Webhook 事件枚举添加
2. 定义事件载荷结构
3. 实现事件触发逻辑

## 贡献指南

### 提交代码

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交变更 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范

- 遵循现有的代码风格
- 添加适当的注释（中英文）
- 更新相关文档
- 确保 TypeSpec 编译通过

### 提交信息规范

```
type(scope): subject

body

footer
```

**类型：**
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式
- `refactor`: 重构
- `test`: 测试
- `chore`: 构建/工具

**示例：**
```
feat(api): 添加 Webhook 支持

- 添加 Webhook 管理接口
- 支持 20+ 种事件类型
- 实现 HMAC 签名验证

Closes #123
```

## 下一步

- 查看 [架构设计](./architecture.md) 了解系统架构
- 查看 [API 参考](../references/api-reference.md) 了解所有端点
- 查看 [最佳实践](./best-practices.md) 了解使用建议
