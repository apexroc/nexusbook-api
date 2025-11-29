import "@typespec/http";
import "@typespec/openapi3";

import "./types/common.tsp";
import "./types/auth.tsp";
import "./types/metadata.tsp";
import "./types/views.tsp";
import "./types/data.tsp";
import "./types/comments.tsp";
import "./types/revisions.tsp";
import "./types/requests.tsp";
import "./types/approvals.tsp";
import "./types/settings.tsp";
import "./types/doc.tsp";

using TypeSpec.Http;
using OpenAPI;

@server("Open", "https://open.nexusbook.com/api/v1")
@service(#{ title: "NexuxBook OpenAPI" })
@route("/api/v1")
namespace NexusBook.Api.Document {}

@server("Auth", "https://auth.nexusbook.com")
@service(#{ title: "NexuxBook Auth API" })
namespace NexusBook.Auth {}