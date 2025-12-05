# Document API 组织结构 Review

## 📊 当前 API 分组概览

### 1. Foundation (基础) ✅
```
- Users (用户管理)
- Organizations (组织管理)
- Workspaces (工作区管理)
- Invitations (邀请管理)
- Join Requests (加入申请)
```
**评价**: ✅ 组织合理，职责清晰

---

### 2. Document (文档) - 需要优化

#### 📁 当前子分组（14个标签）

```
Document (文档)
├─ Document - Core          ← 聚合查询
├─ Document - Data          ← 数据行 CRUD
├─ Document - Views         ← 视图管理
├─ Document - Properties    ← 文档属性
├─ Document - Settings      ← 文档设置
├─ Document - Relations     ← 文档关联
├─ Document - Attachments   ← 附件管理
├─ Document - Sync          ← 数据同步
├─ Document - Realtime      ← 实时协作
├─ Document - Content       ← 评论
├─ Document - Workflow      ← 审批+请求+修订
├─ Document - Aggregate     ← (重复？)
├─ Organization Documents   ← 组织级文档
└─ Workspace Documents      ← 工作区级文档
```

---

## 🔍 问题分析

### ❌ 问题 1: 路由不一致

#### 问题：Attachments 和 Realtime 的路由与其他模块不一致

**其他模块的路由模式**:
```
/doc/{docType}/{docId}/metadata      ← 一致
/doc/{docType}/{docId}/views         ← 一致
/doc/{docType}/{docId}/data          ← 一致
/doc/{docType}/{docId}/properties    ← 一致
/doc/{docType}/{docId}/relations     ← 一致
/doc/{docType}/{docId}/sync          ← 一致
/doc/{docType}/{docId}/comments      ← 一致
/doc/{docType}/{docId}/requests      ← 一致
/doc/{docType}/{docId}/revisions     ← 一致
```

**不一致的模块**:
```
/attachments                         ← ❌ 全局路由，不是文档级
/realtime/doc/{docType}/{docId}/*    ← ❌ 前缀不同
```

**影响**:
- ❌ API 风格不统一
- ❌ 用户心智负担增加
- ❌ 不符合 RESTful 资源嵌套原则

---

### ❌ 问题 2: 标签分组过细

**当前**: 14 个子标签，在 Redoc 中展开太长

**建议**: 合并为更合理的逻辑分组

---

### ❌ 问题 3: "Document - Core" 和 "Document - Aggregate" 概念重叠

**Document - Core** 的 API：
```
GET /doc/{docType}/{docId}  ← 聚合查询（支持 include 参数）
```

**Document - Aggregate** 可能会让人误以为是另一个聚合 API

**建议**: 
- 保留 "Document - Core" 作为聚合查询
- 移除 "Document - Aggregate" 标签

---

## ✅ 优化建议

### 方案 A: 按功能领域分组（推荐）

```
Foundation (基础)
├─ Users
├─ Organizations
├─ Workspaces
├─ Invitations
└─ Join Requests

Document (文档)
├─ Document Core          ← 聚合查询、元数据、设置
├─ Document Data          ← 数据行 CRUD、查询、批量操作
├─ Document Views         ← 视图管理
├─ Document Properties    ← 文档属性
├─ Document Relations     ← 文档关联
├─ Document Attachments   ← 附件管理
├─ Document Sync          ← 数据同步
├─ Document Collaboration ← 评论、实时协作
├─ Document Workflow      ← 审批、变更请求、修订
└─ Document Tenancy       ← 组织级、工作区级文档

Auth (认证)
└─ Auth
```

**优点**:
- ✅ 从 14 个减少到 10 个子分组
- ✅ 逻辑更清晰：Core、Data、Collaboration、Workflow
- ✅ "Collaboration" 合并了评论和实时协作

---

### 方案 B: 按使用频率分组

```
Document (文档)
├─ Essentials          ← 核心必需 (聚合、元数据、数据、视图)
├─ Collaboration       ← 协作功能 (评论、实时、附件)
├─ Workflow            ← 工作流 (请求、审批、修订)
├─ Advanced            ← 高级功能 (关联、同步、属性、设置)
└─ Multi-tenancy       ← 多租户 (组织/工作区级文档)
```

**优点**:
- ✅ 仅 5 个子分组，最简洁
- ✅ 适合不同用户层次

**缺点**:
- ❌ 分类标准较主观

---

### 方案 C: 扁平化（最激进）

```
Foundation (基础)
├─ Users
├─ Organizations
├─ Workspaces
├─ Invitations
└─ Join Requests

Document (文档)  ← 所有 Document API 合并到一个分组
├─ 聚合查询
├─ 元数据管理
├─ 数据行管理
├─ 视图管理
├─ 属性管理
... (所有端点扁平展示)

Auth (认证)
└─ Auth
```

**优点**:
- ✅ 最简单，只有 3 个顶级分组

**缺点**:
- ❌ Document 下的端点太多，不易查找
- ❌ 失去了逻辑层次

---

## 🎯 推荐方案

### 推荐：**方案 A（功能领域分组）**

#### 实施建议

**1. 修改 tag 映射**

```javascript
// scripts/add-tag-groups.js

const tagMapping = {
  'Document': 'Document - Core',           // 聚合查询
  'Attachments': 'Document - Attachments', // 附件
  'Realtime': 'Document - Collaboration',  // 合并到协作
};
```

**2. 新的分组结构**

```yaml
x-tagGroups:
  - name: Foundation (基础)
    tags:
      - Users
      - Organizations
      - Workspaces
      - Invitations
      - Join Requests
      
  - name: Document (文档)
    tags:
      - Document - Core          # 聚合查询、元数据、设置
      - Document - Data          # 数据行 CRUD
      - Document - Views         # 视图管理
      - Document - Properties    # 文档属性
      - Document - Relations     # 文档关联
      - Document - Attachments   # 附件管理
      - Document - Sync          # 数据同步
      - Document - Collaboration # 评论 + 实时协作
      - Document - Workflow      # 审批 + 请求 + 修订
      - Document - Tenancy       # 组织/工作区级文档
      
  - name: Auth (认证)
    tags:
      - Auth
```

**3. Tag 细分**

| 新 Tag | 包含的接口 | 模块文件 |
|--------|-----------|---------|
| Document - Core | 聚合查询、元数据、设置 | aggregate/, core/metadata.tsp, core/settings.tsp |
| Document - Data | 数据行 CRUD、查询、批量操作 | core/data.tsp |
| Document - Views | 视图管理 | core/views.tsp |
| Document - Properties | 文档属性 | core/properties.tsp |
| Document - Relations | 文档关联 | relations/ |
| Document - Attachments | 附件管理 | attachments/ |
| Document - Sync | 数据同步 | sync/ |
| Document - Collaboration | 评论 + 实时协作 | content/comments.tsp + realtime/ |
| Document - Workflow | 审批 + 变更请求 + 修订 | workflow/ |
| Document - Tenancy | 组织/工作区文档 | tenant-document.tsp |

---

## 🔧 需要重构的问题

### 1. Attachments 路由重构（可选）

**当前**:
```
/attachments/upload
/attachments/{id}
/attachments/quota/{orgId}
```

**建议**（如果要保持一致性）:
```
/doc/{docType}/{docId}/attachments       ← 文档级附件
/attachments/{id}                        ← 全局附件操作（保留）
/organizations/{orgId}/attachments/quota ← 配额
```

**权衡**:
- ✅ 保持路由一致性
- ❌ 需要重构代码
- ⚠️ 附件本身可能是跨文档共享的，全局路由也合理

**建议**: **暂不修改**，在文档中说明附件是全局资源

---

### 2. Realtime 路由重构（可选）

**当前**:
```
/realtime/doc/{docType}/{docId}/connect
/realtime/doc/{docType}/{docId}/users
```

**建议**:
```
/doc/{docType}/{docId}/realtime/connect   ← 改为文档级
/doc/{docType}/{docId}/realtime/users
```

**权衡**:
- ✅ 路由风格统一
- ❌ 需要重构代码
- ⚠️ Realtime 是独立服务，`/realtime` 前缀也有其合理性

**建议**: **暂不修改**，在文档中说明 realtime 是独立服务

---

## 📋 实施清单

### 立即执行（无需代码改动）

- [x] 合并 "Document - Content" 为 "Document - Collaboration"
- [x] 将 "Realtime" 标签映射到 "Document - Collaboration"
- [x] 合并 "Organization Documents" + "Workspace Documents" 为 "Document - Tenancy"
- [x] 移除 "Document - Aggregate" 重复概念
- [x] 从 14 个子分组优化到 10 个

### 未来优化（需要代码改动）

- [ ] 统一 Attachments 路由到 `/doc/{docType}/{docId}/attachments`
- [ ] 统一 Realtime 路由到 `/doc/{docType}/{docId}/realtime`
- [ ] 添加 `/doc/{docType}/{docId}/collaborators` 管理协作者

---

## 🎨 最终效果预览

```
📚 API 文档结构

Foundation (基础)
  └─ 5 个基础管理 API

Document (文档)
  ├─ Core          聚合查询、元数据、设置
  ├─ Data          数据行管理
  ├─ Views         视图管理
  ├─ Properties    文档属性
  ├─ Relations     文档关联
  ├─ Attachments   附件管理
  ├─ Sync          数据同步
  ├─ Collaboration 评论 + 实时协作
  ├─ Workflow      审批 + 请求 + 修订
  └─ Tenancy       组织/工作区级文档

Auth (认证)
  └─ OAuth2 & OIDC
```

**优点总结**:
- ✅ 10 个子分组，数量合理
- ✅ 逻辑清晰，易于查找
- ✅ 无需修改现有代码
- ✅ 仅需调整 tag 映射

---

## 💡 建议

**当前最优方案**: 采用 **方案 A（功能领域分组）**

**理由**:
1. ✅ 平衡了简洁性和组织性
2. ✅ 无需修改现有 API 路由
3. ✅ 仅需调整 tag-groups 脚本
4. ✅ 适合当前的模块化设计

**下一步**:
1. 修改 `scripts/add-tag-groups.js`
2. 更新 tag 映射关系
3. 重新生成文档
4. 用户预览确认
5. 提交代码
