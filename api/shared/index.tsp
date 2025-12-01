import "@typespec/http";
import "@typespec/openapi3";

import "./common.tsp";
import "./constants.tsp";

using TypeSpec.Http;
using OpenAPI;

/**
 * 共享模块入口
 * Shared module index
 *
 * 导出所有通用类型和常数。
 */
