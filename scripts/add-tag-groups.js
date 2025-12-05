/**
 * 为 OpenAPI 文件添加 x-tagGroups 以组织 API 文档结构
 */

const fs = require('fs-extra');
const path = require('path');
const yaml = require('js-yaml');

// 支持从命令行参数指定文件路径
const OPENAPI_FILE = process.argv[2] || path.join(__dirname, '../dist/openapi/@typespec/openapi3/openapi.NexusBook.Api.yaml');

async function main() {
  console.log(`📝 Adding x-tagGroups to ${OPENAPI_FILE}...`);

  // 读取 OpenAPI 文件
  const content = await fs.readFile(OPENAPI_FILE, 'utf8');
  const openapi = yaml.load(content);

  // 判断是合并文件还是单个文件
  const isJoinedFile = OPENAPI_FILE.includes('openapi.yaml');

  // 定义 tag groups - 方案 A：功能领域分组
  if (isJoinedFile) {
    // 合并文件：使用功能领域分组（10个子分组）
    openapi['x-tagGroups'] = [
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
  } else {
    // 单个文件：保留原有结构
    openapi['x-tagGroups'] = [
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

  // 更新 tags 定义，添加描述
  const tagDescriptions = {
    'Users': '用户管理',
    'Organizations': '组织管理',
    'Workspaces': '工作区管理',
    'Invitations': '邀请管理',
    'Join Requests': '加入申请',
    'OAuth': 'OAuth2/OIDC 认证',
    'Authentication': '用户注册与登录',
    'API Keys': 'API 密钥管理',
    'Document - Core': '核心功能（聚合查询、元数据、设置）',
    'Document - Data': '数据行管理',
    'Document - Views': '视图管理',
    'Document - Properties': '文档属性',
    'Document - Relations': '文档关联',
    'Document - Attachments': '附件管理',
    'Document - Sync': '数据同步',
    'Document - Collaboration': '协作功能（评论、实时）',
    'Document - Workflow': '工作流（审批、变更请求、修订）',
    'Document - Tenancy': '多租户（组织/工作区级文档）',
    'Subscription Plans': '订阅计划管理',
    'Subscription Management': '订阅管理',
    'Invoices': '账单管理',
    'Payment Methods': '支付方式管理',
    'Usage & Quota': '使用量与配额管理',
    'Audit Logs': '审计日志',
    'Compliance': '合规性报告',
    'Webhooks': 'Webhook 管理',
    'Internationalization': '国际化翻译',
    'User Preferences': '用户偏好设置'
  };

  // 更新 tags
  if (!openapi.tags) {
    openapi.tags = [];
  }

  const existingTags = new Set(openapi.tags.map(t => t.name));
  
  Object.keys(tagDescriptions).forEach(tagName => {
    if (!existingTags.has(tagName)) {
      openapi.tags.push({
        name: tagName,
        description: tagDescriptions[tagName]
      });
    } else {
      // 更新现有 tag 的描述
      const tag = openapi.tags.find(t => t.name === tagName);
      if (tag && !tag.description) {
        tag.description = tagDescriptions[tagName];
      }
    }
  });

  // 重新映射某些 tags（方案 A）
  const tagMapping = {
    'Document': 'Document - Core',              // 聚合查询映射到 Core
    'Attachments': 'Document - Attachments',     // 附件管理
    'Realtime': 'Document - Collaboration',      // 实时协作合并到协作
    'Organization Documents': 'Document - Tenancy',  // 组织文档合并到租户
    'Workspace Documents': 'Document - Tenancy'      // 工作区文档合并到租户
  };

  // 遍历所有路径，更新 tags
  if (openapi.paths) {
    Object.keys(openapi.paths).forEach(pathKey => {
      const pathItem = openapi.paths[pathKey];
      ['get', 'post', 'put', 'patch', 'delete'].forEach(method => {
        if (pathItem[method] && pathItem[method].tags) {
          pathItem[method].tags = pathItem[method].tags.map(tag => {
            // 映射 tag 名称
            if (tagMapping[tag]) {
              return tagMapping[tag];
            }
            return tag;
          });
        }
      });
    });
  }

  // 写回文件
  const yamlContent = yaml.dump(openapi, {
    indent: 2,
    lineWidth: -1,
    noRefs: true
  });

  await fs.writeFile(OPENAPI_FILE, yamlContent, 'utf8');

  console.log('✅ x-tagGroups added successfully!');
  console.log('\nTag Groups:');
  openapi['x-tagGroups'].forEach(group => {
    console.log(`  - ${group.name}: ${group.tags.length} tags`);
  });
}

main().catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});
