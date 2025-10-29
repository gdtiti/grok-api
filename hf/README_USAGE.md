# HuggingFace Space 使用指南

## 快速开始

### 1. 复制 Space

访问 [项目 Space 页面](https://huggingface.co/spaces/your-username/grok2api)，点击 "Duplicate this Space" 按钮。

### 2. 配置环境变量

在 Space 设置中添加以下环境变量：

```bash
# 基础配置（必需）
HOST=0.0.0.0
PORT=7860

# 可选配置
GROK_USE_MIRROR=false
GROK_API_BASE_URL=https://grok.com
GROK_ASSETS_BASE_URL=https://assets.grok.com
```

### 3. 添加 Token

Space 启动后，访问管理界面添加 Grok Token：

1. 打开 `https://your-space.hf.space/admin`
2. 在 Token 管理页面添加你的 Grok Token
3. 保存配置

## API 使用

### 聊天对话

```bash
curl -X POST "https://your-space.hf.space/v1/chat/completions" \
  -H "Authorization: Bearer your-grok-token" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-2-latest",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ]
  }'
```

### 获取模型列表

```bash
curl -X GET "https://your-space.hf.space/v1/models" \
  -H "Authorization: Bearer your-grok-token"
```

### 图片对话

```bash
curl -X POST "https://your-space.hf.space/v1/chat/completions" \
  -H "Authorization: Bearer your-grok-token" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-vision-beta",
    "messages": [
      {
        "role": "user",
        "content": [
          {"type": "text", "text": "描述这张图片"},
          {
            "type": "image_url",
            "image_url": {
              "url": "https://example.com/image.jpg"
            }
          }
        ]
      }
    ]
  }'
```

## 支持的模型

- `grok-2-latest` - 最新的 Grok 2 模型
- `grok-2-mini` - 轻量版 Grok 2
- `grok-vision-beta` - 视觉理解模型
- `grok-imagine-0.9` - 图像生成模型
- `grok-3-mini` - Grok 3 轻量版
- `grok-3-fast` - 快速响应版本
- `grok-4-heavy` - 高性能版本

## 功能特性

### 🔄 Token 管理
- 支持多个 Token 轮询使用
- 自动检测 Token 失效
- 负载均衡和失败重试

### 🖼️ 图片处理
- 支持 URL 和 Base64 格式
- 自动图片缓存
- 格式转换和优化

### 🎥 视频生成
- 支持 Grok 视频生成功能
- 自动视频下载和缓存
- 流式返回支持

### 📊 管理界面
- Token 管理和统计
- 请求日志查看
- 系统状态监控

### 🔧 镜像支持
- 支持自定义上游镜像地址
- 透明代理，无需修改客户端代码
- 自动故障切换

## 部署方式

### 方式一：HuggingFace Space（推荐）

1. 点击复制 Space
2. 配置环境变量
3. 等待构建完成
4. 添加 Token 开始使用

### 方式二：本地部署

```bash
# 克隆项目
git clone https://github.com/chenyme/grok2api.git
cd grok2api

# 安装依赖
pip install -r requirements.txt

# 启动服务
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### 方式三：Docker 部署

```bash
# 使用预构建镜像
docker run -d \
  -p 8000:8000 \
  -e GROK_USE_MIRROR=false \
  ghcr.io/gdtiti/grok2api:latest

# 或自行构建
docker build -t grok2api .
docker run -d -p 8000:8000 grok2api
```

## 故障排除

### 常见问题

1. **Token 失效**
   - 检查 Token 是否有效
   - 登录 Grok.com 确认账号状态

2. **请求超时**
   - 检查网络连接
   - 考虑使用代理或镜像

3. **图片处理失败**
   - 确认图片 URL 可访问
   - 检查图片格式是否支持

4. **Space 构建失败**
   - 检查依赖是否正确
   - 查看 Space 构建日志

### 获取帮助

- [GitHub Issues](https://github.com/chenyme/grok2api/issues)
- [项目文档](https://github.com/chenyme/grok2api/blob/main/readme.md)
- [社区讨论](https://github.com/chenyme/grok2api/discussions)

## 许可证

MIT License - 可自由使用和修改。