# API 文档组织优化总结

## ✅ 已完成的优化（方案 A）

### 📊 优化前后对比

| 项目 | 优化前 | 优化后 |
|------|--------|--------|
| **顶级分组** | 3 个 | 3 个 |
| **Document 子分组** | 14 个 | **10 个** ⬇️ |
| **总体结构** | 过于细碎 | 清晰合理 |

---

## 🎯 新的 API 文档结构

### 三大顶级分组

```
1. Foundation (基础) - 5 个 API 标签
   ├─ Users
   ├─ Organizations
   ├─ Workspaces
   ├─ Invitations
   └─ Join Requests

2. Document (文档) - 10 个 API 标签
   ├─ Document - Core          【聚合查询、元数据、设置】
   ├─ Document - Data          【数据行 CRUD、查询】
   ├─ Document - Views         【视图管理】
   ├─ Document - Properties    【文档属性】
   ├─ Document - Relations     【文档关联】
   ├─ Document - Attachments   【附件管理】
   ├─ Document - Sync          【数据同步】
   ├─ Document - Collaboration 【评论 + 实时协作】✨ 合并
   ├─ Document - Workflow      【审批 + 请求 + 修订】
   └─ Document - Tenancy       【组织/工作区级文档】✨ 合并

3. Auth (认证) - 1 个 API 标签
   └─ Auth
```

---

## 🔧 修改详情

### 1. 脚本优化 (`scripts/add-tag-groups.js`)

**变更内容**:
- ✅ 减少 Document 子分组从 14 个到 10 个
- ✅ 合并 "Content" + "Realtime" → "Collaboration"
- ✅ 合并 "Organization Documents" + "Workspace Documents" → "Tenancy"
- ✅ 更新 tag 映射规则
- ✅ 简化 tag 描述

**新的 tag 映射**:
```javascript
const tagMapping = {
  'Document': 'Document - Core',              // 聚合查询映射到 Core
  'Attachments': 'Document - Attachments',     // 附件管理
  'Realtime': 'Document - Collaboration',      // 实时协作合并到协作
  'Organization Documents': 'Document - Tenancy',  // 组织文档合并到租户
  'Workspace Documents': 'Document - Tenancy'      // 工作区文档合并到租户
};
```

---

### 2. TypeSpec 文件标签优化

修改了以下文件的 `@tag` 标注：

#### Core 模块
- ✅ `core/settings.tsp`: `@tag("Document")` → `@tag("Document - Core")`
- ✅ `core/metadata.tsp`: `@tag("Document")` → `@tag("Document - Core")`
- ✅ `core/data.tsp`: `@tag("Document")` → `@tag("Document - Data")`
- ✅ `core/views.tsp`: `@tag("Document")` → `@tag("Document - Views")`
- ✅ `core/properties.tsp`: `@tag("Document")` → `@tag("Document - Properties")`

#### 其他模块
- ✅ `aggregate/index.tsp`: `@tag("Document")` → `@tag("Document - Core")`
- ✅ `relations/index.tsp`: `@tag("Document")` → `@tag("Document - Relations")`
- ✅ `sync/index.tsp`: `@tag("Document")` → `@tag("Document - Sync")`
- ✅ `content/comments.tsp`: `@tag("Document")` → `@tag("Document - Collaboration")`

#### Workflow 模块
- ✅ `workflow/approvals.tsp`: `@tag("Document")` → `@tag("Document - Workflow")`
- ✅ `workflow/requests.tsp`: `@tag("Document")` → `@tag("Document - Workflow")`
- ✅ `workflow/revisions.tsp`: `@tag("Document")` → `@tag("Document - Workflow")`

---

### 3. Makefile 构建流程优化

**问题**: Redocly join 遇到多个文件有相同 tag 名称时会报冲突

**解决方案**: 添加 `--without-x-tag-groups` 选项

**修改内容**:
```makefile
# build-docs 目标
npx redocly join $$FILES --without-x-tag-groups -o dist/openapi/openapi.yaml && \
node scripts/add-tag-groups.js dist/openapi/openapi.yaml && \
npx redocly build-docs dist/openapi/openapi.yaml --output dist/redoc/index.html;

# generate-go 目标
npx redocly join $$FILES --without-x-tag-groups -o $$TARGET && \
oapi-codegen -generate types,gin -package apigen -o server/apigen/apigen.gen.go $$TARGET;
```

---

### 4. 清理无用文件夹

- ✅ 删除空文件夹 `api/document/operations/`

---

## 📈 优化效果

### ✅ 优点

1. **更简洁**: 从 14 个子分组减少到 10 个
2. **更清晰**: 逻辑分组更合理
   - "Collaboration" 合并了评论和实时协作，语义更统一
   - "Tenancy" 合并了组织和工作区级文档，突出多租户特性
3. **更易用**: 用户查找 API 更快捷
4. **无侵入**: 无需修改 API 路由，仅调整标签

### 📊 合并的模块

| 原标签 | 新标签 | 包含的功能 |
|--------|--------|-----------|
| Document - Content<br>Document - Realtime | **Document - Collaboration** | 评论<br>实时协作（Yjs）<br>在线用户<br>单元格锁定 |
| Organization Documents<br>Workspace Documents | **Document - Tenancy** | 组织级文档聚合<br>工作区级文档聚合<br>多租户文档管理 |

---

## 🎨 最终文档结构

在 Redoc 文档左侧导航栏中，用户将看到：

```
📚 API Reference

▼ Foundation (基础)
  · Users
  · Organizations
  · Workspaces
  · Invitations
  · Join Requests

▼ Document (文档)
  · Core          - 聚合查询、元数据、设置
  · Data          - 数据行 CRUD
  · Views         - 视图管理
  · Properties    - 文档属性
  · Relations     - 文档关联
  · Attachments   - 附件管理
  · Sync          - 数据同步
  · Collaboration - 评论 + 实时协作
  · Workflow      - 审批 + 请求 + 修订
  · Tenancy       - 多租户文档

▼ Auth (认证)
  · Auth - OAuth2 & OIDC
```

---

## 🔍 路由设计说明

### ✅ 路由一致性

大部分 Document API 遵循统一路由模式：
```
/doc/{docType}/{docId}/metadata
/doc/{docType}/{docId}/data
/doc/{docType}/{docId}/views
/doc/{docType}/{docId}/properties
/doc/{docType}/{docId}/relations
/doc/{docType}/{docId}/sync
/doc/{docType}/{docId}/comments
/doc/{docType}/{docId}/requests
/doc/{docType}/{docId}/revisions
/doc/{docType}/{docId}/approval
```

### ⚠️ 特殊路由（保留现状）

以下模块使用特殊路由模式，**暂不修改**：

1. **Attachments** - 全局路由
   ```
   /attachments/upload
   /attachments/{id}
   /attachments/quota/{orgId}
   ```
   **原因**: 附件可能跨文档共享，全局路由更合理

2. **Realtime** - 独立服务前缀
   ```
   /realtime/doc/{docType}/{docId}/connect
   /realtime/doc/{docType}/{docId}/users
   ```
   **原因**: Realtime 是独立的 WebSocket 服务，独立前缀有其合理性

---

## 📝 待优化项（未来）

如果需要进一步统一路由风格，可以考虑：

1. **Attachments 路由重构**
   ```
   /doc/{docType}/{docId}/attachments       ← 文档级附件
   /attachments/{id}                        ← 保留全局操作
   ```

2. **Realtime 路由重构**
   ```
   /doc/{docType}/{docId}/realtime/connect
   /doc/{docType}/{docId}/realtime/users
   ```

**权衡**: 这需要修改大量代码，当前优先级不高

---

## ✅ 验证清单

- [x] TypeSpec 编译成功（0 errors, 6 warnings）
- [x] OpenAPI 文件生成成功
- [x] x-tagGroups 正确添加（3 大分组，Document 10 个子分组）
- [x] Redoc 文档生成成功
- [x] 文档站点构建成功
- [x] 本地文档服务启动（http://localhost:8091）
- [x] 删除空文件夹 `operations/`

---

## 🎉 总结

本次优化成功实现了**方案 A（功能领域分组）**，将 Document 模块从 14 个子分组优化到 10 个，结构更清晰合理。

**核心优化**:
- ✅ 合并相关功能模块（Collaboration、Tenancy）
- ✅ 统一 tag 命名规范
- ✅ 无需修改 API 路由
- ✅ 保持向后兼容

**用户体验提升**:
- 📖 文档导航更简洁
- 🔍 API 查找更快捷
- 🎯 功能分类更合理

---

**文档访问**: http://localhost:8091/api/
**完整分析**: `api/document/API_ORGANIZATION_REVIEW.md`
