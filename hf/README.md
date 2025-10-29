---
title: G2API
emoji: 🤖
colorFrom: blue
colorTo: purple
sdk: docker
pinned: false
license: mit
short_description: 一个强大的Grok API代理服务
---

# Grok2API HuggingFace Space

这是 Grok2API 项目的 HuggingFace Space 版本，提供了一个强大的 Grok API 代理服务。

## 功能特性

- 🚀 **高性能代理**：基于 FastAPI 的高性能 API 代理服务
- 🔐 **Token 管理**：支持多 Token 负载均衡和失效检测
- 🖼️ **图片处理**：支持图片上传、缓存和格式转换
- 🎥 **视频生成**：支持 Grok 视频生成功能
- 📊 **管理界面**：内置 Web 管理界面
- 🔧 **镜像支持**：支持通过环境变量配置上游镜像地址
- 📝 **完整日志**：详细的请求和响应日志

## 环境变量配置

### 基础配置

```bash
# 应用配置
HOST=0.0.0.0
PORT=7860

# 镜像配置（可选）
GROK_USE_MIRROR=false
GROK_API_BASE_URL=https://grok.com
GROK_ASSETS_BASE_URL=https://assets.grok.com
```

### 高级配置

更多配置选项请参考项目的 [setting.toml](../data/setting.toml.example) 文件。

## API 端点

### OpenAI 兼容接口

- `POST /v1/chat/completions` - 聊天对话接口
- `GET /v1/models` - 获取可用模型列表

### 管理接口

- `GET /admin` - Web 管理界面
- `GET /health` - 健康检查

## 使用示例

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

## 部署说明

1. 点击 HuggingFace Space 页面上的 "Duplicate this Space" 按钮
2. 根据需要配置环境变量
3. 等待构建完成即可使用

## 支持的模型

- `grok-2-latest`
- `grok-2-mini`
- `grok-vision-beta`
- `grok-imagine-0.9`
- `grok-3-mini`
- `grok-3-fast`
- `grok-4-heavy`

## 许可证

MIT License - 详见 [LICENSE](../LICENSE) 文件

## 相关链接

- [GitHub 项目](https://github.com/chenyme/grok2api)
- [项目文档](../readme.md)

---

> 💡 **提示**：这个 Space 是 Grok2API 项目的演示版本。对于生产使用，建议自行部署以获得更好的性能和控制。