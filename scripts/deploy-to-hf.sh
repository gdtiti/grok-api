#!/bin/bash

# HuggingFace Space 部署脚本
# 使用方法: ./scripts/deploy-to-hf.sh [version] [space_name]

set -e

# 默认参数
REGISTRY=${REGISTRY:-"ghcr.io"}
REPOSITORY=${REPOSITORY:-"gdtiti/grok2api"}
VERSION=${1:-"latest"}
SPACE_NAME=${2:-""}
PLATFORM=${PLATFORM:-"amd64"}

# 检查必要工具
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo "错误: 未找到 $1，请先安装"
        exit 1
    fi
}

echo "检查必要工具..."
check_tool docker
check_tool huggingface-cli

# 检查 HuggingFace 登录状态
echo "检查 HuggingFace 登录状态..."
if ! huggingface-cli whoami &> /dev/null; then
    echo "未登录到 HuggingFace，请先运行: huggingface-cli login"
    exit 1
fi

# 构建镜像
TAG="${REGISTRY}/${REPOSITORY}:hf-${PLATFORM}-${VERSION}"
echo "构建 HuggingFace Space 镜像: ${TAG}"

docker build \
    -f hf/Dockerfile \
    -t "${TAG}" \
    .

# 推送镜像
echo "推送镜像到仓库..."
docker push "${TAG}"

# 输出结果
echo ""
echo "🎉 部署完成!"
echo "镜像地址: ${TAG}"

if [ -n "$SPACE_NAME" ]; then
    echo "Space 地址: https://huggingface.co/spaces/${SPACE_NAME}"
    echo ""
    echo "📝 更新说明:"
    echo "请访问 HuggingFace Space 页面，在 Space 设置中将 Docker 镜像地址修改为:"
    echo "${TAG}"
    echo ""
    echo "或者使用 huggingface-cli 命令更新 (如果支持):"
    echo "huggingface-cli space run ${SPACE_NAME} --docker-image ${TAG}"
fi

echo ""
echo "🚀 环境变量配置示例:"
echo "请将以下环境变量添加到 HuggingFace Space 的设置中:"
cat hf/.env.example