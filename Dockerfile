# 使用 nginx 提供静态文件服务
FROM nginx:alpine

# 复制自定义 nginx 配置
COPY deployment/nginx.conf /etc/nginx/nginx.conf

# 从构建产物复制文档文件（由 GitHub Actions 提供）
COPY docs/ /usr/share/nginx/html/

# 暴露端口
EXPOSE 80

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]
