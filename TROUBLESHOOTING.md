# 故障排除指南

## GitHub Actions 权限问题

### 问题描述

```
ERROR: failed to build: failed to solve: failed to push ghcr.io/gdtiti/grok2api:main-amd64: denied: permission_denied: write_package
```

### 特殊情况：包名冲突

如果你之前删除过同名的 Container Registry 包，可能会遇到包名冲突问题。这是一个常见的 GitHub Container Registry 限制。

**✅ 已实施的修复**: 我们已经将包名从 `ghcr.io/gdtiti/grok2api` 更改为 `ghcr.io/gdtiti/grok2api-api`。

详细解决方案请参考 [REGISTRY_FIX.md](REGISTRY_FIX.md)。

### 解决方案

#### 1. 仓库权限设置

确保 GitHub Actions 有足够的权限：

1. 进入仓库设置页面
2. 点击 **Actions** > **General**
3. 在 **Workflow permissions** 部分：
   - 选择 **Read and write permissions**
   - ✅ 勾选 **Allow GitHub Actions to create and approve pull requests**
   - ✅ 勾选 **Allow GitHub Actions to run approved pull requests from forks**




#### 2. 工作流权限配置

工作流文件中已配置了正确的权限：

```yaml
permissions:
  contents: read
  packages: write
  id-token: write
  attestations: write
```

#### 3. Container Registry 访问权限

确保仓库启用了 Container Registry：

1. 进入仓库设置页面
2. 点击 **Actions** > **General**
3. 滚动到 **Package access** 部分
4. 确保选择了正确的访问权限（通常选择 **Allow selected actions** 或 **Allow all actions**）

#### 4. 个人访问令牌（如果需要）

如果使用个人访问令牌，确保包含以下权限：
- `repo` - 完整仓库访问权限
- `write:packages` - 包写入权限
- `read:packages` - 包读取权限

## HuggingFace 部署问题

### 1. HF_TOKEN 设置

在 GitHub 仓库设置中添加 Secret：

1. 进入仓库设置页面
2. 点击 **Secrets and variables** > **Actions**
3. 点击 **New repository secret**
4. 添加以下 Secret：
   - **Name**: `HF_TOKEN`
   - **Secret**: 你的 HuggingFace Access Token

### 2. 获取 HuggingFace Access Token

1. 登录 [HuggingFace](https://huggingface.co)
2. 点击右上角头像 > **Settings**
3. 点击 **Access Tokens**
4. 点击 **New token**
5. 选择 **write** 权限
6. 复制生成的 token

### 3. Space 权限问题

确保你有以下权限：
- Space 的写入权限
- 创建和修改 Space 的权限

## 常见问题

### Q: 构建成功但推送失败

**A**: 检查权限设置：
1. 确认仓库 Actions 权限设置为 **Read and write**
2. 确认 Container Registry 已启用
3. 检查网络连接和代理设置

### Q: HF 部署时 API 调用失败

**A**: 检查以下项目：
1. `HF_TOKEN` 是否正确设置且有足够权限
2. Space 名称是否正确（格式：`username/space-name`）
3. 镜像地址是否正确推送到 registry

### Q: 工作流参数不生效

**A**: 检查参数格式：
1. 分支名称必须存在
2. 版本号建议使用语义化版本（如：v1.0.0）
3. Space 名称格式必须正确

### Q: 多架构镜像合并失败

**A**: 检查以下项目：
1. 确保所有平台都成功构建
2. 检查镜像标签是否一致
3. 确认有足够的权限操作清单

## 调试技巧

### 1. 查看详细日志

在 GitHub Actions 页面：
1. 点击失败的工作流运行
2. 点击具体的作业
3. 查看详细的错误日志

### 2. 本地测试

```bash
# 本地构建测试
docker buildx build -t test-image .

# 本地推送测试
docker tag test-image ghcr.io/your-username/your-repo:test
docker push ghcr.io/your-username/your-repo:test
```

### 3. 权限验证

```bash
# 验证 GitHub CLI 登录
gh auth status

# 验证 Docker 登录
docker info | grep "Registry Mirrors"
```

## 获取帮助

如果遇到无法解决的问题：

1. **GitHub Actions**: [GitHub Actions 文档](https://docs.github.com/en/actions)
2. **Container Registry**: [GitHub Packages 文档](https://docs.github.com/en/packages)
3. **HuggingFace**: [HuggingFace 文档](https://huggingface.co/docs/hub)
4. **项目 Issues**: [GitHub Issues](https://github.com/chenyme/grok2api/issues)

## 检查清单

在运行工作流前，确认以下项目：

- [ ] 仓库 Actions 权限设置为 **Read and write**
- [ ] Container Registry 已启用
- [ ] `HF_TOKEN` Secret 已设置（如果部署到 HF）
- [ ] 目标分支存在
- [ ] Space 名称格式正确（如果部署到 HF）
- [ ] 网络连接正常