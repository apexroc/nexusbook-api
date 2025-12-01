/**
 * 常数和枚举定义
 * Constants and enums
 *
 * 集中定义所有模块共用的枚举类型。
 */
namespace NexusBook.Common;

/**
 * 请求状态
 * Request status
 */
enum RequestStatus {
    /**
     * 开放状态，待审核或直接应用
     * Open state, awaiting review or direct application
     */
    open,

    /**
     * 已合并，变更已生效
     * Merged, changes are effective
     */
    merged,

    /**
     * 已关闭，变更已拒绝或取消
     * Closed, changes rejected or canceled
     */
    closed,
}

/**
 * 审批状态
 * Approval status
 */
enum ApprovalStatus {
    /**
     * 待审批
     * Pending approval
     */
    pending,

    /**
     * 已批准
     * Approved
     */
    approved,

    /**
     * 已拒绝
     * Rejected
     */
    rejected,

    /**
     * 已取消
     * Canceled
     */
    canceled,
}

/**
 * 审批决议
 * Approval decision
 */
enum ApprovalDecision {
    /**
     * 批准
     * Approve
     */
    approve,

    /**
     * 拒绝
     * Reject
     */
    reject,

    /**
     * 请求修改
     * Request changes
     */
    request_changes,
}

/**
 * 视图类型
 * View type
 */
enum ViewType {
    /**
     * 表格视图
     * Table view
     */
    table,

    /**
     * 相册/网格视图
     * Gallery / grid view
     */
    gallery,

    /**
     * 看板视图
     * Kanban view
     */
    kanban,

    /**
     * 日历视图
     * Calendar view
     */
    calendar,

    /**
     * 图表视图
     * Chart view
     */
    chart,

    /**
     * 表单视图
     * Form view
     */
    form,

    /**
     * 地图视图
     * Map view
     */
    map,

    /**
     * 时间线视图
     * Timeline view
     */
    timeline,
}

/**
 * 字段类型
 * Field type
 */
enum FieldType {
    /**
     * 单行文本
     * Single line text
     */
    text,

    /**
     * 长文本
     * Long text
     */
    long_text,

    /**
     * 数字
     * Number
     */
    number,

    /**
     * 货币
     * Currency
     */
    currency,

    /**
     * 百分比
     * Percent
     */
    percent,

    /**
     * 布尔值
     * Boolean
     */
    boolean,

    /**
     * 日期
     * Date
     */
    date,

    /**
     * 日期时间
     * DateTime
     */
    datetime,

    /**
     * 单选
     * Single select
     */
    single_select,

    /**
     * 多选
     * Multi select
     */
    multi_select,

    /**
     * 附件
     * Attachment
     */
    attachment,

    /**
     * 用户
     * User
     */
    user,

    /**
     * 协作者
     * Collaborator
     */
    collaborator,

    /**
     * 关系字段
     * Relation
     */
    relation,

    /**
     * 查找字段
     * Lookup
     */
    lookup,

    /**
     * 汇总字段
     * Rollup
     */
    rollup,

    /**
     * 公式字段
     * Formula
     */
    formula,

    /**
     * 评分
     * Rating
     */
    rating,

    /**
     * 时间段
     * Duration
     */
    duration,
}

/**
 * 文档类型
 * Document type
 */
enum DocumentType {
    /**
     * 采购订单
     * Purchase order
     */
    purchaseOrder,

    /**
     * 发票
     * Invoice
     */
    invoice,

    /**
     * 产品
     * Product
     */
    product,

    /**
     * 库存
     * Inventory
     */
    inventory,

    /**
     * 项目
     * Project
     */
    project,

    /**
     * 销售
     * Sales
     */
    sales,

    /**
     * 人力资源
     * Human resource
     */
    hr,

    /**
     * 自定义
     * Custom
     */
    custom,
}
