# Apple Design 风格 API 文档

## 概述

NexusBook API 文档现在采用 **Apple Design** 风格，使用 Redocly 生成，提供现代化、优雅的阅读体验。

## 主要特性

### 🎨 视觉设计

- **Apple 官方配色**
  - 主色：`#007AFF`（Apple 蓝）
  - 成功色：`#34C759`（Apple 绿）
  - 警告色：`#FF9500`（Apple 橙）
  - 错误色：`#FF3B30`（Apple 红）
  
- **系统字体栈**
  - 正文：`-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto`
  - 代码：`SF Mono, Monaco, "Cascadia Code", "Roboto Mono"`
  
- **圆角设计**
  - 侧边栏：`12px` 圆角
  - 按钮/标签：`6-8px` 圆角
  - 代码块：`8px` 圆角

### 📱 侧边栏导航

- **左侧边栏** (280px)
  - 分组折叠导航
  - 实时搜索
  - 毛玻璃效果 (`backdrop-filter: blur(20px)`)
  - 悬停动画和活跃状态高亮
  
- **右侧代码面板**
  - 暗色主题
  - 多语言代码示例（cURL/JavaScript/Python/Java）
  - 语法高亮

### ✨ 交互效果

- 平滑过渡动画 (`transition: all 0.2s ease`)
- 悬停效果（`transform: translateY(-1px)`)
- 按钮阴影增强
- 滚动条美化

### 🌓 暗色模式

- 自动适配系统主题 (`prefers-color-scheme: dark`)
- 暗色背景 + 浅色文本
- 代码块暗色主题

### 📐 响应式设计

- 移动端适配
- 灵活布局
- 触摸友好的交互

## 构建和预览

### 生成文档

```bash
# 完整构建流程
make build-docs

# 包含以下步骤：
# 1. 编译 TypeSpec → OpenAPI
# 2. 使用 Redocly 生成 HTML（应用 redocly.yaml 配置）
# 3. 注入自定义 Apple Design CSS
```

### 本地预览

```bash
# 启动文档服务器
make serve-docs

# 或完整文档站点
make serve
```

访问 `http://localhost:8091` 查看效果。

## 文件结构

```
nexusbook-api/
├── redocly.yaml                          # Redocly 主配置
├── docs-src/
│   └── styles/
│       └── redocly-apple.css            # Apple Design 自定义样式（351 行）
├── scripts/
│   └── inject-apple-styles.js           # 样式注入脚本
├── dist/
│   └── redoc/
│       └── index.html                   # 生成的文档（已注入样式）
└── Makefile                             # 构建配置
```

## 配置说明

### redocly.yaml

核心配置文件，定义：

- **颜色主题**：Apple 配色方案
- **字体**：系统字体栈
- **侧边栏**：宽度、背景色、圆角
- **代码示例**：支持的语言
- **功能开关**：搜索、下载、展开响应等

### redocly-apple.css

自定义 CSS 增强：

- **侧边栏样式**：毛玻璃效果、悬停动画
- **标题**：Apple 风格字重和间距
- **HTTP 方法标签**：彩色圆角徽章
- **表格**：悬停高亮
- **暗色模式**：完整适配
- **滚动条**：美化样式

### inject-apple-styles.js

构建时自动将 `redocly-apple.css` 注入到生成的 HTML `<head>` 中。

## HTTP 方法颜色

| 方法 | 颜色 | 用途 |
|------|------|------|
| GET | `#007AFF` (蓝) | 读取资源 |
| POST | `#34C759` (绿) | 创建资源 |
| PUT | `#FF9500` (橙) | 完整更新 |
| PATCH | `#AF52DE` (紫) | 部分更新 |
| DELETE | `#FF3B30` (红) | 删除资源 |

## 开发建议

### 修改主题色

编辑 `redocly.yaml`：

```yaml
theme:
  openapi:
    theme:
      colors:
        primary:
          main: '#YOUR_COLOR'  # 修改主色
```

### 添加自定义样式

编辑 `docs-src/styles/redocly-apple.css`：

```css
/* 添加你的自定义样式 */
.my-custom-class {
  /* ... */
}
```

重新构建：

```bash
make build-docs
```

### 禁用样式注入

注释 `Makefile` 中的注入步骤：

```makefile
build-docs: openapi
	# ...
	# @node scripts/inject-apple-styles.js  # 注释这行
```

## 技术栈

- **Redocly CLI** - API 文档生成器
- **TypeSpec** - API 定义语言
- **OpenAPI 3.0** - API 规范标准
- **CSS3** - 现代样式特性（backdrop-filter、CSS 变量等）

## 最佳实践

1. **保持配色一致**：使用 Apple 官方色值
2. **字体优先级**：首选系统字体（-apple-system）
3. **圆角统一**：按钮 6-8px，卡片 12px
4. **动画流畅**：0.2s ease 过渡
5. **响应式优先**：移动端适配
6. **暗色模式**：提供完整支持

## 参考资源

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Redocly Documentation](https://redocly.com/docs/)
- [TypeSpec Documentation](https://typespec.io/)

---

**提示**：文档风格基于 Apple Developer Documentation 设计，旨在提供清晰、优雅的 API 文档阅读体验。
