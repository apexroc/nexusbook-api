# 📚 文档说明

## 目录结构

```
├── docs-src/          # ✅ Markdown 源文件（提交到 Git）
│   ├── README.md      # 文档使用指南
│   ├── CONTRIBUTING.md # 文档贡献指南
│   ├── guides/        # 开发指南 Markdown 源文件
│   └── references/    # 参考文档 Markdown 源文件
│
├── docs/              # ❌ 生成的 HTML（不提交，已在 .gitignore）
│   ├── index.html     # 文档站点主页
│   ├── api/           # OpenAPI 文档
│   ├── guides/        # 开发指南 HTML
│   ├── references/    # 参考文档 HTML
│   └── styles/        # 样式文件
│
└── scripts/
    └── build-docs.js  # 文档构建脚本
```

## 快速开始

### 查看文档

```bash
# 一键启动文档服务器
make serve

# 访问 http://localhost:8091
```

### 编辑文档

1. 编辑 `docs-src/` 目录下的 Markdown 文件
2. 运行 `make docs` 重新生成 HTML
3. 运行 `make serve` 预览更改

### 可用命令

| 命令 | 说明 |
|------|------|
| `make docs` | 构建完整文档站点 |
| `make serve` | 启动文档服务器（端口 8091） |
| `make clean-docs` | 清理生成的文档 |

## 重要说明

⚠️ **只编辑 `docs-src/` 下的文件**
- `docs/` 目录是自动生成的，不要直接编辑
- `docs/` 目录已加入 `.gitignore`，不会提交到 Git
- 所有文档修改应在 `docs-src/` 中进行

## 了解更多

- 📖 [文档使用指南](docs-src/README.md)
- 🤝 [文档贡献指南](docs-src/CONTRIBUTING.md)
