# HuggingFace Space 构建策略

## 🏗️ 构架概述

本项目采用**分层构建策略**来优化 HuggingFace Space 的部署：

```
GitHub Actions → 主镜像 → HF 包装镜像 → HuggingFace Space
```

## 🔄 构建流程

### 第一阶段：主镜像构建
1. **GitHub Actions** 构建完整的应用镜像
2. 镜像标签：`ghcr.io/gdtiti/grok2api-api:{version}`
3. 包含所有代码、依赖和配置

### 第二阶段：HF 包装
1. **HF Dockerfile** 基于主镜像创建轻量级包装
2. 镜像标签：`ghcr.io/gdtiti/grok2api-api:hf-{platform}-{version}`
3. 仅添加 HuggingFace Space 特定配置

## 📦 镜像关系

### 主镜像（基础镜像）
```dockerfile
# 完整的应用镜像
ghcr.io/gdtiti/grok2api-api:latest
ghcr.io/gdtiti/grok2api-api:v1.0.0
ghcr.io/gdtiti/grok2api-api:main
```

### HF 包装镜像（派生镜像）
```dockerfile
# 基于 main 镜像的 HF 版本
FROM ghcr.io/gdtiti/grok2api-api:latest

# 仅添加 HF 特定配置
ENV HOST=0.0.0.0
ENV PORT=7860
EXPOSE 7860
```

## 🎯 优势

### 1. **构建时间优化**
- 主镜像：约 8-10 分钟（完整构建）
- HF 包装：约 1-2 分钟（轻量级包装）
- **总体节省：60-80% 的构建时间**

### 2. **资源效率**
- 避免重复编译依赖
- 利用 Docker 层缓存
- 减少网络传输

### 3. **版本一致性**
- HF Space 与生产环境使用相同基础镜像
- 确保功能一致性
- 简化版本管理

### 4. **维护便利**
- 主镜像更新自动传递到 HF
- 单一源代码管理
- 减少配置重复

## 🔧 构建命令示例

### 本地构建 HF 镜像
```bash
# 构建主镜像（如果不存在）
docker pull ghcr.io/gdtiti/grok2api-api:latest

# 构建 HF 包装镜像
docker build \
  -f hf/Dockerfile \
  -t ghcr.io/gdtiti/grok2api-api:hf-amd64-latest \
  --build-arg BASE_IMAGE=ghcr.io/gdtiti/grok2api-api:latest \
  .
```

### GitHub Actions 自动构建
工作流会自动：
1. 构建主镜像
2. 使用主镜像构建 HF 包装镜像
3. 推送到 Container Registry
4. 可选：更新 HuggingFace Space

## 📋 目录结构

```
hf/
├── Dockerfile              # HF 包装 Dockerfile
├── README.md              # HF Space 主页
├── .env.example           # 环境变量示例
└── README_USAGE.md        # 使用指南

.github/workflows/
└── docker.yml             # 包含主镜像和 HF 镜像构建
```

## 🚀 部署场景

### 场景 1：GitHub Actions 自动部署
```yaml
# 1. 构建主镜像
# 2. 构建 HF 包装镜像
# 3. 推送到 GHCR
# 4. 更新 HuggingFace Space
```

### 场景 2：手动部署
```bash
# 1. 拉取主镜像
docker pull ghcr.io/gdtiti/grok2api-api:latest

# 2. 构建 HF 镜像
./scripts/deploy-to-hf.sh latest your-username/grok2api-space
```

### 场景 3：本地开发
```bash
# 1. 构建主镜像（开发版）
docker build -t grok2api-dev .

# 2. 构建 HF 包装
docker build \
  -f hf/Dockerfile \
  -t grok2api-hf-dev \
  --build-arg BASE_IMAGE=grok2api-dev \
  .
```

## ⚙️ 配置说明

### HF Dockerfile 参数
```dockerfile
ARG BASE_IMAGE  # 基础镜像地址
FROM ${BASE_IMAGE}

# HF 特定配置
ENV HOST=0.0.0.0
ENV PORT=7860
EXPOSE 7860
```

### 构建参数传递
```bash
--build-arg BASE_IMAGE=ghcr.io/gdtiti/grok2api-api:v1.0.0
```

## 🔍 故障排除

### 问题 1：基础镜像拉取失败
```bash
# 检查镜像是否存在
docker pull ghcr.io/gdtiti/grok2api-api:latest

# 如果不存在，先构建主镜像
docker build -t ghcr.io/gdtiti/grok2api-api:latest .
```

### 问题 2：HF 镜像构建失败
```bash
# 检查基础镜像标签
docker images | grep grok2api-api

# 手动指定基础镜像
docker build \
  -f hf/Dockerfile \
  --build-arg BASE_IMAGE=ghcr.io/gdtiti/grok2api-api:main \
  -t test-hf .
```

### 问题 3：Space 启动失败
1. 检查环境变量配置
2. 验证健康检查端点
3. 查看容器日志

## 📊 性能对比

| 构建方式 | 构建时间 | 镜像大小 | 网络传输 |
|---------|---------|---------|---------|
| 完整构建 | 8-10 分钟 | ~500MB | 完整 |
| 分层构建 | 1-2 分钟 | ~502MB | 增量 |

## 🎉 最佳实践

1. **版本化构建**：始终使用明确的版本标签
2. **缓存利用**：充分利用 Docker 层缓存
3. **环境隔离**：HF 特定配置通过环境变量传递
4. **监控日志**：密切关注构建和部署日志
5. **定期更新**：保持基础镜像和依赖的最新状态

---

这种分层构建策略确保了高效的部署流程，同时保持了生产环境和 HuggingFace Space 的一致性。