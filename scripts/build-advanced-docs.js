#!/usr/bin/env node

const fs = require('fs-extra');
const path = require('path');

const REPOWIKI_DIR = path.join(__dirname, '../.qoder/repowiki/zh/content');
const ADVANCED_CONTENT_DIR = path.join(__dirname, '../docs/advanced');

// 清理并创建目标目录
async function prepareDirectories() {
  await fs.remove(ADVANCED_CONTENT_DIR);
  await fs.ensureDir(ADVANCED_CONTENT_DIR);
}

// 递归复制 Markdown 文件
async function copyMarkdownFiles(srcDir, destDir, relativePath = '') {
  const entries = await fs.readdir(srcDir, { withFileTypes: true });

  for (const entry of entries) {
    const srcPath = path.join(srcDir, entry.name);
    const destPath = path.join(destDir, entry.name);

    if (entry.isDirectory()) {
      await fs.ensureDir(destPath);
      const newRelativePath = relativePath ? `${relativePath}/${entry.name}` : entry.name;
      await copyMarkdownFiles(srcPath, destPath, newRelativePath);
    } else if (entry.name.endsWith('.md')) {
      // 直接复制 Markdown 文件
      await fs.copy(srcPath, destPath);
      console.log(`✓ 复制 ${relativePath ? relativePath + '/' : ''}${entry.name}`);
    }
  }
}

// 生成侧边栏配置
async function generateSidebar() {
  const sidebar = [];
  
  // 读取根目录的 README.md
  const readmePath = path.join(REPOWIKI_DIR, 'README.md');
  if (await fs.pathExists(readmePath)) {
    sidebar.push('* [首页](README.md)');
    sidebar.push('');
  }

  // 读取根目录的直接 Markdown 文件
  const rootEntries = await fs.readdir(REPOWIKI_DIR, { withFileTypes: true });
  const rootFiles = rootEntries
    .filter(e => e.isFile() && e.name.endsWith('.md') && e.name !== 'README.md')
    .map(e => e.name.replace('.md', ''));
  
  if (rootFiles.length > 0) {
    sidebar.push('* 📖 核心文档');
    rootFiles.forEach(name => {
      sidebar.push(`  * [${name}](${name}.md)`);
    });
    sidebar.push('');
  }

  // 读取子目录
  const directories = rootEntries
    .filter(e => e.isDirectory())
    .map(e => e.name)
    .sort();

  for (const dir of directories) {
    const dirPath = path.join(REPOWIKI_DIR, dir);
    sidebar.push(`* 📂 ${dir}`);
    
    await addDirectoryToSidebar(dirPath, sidebar, '  ', dir);
    sidebar.push('');
  }

  const sidebarContent = sidebar.join('\n');
  await fs.writeFile(path.join(ADVANCED_CONTENT_DIR, '_sidebar.md'), sidebarContent, 'utf-8');
  console.log('✓ 生成侧边栏配置');
}

async function addDirectoryToSidebar(dirPath, sidebar, indent, relativePath) {
  const entries = await fs.readdir(dirPath, { withFileTypes: true });
  
  // 先添加文件
  const files = entries
    .filter(e => e.isFile() && e.name.endsWith('.md'))
    .map(e => e.name);
  
  for (const file of files) {
    const name = file.replace('.md', '');
    const link = `${relativePath}/${file}`;
    sidebar.push(`${indent}* [${name}](${link})`);
  }
  
  // 再递归处理子目录
  const subdirs = entries
    .filter(e => e.isDirectory())
    .map(e => e.name)
    .sort();
  
  for (const subdir of subdirs) {
    const subdirPath = path.join(dirPath, subdir);
    const newRelativePath = `${relativePath}/${subdir}`;
    sidebar.push(`${indent}* 📁 ${subdir}`);
    await addDirectoryToSidebar(subdirPath, sidebar, indent + '  ', newRelativePath);
  }
}

// 生成 Docsify index.html
async function generateDocsifyIndex() {
  const indexHtml = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>NexusBook API 高级手册</title>
  <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/themes/vue.css">
  <style>
    :root {
      --base-font-size: 16px;
      --theme-color: #1976d2;
      --sidebar-width: 280px;
    }
  </style>
</head>
<body>
  <div id="app">加载中...</div>
  <script>
    window.$docsify = {
      name: 'NexusBook API 高级手册',
      repo: 'https://github.com/NexusBook/nexusbook-api',
      loadSidebar: true,
      subMaxLevel: 3,
      maxLevel: 4,
      auto2top: true,
      homepage: 'README.md',
      search: {
        maxAge: 86400000,
        paths: 'auto',
        placeholder: '搜索',
        noData: '没有结果',
        depth: 6
      },
      pagination: {
        previousText: '上一章',
        nextText: '下一章',
        crossChapter: true
      },
      coverpage: false,
      onlyCover: false
    }
  </script>
  <script src="//cdn.jsdelivr.net/npm/docsify@4"></script>
  <script src="//cdn.jsdelivr.net/npm/docsify@4/lib/plugins/search.js"></script>
  <script src="//cdn.jsdelivr.net/npm/docsify-pagination@2/dist/docsify-pagination.min.js"></script>
  <script src="//cdn.jsdelivr.net/npm/prismjs@1/components/prism-bash.min.js"></script>
  <script src="//cdn.jsdelivr.net/npm/prismjs@1/components/prism-javascript.min.js"></script>
  <script src="//cdn.jsdelivr.net/npm/prismjs@1/components/prism-typescript.min.js"></script>
  <script src="//cdn.jsdelivr.net/npm/prismjs@1/components/prism-json.min.js"></script>
  <script src="//cdn.jsdelivr.net/npm/prismjs@1/components/prism-yaml.min.js"></script>
  <script src="//cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <script src="//cdn.jsdelivr.net/npm/docsify-mermaid@2/dist/docsify-mermaid.js"></script>
  <script>
    mermaid.initialize({ startOnLoad: true, theme: 'default' });
  </script>
</body>
</html>
`;

  await fs.writeFile(path.join(ADVANCED_CONTENT_DIR, 'index.html'), indexHtml, 'utf-8');
  console.log('✓ 生成 Docsify index.html');
}

async function main() {
  console.log('开始构建高级手册...');
  
  await prepareDirectories();
  await copyMarkdownFiles(REPOWIKI_DIR, ADVANCED_CONTENT_DIR);
  await generateSidebar();
  await generateDocsifyIndex();
  
  console.log('✅ 高级手册构建完成！');
}

main().catch(err => {
  console.error('构建失败:', err);
  process.exit(1);
});
