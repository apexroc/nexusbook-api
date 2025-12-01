# GitHub Pages 部署配置

本项目使用 GitHub Actions 自动构建并部署文档到 GitHub Pages。

## 启用 GitHub Pages

1. 进入仓库的 **Settings** > **Pages**
2. 在 **Source** 下选择 **GitHub Actions**
3. 保存设置

## 自动部署

每次推送到 `main` 分支时，GitHub Actions 会自动：

1. 安装项目依赖
2. 编译 TypeSpec 生成 OpenAPI 规范
3. 构建 Redoc API 文档
4. 生成完整的文档站点
5. 部署到 GitHub Pages

## 手动触发部署

1. 进入仓库的 **Actions** 标签页
2. 选择 **Deploy Documentation to GitHub Pages** 工作流
3. 点击 **Run workflow** 按钮
4. 选择分支（默认 main）并运行

## 访问文档

部署完成后，可以通过以下地址访问文档：

```
https://{username}.github.io/{repository-name}/
```

例如：
```
https://nexusbook.github.io/nexusbook-api/
```

## 本地预览

构建并在本地预览文档站点：

```bash
# 构建文档站点
make docs

# 启动本地服务器（默认端口 8091）
make serve

# 使用自定义端口
PORT=3000 make serve
```

访问 `http://localhost:8091` 查看文档。

## 文档结构

```
docs/                    # 生成的文档站点（不提交到 Git）
├── .nojekyll           # GitHub Pages 配置文件
├── index.html          # 文档主页
├── api/                # API 参考文档
│   ├── index.html     # Redoc API 文档
│   └── openapi.yaml   # OpenAPI 规范文件
├── guides/             # 开发指南
│   ├── getting-started.html
│   ├── authentication.html
│   └── ...
├── references/         # 参考文档
│   ├── error-codes.html
│   ├── field-types.html
│   └── ...
└── styles/             # 样式文件
    └── main.css

docs-src/               # 文档源文件（提交到 Git）
├── .nojekyll          # GitHub Pages 配置
├── README.md          # 文档说明
├── guides/            # 指南源文件（Markdown）
├── references/        # 参考源文件（Markdown）
└── styles/            # 样式源文件
    └── main.css
```

## 工作流配置

GitHub Actions 工作流配置文件位于：
```
.github/workflows/deploy-docs.yml
```

## 注意事项

1. **不要提交 `docs/` 目录**：该目录由构建脚本自动生成
2. **提交 `docs-src/` 目录**：这是文档的源文件
3. **提交 `.github/workflows/`**：GitHub Actions 配置
4. **`.nojekyll` 文件**：确保 GitHub Pages 不使用 Jekyll 处理文件

## 故障排查

### 文档未更新

1. 检查 GitHub Actions 工作流是否成功运行
2. 查看 Actions 标签页的日志输出
3. 确认 GitHub Pages 设置正确

### 样式丢失

1. 确保 `docs-src/styles/main.css` 文件存在
2. 检查构建日志中是否有样式文件复制的提示
3. 验证生成的 HTML 中样式文件路径正确

### 404 错误

1. 确认 `.nojekyll` 文件已创建
2. 检查文件路径大小写是否正确
3. 等待几分钟，GitHub Pages 部署需要时间

## 更多信息

- [GitHub Pages 文档](https://docs.github.com/en/pages)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
