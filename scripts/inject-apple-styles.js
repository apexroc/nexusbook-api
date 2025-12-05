#!/usr/bin/env node

/**
 * 将自定义 Apple Design 样式注入到 Redocly 生成的 HTML 中
 */

const fs = require('fs-extra');
const path = require('path');

async function injectAppleStyles() {
  const htmlPath = path.join(__dirname, '../dist/redoc/index.html');
  const cssPath = path.join(__dirname, '../docs-src/styles/redocly-apple.css');

  if (!fs.existsSync(htmlPath)) {
    console.error('❌ 未找到生成的 HTML 文件:', htmlPath);
    process.exit(1);
  }

  if (!fs.existsSync(cssPath)) {
    console.error('❌ 未找到自定义 CSS 文件:', cssPath);
    process.exit(1);
  }

  // 读取文件
  let html = await fs.readFile(htmlPath, 'utf8');
  const customCSS = await fs.readFile(cssPath, 'utf8');

  // 在 </head> 之前注入自定义样式
  const styleTag = `
    <!-- Apple Design Custom Styles -->
    <style>
      ${customCSS}
    </style>
  `;

  html = html.replace('</head>', `${styleTag}\n</head>`);

  // 写回文件
  await fs.writeFile(htmlPath, html, 'utf8');

  console.log('✅ 已注入 Apple Design 自定义样式');
}

injectAppleStyles().catch(err => {
  console.error('❌ 注入样式失败:', err);
  process.exit(1);
});
