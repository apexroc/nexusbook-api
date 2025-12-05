#!/usr/bin/env node

const fs = require('fs-extra');
const path = require('path');
const { marked } = require('marked');
const yaml = require('js-yaml');

const DOCS_DIR = path.join(__dirname, '../docs');
const DOCS_SRC_DIR = path.join(__dirname, '../docs-src');
const API_DIR = path.join(__dirname, '../api');
const README_PATH = path.join(__dirname, '../README.md');
const REDOCLY_CONFIG_PATH = path.join(__dirname, '../redocly.yaml');

// 支持 GitHub Pages 子路径部署
// 本地开发时使用 '/', GitHub Pages 时使用 '/nexusbook-api/'
const BASE_PATH = process.env.BASE_PATH || '/';

// 辅助函数：生成正确的路径
function resolvePath(relativePath) {
  if (BASE_PATH === '/') {
    return '/' + relativePath.replace(/^\//, '');
  }
  return BASE_PATH.replace(/\/$/, '') + '/' + relativePath.replace(/^\//, '');
}

// 配置 marked
marked.setOptions({
  gfm: true,
  breaks: false,
  headerIds: true,
  mangle: false
});

// 读取 sidebars 配置
let sidebarConfig = [];
try {
  const redoclyConfig = yaml.load(fs.readFileSync(REDOCLY_CONFIG_PATH, 'utf8'));
  if (redoclyConfig.sidebars && redoclyConfig.sidebars.main) {
    sidebarConfig = redoclyConfig.sidebars.main;
  }
} catch (error) {
  console.warn('⚠ 无法读取 sidebars 配置，使用默认配置');
}

// 生成侧边栏 HTML
function generateSidebarHTML(currentPath = '') {
  if (!sidebarConfig || sidebarConfig.length === 0) {
    return '';
  }

  let html = '<nav class="sidebar">\n';
  html += '<div class="sidebar-header">\n';
  html += `<a href="${resolvePath('index.html')}" class="sidebar-logo">NexusBook API</a>\n`;
  html += '</div>\n';
  html += '<div class="sidebar-content">\n';

  sidebarConfig.forEach(group => {
    const expanded = group.expanded !== false;
    html += `<div class="sidebar-group ${expanded ? 'expanded' : ''}">\n`;
    html += `<div class="sidebar-group-title">${group.group || 'Group'}</div>\n`;
    html += '<ul class="sidebar-items">\n';

    if (group.pages) {
      group.pages.forEach(item => {
        const pagePath = item.page || '';
        const label = item.label || 'Page';
        const isActive = currentPath.includes(pagePath.replace('.md', '.html'));
        const href = resolvePath(pagePath.replace('.md', '.html'));
        html += `<li class="sidebar-item ${isActive ? 'active' : ''}">\n`;
        html += `<a href="${href}">${label}</a>\n`;
        html += '</li>\n';
      });
    }

    html += '</ul>\n';
    html += '</div>\n';
  });

  html += '</div>\n';
  html += '</nav>\n';

  return html;
}

// 生成文档主页
async function generateHomePage() {
  const indexHtml = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NexusBook API 文档</title>
    <link rel="stylesheet" href="styles/main.css?v=${Date.now()}">
</head>
<body>
    <header class="header">
        <div class="container">
            <h1 class="logo">NexusBook API</h1>
            <nav class="nav">
                <a href="${resolvePath('index.html')}">首页</a>
                <a href="${resolvePath('api/index.html')}">API 参考</a>
                <a href="${resolvePath('guides/getting-started.html')}">开发指南</a>
                <a href="${resolvePath('references/error-codes.html')}">参考文档</a>
                <a href="https://github.com/NexusBook/nexusbook-api" target="_blank">GitHub</a>
            </nav>
        </div>
    </header>

    <main class="main">
        <section class="hero">
            <div class="container">
                <h2 class="hero-title">文档管理和数据协作平台 API 文档</h2>
                <p class="hero-description">
                    一个功能强大的开源文档管理和数据协作平台 API，
                    支持统一的文档抽象、多种视图类型、完整的协作功能和事件驱动通知。
                </p>
                <div class="hero-actions">
                    <a href="${resolvePath('guides/getting-started.html')}" class="btn btn-primary">快速开始</a>
                    <a href="${resolvePath('api/index.html')}" class="btn btn-secondary">查看 API 文档</a>
                </div>
            </div>
        </section>

        <section class="features">
            <div class="container">
                <div class="feature-grid">
                    <div class="feature-card">
                        <div class="feature-icon">📚</div>
                        <h3>OpenAPI 文档</h3>
                        <p>完整的 API 接口参考，包含所有端点的详细说明、请求/响应示例。</p>
                        <a href="${resolvePath('api/index.html')}" class="feature-link">查看文档 →</a>
                    </div>

                    <div class="feature-card">
                        <div class="feature-icon">🚀</div>
                        <h3>开发指南</h3>
                        <p>从快速开始到高级用法，涵盖认证授权、文档模型、数据操作等核心功能。</p>
                        <a href="${resolvePath('guides/getting-started.html')}" class="feature-link">查看指南 →</a>
                    </div>

                    <div class="feature-card">
                        <div class="feature-icon">🔔</div>
                        <h3>Webhook 指南</h3>
                        <p>事件驱动的通知机制，支持 20+ 种事件类型，自动推送变更通知。</p>
                        <a href="${resolvePath('guides/webhooks.html')}" class="feature-link">查看指南 →</a>
                    </div>

                    <div class="feature-card">
                        <div class="feature-icon">📖</div>
                        <h3>参考文档</h3>
                        <p>错误码、字段类型、国际化等参考资料，便于快速查阅。</p>
                        <a href="${resolvePath('references/error-codes.html')}" class="feature-link">查看参考 →</a>
                    </div>
                </div>
            </div>
        </section>

        <section class="documentation">
            <div class="container">
                <h2>📚 完整文档列表</h2>
                <div class="doc-section">
                    <h3>🚀 开发指南</h3>
                    <ul class="doc-list">
                        <li><a href="${resolvePath('guides/getting-started.html')}">快速开始</a> - 5分钟了解如何使用 API</li>
                        <li><a href="${resolvePath('guides/authentication.html')}">认证授权指南</a> - OAuth2、OIDC 和 JWT 详解</li>
                        <li><a href="${resolvePath('guides/document-model.html')}">文档模型详解</a> - 统一文档抽象和字段类型</li>
                        <li><a href="${resolvePath('guides/data-operations.html')}">数据操作指南</a> - CRUD 操作和高级查询</li>
                        <li><a href="${resolvePath('guides/webhooks.html')}">Webhook 使用指南</a> - 事件驱动通知机制</li>
                        <li><a href="${resolvePath('guides/best-practices.html')}">最佳实践</a> - 性能优化和安全建议</li>
                        <li><a href="${resolvePath('guides/examples.html')}">完整示例</a> - 常见场景的代码示例</li>
                        <li><a href="${resolvePath('guides/architecture.html')}">架构设计</a> - 系统架构和设计原则</li>
                        <li><a href="${resolvePath('guides/development.html')}">开发指南</a> - 项目开发和贡献指南</li>
                    </ul>
                </div>
                <div class="doc-section">
                    <h3>📖 参考文档</h3>
                    <ul class="doc-list">
                        <li><a href="${resolvePath('references/api-reference.html')}">API 参考手册</a> - 所有端点的详细文档</li>
                        <li><a href="${resolvePath('references/error-codes.html')}">错误码参考</a> - 完整的错误码列表</li>
                        <li><a href="${resolvePath('references/field-types.html')}">字段类型参考</a> - 25+ 种字段类型说明</li>
                        <li><a href="${resolvePath('references/i18n.html')}">国际化说明</a> - 多语言支持文档</li>
                        <li><a href="${resolvePath('references/changelog.html')}">变更日志</a> - 版本更新记录</li>
                    </ul>
                </div>
            </div>
        </section>

        <section class="quick-links">
            <div class="container">
                <h2>核心特性</h2>
                <div class="links-grid">
                    <div class="link-item">
                        <h4>📊 文档与数据管理</h4>
                        <ul>
                            <li>统一的文档抽象</li>
                            <li>25+ 种字段类型</li>
                            <li>高级查询能力</li>
                        </ul>
                    </div>
                    <div class="link-item">
                        <h4>👁️ 多视图支持</h4>
                        <ul>
                            <li>8 种视图类型</li>
                            <li>自定义过滤和排序</li>
                            <li>灵活的配置选项</li>
                        </ul>
                    </div>
                    <div class="link-item">
                        <h4>💬 协作与工作流</h4>
                        <ul>
                            <li>统一评论系统</li>
                            <li>版本控制系统</li>
                            <li>审批工作流</li>
                        </ul>
                    </div>
                    <div class="link-item">
                        <h4>🔐 认证与授权</h4>
                        <ul>
                            <li>OAuth2 & OIDC</li>
                            <li>JWT Token 管理</li>
                            <li>基于 Scope 的权限</li>
                        </ul>
                    </div>
                </div>
            </div>
        </section>

        <section class="resources">
            <div class="container">
                <h2>相关资源</h2>
                <ul class="resources-list">
                    <li>📦 <a href="https://github.com/NexusBook/nexusbook-api" target="_blank">GitHub 仓库</a></li>
                    <li>🐛 <a href="https://github.com/NexusBook/nexusbook-api/issues" target="_blank">问题反馈</a></li>
                    <li>📝 <a href="${resolvePath('references/changelog.html')}">变更日志</a></li>
                </ul>
            </div>
        </section>
    </main>

    <footer class="footer">
        <div class="container">
            <p>&copy; 2024 NexusBook. 基于 TypeSpec 定义并生成 OpenAPI 3.0 规范。</p>
        </div>
    </footer>
</body>
</html>`;

  await fs.writeFile(path.join(DOCS_DIR, 'index.html'), indexHtml, 'utf-8');
  console.log('✓ 生成文档主页');
}

// 生成页面模板
function generatePageTemplate(title, content, activeNav = '', currentPath = '') {
  const sidebar = generateSidebarHTML(currentPath);
  const hasSidebar = sidebar !== '';
  
  return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title} - NexusBook API 文档</title>
    <link rel="stylesheet" href="../styles/main.css?v=${Date.now()}">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/highlight.js@11.9.0/styles/github.min.css">
    <script src="https://cdn.jsdelivr.net/npm/highlight.js@11.9.0/lib/common.min.js"></script>
    <script>
      if (window.hljs) { hljs.highlightAll(); }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
    <script>
      mermaid.initialize({ startOnLoad: true, theme: 'default' });
    </script>
</head>
<body ${hasSidebar ? 'class="has-sidebar"' : ''}>
    ${sidebar}
    
    <div class="main-wrapper">
        <header class="header">
            <div class="container">
                <h1 class="logo"><a href="${resolvePath('index.html')}">NexusBook API</a></h1>
                <nav class="nav">
                    <a href="${resolvePath('index.html')}">首页</a>
                    <a href="${resolvePath('api/index.html')}" ${activeNav === 'api' ? 'class="active"' : ''}>API 参考</a>
                    <a href="${resolvePath('guides/getting-started.html')}" ${activeNav === 'guides' ? 'class="active"' : ''}>开发指南</a>
                    <a href="${resolvePath('references/error-codes.html')}" ${activeNav === 'references' ? 'class="active"' : ''}>参考文档</a>
                    <a href="https://github.com/NexusBook/nexusbook-api" target="_blank">GitHub</a>
                </nav>
            </div>
        </header>

        <main class="main content-page">
            <div class="container">
                <article class="content">
                    ${content}
                </article>
            </div>
        </main>

        <footer class="footer">
            <div class="container">
                <p>&copy; 2024 NexusBook. 基于 TypeSpec 定义并生成 OpenAPI 3.0 规范。</p>
            </div>
        </footer>
    </div>
</body>
</html>`;
}

// 转换 Markdown 为 HTML
async function convertMarkdownToHtml(mdPath, outputPath, title, activeNav) {
  try {
    let mdContent = await fs.readFile(mdPath, 'utf-8');
    
    // 保存 Mermaid 代码块，用占位符替换
    const mermaidBlocks = [];
    mdContent = mdContent.replace(/```mermaid([\s\S]*?)```/g, (match, code) => {
      const index = mermaidBlocks.length;
      mermaidBlocks.push(code.trim());
      return `

<MERMAID_BLOCK_${index}></MERMAID_BLOCK_${index}>

`;
    });
    
    // 转换 Markdown 为 HTML
    let htmlContent = marked(mdContent);
    
    // 还原 Mermaid 代码块
    mermaidBlocks.forEach((code, index) => {
      htmlContent = htmlContent.replace(
        new RegExp(`<p><MERMAID_BLOCK_${index}></MERMAID_BLOCK_${index}></p>`, 'g'),
        `<div class="mermaid">${code}</div>`
      );
      // 兼容被 HTML 转义的占位符（marked 会将未知标签转义）
      htmlContent = htmlContent.replace(
        new RegExp(`&lt;MERMAID_BLOCK_${index}&gt;&lt;/MERMAID_BLOCK_${index}&gt;`, 'g'),
        `<div class="mermaid">${code}</div>`
      );
    });
    
    const fullHtml = generatePageTemplate(title, htmlContent, activeNav);
    await fs.writeFile(outputPath, fullHtml, 'utf-8');
    console.log(`✓ 生成 ${path.basename(outputPath)}`);
  } catch (error) {
    console.warn(`⚠ 跳过 ${path.basename(mdPath)}: ${error.message}`);
  }
}

// 主函数
async function build() {
  console.log('开始构建文档站点...\n');

  try {
    // 确保目录存在
    await fs.ensureDir(DOCS_DIR);
    await fs.ensureDir(path.join(DOCS_DIR, 'guides'));
    await fs.ensureDir(path.join(DOCS_DIR, 'references'));
    await fs.ensureDir(path.join(DOCS_DIR, 'styles'));

    // 复制样式文件
    const stylesSource = path.join(DOCS_SRC_DIR, 'styles', 'main.css');
    const stylesTarget = path.join(DOCS_DIR, 'styles', 'main.css');
    if (await fs.pathExists(stylesSource)) {
      await fs.copy(stylesSource, stylesTarget);
      console.log('✓ 复制样式文件');
    } else {
      console.warn('⚠ 样式文件不存在:', stylesSource);
    }

    // 复制 .nojekyll 文件（GitHub Pages 需要）
    const nojekyllSource = path.join(DOCS_SRC_DIR, '.nojekyll');
    const nojekyllTarget = path.join(DOCS_DIR, '.nojekyll');
    if (await fs.pathExists(nojekyllSource)) {
      await fs.copy(nojekyllSource, nojekyllTarget);
      console.log('✓ 复制 .nojekyll 文件');
    }

    // 生成主页
    await generateHomePage();

    // 转换指南文档
    const guides = [
      { file: 'getting-started', title: '快速开始' },
      { file: 'authentication', title: '认证授权指南' },
      { file: 'document-model', title: '文档模型详解' },
      { file: 'data-operations', title: '数据操作指南' },
      { file: 'webhooks', title: 'Webhook 使用指南' },
      { file: 'best-practices', title: '最佳实践' },
      { file: 'examples', title: '完整示例' },
      { file: 'architecture', title: '架构设计' },
      { file: 'development', title: '开发指南' },
      { file: 'realtime-collaboration', title: '实时协同开发指南' }
    ];

    for (const guide of guides) {
      const mdPath = path.join(DOCS_SRC_DIR, 'guides', `${guide.file}.md`);
      const htmlPath = path.join(DOCS_DIR, 'guides', `${guide.file}.html`);
      await convertMarkdownToHtml(mdPath, htmlPath, guide.title, 'guides');
    }

    // 转换参考文档
    const references = [
      { file: 'error-codes', title: '错误码参考' },
      { file: 'field-types', title: '字段类型参考' },
      { file: 'i18n', title: '国际化说明' },
      { file: 'changelog', title: '变更日志' },
      { file: 'api-reference', title: 'API 参考手册' }
    ];

    for (const ref of references) {
      const mdPath = path.join(DOCS_SRC_DIR, 'references', `${ref.file}.md`);
      const htmlPath = path.join(DOCS_DIR, 'references', `${ref.file}.html`);
      await convertMarkdownToHtml(mdPath, htmlPath, ref.title, 'references');
    }

    console.log('\n✅ 文档站点构建完成！');
  } catch (error) {
    console.error('❌ 构建失败:', error);
    process.exit(1);
  }
}

// 执行构建
build();
