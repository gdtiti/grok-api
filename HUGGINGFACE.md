# HuggingFace Space 集成指南

本项目支持一键部署到 HuggingFace Space，提供在线的 Grok API 代理服务。

## 📁 文件结构

```
hf/
├── README.md              # HuggingFace Space 主页面
├── Dockerfile             # Space 专用 Docker 镜像
├── .env.example           # 环境变量示例
└── README_USAGE.md        # 详细使用指南

scripts/
├── deploy-to-hf.py        # Python 部署脚本
└── deploy-to-hf.sh        # Shell 部署脚本
```

## 🚀 部署方式

### 方式一：GitHub Actions 自动部署（推荐）

1. **设置 HuggingFace Token**
   ```bash
   # 在 GitHub 仓库设置中添加 Secret
   # HF_TOKEN: 你的 HuggingFace Access Token
   ```

2. **触发工作流**
   - 进入 GitHub Actions 页面
   - 选择 "Build Docker Image" 工作流
   - 点击 "Run workflow"
   - 填写以下参数：
     ```
     branch: main
     version: v1.0.0  # 或其他版本号
     push_image: true
     deploy_to_hf: true
     hf_space_name: your-username/grok2api-space
     ```

3. **自动部署**
   - 工作流会自动构建 HF 专用镜像
   - 镜像标签：`ghcr.io/gdtiti/grok2api:hf-amd64-v1.0.0`
   - 自动更新 HuggingFace Space 配置

### 方式二：手动部署脚本

#### 使用 Python 脚本

```bash
# 安装依赖
pip install huggingface_hub

# 登录 HuggingFace
huggingface-cli login --token YOUR_HF_TOKEN

# 运行部署脚本
python scripts/deploy-to-hf.py \
  --repository gdtiti/grok2api \
  --version v1.0.0 \
  --space-name your-username/grok2api-space \
  --platform amd64
```

#### 使用 Shell 脚本

```bash
# 设置环境变量
export REGISTRY=ghcr.io
export REPOSITORY=gdtiti/grok2api

# 登录 HuggingFace
huggingface-cli login

# 运行部署脚本
./scripts/deploy-to-hf.sh v1.0.0 your-username/grok2api-space
```

### 方式三：手动构建和部署

```bash
# 1. 构建 HF 专用镜像
docker build -f hf/Dockerfile -t ghcr.io/gdtiti/grok2api:hf-amd64-latest .

# 2. 推送镜像
docker push ghcr.io/gdtiti/grok2api:hf-amd64-latest

# 3. 在 HuggingFace Space 中设置镜像地址
# 访问你的 Space -> Settings -> Docker Image
# 设置为: ghcr.io/gdtiti/grok2api:hf-amd64-latest
```

## 🔧 配置说明

### 环境变量

在 HuggingFace Space 的设置中配置以下环境变量：

```bash
# 基础配置（必需）
HOST=0.0.0.0
PORT=7860

# 镜像配置（可选）
GROK_USE_MIRROR=false
GROK_API_BASE_URL=https://grok.com
GROK_ASSETS_BASE_URL=https://assets.grok.com

# 高级配置（可选）
# PROXY_URL=socks5h://proxy.example.com:1080
# CACHE_PROXY_URL=
# CF_CLEARANCE=your_cf_clearance_value
```

### Space 配置

- **SDK**: Docker
- **Hardware**: CPU Basic (免费) 或 T4 GPU (付费)
- **Visibility**: Public 或 Private
- **Docker Image**: `ghcr.io/gdtiti/grok2api:hf-amd64-{version}`

## 📦 镜像标签规范

### 标签格式

```
{registry}/{repository}:hf-{platform}-{version}
```

### 示例标签

- `ghcr.io/gdtiti/grok2api:hf-amd64-v1.0.0`
- `ghcr.io/gdtiti/grok2api:hf-arm64-v1.0.0`
- `ghcr.io/gdtiti/grok2api:hf-amd64-main`
- `ghcr.io/gdtiti/grok2api:hf-arm64-develop`

### 平台支持

- `amd64`: 适用于大多数服务器
- `arm64`: 适用于 ARM 架构服务器

## 🛠️ 本地开发

### 构建 HF 镜像

```bash
# 构建本地开发镜像
docker build -f hf/Dockerfile -t grok2api-hf:dev .

# 运行容器
docker run -d \
  -p 7860:7860 \
  -e HOST=0.0.0.0 \
  -e PORT=7860 \
  grok2api-hf:dev
```

### 测试 Space 配置

```bash
# 使用 HF CLI 测试
huggingface-cli space download your-username/grok2api-space

# 本地测试配置
docker run --rm \
  -e GROK_USE_MIRROR=true \
  -e GROK_API_BASE_URL=https://your-mirror.com \
  ghcr.io/gdtiti/grok2api:hf-amd64-latest
```

## 🔍 监控和日志

### Space 健康检查

```bash
# 检查服务状态
curl https://your-space.hf.space/health

# 检查模型列表
curl https://your-space.hf.space/v1/models
```

### 日志查看

- HuggingFace Space 网页界面中的 "Logs" 标签
- 通过 API 端点 `/admin` 查看请求日志

## 🚨 注意事项

1. **资源限制**
   - 免费版 Space 有 CPU 和内存限制
   - 建议使用付费版获得更好的性能

2. **Token 安全**
   - 不要在环境变量中直接存储 Token
   - 通过管理界面动态添加 Token

3. **使用配额**
   - 注意 HuggingFace Space 的使用限制
   - 监控 API 调用频率

4. **镜像更新**
   - 更新镜像后需要重启 Space
   - 建议使用版本化标签便于回滚

## 📚 相关链接

- [HuggingFace Spaces 文档](https://huggingface.co/docs/hub/spaces)
- [Docker SDK for Spaces](https://huggingface.co/docs/hub/spaces-sdks-docker)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [项目主页](https://github.com/chenyme/grok2api)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进 HuggingFace 集成功能。