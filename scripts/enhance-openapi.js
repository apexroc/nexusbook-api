#!/usr/bin/env node

/**
 * 增强 OpenAPI 文件
 * 
 * 功能：
 * 1. 添加完整的 info 元信息（version, contact, license, termsOfService）
 * 2. 添加 externalDocs 链接
 * 3. 添加 x-tagGroups 分组（更清晰的 API 组织）
 * 4. 增强 description 内容
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { execSync } = require('child_process');

const TSP_OUTPUT_DIR = path.join(__dirname, '../tsp-output/@typespec/openapi3');
const API_FILE = path.join(TSP_OUTPUT_DIR, 'openapi.NexusBook.Api.yaml');
const AUTH_FILE = path.join(TSP_OUTPUT_DIR, 'openapi.NexusBook.Auth.yaml');

/**
 * 获取 Git tag 版本
 */
function getGitVersion() {
  try {
    const version = execSync('git describe --tags --abbrev=0', { encoding: 'utf8' }).trim();
    // 移除 'v' 前缀（如果有）
    return version.startsWith('v') ? version.slice(1) : version;
  } catch (error) {
    console.warn('⚠️  无法获取 Git tag 版本，使用默认版本 1.0.0');
    return '1.0.0';
  }
}

/**
 * 增强 API 文件的 info 部分
 */
function enhanceInfo(spec, isAuthAPI = false) {
  const baseInfo = spec.info || {};
  const version = getGitVersion();
  
  if (isAuthAPI) {
    spec.info = {
      title: baseInfo.title || 'NexusBook Auth API',
      version: version,
      description: baseInfo.description || '',
      termsOfService: 'https://nexusbook.app/terms',
      contact: {
        name: 'NexusBook API Support',
        url: 'https://docs.nexusbook.app/support',
        email: 'api@nexusbook.app'
      },
      license: {
        name: 'Apache 2.0',
        url: 'https://www.apache.org/licenses/LICENSE-2.0.html'
      }
    };
    
    spec.externalDocs = {
      description: '完整的认证服务文档和开发指南',
      url: 'https://docs.nexusbook.app/guides/authentication'
    };
  } else {
    spec.info = {
      title: baseInfo.title || 'NexusBook OpenAPI',
      version: version,
      description: baseInfo.description || '',
      termsOfService: 'https://nexusbook.app/terms',
      contact: {
        name: 'NexusBook API Support',
        url: 'https://docs.nexusbook.app/support',
        email: 'api@nexusbook.app'
      },
      license: {
        name: 'Apache 2.0',
        url: 'https://www.apache.org/licenses/LICENSE-2.0.html'
      }
    };
    
    spec.externalDocs = {
      description: '完整的 API 文档和开发指南',
      url: 'https://docs.nexusbook.app'
    };
  }
}

/**
 * 添加 x-tagGroups 分组
 */
function addTagGroups(spec) {
  // 定义 tag 映射（将某些 tag 重新映射到统一的分组）
  const tagMapping = {
    'Attachments': 'Document - Attachments',
    'Realtime': 'Document - Collaboration',
    'Organization Documents': 'Document - Tenancy',
    'Workspace Documents': 'Document - Tenancy'
  };

  // 遍历所有路径，更新 tags
  if (spec.paths) {
    Object.keys(spec.paths).forEach(pathKey => {
      const pathItem = spec.paths[pathKey];
      ['get', 'post', 'put', 'patch', 'delete'].forEach(method => {
        if (pathItem[method] && pathItem[method].tags) {
          pathItem[method].tags = pathItem[method].tags.map(tag => {
            if (tagMapping[tag]) {
              return tagMapping[tag];
            }
            return tag;
          });
        }
      });
    });
  }

  // 更新 tags 定义，移除被映射的 tag，添加新的 tag
  if (spec.tags) {
    // 移除被映射的旧 tags
    spec.tags = spec.tags.filter(tag => !tagMapping[tag.name]);
    
    // 添加新的 tags（如果不存在）
    const existingTagNames = new Set(spec.tags.map(t => t.name));
    const newTags = [
      { name: 'Document - Attachments', description: '附件管理' },
      { name: 'Document - Tenancy', description: '多租户（组织/工作区级文档）' }
    ];
    
    newTags.forEach(newTag => {
      if (!existingTagNames.has(newTag.name)) {
        spec.tags.push(newTag);
      }
    });
  }

  // 定义 x-tagGroups
  spec['x-tagGroups'] = [
    {
      name: 'Foundation (基础)',
      tags: [
        'Users',
        'Organizations',
        'Workspaces',
        'Invitations',
        'Join Requests'
      ]
    },
    {
      name: 'Document (文档)',
      tags: [
        'Document - Core',
        'Document - Data',
        'Document - Views',
        'Document - Properties',
        'Document - Relations',
        'Document - Attachments',
        'Document - Sync',
        'Document - Collaboration',
        'Document - Workflow',
        'Document - Tenancy'
      ]
    },
    {
      name: 'Supply Chain (供应链协作)',
      tags: [
        'Catalog',
        'OrderBook',
        'Connection',
        'Connector'
      ]
    },
    {
      name: 'Auth (认证)',
      tags: [
        'OAuth',
        'Authentication',
        'API Keys'
      ]
    },
    {
      name: 'Billing (商业化)',
      tags: [
        'Subscription Plans',
        'Subscription Management',
        'Invoices',
        'Payment Methods',
        'Usage & Quota'
      ]
    },
    {
      name: 'Audit (审计)',
      tags: [
        'Audit Logs',
        'Compliance'
      ]
    },
    {
      name: 'Extensions (扩展)',
      tags: [
        'Webhooks',
        'Internationalization',
        'User Preferences'
      ]
    }
  ];
}

/**
 * 处理单个 OpenAPI 文件
 */
function processFile(filePath, isAuthAPI = false) {
  if (!fs.existsSync(filePath)) {
    console.log(`⚠️  文件不存在: ${filePath}`);
    return;
  }

  console.log(`📝 处理文件: ${path.basename(filePath)}`);
  
  // 读取 YAML
  const content = fs.readFileSync(filePath, 'utf8');
  const spec = yaml.load(content);
  
  // 增强 info
  enhanceInfo(spec, isAuthAPI);
  
  // 添加 tag groups（仅主 API）
  if (!isAuthAPI) {
    addTagGroups(spec);
  }
  
  // 写回文件
  const output = yaml.dump(spec, {
    lineWidth: 120,
    noRefs: true,
    sortKeys: false
  });
  
  fs.writeFileSync(filePath, output, 'utf8');
  console.log(`✅ 完成: ${path.basename(filePath)}`);
}

/**
 * 主函数
 */
function main() {
  console.log('🚀 开始增强 OpenAPI 文件...\n');
  
  // 检查是否有命令行参数
  const args = process.argv.slice(2);
  
  if (args.length > 0) {
    // 处理指定的文件
    args.forEach(filePath => {
      const absolutePath = path.isAbsolute(filePath) 
        ? filePath 
        : path.join(process.cwd(), filePath);
      processFile(absolutePath, false);
    });
  } else {
    // 默认处理 tsp-output 目录下的文件
    processFile(API_FILE, false);
    processFile(AUTH_FILE, true);
  }
  
  console.log('\n✨ 所有文件处理完成！');
}

// 执行
main();
