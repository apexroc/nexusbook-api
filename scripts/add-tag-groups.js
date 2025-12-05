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

  // 定义 tag groups
  if (isJoinedFile) {
    // 合并文件：使用更简洁的结构
    openapi['x-tagGroups'] = [
      {
        name: 'Base (基础)',
        tags: [
          'Users',
          'Organizations',
          'Workspaces',
          'Invitations',
          'Join Requests'
        ]
      },
      {
        name: 'Document - Core (核心)',
        tags: [
          'Document - Core',
          'Document - Data',
          'Document - Properties',
          'Document - Settings',
          'Organization Documents',
          'Workspace Documents'
        ]
      },
      {
        name: 'Document - Views (视图)',
        tags: [
          'Document - Views'
        ]
      },
      {
        name: 'Document - Relations (关联)',
        tags: [
          'Document - Relations'
        ]
      },
      {
        name: 'Document - Attachments (附件)',
        tags: [
          'Document - Attachments'
        ]
      },
      {
        name: 'Document - Sync (同步)',
        tags: [
          'Document - Sync'
        ]
      },
      {
        name: 'Document - Realtime (实时协作)',
        tags: [
          'Document - Realtime'
        ]
      },
      {
        name: 'Document - Content (内容)',
        tags: [
          'Document - Content'
        ]
      },
      {
        name: 'Document - Workflow (工作流)',
        tags: [
          'Document - Workflow'
        ]
      },
      {
        name: 'Document - Aggregate (聚合)',
        tags: [
          'Document - Aggregate'
        ]
      },
      {
        name: 'Auth (认证)',
        tags: [
          'Auth'
        ]
      }
    ];
  } else {
    // 单个文件：保留原有结构
    openapi['x-tagGroups'] = [
      {
        name: 'Auth (认证)',
        tags: []
      },
      {
        name: 'Base (基础)',
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
          'Document',
          'Document - Core',
          'Document - Views',
          'Document - Data',
          'Document - Properties',
          'Document - Settings',
          'Document - Relations',
          'Document - Attachments',
          'Document - Sync',
          'Document - Realtime',
          'Document - Content',
          'Document - Workflow',
          'Document - Aggregate',
          'Organization Documents',
          'Workspace Documents'
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
    'Document': '文档核心',
    'Document - Core': '核心数据模型（元数据、数据行、属性、视图、设置）',
    'Document - Views': '视图管理',
    'Document - Data': '数据行管理',
    'Document - Properties': '文档属性',
    'Document - Settings': '文档设置',
    'Document - Relations': '文档关联',
    'Document - Attachments': '附件管理',
    'Document - Sync': '数据同步',
    'Document - Realtime': '实时协作',
    'Document - Content': '内容协作（评论）',
    'Document - Workflow': '工作流（审批、变更请求、修订）',
    'Document - Aggregate': '聚合查询',
    'Attachments': '附件管理',
    'Realtime': '实时协作',
    'Organization Documents': '组织级文档',
    'Workspace Documents': '工作区级文档'
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

  // 重新映射某些 tags
  const tagMapping = {
    'Document': 'Document - Core',
    'Attachments': 'Document - Attachments',
    'Realtime': 'Document - Realtime'
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
