# 架构设计

本文档详细介绍 NexusBook API 的架构设计、目录结构和设计原则。

## Document 核心概念架构

```mermaid
graph TB
    subgraph "Document 文档抽象"
        Doc["📄 Document<br/>{doc-type}/{doc-id}"]
        
        subgraph "核心数据层 Core Data"
            Props["🏷️ Properties<br/>文档属性<br/><small>订单时间、门店、金额</small>"]
            Meta["📋 Metadata<br/>字段定义<br/><small>25+ 字段类型</small>"]
            Views["👁️ Views<br/>视图配置<br/><small>8 种视图类型</small>"]
            Data["📊 Data<br/>数据行<br/><small>结构化数据</small>"]
            Settings["⚙️ Settings<br/>配置<br/><small>文档/类型级</small>"]
        end
        
        subgraph "协作层 Collaboration"
            Comments["💬 Comments<br/>评论系统<br/><small>文档/字段/行/单元格</small>"]
        end
        
        subgraph "工作流层 Workflow"
            Requests["📝 Requests<br/>变更请求<br/><small>类似 Git PR</small>"]
            Revisions["📜 Revisions<br/>修订历史<br/><small>完整变更追踪</small>"]
            Approvals["✅ Approvals<br/>审批流程<br/><small>多层级审批</small>"]
        end
    end
    
    subgraph "查询能力 Query Engine"
        Filter["🔍 Filter<br/>过滤器<br/><small>嵌套逻辑</small>"]
        Sort["📶 Sort<br/>排序<br/><small>多字段</small>"]
        Group["📊 Group<br/>分组聚合<br/><small>5 种聚合函数</small>"]
        Aggregate["🎯 Aggregate<br/>聚合查询<br/><small>一次获取多种数据</small>"]
    end
    
    subgraph "认证授权 Auth"
        OAuth["🔐 OAuth2/OIDC<br/>标准认证"]
        Token["🎫 JWT Token<br/>令牌管理"]
        Scope["🔑 Scopes<br/>权限控制"]
    end
    
    Doc --> Props
    Doc --> Meta
    Doc --> Views
    Doc --> Data
    Doc --> Settings
    Doc --> Comments
    Doc --> Requests
    Doc --> Revisions
    Doc --> Approvals
    
    Data --> Filter
    Data --> Sort
    Data --> Group
    Doc --> Aggregate
    
    Requests -->|合并生成| Revisions
    Requests -->|可选| Approvals
    Data -->|默认生成| Requests
    %% Removed apply=true edge
    
    OAuth --> Token
    Token --> Scope
    Scope --> Doc
```

**核心概念说明：**

- **Document** - 统一的文档抽象，支持多种业务类型（订货单、产品、库存等）
- **核心数据层** - Properties（文档属性）、Metadata（字段定义）、Views（视图）、Data（数据行）、Settings（配置）
- **协作层** - Comments 支持在文档任何位置进行评论和讨论
- **工作流层** - Requests（变更请求）→ Revisions（修订历史）+ Approvals（审批流程）
- **查询能力** - 强大的过滤、排序、分组和聚合查询
- **认证授权** - OAuth2/OIDC 标准认证，基于 Scope 的权限控制

## 目录结构

```
api/
├── main.tsp                    # 顶层入口
│
├── shared/                     # 共享基础模块
│   ├── common.tsp             # 通用类型（ApiResponse, Filter, Value...）
│   ├── constants.tsp          # 枚举定义
│   └── index.tsp              # 模块入口
│
├── auth/                       # 认证模块
│   ├── models.tsp             # OAuth2/OIDC 模型
│   └── index.tsp              # 模块入口
│
└── document/                   # 文档模块
    ├── core/                  # 核心数据模型
    │   ├── metadata.tsp       # 字段定义
    │   ├── data.tsp           # 数据行管理
    │   ├── properties.tsp     # 文档属性
    │   ├── views.tsp          # 视图配置
    │   ├── settings.tsp       # 设置
    │   └── index.tsp
    │
    ├── content/               # 内容协作
    │   ├── comments.tsp       # 评论系统
    │   └── index.tsp
    │
    ├── workflow/              # 工作流管理
    │   ├── approvals.tsp      # 审批流程
    │   ├── requests.tsp       # 变更请求
    │   ├── revisions.tsp      # 修订历史
    │   └── index.tsp
    │
    ├── aggregate/             # 聚合查询
    │   └── index.tsp
    │
    ├── operations/            # 预留目录
    └── index.tsp
```

## 架构层次

```mermaid
graph TB
    subgraph "顶层 Top Level"
        Main["📄 main.tsp<br/>顶层入口"]
    end
    
    subgraph "基础层 Foundation Layer"
        Shared["📦 shared/<br/>共享基础模块"]
        Common["common.tsp<br/>通用类型"]
        Constants["constants.tsp<br/>枚举定义"]
        
        Shared --> Common
        Shared --> Constants
    end
    
    subgraph "认证层 Auth Layer"
        Auth["🔐 auth/<br/>认证模块"]
        AuthModels["models.tsp<br/>OAuth2/OIDC"]
        
        Auth --> AuthModels
    end
    
    subgraph "业务层 Business Layer"
        Document["📚 document/<br/>文档模块"]
        
        subgraph "核心 Core"
            Core["core/"]
            Metadata["metadata.tsp"]
            Data["data.tsp"]
            Properties["properties.tsp"]
            Views["views.tsp"]
            Settings["settings.tsp"]
            
            Core --> Metadata
            Core --> Data
            Core --> Properties
            Core --> Views
            Core --> Settings
        end
        
        subgraph "协作 Content"
            Content["content/"]
            Comments["comments.tsp"]
            
            Content --> Comments
        end
        
        subgraph "工作流 Workflow"
            Workflow["workflow/"]
            Approvals["approvals.tsp"]
            Requests["requests.tsp"]
            Revisions["revisions.tsp"]
            
            Workflow --> Approvals
            Workflow --> Requests
            Workflow --> Revisions
        end
        
        subgraph "聚合 Aggregate"
            Aggregate["aggregate/"]
            AggregateAPI["index.tsp"]
            
            Aggregate --> AggregateAPI
        end
        
        Document --> Core
        Document --> Content
        Document --> Workflow
        Document --> Aggregate
    end
    
    subgraph "扩展层 Extension Layer"
        Extensions["🔌 extensions/<br/>扩展模块<br/><small>预留</small>"]
        Integrations["integrations/"]
        Webhooks["webhooks/"]
        
        Extensions -.-> Integrations
        Extensions -.-> Webhooks
    end
    
    Main --> Shared
    Main --> Auth
    Main --> Document
    Main -.-> Extensions
    
    Auth --> Shared
    Document --> Shared
    Extensions -.-> Shared
    
    Core --> Shared
    Content --> Shared
    Workflow --> Shared
    Aggregate --> Shared
    
    Workflow --> Core
    Aggregate --> Core
    Aggregate --> Content
    Aggregate --> Workflow
```

**依赖关系说明：**

- **实线箭头** - 直接依赖关系
- **虚线箭头** - 预留/可选依赖
- **颜色分层** - 蓝色（顶层）→ 橙色（基础）→ 粉色（认证）→ 绿色（业务）→ 紫色（扩展）

**依赖原则：**

1. **单向依赖** - 上层依赖下层，下层不依赖上层
2. **基础优先** - 所有模块都依赖 shared 基础层
3. **模块独立** - 同层模块之间尽量独立
4. **聚合组合** - aggregate 模块组合其他模块的功能

## 设计原则

1. **分层架构** - 清晰的 4 层结构（shared → auth → document → extensions）
2. **单一职责** - 每个模块功能明确，职责单一
3. **依赖管理** - 明确的依赖关系，避免循环依赖
4. **可扩展性** - 预留扩展目录，支持动态扩展
5. **模块化** - 高内聚低耦合，便于维护和测试

## 模块职责

| 模块 | 职责 | 主要内容 |
|------|------|---------|
| **shared** | 基础设施 | 通用类型、错误码、过滤器、聚合函数 |
| **auth** | 认证授权 | OAuth2、OIDC、JWT、用户信息 |
| **document/core** | 核心数据 | 元数据、数据行、属性、视图、设置 |
| **document/content** | 内容协作 | 评论系统 |
| **document/workflow** | 工作流 | 审批、请求、修订 |
| **document/aggregate** | 聚合查询 | 一次性获取多种数据 |
| **extensions** | 扩展功能 | 集成、Webhooks（预留） |

## 数据流与工作流

```mermaid
sequenceDiagram
    participant User as 👤 用户
    participant API as 🌐 API
    participant Request as 📝 Request
    participant Approval as ✅ Approval
    participant Revision as 📜 Revision
    participant Data as 📊 Data Store

    Note over User,Data: 场景 1: 直接应用变更 (apply=true)
    User->>API: POST /data?apply=true
    API->>Data: 直接写入数据
    API->>Revision: 生成修订记录
    Revision-->>User: 返回修订 ID
    
    Note over User,Data: 场景 2: 创建变更请求（默认）
    User->>API: POST /data
    API->>Request: 创建 Request
    Request-->>User: 返回 Request ID
    
    Note over User,Data: 场景 3: 多人协作编辑
    User->>Request: 添加/修改变更
    User->>Request: 继续编辑
    Note over Request: 多个用户可以<br/>在同一 Request 中<br/>协作编辑
    
    Note over User,Data: 场景 4: 审批流程
    User->>API: POST /requests/{id}/merge
    API->>Approval: 触发审批流程
    Approval->>Approval: 多层级审批
    alt 审批通过
        Approval->>Request: 批准合并
        Request->>Data: 应用变更
        Request->>Revision: 生成修订
        Revision-->>User: 完成
    else 审批拒绝
        Approval->>Request: 拒绝
        Request-->>User: 需要修改
    end
    
    Note over User,Data: 场景 5: 版本对比与回滚
    User->>API: GET /revisions/{id}/diff?base={base-id}
    API-->>User: 返回差异
    User->>API: POST /revisions/{id}/revert
    API->>Request: 创建回滚 Request
    Request->>Data: 应用回滚
    API->>Revision: 生成回滚修订
    Revision-->>User: 完成回滚
```

**工作流说明：**

1. **直接应用** - 使用 `?apply=true` 参数直接写入数据并生成修订
2. **变更请求** - 默认创建 Request，支持多人协作编辑
3. **审批流程** - 可选的多层级审批机制
4. **修订追踪** - 所有变更都会生成修订记录
5. **版本回滚** - 支持对比和回滚到任意历史版本

## 字段类型与值类型映射

```mermaid
graph LR
    subgraph "字段类型 Field Types"
        F1["text<br/>long_text"]
        F2["number<br/>currency<br/>percent"]
        F3["boolean"]
        F4["date<br/>datetime"]
        F5["duration"]
        F6["single_select"]
        F7["multi_select"]
        F8["rating"]
        F9["attachment"]
        F10["user"]
        F11["collaborator"]
        F12["relation"]
        F13["lookup<br/>rollup<br/>formula"]
    end
    
    subgraph "值类型 Value Types"
        V1["string"]
        V2["float64"]
        V3["boolean"]
        V4["string<br/><small>ISO 8601</small>"]
        V5["int64<br/><small>毫秒</small>"]
        V6["SelectOption"]
        V7["SelectOption[]"]
        V8["int32<br/><small>1-5</small>"]
        V9["Attachment[]"]
        V10["UserRef"]
        V11["CollaboratorRef"]
        V12["RelationRef[]"]
        V13["<small>动态类型</small>"]
    end
    
    F1 --> V1
    F2 --> V2
    F3 --> V3
    F4 --> V4
    F5 --> V5
    F6 --> V6
    F7 --> V7
    F8 --> V8
    F9 --> V9
    F10 --> V10
    F11 --> V11
    F12 --> V12
    F13 --> V13
```

## 文档类型路由

**Provider 模式：**

```
/api/v1/doc/{doc-type}/{doc-id}
              ↓
        Provider 解析
              ↓
    ┌─────────┼─────────┐
    ▼         ▼         ▼
 Product  Purchase   Invoice
 Provider  Provider  Provider
```

**扩展新类型：**
- 实现对应的 Provider
- 注册到路由系统
- 无需修改 API 定义

## 资源抽象

```
Doc: {doc-type} + {doc-id}
  ├── properties    # 文档属性（订单时间、门店、金额等）
  ├── metadata      # 字段定义
  ├── views         # 视图配置
  ├── data          # 数据行
  ├── comments      # 评论
  ├── revisions     # 修订历史
  ├── requests      # 变更请求
  ├── approval      # 审批流程
  └── settings      # 设置
```

## 下一步

- 查看 [API 参考文档](../references/api-reference.md) 了解详细的 API 端点
- 查看 [开发指南](./development.md) 了解如何扩展和修改 API
- 查看 [数据操作指南](./data-operations.md) 了解查询和过滤功能
