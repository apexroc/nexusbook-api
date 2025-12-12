# 多阶段构建 - 构建 API 文档
FROM node:20-alpine AS builder

WORKDIR /app

# 安装 make (Alpine 需要)
RUN apk add --no-cache make

# 复制依赖文件
COPY package*.json ./
COPY tspconfig.yaml ./
COPY redocly.yaml ./
COPY sidebars.yaml ./
COPY Makefile ./

# 安装依赖
RUN npm ci

# 复制源代码
COPY api/ ./api/
COPY docs-src/ ./docs-src/
COPY scripts/ ./scripts/

# 构建文档 (不使用 BASE_PATH，K3s 部署使用根路径)
RUN make docs

# 生产镜像 - 使用 nginx 提供静态文件服务
FROM nginx:alpine

# 复制自定义 nginx 配置
COPY deployment/nginx.conf /etc/nginx/nginx.conf

# 从构建阶段复制文档文件
COPY --from=builder /app/docs /usr/share/nginx/html

# 暴露端口
EXPOSE 80

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]
