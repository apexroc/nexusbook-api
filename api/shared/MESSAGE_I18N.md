# 多语言消息系统 (Multi-Language Message System)

## 概述

NexusBook API 使用灵活的多语言消息结构，支持任意语言的国际化。

## 数据结构

### Message 模型

```typescript
type Message = Record<string, string>;
```

使用 ISO 639-1 语言代码作为键，消息文本作为值。

### 支持的语言代码

| 代码 | 语言 | Language |
|------|------|----------|
| `zh` | 中文 | Chinese |
| `en` | 英文 | English |
| `ja` | 日语 | Japanese |
| `ko` | 韩语 | Korean |
| `es` | 西班牙语 | Spanish |
| `fr` | 法语 | French |
| `de` | 德语 | German |
| `pt` | 葡萄牙语 | Portuguese |
| `ru` | 俄语 | Russian |
| `ar` | 阿拉伯语 | Arabic |
| `it` | 意大利语 | Italian |
| `nl` | 荷兰语 | Dutch |
| `pl` | 波兰语 | Polish |
| `tr` | 土耳其语 | Turkish |
| `vi` | 越南语 | Vietnamese |
| `th` | 泰语 | Thai |
| `id` | 印尼语 | Indonesian |
| `ms` | 马来语 | Malay |
| `hi` | 印地语 | Hindi |

## 使用示例

### 基本示例

```json
{
  "success": false,
  "code": "USER_NOT_FOUND",
  "message": {
    "zh": "用户未找到",
    "en": "User not found"
  },
  "payload": null
}
```

### 多语言完整示例

```json
{
  "success": false,
  "code": "INVALID_TOKEN",
  "message": {
    "zh": "令牌无效或已过期",
    "en": "Token is invalid or expired",
    "ja": "トークンが無効または期限切れです",
    "ko": "토큰이 유효하지 않거나 만료되었습니다",
    "es": "El token no es válido o ha expirado",
    "fr": "Le jeton est invalide ou expiré",
    "de": "Token ist ungültig oder abgelaufen",
    "pt": "O token é inválido ou expirou",
    "ru": "Токен недействителен или истек срок действия"
  },
  "payload": null
}
```

### 最小示例（仅包含必要语言）

```json
{
  "success": false,
  "code": "ORG_NOT_FOUND",
  "message": {
    "zh": "组织不存在",
    "en": "Organization not found"
  },
  "payload": null
}
```

## 实现建议

### 后端实现

```go
// 根据错误码和用户首选语言生成消息
func GetErrorMessage(code ErrorCode, preferredLangs []string) map[string]string {
    messages := errorMessages[code]
    
    // 返回完整的多语言消息
    return messages
}

// 错误消息字典
var errorMessages = map[ErrorCode]map[string]string{
    USER_NOT_FOUND: {
        "zh": "用户未找到",
        "en": "User not found",
        "ja": "ユーザーが見つかりません",
        "es": "Usuario no encontrado",
    },
    // ... 其他错误码
}
```

### 前端使用

```typescript
// 根据用户语言偏好获取消息
function getMessage(response: ApiResponse<any>): string {
    const userLang = navigator.language.split('-')[0]; // 获取语言代码
    
    // 优先使用用户语言，降级到英语，最后使用任意可用语言
    return response.message?.[userLang] 
        || response.message?.['en'] 
        || Object.values(response.message || {})[0]
        || 'Unknown error';
}
```

## 最佳实践

### 1. 语言覆盖

- **必须**: 至少提供 `zh` 和 `en` 两种语言
- **推荐**: 根据目标市场添加其他语言
- **可选**: 可以动态扩展任意语言

### 2. 消息质量

- 保持消息简洁明了
- 使用专业的翻译服务
- 避免使用机器翻译的生硬表达
- 保持各语言版本含义一致

### 3. 降级策略

客户端应实现降级逻辑：
1. 优先使用用户首选语言
2. 降级到英语
3. 使用任意可用语言
4. 显示错误码

### 4. 扩展性

新增语言时无需修改 API 定义，只需在后端添加翻译即可：

```go
// 添加新语言支持
errorMessages[USER_NOT_FOUND]["vi"] = "Không tìm thấy người dùng"
errorMessages[USER_NOT_FOUND]["th"] = "ไม่พบผู้ใช้"
```

## 技术优势

1. **灵活性**: 支持任意数量的语言
2. **可扩展**: 无需修改 API 结构即可添加新语言
3. **向后兼容**: 现有客户端仍可正常工作
4. **国际化友好**: 符合国际化最佳实践

## 迁移指南

### 从固定字段迁移

如果之前使用固定的 `zh` 和 `en` 字段：

```typescript
// 旧结构
interface OldMessage {
  zh: string;
  en: string;
}

// 新结构
type NewMessage = Record<string, string>;
```

迁移代码：

```typescript
// 旧代码仍然兼容
const message: NewMessage = {
  zh: "错误",
  en: "Error"
};

// 可以添加更多语言
const enhancedMessage: NewMessage = {
  zh: "错误",
  en: "Error",
  ja: "エラー",
  ko: "오류"
};
```

## 参考资源

- [ISO 639-1 语言代码](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
- [i18n 最佳实践](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Internationalization)
