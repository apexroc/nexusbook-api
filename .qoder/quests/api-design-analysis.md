# NexusBook API 多租户 SaaS 功能缺口分析

## 一、现有模块概览

### 1.1 已实现的核心模块

#### 认证与授权模块 (Auth)
- ✅ OAuth2/OIDC 标准认证
- ✅ 用户注册与登录（邮箱/手机/OAuth）
- ✅ 密码管理（找回/重置/修改）
- ✅ 两步验证（TOTP/SMS/Email）
- ✅ 会话管理
- ✅ API Keys 管理
- ✅ 基于 Scope 的权限控制（doc:read、data:write 等）

#### 租户管理模块 (Tenant)
- ✅ 用户模型（User）
- ✅ 组织模型（Organization）及其成员管理
- ✅ 工作区模型（Workspace）及其成员管理
- ✅ 邀请系统（Invitation）
- ✅ OAuth 连接管理
- ✅ 角色定义
  - 组织角色：owner、admin、member、guest
  - 工作区角色：owner、editor、viewer

#### 文档管理模块 (Document)
- ✅ 核心数据层（Properties、Metadata、Views、Data、Settings）
- ✅ 内容协作（Comments）
- ✅ 工作流管理（Approvals、Requests、Revisions）
- ✅ 聚合查询（Aggregate）
- ✅ 文档间关联（Relations）
- ✅ 附件管理（Attachments）
- ✅ 数据同步（Sync）
- ✅ 实时协作（Realtime - Yjs）

#### 扩展功能模块 (Extensions)
- ✅ Webhooks（事件驱动通知）

## 二、多租户 SaaS 关键功能缺口分析

### 2.1 权限与访问控制缺口

#### 🔴 缺失：细粒度权限系统（RBAC/ABAC）

**当前状态**
- 仅有基于 Scope 的粗粒度权限控制
- 组织和工作区有简单的角色定义
- 缺乏文档级别、字段级别的细粒度权限控制

**缺失功能**
- 资源级权限控制（Resource-Level Permissions）
  - 文档级别权限（特定文档的读写权限）
  - 字段级别权限（敏感字段的访问控制）
  - 数据行级别权限（Row-Level Security）
  - 视图级别权限（不同视图的访问控制）

- 自定义角色与权限模板
  - 可配置的角色定义
  - 权限模板系统
  - 权限继承机制
  - 权限委托（临时授权）

- 基于属性的访问控制（ABAC）
  - 基于用户属性的动态权限
  - 基于资源属性的访问控制
  - 基于环境上下文的权限（时间、地理位置、设备类型）

**业务影响**
- 无法支持企业级的精细权限需求
- 敏感数据保护不足
- 跨部门协作场景受限

#### 🟡 缺失：权限审计日志

**缺失功能**
- 权限变更记录
- 访问日志追踪
- 异常访问检测
- 权限合规性报告

### 2.2 计费与订阅管理缺口

#### 🔴 缺失：订阅计划管理（Subscription Management）

**缺失功能**
- 订阅计划定义
  - 多层级定价方案（Free、Pro、Enterprise）
  - 按用户数计费
  - 按存储空间计费
  - 按 API 调用量计费
  - 功能限制配置（文档数量、工作区数量、成员数量）

- 订阅生命周期管理
  - 订阅创建与激活
  - 升级/降级处理
  - 试用期管理
  - 订阅续期与自动续费
  - 订阅取消与暂停
  - 订阅过期处理

- 订阅状态追踪
  - 试用中、活跃、已过期、已取消、已暂停

**业务影响**
- 无法实现商业化运营
- 无法区分不同付费层级的用户
- 缺乏收入增长机制

#### 🔴 缺失：计费与支付模块

**缺失功能**
- 账单生成与管理
  - 按月/按年账单生成
  - 使用量统计与计费
  - 发票生成
  - 账单历史记录

- 支付集成
  - 支付方式管理（信用卡、支付宝、微信支付、银行转账）
  - 支付网关集成（Stripe、PayPal、国内支付）
  - 支付状态追踪
  - 支付失败重试机制

- 财务管理
  - 欠费管理
  - 退款处理
  - 信用额度管理
  - 财务报表

**业务影响**
- 无法自动化收款流程
- 缺乏财务透明度
- 增加人工处理成本

#### 🟡 缺失：使用量追踪与配额管理

**缺失功能**
- 资源使用量统计
  - 存储空间使用量
  - API 调用量统计
  - 文档数量统计
  - 成员数量追踪
  - 实时协作会话数

- 配额限制与强制
  - 按订阅计划设置配额
  - 软限制与硬限制
  - 超额警告通知
  - 超额自动限流/阻止

- 使用量报告
  - 组织级使用量报告
  - 工作区级使用量报告
  - 用户级使用量报告
  - 趋势分析

**业务影响**
- 无法防止资源滥用
- 无法实施公平使用政策
- 成本控制困难

### 2.3 运营与管理缺口

#### 🔴 缺失：系统管理面板（Admin Panel）

**缺失功能**
- 全局用户管理
  - 查看所有用户
  - 用户状态管理（激活/暂停/删除）
  - 批量操作
  - 用户行为分析

- 组织管理
  - 查看所有组织
  - 组织状态管理
  - 强制删除/归档组织
  - 数据迁移工具

- 系统监控与统计
  - 平台整体使用统计
  - 活跃用户数（DAU/MAU）
  - 存储使用情况
  - API 调用量统计
  - 性能指标监控

- 内容审核
  - 举报处理
  - 内容违规检测
  - 黑名单管理

**业务影响**
- 运营效率低下
- 缺乏平台级洞察
- 无法及时处理异常情况

#### 🟡 缺失：审计日志系统（Audit Logs）

**缺失功能**
- 操作审计日志
  - 用户操作记录（登录、数据修改、权限变更）
  - 管理员操作记录
  - API 调用日志
  - 系统事件日志

- 日志查询与分析
  - 按用户/组织/时间范围查询
  - 日志导出（CSV/JSON）
  - 日志告警规则
  - 异常行为检测

- 合规性支持
  - GDPR 合规日志
  - SOC2 审计日志
  - 数据访问记录

**业务影响**
- 安全事件难以追溯
- 合规性要求无法满足
- 故障排查困难

#### 🟡 缺失：通知系统（Notifications）

**当前状态**
- 仅有 Webhook 事件通知
- 缺乏用户级通知机制

**缺失功能**
- 应用内通知
  - 实时通知推送
  - 未读通知管理
  - 通知历史记录
  - 通知分类（@提及、评论、审批、系统通知）

- 多渠道通知
  - 邮件通知
  - 短信通知
  - 桌面推送通知
  - 移动推送通知

- 通知偏好设置
  - 用户级通知偏好
  - 通知频率控制
  - 勿扰模式
  - 通知渠道选择

**业务影响**
- 用户协作效率降低
- 重要事件可能被遗漏
- 用户体验不完整

### 2.4 数据管理缺口

#### 🟡 缺失：数据导入导出

**缺失功能**
- 批量数据导入
  - Excel/CSV 导入
  - 字段映射配置
  - 导入预览与验证
  - 导入错误处理
  - 导入任务管理

- 数据导出
  - 多格式导出（Excel、CSV、JSON、PDF）
  - 自定义导出字段
  - 导出任务调度
  - 大数据量导出优化

- 数据模板
  - 导入模板下载
  - 模板版本管理

**业务影响**
- 数据迁移困难
- 缺乏与外部系统集成能力
- 用户上手成本高

#### 🟡 缺失：数据备份与恢复

**缺失功能**
- 自动备份
  - 定期全量备份
  - 增量备份
  - 备份策略配置
  - 备份存储管理

- 数据恢复
  - 按时间点恢复
  - 选择性恢复（组织/工作区/文档级）
  - 恢复预览
  - 恢复任务管理

- 灾难恢复
  - 多地域备份
  - 恢复演练
  - RTO/RPO 保证

**业务影响**
- 数据安全风险
- 业务连续性无保障
- 企业客户信任度降低

#### 🟡 缺失：数据归档与保留策略

**缺失功能**
- 数据归档
  - 自动归档策略
  - 归档数据访问
  - 归档存储优化

- 数据保留策略
  - 按法规要求配置保留期
  - 自动删除过期数据
  - 法律保留（Legal Hold）

**业务影响**
- 合规性风险
- 存储成本持续增长
- 数据治理能力弱

### 2.5 安全与合规缺口

#### 🟡 缺失：单点登录（SSO）集成

**缺失功能**
- SAML 2.0 支持
  - SAML 身份提供商集成
  - SP-initiated SSO
  - IdP-initiated SSO
  - SAML 属性映射

- SCIM 用户同步
  - 自动用户创建/更新/删除
  - 组织成员同步
  - 批量操作支持

- 企业身份提供商集成
  - Azure AD / Entra ID
  - Okta
  - Google Workspace
  - Auth0

**业务影响**
- 无法满足企业客户需求
- 失去大客户机会
- 用户管理成本高

#### 🟡 缺失：数据加密与密钥管理

**缺失功能**
- 数据加密
  - 传输加密（TLS）
  - 静态数据加密
  - 字段级加密（敏感字段）
  - 客户端加密

- 密钥管理
  - 密钥轮换策略
  - 密钥版本管理
  - 客户管理的密钥（CMEK）
  - KMS 集成（AWS KMS、Azure Key Vault）

**业务影响**
- 数据安全风险
- 无法满足高安全等级需求
- 合规性要求无法达成

#### 🟡 缺失：IP 白名单与地理访问控制

**缺失功能**
- IP 白名单
  - 组织级 IP 白名单
  - 工作区级 IP 白名单
  - IP 范围配置
  - 白名单例外规则

- 地理访问控制
  - 按国家/地区限制访问
  - 数据本地化要求
  - 地理围栏规则

**业务影响**
- 安全防护不足
- 无法满足特定行业需求
- 数据主权问题

### 2.6 集成与扩展缺口

#### 🟡 缺失：应用市场与插件系统

**缺失功能**
- 应用市场
  - 第三方应用接入
  - 应用安装/卸载
  - 应用权限管理
  - 应用评价与反馈

- 插件/扩展机制
  - 自定义字段类型
  - 自定义视图类型
  - 自定义函数
  - 工作流扩展点

- OAuth 应用管理
  - 第三方应用注册
  - OAuth 授权管理
  - Token 管理

**业务影响**
- 生态系统建设困难
- 无法满足定制化需求
- 平台价值增长受限

#### 🟡 缺失：Open API / GraphQL 支持

**当前状态**
- 仅提供 RESTful API
- 缺乏 GraphQL 支持

**缺失功能**
- GraphQL API
  - 灵活的数据查询
  - 减少 API 调用次数
  - 类型系统与自省

- API 版本管理
  - API 版本策略
  - 废弃 API 管理
  - 向后兼容性保证

**业务影响**
- 集成效率较低
- 开发者体验不佳
- 竞争力下降

### 2.7 用户体验与支持缺口

#### 🟡 缺失：多语言支持（国际化）

**当前状态**
- API 响应消息支持多语言（zh/en）
- 缺乏系统级国际化配置

**缺失功能**
- 语言偏好管理
  - 用户级语言设置
  - 组织级默认语言
  - 自动语言检测

- 本地化内容
  - 日期时间格式化
  - 数字货币格式化
  - 时区处理

- 多语言内容管理
  - 字段多语言标签
  - 视图多语言名称
  - 帮助文档多语言

**业务影响**
- 国际化扩展受限
- 用户体验不一致
- 全球市场竞争力弱

#### 🟡 缺失：帮助与支持系统

**缺失功能**
- 在线帮助中心
  - 知识库文章
  - 视频教程
  - 常见问题（FAQ）
  - 搜索功能

- 用户反馈
  - 功能请求
  - Bug 报告
  - 满意度调查
  - 反馈状态追踪

- 在线客服
  - 聊天支持
  - 工单系统
  - SLA 管理

**业务影响**
- 用户支持成本高
- 用户自助能力弱
- 客户满意度降低

### 2.8 分析与洞察缺口

#### 🟡 缺失：数据分析与报表

**缺失功能**
- 内置分析功能
  - 数据透视表
  - 多维分析
  - 趋势图表
  - 自定义报表

- 仪表盘
  - 可配置仪表盘
  - 实时数据刷新
  - 数据可视化组件
  - 仪表盘共享

- 数据导出分析
  - BI 工具集成
  - 数据连接器
  - SQL 查询接口

**业务影响**
- 数据价值挖掘不足
- 决策支持能力弱
- 产品竞争力降低

#### 🟡 缺失：使用分析与洞察

**缺失功能**
- 用户行为分析
  - 功能使用统计
  - 用户路径分析
  - 留存率分析
  - 活跃度分析

- 组织洞察
  - 团队协作效率分析
  - 工作区使用情况
  - 热门文档统计

- 产品分析集成
  - Google Analytics
  - Mixpanel
  - Amplitude

**业务影响**
- 产品优化方向不明确
- 用户流失原因不清楚
- 增长策略缺乏数据支撑

## 三、优先级建议

### 高优先级（P0）- 商业化运营必需

1. **订阅计划管理** - 实现商业化的基础
2. **计费与支付模块** - 收入来源
3. **使用量追踪与配额管理** - 资源控制与公平使用
4. **细粒度权限系统** - 企业客户必需
5. **系统管理面板** - 平台运营基础

### 中优先级（P1）- 提升竞争力

6. **单点登录（SSO）** - 企业客户关键需求
7. **审计日志系统** - 合规性要求
8. **通知系统** - 用户体验提升
9. **数据导入导出** - 用户迁移与集成
10. **数据备份与恢复** - 数据安全保障

### 低优先级（P2）- 长期竞争力

11. **应用市场与插件系统** - 生态建设
12. **数据分析与报表** - 增值服务
13. **多语言支持增强** - 国际化扩展
14. **IP 白名单与地理控制** - 特定行业需求
15. **数据加密增强** - 高安全等级需求

## 四、实施路线图建议

### 阶段一：商业化基础（1-2个月）
- 订阅计划管理 API
- 计费与支付集成
- 使用量追踪与配额控制
- 基础系统管理面板

**里程碑**：实现付费订阅功能，支持基本的商业化运营

### 阶段二：企业级能力（2-3个月）
- 细粒度权限系统（RBAC）
- 审计日志系统
- SSO 集成（SAML/SCIM）
- 通知系统
- 数据导入导出

**里程碑**：满足中小型企业客户需求，具备企业级安全与合规能力

### 阶段三：平台增强（3-4个月）
- 数据备份与恢复
- 应用市场框架
- 增强的数据分析
- 多语言支持增强
- 帮助与支持系统

**里程碑**：提升平台成熟度，支持大型企业客户

### 阶段四：生态建设（持续）
- 插件系统完善
- GraphQL API
- 高级安全特性
- BI 集成
- 国际化扩展

**里程碑**：建立开放生态，形成竞争壁垒

## 五、关键设计原则

### 5.1 多租户数据隔离
- 组织级数据隔离
- 工作区级权限边界
- 跨租户数据访问严格控制

### 5.2 可扩展性
- 模块化设计
- 插件化架构
- 水平扩展能力

### 5.3 安全优先
- 最小权限原则
- 零信任架构
- 数据加密（传输与静态）

### 5.4 合规性
- GDPR 兼容
- SOC2 审计要求
- 数据保留策略

### 5.5 API 设计一致性
- RESTful 规范
- 统一的错误处理
- 标准的响应格式
- 版本管理策略

## 六、技术架构建议

### 6.1 权限系统架构
- 基于策略的访问控制（Policy-Based Access Control）
- 权限缓存与快速验证
- 权限继承与传播机制

### 6.2 计费系统架构
- 事件驱动的使用量追踪
- 异步账单生成
- 支付网关抽象层（适配多种支付方式）

### 6.3 审计日志架构
- 分布式日志收集
- 日志存储优化（热数据/冷数据分离）
- 实时日志流处理

### 6.4 通知系统架构
- 消息队列（异步处理）
- 多渠道通知路由
- 通知去重与合并

## 七、数据模型设计建议

### 7.1 订阅模型
```
Organization
  ├── Subscription（订阅）
  │     ├── plan: Plan（计划）
  │     ├── status: SubscriptionStatus
  │     ├── currentPeriodStart
  │     ├── currentPeriodEnd
  │     └── features: Feature[]（功能限制）
  ├── Invoice（账单）
  └── Usage（使用量）
```

### 7.2 权限模型
```
Permission
  ├── subject: User | Team | Role
  ├── resource: Document | Workspace | Organization
  ├── action: read | write | delete | manage
  ├── conditions: Condition[]（基于属性的条件）
  └── inheritedFrom: Permission（继承关系）
```

### 7.3 审计日志模型
```
AuditLog
  ├── timestamp
  ├── actor: User（操作者）
  ├── action: string（操作类型）
  ├── resource: Resource（资源）
  ├── changes: Change[]（变更详情）
  ├── ipAddress
  ├── userAgent
  └── organizationId
```

## 八、总结

作为多租户 SaaS 平台，NexusBook API 当前具备了扎实的文档管理和协作基础，但在商业化运营、企业级能力、运营管理、数据安全等方面存在明显的功能缺口。

**最关键的缺失模块**：
1. 订阅与计费系统（商业化基础）
2. 细粒度权限控制（企业级安全）
3. 系统管理面板（运营支撑）
4. 审计日志系统（合规要求）
5. 单点登录（企业客户必需）

建议优先实施阶段一和阶段二的功能模块，快速建立商业化能力和企业级服务水平，然后逐步完善平台的深度和广度。

---

# 附录：API 接口设计详细方案

## 一、商业化运营 API 设计

### 1.1 订阅计划管理模块

#### 数据模型

**订阅计划（Subscription Plan）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 计划唯一标识 |
| name | string | 计划名称（如 Free、Pro、Enterprise） |
| displayName | Message | 多语言显示名称 |
| description | Message | 多语言描述 |
| type | PlanType | 计划类型（trial/standard/custom） |
| billingCycle | BillingCycle | 计费周期（monthly/yearly） |
| price | float64 | 价格（单位：元/美元） |
| currency | string | 货币代码（CNY/USD） |
| trialDays | int32 | 试用天数 |
| features | PlanFeature[] | 功能特性列表 |
| quotas | PlanQuota | 配额限制 |
| status | PlanStatus | 状态（active/archived） |
| createdAt | string | 创建时间 |
| updatedAt | string | 更新时间 |

**计划特性（Plan Feature）**

| 字段 | 类型 | 说明 |
|------|------|------|
| featureKey | string | 功能键（如 advanced_permissions） |
| featureName | Message | 功能名称 |
| enabled | boolean | 是否启用 |
| limit | int32 | 限制值（-1 表示无限制） |

**计划配额（Plan Quota）**

| 字段 | 类型 | 说明 |
|------|------|------|
| maxMembers | int32 | 最大成员数（-1 无限制） |
| maxWorkspaces | int32 | 最大工作区数 |
| maxDocuments | int32 | 最大文档数 |
| maxStorageGB | int32 | 最大存储空间（GB） |
| maxAPICallsPerMonth | int64 | 每月 API 调用量 |
| maxRealtimeSessions | int32 | 最大实时协作会话数 |

**组织订阅（Organization Subscription）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 订阅唯一标识 |
| organizationId | string | 组织 ID |
| planId | string | 订阅计划 ID |
| plan | SubscriptionPlan | 计划详情（可选包含） |
| status | SubscriptionStatus | 订阅状态 |
| trialStart | string | 试用开始时间 |
| trialEnd | string | 试用结束时间 |
| currentPeriodStart | string | 当前计费周期开始 |
| currentPeriodEnd | string | 当前计费周期结束 |
| cancelAt | string | 取消时间（计划取消时） |
| canceledAt | string | 实际取消时间 |
| metadata | Record<string> | 自定义元数据 |
| createdAt | string | 创建时间 |
| updatedAt | string | 更新时间 |

**枚举定义**

```
PlanType: trial（试用） | standard（标准） | custom（定制）

BillingCycle: monthly（月付） | yearly（年付）

PlanStatus: active（活跃） | archived（已归档）

SubscriptionStatus: 
  - trialing（试用中）
  - active（活跃）
  - past_due（逾期）
  - canceled（已取消）
  - expired（已过期）
```

#### API 接口

**标签组**：`Billing & Subscriptions`

**1. 列出可用订阅计划**

```
GET /api/v1/billing/plans
```

**请求参数**
- `includeArchived`（query, boolean）：是否包含已归档计划

**响应**
```
ApiResponse<SubscriptionPlan[]>
```

**2. 获取订阅计划详情**

```
GET /api/v1/billing/plans/{planId}
```

**响应**
```
ApiResponse<SubscriptionPlan>
```

**3. 获取当前组织订阅信息**

```
GET /api/v1/organizations/{organizationId}/subscription
```

**响应**
```
ApiResponse<OrganizationSubscription>
```

**4. 创建或更新组织订阅**

```
POST /api/v1/organizations/{organizationId}/subscription
```

**请求体**
```json
{
  "planId": "plan_pro_monthly",
  "billingCycle": "monthly",
  "paymentMethodId": "pm_xxx"
}
```

**响应**
```
ApiResponse<OrganizationSubscription>
```

**5. 升级/降级订阅**

```
POST /api/v1/organizations/{organizationId}/subscription/change-plan
```

**请求体**
```json
{
  "targetPlanId": "plan_enterprise_yearly",
  "billingCycle": "yearly",
  "effectiveDate": "immediate" | "next_billing_cycle"
}
```

**响应**
```
ApiResponse<{
  subscription: OrganizationSubscription,
  prorationAmount: float64,
  nextBillingDate: string
}>
```

**6. 取消订阅**

```
POST /api/v1/organizations/{organizationId}/subscription/cancel
```

**请求体**
```json
{
  "cancelImmediately": false,
  "reason": "切换到其他平台",
  "feedback": "功能不满足需求"
}
```

**响应**
```
ApiResponse<OrganizationSubscription>
```

**7. 恢复已取消的订阅**

```
POST /api/v1/organizations/{organizationId}/subscription/resume
```

**响应**
```
ApiResponse<OrganizationSubscription>
```

### 1.2 计费与账单模块

#### 数据模型

**账单（Invoice）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 账单唯一标识 |
| organizationId | string | 组织 ID |
| subscriptionId | string | 订阅 ID |
| invoiceNumber | string | 账单编号 |
| status | InvoiceStatus | 状态 |
| subtotal | float64 | 小计 |
| tax | float64 | 税额 |
| total | float64 | 总计 |
| currency | string | 货币代码 |
| items | InvoiceItem[] | 账单项 |
| periodStart | string | 计费周期开始 |
| periodEnd | string | 计费周期结束 |
| dueDate | string | 到期日期 |
| paidAt | string | 支付时间 |
| paymentIntentId | string | 支付意图 ID |
| invoiceUrl | string | 账单 URL |
| invoicePdfUrl | string | PDF 下载链接 |
| createdAt | string | 创建时间 |

**账单项（Invoice Item）**

| 字段 | 类型 | 说明 |
|------|------|------|
| description | Message | 描述 |
| quantity | int32 | 数量 |
| unitPrice | float64 | 单价 |
| amount | float64 | 金额 |
| type | ItemType | 类型（subscription/usage/addon） |

**支付方式（Payment Method）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 支付方式 ID |
| organizationId | string | 组织 ID |
| type | PaymentMethodType | 类型 |
| isDefault | boolean | 是否默认 |
| cardLast4 | string | 卡号后4位（信用卡） |
| cardBrand | string | 卡品牌（Visa/MasterCard） |
| expiryMonth | int32 | 过期月份 |
| expiryYear | int32 | 过期年份 |
| billingEmail | string | 账单邮箱 |
| createdAt | string | 添加时间 |

**枚举定义**

```
InvoiceStatus: 
  - draft（草稿）
  - open（待支付）
  - paid（已支付）
  - void（已作废）
  - uncollectible（无法收款）

PaymentMethodType:
  - card（信用卡）
  - alipay（支付宝）
  - wechat（微信支付）
  - bank_transfer（银行转账）
```

#### API 接口

**标签组**：`Billing & Subscriptions`

**8. 列出组织账单**

```
GET /api/v1/organizations/{organizationId}/invoices
```

**请求参数**
- `status`（query, InvoiceStatus）：按状态过滤
- `page`（query, int32）：页码
- `pageSize`（query, int32）：每页数量

**响应**
```
ApiResponse<Page<Invoice>>
```

**9. 获取账单详情**

```
GET /api/v1/organizations/{organizationId}/invoices/{invoiceId}
```

**响应**
```
ApiResponse<Invoice>
```

**10. 支付账单**

```
POST /api/v1/organizations/{organizationId}/invoices/{invoiceId}/pay
```

**请求体**
```json
{
  "paymentMethodId": "pm_xxx"
}
```

**响应**
```
ApiResponse<{
  invoice: Invoice,
  paymentStatus: string,
  requiresAction: boolean,
  clientSecret: string
}>
```

**11. 列出支付方式**

```
GET /api/v1/organizations/{organizationId}/payment-methods
```

**响应**
```
ApiResponse<PaymentMethod[]>
```

**12. 添加支付方式**

```
POST /api/v1/organizations/{organizationId}/payment-methods
```

**请求体**
```json
{
  "type": "card",
  "paymentToken": "tok_xxx",
  "setAsDefault": true
}
```

**响应**
```
ApiResponse<PaymentMethod>
```

**13. 删除支付方式**

```
DELETE /api/v1/organizations/{organizationId}/payment-methods/{paymentMethodId}
```

**响应**
```
ApiResponse<{}>
```

**14. 设置默认支付方式**

```
POST /api/v1/organizations/{organizationId}/payment-methods/{paymentMethodId}/set-default
```

**响应**
```
ApiResponse<PaymentMethod>
```

### 1.3 使用量与配额管理模块

#### 数据模型

**组织使用量（Organization Usage）**

| 字段 | 类型 | 说明 |
|------|------|------|
| organizationId | string | 组织 ID |
| periodStart | string | 统计周期开始 |
| periodEnd | string | 统计周期结束 |
| members | UsageMetric | 成员使用量 |
| workspaces | UsageMetric | 工作区使用量 |
| documents | UsageMetric | 文档使用量 |
| storage | UsageMetric | 存储使用量（GB） |
| apiCalls | UsageMetric | API 调用量 |
| realtimeSessions | UsageMetric | 实时协作会话 |
| updatedAt | string | 更新时间 |

**使用量指标（Usage Metric）**

| 字段 | 类型 | 说明 |
|------|------|------|
| current | int64 | 当前使用量 |
| limit | int64 | 配额限制（-1 无限制） |
| percentage | float64 | 使用百分比 |
| isOverQuota | boolean | 是否超额 |

**使用量历史（Usage History）**

| 字段 | 类型 | 说明 |
|------|------|------|
| organizationId | string | 组织 ID |
| metricType | MetricType | 指标类型 |
| value | int64 | 值 |
| timestamp | string | 时间戳 |
| metadata | Record<string> | 元数据 |

**枚举定义**

```
MetricType:
  - members（成员数）
  - workspaces（工作区数）
  - documents（文档数）
  - storage_gb（存储空间）
  - api_calls（API 调用）
  - realtime_sessions（实时会话）
```

#### API 接口

**标签组**：`Billing & Subscriptions`

**15. 获取组织当前使用量**

```
GET /api/v1/organizations/{organizationId}/usage
```

**响应**
```
ApiResponse<OrganizationUsage>
```

**16. 获取使用量历史趋势**

```
GET /api/v1/organizations/{organizationId}/usage/history
```

**请求参数**
- `metricType`（query, MetricType）：指标类型
- `startDate`（query, string）：开始日期
- `endDate`（query, string）：结束日期
- `granularity`（query, string）：粒度（hour/day/month）

**响应**
```
ApiResponse<{
  metricType: MetricType,
  dataPoints: UsageDataPoint[]
}>
```

其中 `UsageDataPoint` 结构：
```
{
  timestamp: string,
  value: int64
}
```

**17. 获取配额警告**

```
GET /api/v1/organizations/{organizationId}/usage/warnings
```

**响应**
```
ApiResponse<{
  warnings: QuotaWarning[]
}>
```

其中 `QuotaWarning` 结构：
```
{
  metricType: MetricType,
  current: int64,
  limit: int64,
  percentage: float64,
  severity: "warning" | "critical",
  message: Message
}
```

## 二、单点登录（SSO）API 设计

### 2.1 SAML SSO 模块

#### 数据模型

**SAML 配置（SAML Configuration）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 配置唯一标识 |
| organizationId | string | 组织 ID |
| enabled | boolean | 是否启用 |
| entityId | string | Service Provider Entity ID |
| ssoUrl | string | SSO 登录 URL |
| sloUrl | string | Single Logout URL |
| certificate | string | SAML 证书（X.509） |
| signatureAlgorithm | string | 签名算法 |
| nameIdFormat | string | Name ID 格式 |
| attributeMapping | AttributeMapping | 属性映射配置 |
| defaultRole | OrganizationRole | 新用户默认角色 |
| autoProvision | boolean | 自动创建用户 |
| enforceSSO | boolean | 强制使用 SSO 登录 |
| createdAt | string | 创建时间 |
| updatedAt | string | 更新时间 |

**属性映射（Attribute Mapping）**

| 字段 | 类型 | 说明 |
|------|------|------|
| email | string | 邮箱属性名 |
| displayName | string | 显示名称属性名 |
| firstName | string | 名字属性名 |
| lastName | string | 姓氏属性名 |
| groups | string | 组属性名 |

**SAML 连接（SAML Connection）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 连接 ID |
| userId | string | 用户 ID |
| organizationId | string | 组织 ID |
| nameId | string | SAML Name ID |
| sessionIndex | string | 会话索引 |
| attributes | Record<string> | SAML 属性 |
| lastLoginAt | string | 最后登录时间 |
| createdAt | string | 创建时间 |

#### API 接口

**标签组**：`SSO & Identity`

**1. 获取组织 SAML 配置**

```
GET /api/v1/organizations/{organizationId}/sso/saml/config
```

**响应**
```
ApiResponse<SAMLConfiguration>
```

**2. 更新 SAML 配置**

```
PUT /api/v1/organizations/{organizationId}/sso/saml/config
```

**请求体**
```json
{
  "enabled": true,
  "entityId": "https://idp.example.com/metadata",
  "ssoUrl": "https://idp.example.com/sso",
  "sloUrl": "https://idp.example.com/slo",
  "certificate": "-----BEGIN CERTIFICATE-----\n...",
  "nameIdFormat": "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
  "attributeMapping": {
    "email": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
    "displayName": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
  },
  "defaultRole": "member",
  "autoProvision": true,
  "enforceSSO": false
}
```

**响应**
```
ApiResponse<SAMLConfiguration>
```

**3. 获取 Service Provider 元数据**

```
GET /api/v1/organizations/{organizationId}/sso/saml/metadata
```

**响应**
XML 格式的 SAML 元数据

**4. 启用/禁用 SAML SSO**

```
POST /api/v1/organizations/{organizationId}/sso/saml/toggle
```

**请求体**
```json
{
  "enabled": true
}
```

**响应**
```
ApiResponse<SAMLConfiguration>
```

**5. 测试 SAML 连接**

```
POST /api/v1/organizations/{organizationId}/sso/saml/test
```

**请求体**
```json
{
  "samlResponse": "base64_encoded_saml_response"
}
```

**响应**
```
ApiResponse<{
  success: boolean,
  nameId: string,
  attributes: Record<string>,
  errors: string[]
}>
```

**6. SAML ACS 端点（Assertion Consumer Service）**

```
POST /api/v1/sso/saml/acs
```

接收 SAML 响应并完成登录

**7. SAML 发起 SSO 登录**

```
GET /api/v1/sso/saml/login
```

**请求参数**
- `organizationId`（query, string）：组织 ID
- `redirectUrl`（query, string）：登录后重定向 URL

重定向到 IdP 的 SSO URL

**8. SAML 单点登出**

```
GET /api/v1/sso/saml/logout
```

**请求参数**
- `sessionIndex`（query, string）：会话索引

### 2.2 SCIM 用户同步模块

#### 数据模型

**SCIM 配置（SCIM Configuration）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 配置 ID |
| organizationId | string | 组织 ID |
| enabled | boolean | 是否启用 |
| baseUrl | string | SCIM 基础 URL |
| bearerToken | string | 认证 Token |
| syncDirection | SyncDirection | 同步方向 |
| autoCreateUsers | boolean | 自动创建用户 |
| autoUpdateUsers | boolean | 自动更新用户 |
| autoDeactivateUsers | boolean | 自动停用用户 |
| lastSyncAt | string | 最后同步时间 |
| createdAt | string | 创建时间 |
| updatedAt | string | 更新时间 |

**SCIM 同步日志（SCIM Sync Log）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 日志 ID |
| organizationId | string | 组织 ID |
| operation | SCIMOperation | 操作类型 |
| resourceType | string | 资源类型（User/Group） |
| resourceId | string | 资源 ID |
| status | string | 状态（success/failed） |
| errorMessage | string | 错误消息 |
| details | Record<string> | 详细信息 |
| timestamp | string | 时间戳 |

**枚举定义**

```
SyncDirection:
  - inbound（从 IdP 同步到平台）
  - outbound（从平台同步到 IdP）
  - bidirectional（双向同步）

SCIMOperation:
  - create（创建）
  - update（更新）
  - delete（删除）
  - replace（替换）
```

#### API 接口

**标签组**：`SSO & Identity`

**9. 获取 SCIM 配置**

```
GET /api/v1/organizations/{organizationId}/sso/scim/config
```

**响应**
```
ApiResponse<SCIMConfiguration>
```

**10. 更新 SCIM 配置**

```
PUT /api/v1/organizations/{organizationId}/sso/scim/config
```

**请求体**
```json
{
  "enabled": true,
  "syncDirection": "inbound",
  "autoCreateUsers": true,
  "autoUpdateUsers": true,
  "autoDeactivateUsers": false
}
```

**响应**
```
ApiResponse<SCIMConfiguration>
```

**11. 生成 SCIM Token**

```
POST /api/v1/organizations/{organizationId}/sso/scim/token/generate
```

**响应**
```
ApiResponse<{
  token: string,
  baseUrl: string,
  expiresAt: string
}>
```

**12. 吊销 SCIM Token**

```
POST /api/v1/organizations/{organizationId}/sso/scim/token/revoke
```

**响应**
```
ApiResponse<{}>
```

**13. 获取 SCIM 同步日志**

```
GET /api/v1/organizations/{organizationId}/sso/scim/logs
```

**请求参数**
- `operation`（query, SCIMOperation）：操作类型
- `status`（query, string）：状态
- `startDate`（query, string）：开始时间
- `endDate`（query, string）：结束时间
- `page`（query, int32）：页码
- `pageSize`（query, int32）：每页数量

**响应**
```
ApiResponse<Page<SCIMSyncLog>>
```

**14. 手动触发 SCIM 同步**

```
POST /api/v1/organizations/{organizationId}/sso/scim/sync
```

**响应**
```
ApiResponse<{
  syncJobId: string,
  status: string
}>
```

**15. SCIM 2.0 用户端点（标准）**

```
GET /scim/v2/Users
GET /scim/v2/Users/{userId}
POST /scim/v2/Users
PUT /scim/v2/Users/{userId}
PATCH /scim/v2/Users/{userId}
DELETE /scim/v2/Users/{userId}
```

遵循 SCIM 2.0 RFC 7644 标准

**16. SCIM 2.0 组端点（标准）**

```
GET /scim/v2/Groups
GET /scim/v2/Groups/{groupId}
POST /scim/v2/Groups
PUT /scim/v2/Groups/{groupId}
PATCH /scim/v2/Groups/{groupId}
DELETE /scim/v2/Groups/{groupId}
```

## 三、审计日志 API 设计

### 3.1 审计日志模块

#### 数据模型

**审计日志（Audit Log）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 日志唯一标识 |
| organizationId | string | 组织 ID |
| workspaceId | string | 工作区 ID（可选） |
| actor | AuditActor | 操作者信息 |
| action | AuditAction | 操作类型 |
| resource | AuditResource | 资源信息 |
| result | AuditResult | 操作结果 |
| changes | AuditChange[] | 变更详情 |
| context | AuditContext | 上下文信息 |
| timestamp | string | 时间戳 |
| metadata | Record<string> | 额外元数据 |

**操作者（Audit Actor）**

| 字段 | 类型 | 说明 |
|------|------|------|
| type | ActorType | 类型（user/apikey/system） |
| id | string | ID |
| displayName | string | 显示名称 |
| email | string | 邮箱 |
| role | string | 角色 |

**审计操作（Audit Action）**

| 字段 | 类型 | 说明 |
|------|------|------|
| category | ActionCategory | 分类 |
| name | string | 操作名称 |
| description | Message | 描述 |

**审计资源（Audit Resource）**

| 字段 | 类型 | 说明 |
|------|------|------|
| type | ResourceType | 资源类型 |
| id | string | 资源 ID |
| name | string | 资源名称 |
| parentType | ResourceType | 父资源类型 |
| parentId | string | 父资源 ID |

**审计结果（Audit Result）**

| 字段 | 类型 | 说明 |
|------|------|------|
| status | ResultStatus | 状态（success/failure/partial） |
| errorCode | ErrorCode | 错误码 |
| errorMessage | Message | 错误消息 |

**审计变更（Audit Change）**

| 字段 | 类型 | 说明 |
|------|------|------|
| field | string | 字段名 |
| oldValue | unknown | 旧值 |
| newValue | unknown | 新值 |
| changeType | ChangeType | 变更类型 |

**审计上下文（Audit Context）**

| 字段 | 类型 | 说明 |
|------|------|------|
| ipAddress | string | IP 地址 |
| userAgent | string | User Agent |
| location | Location | 地理位置 |
| sessionId | string | 会话 ID |
| requestId | string | 请求 ID |

**地理位置（Location）**

| 字段 | 类型 | 说明 |
|------|------|------|
| country | string | 国家 |
| region | string | 地区 |
| city | string | 城市 |
| timezone | string | 时区 |

**枚举定义**

```
ActorType:
  - user（用户）
  - apikey（API 密钥）
  - system（系统）
  - webhook（Webhook）

ActionCategory:
  - authentication（认证）
  - authorization（授权）
  - data_access（数据访问）
  - data_modification（数据修改）
  - configuration（配置变更）
  - user_management（用户管理）
  - permission_management（权限管理）
  - billing（计费）
  - security（安全）
  - compliance（合规）

ResourceType:
  - user（用户）
  - organization（组织）
  - workspace（工作区）
  - document（文档）
  - data_row（数据行）
  - view（视图）
  - comment（评论）
  - apikey（API 密钥）
  - webhook（Webhook）
  - subscription（订阅）
  - invoice（账单）

ResultStatus:
  - success（成功）
  - failure（失败）
  - partial（部分成功）

ChangeType:
  - create（创建）
  - update（更新）
  - delete（删除）
```

#### API 接口

**标签组**：`Audit & Compliance`

**1. 查询审计日志**

```
GET /api/v1/organizations/{organizationId}/audit-logs
```

**请求参数**
- `actorId`（query, string）：操作者 ID
- `actorType`（query, ActorType）：操作者类型
- `actionCategory`（query, ActionCategory）：操作分类
- `actionName`（query, string）：操作名称
- `resourceType`（query, ResourceType）：资源类型
- `resourceId`（query, string）：资源 ID
- `resultStatus`（query, ResultStatus）：结果状态
- `startDate`（query, string）：开始时间
- `endDate`（query, string）：结束时间
- `ipAddress`（query, string）：IP 地址
- `search`（query, string）：全文搜索
- `page`（query, int32）：页码
- `pageSize`（query, int32）：每页数量

**响应**
```
ApiResponse<Page<AuditLog>>
```

**2. 获取审计日志详情**

```
GET /api/v1/organizations/{organizationId}/audit-logs/{logId}
```

**响应**
```
ApiResponse<AuditLog>
```

**3. 导出审计日志**

```
POST /api/v1/organizations/{organizationId}/audit-logs/export
```

**请求体**
```json
{
  "format": "csv" | "json" | "pdf",
  "filters": {
    "startDate": "2024-01-01T00:00:00Z",
    "endDate": "2024-12-31T23:59:59Z",
    "actionCategory": "data_modification"
  },
  "includeFields": ["timestamp", "actor", "action", "resource"]
}
```

**响应**
```
ApiResponse<{
  exportId: string,
  status: "processing" | "completed" | "failed",
  downloadUrl: string,
  expiresAt: string
}>
```

**4. 获取导出任务状态**

```
GET /api/v1/organizations/{organizationId}/audit-logs/exports/{exportId}
```

**响应**
```
ApiResponse<{
  exportId: string,
  status: string,
  progress: float64,
  downloadUrl: string,
  expiresAt: string
}>
```

**5. 获取审计统计**

```
GET /api/v1/organizations/{organizationId}/audit-logs/statistics
```

**请求参数**
- `startDate`（query, string）：开始时间
- `endDate`（query, string）：结束时间
- `groupBy`（query, string）：分组维度（action/actor/resource）

**响应**
```
ApiResponse<{
  totalEvents: int64,
  successCount: int64,
  failureCount: int64,
  topActions: ActionStat[],
  topActors: ActorStat[],
  topResources: ResourceStat[],
  timeline: TimelineStat[]
}>
```

其中统计结构：
```
ActionStat: { actionName: string, count: int64 }
ActorStat: { actorId: string, actorName: string, count: int64 }
ResourceStat: { resourceType: ResourceType, count: int64 }
TimelineStat: { timestamp: string, count: int64 }
```

**6. 创建审计日志告警规则**

```
POST /api/v1/organizations/{organizationId}/audit-logs/alert-rules
```

**请求体**
```json
{
  "name": "连续登录失败告警",
  "enabled": true,
  "conditions": {
    "actionCategory": "authentication",
    "actionName": "login",
    "resultStatus": "failure",
    "threshold": 5,
    "timeWindow": 300
  },
  "actions": {
    "email": ["admin@example.com"],
    "webhook": "https://alert.example.com/webhook"
  }
}
```

**响应**
```
ApiResponse<{
  ruleId: string,
  name: string,
  enabled: boolean,
  createdAt: string
}>
```

**7. 列出告警规则**

```
GET /api/v1/organizations/{organizationId}/audit-logs/alert-rules
```

**响应**
```
ApiResponse<AlertRule[]>
```

**8. 删除告警规则**

```
DELETE /api/v1/organizations/{organizationId}/audit-logs/alert-rules/{ruleId}
```

**响应**
```
ApiResponse<{}>
```

### 3.2 合规性报告模块

#### API 接口

**标签组**：`Audit & Compliance`

**9. 生成合规性报告**

```
POST /api/v1/organizations/{organizationId}/compliance/reports
```

**请求体**
```json
{
  "reportType": "gdpr" | "soc2" | "hipaa" | "custom",
  "periodStart": "2024-01-01T00:00:00Z",
  "periodEnd": "2024-12-31T23:59:59Z",
  "includeAccessLogs": true,
  "includeDataChanges": true,
  "includePermissionChanges": true
}
```

**响应**
```
ApiResponse<{
  reportId: string,
  status: "generating" | "completed" | "failed",
  downloadUrl: string,
  expiresAt: string
}>
```

**10. 获取数据访问记录（GDPR）**

```
GET /api/v1/organizations/{organizationId}/compliance/data-access
```

**请求参数**
- `userId`（query, string）：用户 ID
- `dataType`（query, string）：数据类型
- `startDate`（query, string）：开始时间
- `endDate`（query, string）：结束时间

**响应**
```
ApiResponse<Page<DataAccessLog>>
```

其中 `DataAccessLog` 结构：
```
{
  timestamp: string,
  accessor: AuditActor,
  dataType: string,
  dataId: string,
  operation: string,
  purpose: string
}
```

**11. 获取数据保留策略**

```
GET /api/v1/organizations/{organizationId}/compliance/retention-policies
```

**响应**
```
ApiResponse<{
  policies: RetentionPolicy[]
}>
```

其中 `RetentionPolicy` 结构：
```
{
  dataType: string,
  retentionDays: int32,
  autoDeleteEnabled: boolean,
  legalHoldExempt: boolean
}
```

**12. 更新数据保留策略**

```
PUT /api/v1/organizations/{organizationId}/compliance/retention-policies
```

**请求体**
```json
{
  "policies": [
    {
      "dataType": "audit_logs",
      "retentionDays": 365,
      "autoDeleteEnabled": true
    },
    {
      "dataType": "deleted_documents",
      "retentionDays": 30,
      "autoDeleteEnabled": true
    }
  ]
}
```

**响应**
```
ApiResponse<{
  policies: RetentionPolicy[]
}>
```

## 四、通知系统 API 设计

### 4.1 通知模块

#### 数据模型

**通知（Notification）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 通知唯一标识 |
| recipientId | string | 接收者用户 ID |
| organizationId | string | 组织 ID |
| workspaceId | string | 工作区 ID（可选） |
| type | NotificationType | 通知类型 |
| category | NotificationCategory | 通知分类 |
| priority | NotificationPriority | 优先级 |
| title | Message | 标题 |
| content | Message | 内容 |
| actionUrl | string | 操作链接 |
| actionLabel | Message | 操作按钮文本 |
| actor | UserRef | 触发者 |
| relatedResource | NotificationResource | 相关资源 |
| readAt | string | 阅读时间 |
| archivedAt | string | 归档时间 |
| createdAt | string | 创建时间 |
| expiresAt | string | 过期时间 |

**通知资源（Notification Resource）**

| 字段 | 类型 | 说明 |
|------|------|------|
| type | ResourceType | 资源类型 |
| id | string | 资源 ID |
| name | string | 资源名称 |
| url | string | 资源链接 |

**通知偏好（Notification Preference）**

| 字段 | 类型 | 说明 |
|------|------|------|
| userId | string | 用户 ID |
| category | NotificationCategory | 通知分类 |
| channels | NotificationChannel[] | 启用的通知渠道 |
| frequency | NotificationFrequency | 通知频率 |
| quietHoursEnabled | boolean | 启用勿扰时段 |
| quietHoursStart | string | 勿扰开始时间（HH:mm） |
| quietHoursEnd | string | 勿扰结束时间（HH:mm） |
| updatedAt | string | 更新时间 |

**通知投递记录（Notification Delivery）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 投递记录 ID |
| notificationId | string | 通知 ID |
| channel | NotificationChannel | 投递渠道 |
| status | DeliveryStatus | 投递状态 |
| recipientAddress | string | 接收地址 |
| sentAt | string | 发送时间 |
| deliveredAt | string | 送达时间 |
| failureReason | string | 失败原因 |
| retryCount | int32 | 重试次数 |

**枚举定义**

```
NotificationType:
  - mention（@提及）
  - comment（评论）
  - approval_request（审批请求）
  - approval_approved（审批通过）
  - approval_rejected（审批拒绝）
  - document_shared（文档分享）
  - workspace_invitation（工作区邀请）
  - organization_invitation（组织邀请）
  - data_changed（数据变更）
  - system_announcement（系统公告）
  - quota_warning（配额警告）
  - invoice_due（账单到期）
  - payment_failed（支付失败）

NotificationCategory:
  - collaboration（协作）
  - approval（审批）
  - sharing（分享）
  - system（系统）
  - billing（计费）
  - security（安全）

NotificationPriority:
  - low（低）
  - normal（正常）
  - high（高）
  - urgent（紧急）

NotificationChannel:
  - in_app（应用内）
  - email（邮件）
  - sms（短信）
  - push（推送通知）
  - webhook（Webhook）

NotificationFrequency:
  - realtime（实时）
  - hourly_digest（每小时摘要）
  - daily_digest（每日摘要）
  - weekly_digest（每周摘要）
  - disabled（禁用）

DeliveryStatus:
  - pending（待发送）
  - sent（已发送）
  - delivered（已送达）
  - failed（失败）
  - bounced（退回）
```

#### API 接口

**标签组**：`Notifications`

**1. 获取当前用户通知列表**

```
GET /api/v1/users/me/notifications
```

**请求参数**
- `category`（query, NotificationCategory）：通知分类
- `type`（query, NotificationType）：通知类型
- `unreadOnly`（query, boolean）：仅未读
- `page`（query, int32）：页码
- `pageSize`（query, int32）：每页数量

**响应**
```
ApiResponse<Page<Notification>>
```

**2. 获取未读通知数量**

```
GET /api/v1/users/me/notifications/unread-count
```

**响应**
```
ApiResponse<{
  total: int64,
  byCategory: Record<NotificationCategory, int64>
}>
```

**3. 标记通知为已读**

```
POST /api/v1/users/me/notifications/{notificationId}/read
```

**响应**
```
ApiResponse<Notification>
```

**4. 批量标记为已读**

```
POST /api/v1/users/me/notifications/mark-read
```

**请求体**
```json
{
  "notificationIds": ["notif_1", "notif_2"],
  "markAll": false,
  "category": "collaboration"
}
```

**响应**
```
ApiResponse<{
  markedCount: int32
}>
```

**5. 归档通知**

```
POST /api/v1/users/me/notifications/{notificationId}/archive
```

**响应**
```
ApiResponse<Notification>
```

**6. 删除通知**

```
DELETE /api/v1/users/me/notifications/{notificationId}
```

**响应**
```
ApiResponse<{}>
```

**7. 获取通知偏好设置**

```
GET /api/v1/users/me/notification-preferences
```

**响应**
```
ApiResponse<NotificationPreference[]>
```

**8. 更新通知偏好设置**

```
PUT /api/v1/users/me/notification-preferences
```

**请求体**
```json
{
  "preferences": [
    {
      "category": "collaboration",
      "channels": ["in_app", "email"],
      "frequency": "realtime"
    },
    {
      "category": "billing",
      "channels": ["email"],
      "frequency": "realtime"
    },
    {
      "category": "system",
      "channels": ["in_app"],
      "frequency": "daily_digest"
    }
  ],
  "quietHoursEnabled": true,
  "quietHoursStart": "22:00",
  "quietHoursEnd": "08:00"
}
```

**响应**
```
ApiResponse<NotificationPreference[]>
```

**9. 测试通知发送**

```
POST /api/v1/users/me/notification-preferences/test
```

**请求体**
```json
{
  "channel": "email",
  "category": "collaboration"
}
```

**响应**
```
ApiResponse<{
  sent: boolean,
  deliveryId: string
}>
```

### 4.2 实时通知推送

#### API 接口

**标签组**：`Notifications`

**10. 建立通知 WebSocket 连接**

```
WS /api/v1/users/me/notifications/stream
```

**连接参数**
- `Authorization`（header）：Bearer Token

**消息格式**

服务端推送消息：
```json
{
  "type": "notification",
  "data": {
    "notification": { /* Notification 对象 */ }
  }
}
```

客户端心跳消息：
```json
{
  "type": "ping"
}
```

服务端心跳响应：
```json
{
  "type": "pong"
}
```

**11. 订阅推送通知（移动端）**

```
POST /api/v1/users/me/push-subscriptions
```

**请求体**
```json
{
  "platform": "ios" | "android" | "web",
  "deviceToken": "device_token_here",
  "deviceName": "iPhone 15 Pro",
  "appVersion": "1.2.3"
}
```

**响应**
```
ApiResponse<{
  subscriptionId: string,
  createdAt: string
}>
```

**12. 取消推送订阅**

```
DELETE /api/v1/users/me/push-subscriptions/{subscriptionId}
```

**响应**
```
ApiResponse<{}>
```

**13. 列出推送订阅**

```
GET /api/v1/users/me/push-subscriptions
```

**响应**
```
ApiResponse<PushSubscription[]>
```

其中 `PushSubscription` 结构：
```
{
  id: string,
  platform: string,
  deviceName: string,
  lastUsedAt: string,
  createdAt: string
}
```

### 4.3 通知管理（管理员）

#### API 接口

**标签组**：`Notifications`

**14. 发送系统公告**

```
POST /api/v1/organizations/{organizationId}/notifications/announcements
```

**请求体**
```json
{
  "title": {
    "zh": "系统维护通知",
    "en": "System Maintenance Notice"
  },
  "content": {
    "zh": "系统将于今晚22:00进行维护",
    "en": "System maintenance at 22:00 tonight"
  },
  "priority": "high",
  "channels": ["in_app", "email"],
  "targetAudience": {
    "allMembers": true,
    "workspaceIds": [],
    "userIds": []
  },
  "scheduleAt": "2024-12-06T10:00:00Z",
  "expiresAt": "2024-12-07T22:00:00Z"
}
```

**响应**
```
ApiResponse<{
  announcementId: string,
  recipientCount: int32,
  status: "scheduled" | "sent"
}>
```

**15. 获取通知投递统计**

```
GET /api/v1/organizations/{organizationId}/notifications/delivery-stats
```

**请求参数**
- `startDate`（query, string）：开始时间
- `endDate`（query, string）：结束时间
- `channel`（query, NotificationChannel）：渠道

**响应**
```
ApiResponse<{
  totalSent: int64,
  totalDelivered: int64,
  totalFailed: int64,
  deliveryRate: float64,
  byChannel: Record<NotificationChannel, ChannelStats>
}>
```

其中 `ChannelStats` 结构：
```
{
  sent: int64,
  delivered: int64,
  failed: int64,
  deliveryRate: float64
}
```

**16. 获取通知投递日志**

```
GET /api/v1/organizations/{organizationId}/notifications/deliveries
```

**请求参数**
- `notificationId`（query, string）：通知 ID
- `channel`（query, NotificationChannel）：渠道
- `status`（query, DeliveryStatus）：状态
- `page`（query, int32）：页码
- `pageSize`（query, int32）：每页数量

**响应**
```
ApiResponse<Page<NotificationDelivery>>
```

## 五、TypeSpec 文件结构建议

基于项目现有架构，建议按以下结构组织新增 API 定义：

```
api/
├── billing/                    # 商业化运营模块
│   ├── index.tsp              # 模块入口
│   ├── models.tsp             # 数据模型（Plan, Subscription, Invoice 等）
│   ├── plans.tsp              # 订阅计划 API
│   ├── subscriptions.tsp      # 订阅管理 API
│   ├── invoices.tsp           # 账单管理 API
│   ├── payments.tsp           # 支付方式 API
│   └── usage.tsp              # 使用量与配额 API
│
├── sso/                        # 单点登录模块
│   ├── index.tsp              # 模块入口
│   ├── models.tsp             # 数据模型（SAML, SCIM 配置等）
│   ├── saml.tsp               # SAML SSO API
│   └── scim.tsp               # SCIM 用户同步 API
│
├── audit/                      # 审计模块
│   ├── index.tsp              # 模块入口
│   ├── models.tsp             # 数据模型（AuditLog 等）
│   ├── logs.tsp               # 审计日志 API
│   ├── compliance.tsp         # 合规性报告 API
│   └── alerts.tsp             # 告警规则 API
│
└── notifications/              # 通知模块
    ├── index.tsp              # 模块入口
    ├── models.tsp             # 数据模型（Notification 等）
    ├── user-notifications.tsp # 用户通知 API
    ├── preferences.tsp        # 通知偏好 API
    ├── push.tsp               # 推送订阅 API
    └── admin.tsp              # 管理员通知 API
```

## 六、共享模型扩展

需要在 `api/shared/common.tsp` 中添加以下错误码：

```typescript
enum ErrorCode {
  // ... 现有错误码 ...
  
  // 订阅与计费相关
  PLAN_NOT_FOUND,
  SUBSCRIPTION_NOT_FOUND,
  SUBSCRIPTION_ALREADY_EXISTS,
  SUBSCRIPTION_CANNOT_DOWNGRADE,
  INVOICE_NOT_FOUND,
  PAYMENT_FAILED,
  PAYMENT_METHOD_INVALID,
  QUOTA_EXCEEDED,
  
  // SSO 相关
  SSO_NOT_CONFIGURED,
  SSO_CONFIG_INVALID,
  SAML_ASSERTION_INVALID,
  SCIM_TOKEN_INVALID,
  SSO_PROVIDER_ERROR,
  
  // 审计相关
  AUDIT_LOG_NOT_FOUND,
  EXPORT_JOB_NOT_FOUND,
  ALERT_RULE_NOT_FOUND,
  
  // 通知相关
  NOTIFICATION_NOT_FOUND,
  NOTIFICATION_PREFERENCE_INVALID,
  PUSH_SUBSCRIPTION_INVALID,
}
```

## 七、API 分组标签（x-tagGroups）

在 `main.tsp` 或相关脚本中配置以下标签组：

```json
{
  "x-tagGroups": [
    {
      "name": "认证与授权",
      "tags": ["Authentication", "Users", "SSO & Identity"]
    },
    {
      "name": "租户管理",
      "tags": ["Organizations", "Workspaces"]
    },
    {
      "name": "文档系统",
      "tags": ["Documents", "Metadata", "Views", "Data"]
    },
    {
      "name": "协作与工作流",
      "tags": ["Comments", "Approvals", "Requests", "Revisions"]
    },
    {
      "name": "商业化运营",
      "tags": ["Billing & Subscriptions"]
    },
    {
      "name": "审计与合规",
      "tags": ["Audit & Compliance"]
    },
    {
      "name": "通知系统",
      "tags": ["Notifications"]
    },
    {
      "name": "扩展功能",
      "tags": ["Webhooks"]
    }
  ]
}
```

## 八、实施优先级建议

### 第一阶段（核心商业化能力）
1. 订阅计划管理 API（plans.tsp）
2. 订阅管理 API（subscriptions.tsp）
3. 使用量与配额 API（usage.tsp）
4. 基础审计日志 API（logs.tsp）

### 第二阶段（企业级功能）
5. 计费与支付 API（invoices.tsp, payments.tsp）
6. SAML SSO API（saml.tsp）
7. 通知系统核心 API（user-notifications.tsp, preferences.tsp）
8. 审计日志导出与统计（logs.tsp 扩展）

### 第三阶段（高级功能）
9. SCIM 用户同步 API（scim.tsp）
10. 合规性报告 API（compliance.tsp）
11. 实时通知推送（push.tsp）
12. 系统公告管理（admin.tsp）

## 九、国际化与多语言支持 API 设计

### 9.1 多语言资源管理模块

#### 数据模型

**语言配置（Language Config）**

| 字段 | 类型 | 说明 |
|------|------|------|
| code | string | 语言代码（ISO 639-1，如 zh、en、ja） |
| name | Message | 语言名称（多语言） |
| nativeName | string | 本地语言名称（如"中文"、"English"） |
| enabled | boolean | 是否启用 |
| isDefault | boolean | 是否为默认语言 |
| direction | TextDirection | 文本方向（ltr/rtl） |
| dateFormat | string | 日期格式（如 YYYY-MM-DD） |
| timeFormat | string | 时间格式（如 HH:mm:ss） |
| numberFormat | NumberFormat | 数字格式配置 |
| currencyFormat | CurrencyFormat | 货币格式配置 |
| sortOrder | int32 | 排序顺序 |

**数字格式（Number Format）**

| 字段 | 类型 | 说明 |
|------|------|------|
| decimalSeparator | string | 小数分隔符（如 . 或 ,） |
| thousandSeparator | string | 千分位分隔符 |
| decimalPlaces | int32 | 小数位数 |

**货币格式（Currency Format）**

| 字段 | 类型 | 说明 |
|------|------|------|
| currencyCode | string | 货币代码（ISO 4217，如 CNY、USD） |
| symbol | string | 货币符号（如 ¥、$） |
| symbolPosition | string | 符号位置（before/after） |
| decimalPlaces | int32 | 小数位数 |

**翻译资源（Translation Resource）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 资源唯一标识 |
| namespace | string | 命名空间（如 common、billing、notifications） |
| key | string | 翻译键 |
| translations | Record<string> | 各语言翻译（语言代码 -> 翻译文本） |
| context | string | 上下文说明 |
| category | ResourceCategory | 资源分类 |
| updatedAt | string | 更新时间 |
| updatedBy | string | 更新者 |

**枚举定义**

```
TextDirection:
  - ltr（从左到右）
  - rtl（从右到左）

ResourceCategory:
  - ui（界面文本）
  - field_label（字段标签）
  - validation_message（验证消息）
  - notification_template（通知模板）
  - email_template（邮件模板）
  - system_message（系统消息）
```

#### API 接口

**标签组**：`Internationalization`

**1. 获取支持的语言列表**

```
GET /api/v1/i18n/languages
```

**请求参数**
- `enabledOnly`（query, boolean）：仅返回已启用的语言

**响应**
```
ApiResponse<LanguageConfig[]>
```

**2. 获取语言详细配置**

```
GET /api/v1/i18n/languages/{languageCode}
```

**响应**
```
ApiResponse<LanguageConfig>
```

**3. 获取翻译资源**

```
GET /api/v1/i18n/translations
```

**请求参数**
- `language`（query, string, 必填）：语言代码
- `namespace`（query, string）：命名空间过滤
- `keys`（query, string[]）：指定键列表
- `category`（query, ResourceCategory）：资源分类

**响应**
```
ApiResponse<{
  language: string,
  translations: Record<string, string>,
  fallbackLanguage: string,
  completeness: float64
}>
```

**4. 批量获取多语言翻译**

```
POST /api/v1/i18n/translations/batch
```

**请求体**
```json
{
  "languages": ["zh", "en", "ja"],
  "namespace": "common",
  "keys": ["button.save", "button.cancel", "message.success"]
}
```

**响应**
```
ApiResponse<{
  translations: Record<string, Record<string, string>>
}>
```

其中响应结构示例：
```json
{
  "zh": {
    "button.save": "保存",
    "button.cancel": "取消"
  },
  "en": {
    "button.save": "Save",
    "button.cancel": "Cancel"
  }
}
```

**5. 检测文本语言**

```
POST /api/v1/i18n/detect-language
```

**请求体**
```json
{
  "text": "这是一段测试文本"
}
```

**响应**
```
ApiResponse<{
  detectedLanguage: string,
  confidence: float64,
  alternatives: LanguageDetection[]
}>
```

其中 `LanguageDetection` 结构：
```
{
  language: string,
  confidence: float64
}
```

**6. 获取翻译完整度统计**

```
GET /api/v1/i18n/translation-coverage
```

**请求参数**
- `namespace`（query, string）：命名空间过滤

**响应**
```
ApiResponse<{
  languages: LanguageCoverage[]
}>
```

其中 `LanguageCoverage` 结构：
```
{
  language: string,
  totalKeys: int32,
  translatedKeys: int32,
  missingKeys: int32,
  completeness: float64,
  lastUpdated: string
}
```

### 9.2 用户偏好设置模块

#### 数据模型

**用户偏好（User Preferences）**

| 字段 | 类型 | 说明 |
|------|------|------|
| userId | string | 用户 ID |
| general | GeneralPreferences | 通用偏好 |
| appearance | AppearancePreferences | 外观偏好 |
| notifications | NotificationPreferences | 通知偏好 |
| regional | RegionalPreferences | 地区偏好 |
| accessibility | AccessibilityPreferences | 辅助功能偏好 |
| privacy | PrivacyPreferences | 隐私偏好 |
| updatedAt | string | 更新时间 |

**通用偏好（General Preferences）**

| 字段 | 类型 | 说明 |
|------|------|------|
| defaultOrganizationId | string | 默认组织 ID |
| defaultWorkspaceId | string | 默认工作区 ID |
| defaultView | string | 默认视图类型 |
| startPage | string | 启动页 URL |
| itemsPerPage | int32 | 每页显示数量 |
| enableKeyboardShortcuts | boolean | 启用快捷键 |
| enableAnimations | boolean | 启用动画效果 |

**外观偏好（Appearance Preferences）**

| 字段 | 类型 | 说明 |
|------|------|------|
| theme | ThemeMode | 主题模式 |
| accentColor | string | 强调色（HEX） |
| fontFamily | string | 字体系列 |
| fontSize | FontSize | 字体大小 |
| density | Density | 界面密度 |
| sidebarCollapsed | boolean | 侧边栏折叠状态 |

**地区偏好（Regional Preferences）**

| 字段 | 类型 | 说明 |
|------|------|------|
| language | string | 界面语言 |
| contentLanguages | string[] | 内容语言偏好（优先顺序） |
| timezone | string | 时区（IANA 格式） |
| dateFormat | string | 日期格式 |
| timeFormat | TimeFormat | 时间格式 |
| firstDayOfWeek | DayOfWeek | 每周首日 |
| currency | string | 默认货币 |
| numberFormat | NumberFormatPreference | 数字格式偏好 |

**辅助功能偏好（Accessibility Preferences）**

| 字段 | 类型 | 说明 |
|------|------|------|
| highContrast | boolean | 高对比度 |
| reducedMotion | boolean | 减少动画 |
| screenReader | boolean | 屏幕阅读器支持 |
| keyboardNavigation | boolean | 键盘导航优化 |
| focusIndicator | boolean | 焦点指示器增强 |
| textToSpeech | boolean | 文本转语音 |

**隐私偏好（Privacy Preferences）**

| 字段 | 类型 | 说明 |
|------|------|------|
| showPresenceStatus | boolean | 显示在线状态 |
| allowAnalytics | boolean | 允许分析数据收集 |
| allowMarketing | boolean | 允许营销通知 |
| showProfileToOthers | boolean | 向他人显示个人资料 |
| shareActivityStatus | boolean | 分享活动状态 |

**枚举定义**

```
ThemeMode:
  - light（浅色）
  - dark（深色）
  - auto（自动，跟随系统）

FontSize:
  - small（小）
  - medium（中）
  - large（大）
  - extra_large（特大）

Density:
  - compact（紧凑）
  - comfortable（舒适）
  - spacious（宽松）

TimeFormat:
  - 12h（12小时制）
  - 24h（24小时制）

DayOfWeek:
  - sunday（周日）
  - monday（周一）
  - saturday（周六）
```

#### API 接口

**标签组**：`User Preferences`

**7. 获取当前用户偏好设置**

```
GET /api/v1/users/me/preferences
```

**请求参数**
- `section`（query, string）：获取特定部分（general/appearance/notifications/regional/accessibility/privacy）

**响应**
```
ApiResponse<UserPreferences>
```

**8. 更新用户偏好设置**

```
PATCH /api/v1/users/me/preferences
```

**请求体**
```json
{
  "general": {
    "defaultOrganizationId": "org_123",
    "itemsPerPage": 50
  },
  "appearance": {
    "theme": "dark",
    "fontSize": "medium"
  },
  "regional": {
    "language": "zh",
    "timezone": "Asia/Shanghai",
    "dateFormat": "YYYY-MM-DD",
    "timeFormat": "24h",
    "firstDayOfWeek": "monday",
    "currency": "CNY"
  },
  "accessibility": {
    "reducedMotion": true,
    "highContrast": false
  },
  "privacy": {
    "showPresenceStatus": true,
    "allowAnalytics": true
  }
}
```

**响应**
```
ApiResponse<UserPreferences>
```

**9. 重置用户偏好为默认值**

```
POST /api/v1/users/me/preferences/reset
```

**请求体**
```json
{
  "sections": ["appearance", "notifications"],
  "resetAll": false
}
```

**响应**
```
ApiResponse<UserPreferences>
```

**10. 获取用户语言偏好**

```
GET /api/v1/users/me/preferences/language
```

**响应**
```
ApiResponse<{
  primaryLanguage: string,
  contentLanguages: string[],
  autoDetect: boolean,
  fallbackLanguage: string
}>
```

**11. 更新用户语言偏好**

```
PUT /api/v1/users/me/preferences/language
```

**请求体**
```json
{
  "primaryLanguage": "zh",
  "contentLanguages": ["zh", "en", "ja"],
  "autoDetect": true,
  "fallbackLanguage": "en"
}
```

**响应**
```
ApiResponse<{
  primaryLanguage: string,
  contentLanguages: string[],
  autoDetect: boolean,
  fallbackLanguage: string
}>
```

**12. 获取时区列表**

```
GET /api/v1/i18n/timezones
```

**请求参数**
- `region`（query, string）：按地区过滤（如 Asia、Europe）

**响应**
```
ApiResponse<{
  timezones: Timezone[]
}>
```

其中 `Timezone` 结构：
```
{
  id: string,
  name: string,
  offset: string,
  region: string,
  displayName: Message
}
```

**13. 获取货币列表**

```
GET /api/v1/i18n/currencies
```

**请求参数**
- `includeInactive`（query, boolean）：是否包含不活跃的货币

**响应**
```
ApiResponse<{
  currencies: Currency[]
}>
```

其中 `Currency` 结构：
```
{
  code: string,
  name: Message,
  symbol: string,
  decimalPlaces: int32,
  active: boolean
}
```

**14. 格式化数据预览**

```
POST /api/v1/i18n/format-preview
```

**请求体**
```json
{
  "language": "zh",
  "timezone": "Asia/Shanghai",
  "dateFormat": "YYYY-MM-DD",
  "timeFormat": "24h",
  "currency": "CNY",
  "samples": {
    "date": "2024-12-06T10:30:00Z",
    "number": 1234567.89,
    "currency": 9999.99
  }
}
```

**响应**
```
ApiResponse<{
  formatted: {
    date: string,
    time: string,
    datetime: string,
    number: string,
    currency: string
  }
}>
```

### 9.3 组织级国际化设置

#### API 接口

**标签组**：`Internationalization`

**15. 获取组织国际化配置**

```
GET /api/v1/organizations/{organizationId}/i18n/config
```

**响应**
```
ApiResponse<{
  defaultLanguage: string,
  supportedLanguages: string[],
  enforceLanguage: boolean,
  autoDetectLanguage: boolean,
  fallbackLanguage: string,
  defaultTimezone: string,
  defaultCurrency: string,
  dateFormat: string,
  timeFormat: string,
  numberFormat: NumberFormat
}>
```

**16. 更新组织国际化配置**

```
PUT /api/v1/organizations/{organizationId}/i18n/config
```

**请求体**
```json
{
  "defaultLanguage": "zh",
  "supportedLanguages": ["zh", "en", "ja"],
  "enforceLanguage": false,
  "autoDetectLanguage": true,
  "fallbackLanguage": "en",
  "defaultTimezone": "Asia/Shanghai",
  "defaultCurrency": "CNY",
  "dateFormat": "YYYY-MM-DD",
  "timeFormat": "24h"
}
```

**响应**
```
ApiResponse<OrganizationI18nConfig>
```

**17. 获取组织自定义翻译**

```
GET /api/v1/organizations/{organizationId}/i18n/custom-translations
```

**请求参数**
- `language`（query, string）：语言代码
- `namespace`（query, string）：命名空间

**响应**
```
ApiResponse<{
  customTranslations: Record<string, string>,
  inheritedTranslations: Record<string, string>
}>
```

**18. 添加/更新组织自定义翻译**

```
PUT /api/v1/organizations/{organizationId}/i18n/custom-translations
```

**请求体**
```json
{
  "language": "zh",
  "namespace": "custom",
  "translations": {
    "field.custom_status": "自定义状态",
    "label.department": "部门名称"
  }
}
```

**响应**
```
ApiResponse<{
  added: int32,
  updated: int32,
  translations: Record<string, string>
}>
```

**19. 删除组织自定义翻译**

```
DELETE /api/v1/organizations/{organizationId}/i18n/custom-translations
```

**请求参数**
- `language`（query, string, 必填）：语言代码
- `keys`（query, string[], 必填）：要删除的键列表

**响应**
```
ApiResponse<{
  deleted: int32
}>
```

### 9.4 内容多语言支持

#### API 接口

**标签组**：`Internationalization`

**20. 翻译文档字段内容**

```
POST /api/v1/i18n/translate
```

**请求体**
```json
{
  "sourceLanguage": "zh",
  "targetLanguages": ["en", "ja"],
  "texts": [
    "产品名称",
    "这是产品描述"
  ],
  "context": "product_catalog"
}
```

**响应**
```
ApiResponse<{
  translations: TranslationResult[]
}>
```

其中 `TranslationResult` 结构：
```
{
  sourceText: string,
  translations: Record<string, string>,
  confidence: Record<string, float64>
}
```

**21. 获取翻译建议**

```
POST /api/v1/i18n/translation-suggestions
```

**请求体**
```json
{
  "text": "产品",
  "sourceLanguage": "zh",
  "targetLanguage": "en",
  "context": "field_label",
  "maxSuggestions": 5
}
```

**响应**
```
ApiResponse<{
  suggestions: TranslationSuggestion[]
}>
```

其中 `TranslationSuggestion` 结构：
```
{
  translation: string,
  confidence: float64,
  source: "machine" | "memory" | "glossary"
}
```

**22. 获取翻译术语表**

```
GET /api/v1/organizations/{organizationId}/i18n/glossary
```

**请求参数**
- `sourceLanguage`（query, string）：源语言
- `targetLanguage`（query, string）：目标语言

**响应**
```
ApiResponse<{
  entries: GlossaryEntry[]
}>
```

其中 `GlossaryEntry` 结构：
```
{
  id: string,
  term: string,
  translation: string,
  context: string,
  category: string,
  createdAt: string
}
```

**23. 添加术语到翻译术语表**

```
POST /api/v1/organizations/{organizationId}/i18n/glossary
```

**请求体**
```json
{
  "sourceLanguage": "zh",
  "targetLanguage": "en",
  "entries": [
    {
      "term": "订货单",
      "translation": "Purchase Order",
      "context": "business_document",
      "category": "general"
    }
  ]
}
```

**响应**
```
ApiResponse<{
  added: int32,
  entries: GlossaryEntry[]
}>
```

## 十、设计原则总结

1. **一致性**：遵循现有 API 设计规范，使用统一的响应格式（ApiResponse）和错误处理
2. **多语言支持**：所有面向用户的文本使用 Message 类型支持多语言，支持 `...Record<string>` 动态扩展
3. **RESTful 规范**：资源路径清晰，HTTP 方法语义准确
4. **分页支持**：列表接口统一使用 Page 模型
5. **可扩展性**：数据模型预留 metadata 字段，支持未来扩展
6. **安全优先**：敏感操作需要权限验证，审计日志完整记录
7. **企业就绪**：支持 SSO、审计、合规等企业级功能
8. **开发者友好**：清晰的文档、一致的命名、完整的错误提示
9. **国际化优先**：完整的多语言、时区、货币、格式化支持
10. **用户体验**：丰富的偏好设置，支持无障碍访问
