# Container Registry 包名冲突修复指南

## 问题描述

当你之前删除了同名的 Container Registry 包后，GitHub 的包管理系统会保留包名称的记录，导致无法重新创建同名包。常见的错误信息：

```
ERROR: failed to build: failed to solve: failed to push ghcr.io/gdtiti/grok2api:main-amd64: denied: permission_denied: write_package
```

## 🔧 已实施的修复

我已经修改了工作流文件，使用新的包名称：

**修改前**: `IMAGE_NAME: ${{ github.repository }}`
**修改后**: `IMAGE_NAME: ${{ github.repository }}-api`

这意味着：
- **旧的包名**: `ghcr.io/gdtiti/grok2api`
- **新的包名**: `ghcr.io/gdtiti/grok2api-api`

## 📦 新的镜像标签格式

现在构建的镜像将使用以下标签格式：

### 主镜像
- `ghcr.io/gdtiti/grok2api-api:latest-amd64`
- `ghcr.io/gdtiti/grok2api-api:latest-arm64`
- `ghcr.io/gdtiti/grok2api-api:latest` (合并标签)

### 版本标签
- `ghcr.io/gdtiti/grok2api-api:v1.0.0-amd64`
- `ghcr.io/gdtiti/grok2api-api:v1.0.0-arm64`
- `ghcr.io/gdtiti/grok2api-api:v1.0.0` (合并标签)

### 分支标签
- `ghcr.io/gdtiti/grok2api-api:main-amd64`
- `ghcr.io/gdtiti/grok2api-api:main-arm64`
- `ghcr.io/gdtiti/grok2api-api:main` (合并标签)

### HuggingFace 专用标签
- `ghcr.io/gdtiti/grok2api-api:hf-amd64-v1.0.0`
- `ghcr.io/gdtiti/grok2api-api:hf-arm64-v1.0.0`

## 🚀 立即使用

1. **重新触发工作流**:
   - 进入 GitHub Actions 页面
   - 选择 "Build Docker Image" 工作流
   - 点击 "Run workflow"
   - 填写参数并运行

2. **使用新镜像**:
   ```bash
   # 拉取新镜像
   docker pull ghcr.io/gdtiti/grok2api-api:latest

   # 或者使用版本标签
   docker pull ghcr.io/gdtiti/grok2api-api:v1.0.0
   ```

## 🔍 诊断工具

如果遇到问题，可以运行诊断脚本：

```bash
# 检查 Container Registry 状态
./scripts/check-registry.sh

# 修复权限问题
./scripts/fix-permissions.sh
```

## 📋 其他解决方案（如果需要）

### 方案 A: 使用不同的后缀

如果 `-api` 后缀仍然有问题，可以考虑：

- `-v2` → `ghcr.io/gdtiti/grok2api-v2`
- `-new` → `ghcr.io/gdtiti/grok2api-new`
- `-server` → `ghcr.io/gdtiti/grok2api-server`
- `-service` → `ghcr.io/gdtiti/grok2api-service`

修改方法：
```yaml
# 在 .github/workflows/docker.yml 中
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}-v2  # 修改后缀
```

### 方案 B: 完全不同的包名

使用完全不同的包名：

```yaml
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: gdtiti/grok-api-server  # 完全不同的名称
```

### 方案 C: 使用不同的 Container Registry

如果 GitHub Container Registry 问题持续存在：

#### Docker Hub
```yaml
env:
  REGISTRY: docker.io
  IMAGE_NAME: gdtiti/grok2api
```

#### 其他 Registry
- **Azure Container Registry**: `yourregistry.azurecr.io`
- **AWS ECR**: `youraccount.dkr.ecr.region.amazonaws.com`
- **Google Container Registry**: `gcr.io/your-project`

## 🛠️ 手动清理旧包（如果可能）

### 方法 1: 通过 GitHub Web 界面

1. 访问: https://github.com/gdtiti/packages/container/grok2api
2. 如果包仍然存在，尝试完全删除
3. 删除所有版本和包本身

### 方法 2: 使用 GitHub CLI

```bash
# 列出所有容器包
gh api "https://api.github.com/users/gdtiti/packages?package_type=container"

# 删除特定版本（如果有）
gh api --method DELETE "https://api.github.com/users/gdtiti/packages/container/grok2api/versions/{version_id}"

# 删除整个包（如果允许）
gh api --method DELETE "https://api.github.com/users/gdtiti/packages/container/grok2api"
```

### 方法 3: 联系 GitHub 支持

如果以上方法都不行，可以联系 GitHub 支持团队：
1. 访问: https://support.github.com/
2. 提交支持请求，说明情况
3. 请求他们清理包名称记录

## 📝 部署配置更新

### Docker Compose
```yaml
# 更新前
image: ghcr.io/gdtiti/grok2api:latest

# 更新后
image: ghcr.io/gdtiti/grok2api-api:latest
```

### Kubernetes
```yaml
# 更新前
image: ghcr.io/gdtiti/grok2api:latest

# 更新后
image: ghcr.io/gdtiti/grok2api-api:latest
```

### 脚本和文档

记得更新所有引用旧镜像名称的地方：
- 部署脚本
- 文档中的示例
- CI/CD 配置
- 监控配置

## 🔄 迁移计划

如果需要从旧镜像迁移到新镜像：

1. **并行运行**: 同时运行新旧版本进行测试
2. **逐步迁移**: 逐个环境更新镜像名称
3. **完全切换**: 确认新版本稳定后完全切换
4. **清理旧资源**: 删除旧的镜像和配置

## 📞 获取帮助

如果问题仍然存在：

1. **运行诊断脚本**: `./scripts/check-registry.sh`
2. **查看详细日志**: GitHub Actions 中的错误信息
3. **联系支持**: GitHub Support 或 HuggingFace Support
4. **社区求助**: GitHub Issues 或相关论坛

---

**注意**: 新的包名称 `ghcr.io/gdtiti/grok2api-api` 已经在当前工作流中配置，你现在可以直接使用 GitHub Actions 构建和推送镜像了！