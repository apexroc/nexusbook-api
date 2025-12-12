#!/usr/bin/env node

const fs = require('fs-extra');
const path = require('path');

const REPOWIKI_DIR = path.join(__dirname, '../.qoder/repowiki/zh/content');
const ADVANCED_CONTENT_DIR = path.join(__dirname, '../docs/advanced-content');

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

async function main() {
  console.log('开始构建高级手册...');
  
  await prepareDirectories();
  await copyMarkdownFiles(REPOWIKI_DIR, ADVANCED_CONTENT_DIR);
  await generateSidebar();
  
  console.log('✅ 高级手册构建完成！');
}

main().catch(err => {
  console.error('构建失败:', err);
  process.exit(1);
});
