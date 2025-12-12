# NexusBook API 文档部署指南

本项目支持双环境部署:

1. **GitHub Pages**: `https://apexroc.github.io/nexusbook-api` (公开访问)
2. **K3s 集群**: `https://open.nexusbook.app` (生产环境)

## 📋 目录结构

```
deployment/
├── README.md              # 本文档
├── nginx.conf            # Nginx 配置文件
└── k3s-deployment.yaml   # K3s 部署配置 (Deployment, Service, Ingress)
```

## 🚀 部署方式

### 方式一: GitHub Pages 部署

#### 自动部署 (推荐)
推送版本标签时自动触发:

```bash
git tag -a v0.1.5 -m "Release v0.1.5"
git push origin v0.1.5
```

#### 手动触发
在 GitHub Actions 页面手动触发 `Deploy Docs to GitHub Pages` workflow

---

### 方式二: K3s 集群部署

#### 前置要求

1. **配置 GitHub Secrets**
   
   在 GitHub 仓库设置中添加以下 secrets:
   
   - `KUBECONFIG`: K3s 集群的 kubeconfig 文件 (Base64 编码)
     ```bash
     # 编码 kubeconfig
     cat ~/.kube/config | base64 -w 0  # Linux
     cat ~/.kube/config | base64        # macOS
     ```

2. **GitHub Container Registry 权限**
   
   确保仓库启用了 GitHub Packages，镜像将推送到 `ghcr.io/apexroc/nexusbook-api-docs`

3. **K3s 集群配置**
   
   确保集群已安装:
   - Nginx Ingress Controller
   - cert-manager (用于自动 SSL 证书)

#### 自动部署 (推荐)

推送版本标签时自动触发:

```bash
git tag -a v0.1.5 -m "Release v0.1.5"
git push origin v0.1.5
```

GitHub Actions 将自动:
1. 构建 Docker 镜像
2. 推送到 GitHub Container Registry
3. 部署到 K3s 集群
4. 等待 Deployment 就绪

#### 本地手动部署

```bash
# 1. 设置版本号
export VERSION=v0.1.5

# 2. 构建并推送镜像
make docker-build VERSION=$VERSION
make docker-push VERSION=$VERSION

# 或使用组合命令
make docker-release VERSION=$VERSION

# 3. 部署到 K3s
make k3s-deploy VERSION=$VERSION

# 4. 查看部署状态
make k3s-status

# 5. 查看日志
make k3s-logs
```

#### 完整发布流程

```bash
# 一键发布 (构建 -> 推送 -> 部署)
make release VERSION=v0.1.5
```

---

## 🔧 配置说明

### Docker 镜像配置

修改 `Makefile` 中的默认值:

```makefile
DOCKER_REGISTRY ?= ghcr.io/apexroc  # 镜像仓库地址
IMAGE_NAME ?= nexusbook-api-docs    # 镜像名称
VERSION ?= latest                   # 默认版本
NAMESPACE ?= nexusbook              # K8s 命名空间
```

### K3s 资源配置

编辑 `deployment/k3s-deployment.yaml`:

```yaml
# Deployment 配置
spec:
  replicas: 2  # Pod 副本数
  resources:
    requests:
      memory: "64Mi"
      cpu: "50m"
    limits:
      memory: "128Mi"
      cpu: "200m"

# Ingress 配置
spec:
  rules:
  - host: open.nexusbook.app  # 域名配置
```

### Nginx 配置

编辑 `deployment/nginx.conf` 自定义 Web 服务器行为:

- Gzip 压缩设置
- 缓存策略
- 安全头部
- 路由规则

---

## 📊 监控和管理

### 查看部署状态

```bash
# 查看所有资源状态
make k3s-status

# 或直接使用 kubectl
kubectl get all -n nexusbook -l app=nexusbook-api-docs
```

### 查看日志

```bash
# 实时查看日志 (最近 100 行)
make k3s-logs

# 或直接使用 kubectl
kubectl logs -n nexusbook -l app=nexusbook-api-docs -f
```

### 扩缩容

```bash
# 手动扩展副本数
kubectl scale deployment/nexusbook-api-docs -n nexusbook --replicas=3
```

### 回滚部署

```bash
# 查看历史版本
kubectl rollout history deployment/nexusbook-api-docs -n nexusbook

# 回滚到上一个版本
kubectl rollout undo deployment/nexusbook-api-docs -n nexusbook

# 回滚到指定版本
kubectl rollout undo deployment/nexusbook-api-docs -n nexusbook --to-revision=2
```

---

## 🔐 SSL/TLS 证书

项目使用 cert-manager 自动管理 SSL 证书:

- **Issuer**: `letsencrypt-prod`
- **证书 Secret**: `nexusbook-api-docs-tls`

### 查看证书状态

```bash
# 查看证书
kubectl get certificate -n nexusbook

# 查看证书详情
kubectl describe certificate nexusbook-api-docs-tls -n nexusbook
```

### 手动触发证书更新

```bash
# 删除证书 secret (cert-manager 会自动重新申请)
kubectl delete secret nexusbook-api-docs-tls -n nexusbook
```

---

## 🧹 清理资源

### 删除 K3s 部署

```bash
# 使用 Makefile
make k3s-delete

# 或直接使用 kubectl
kubectl delete -f deployment/k3s-deployment.yaml -n nexusbook
```

### 删除命名空间 (慎用)

```bash
kubectl delete namespace nexusbook
```

---

## 🐛 故障排查

### 镜像拉取失败

```bash
# 检查 imagePullSecrets 配置
kubectl describe pod -n nexusbook -l app=nexusbook-api-docs

# 创建 registry secret (如果使用私有仓库)
kubectl create secret docker-registry registry-secret \
  --docker-server=ghcr.io \
  --docker-username=<github-username> \
  --docker-password=<github-token> \
  -n nexusbook
```

### Pod 无法启动

```bash
# 查看 Pod 事件
kubectl describe pod -n nexusbook -l app=nexusbook-api-docs

# 查看容器日志
kubectl logs -n nexusbook -l app=nexusbook-api-docs --all-containers
```

### Ingress 无法访问

```bash
# 检查 Ingress 状态
kubectl describe ingress nexusbook-api-docs -n nexusbook

# 检查 Ingress Controller 日志
kubectl logs -n kube-system -l app.kubernetes.io/name=ingress-nginx
```

### DNS 解析问题

确保域名 `open.nexusbook.app` 正确解析到 K3s 集群的外部 IP:

```bash
# 获取 Ingress 外部 IP
kubectl get ingress nexusbook-api-docs -n nexusbook

# 测试 DNS 解析
nslookup open.nexusbook.app
dig open.nexusbook.app
```

---

## 📚 相关文档

- [TypeSpec 文档](https://typespec.io/)
- [Redocly 配置](https://redocly.com/docs/)
- [K3s 文档](https://docs.k3s.io/)
- [cert-manager 文档](https://cert-manager.io/docs/)

---

## 🆘 获取帮助

如遇到问题:

1. 查看 GitHub Actions 运行日志
2. 检查 K3s Pod 日志: `make k3s-logs`
3. 查看部署状态: `make k3s-status`
4. 参考上面的故障排查部分
