import "@typespec/http";
import "@typespec/openapi3";

import "./types/common.tsp";
import "./types/auth.tsp";

using TypeSpec.Http;

@server("Auth", "https://auth.nexusbook.com")
@service
namespace NexusBook.Auth {}
