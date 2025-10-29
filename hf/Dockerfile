# HuggingFace Space 专用 Dockerfile
# 基于预构建的 GitHub Container Registry 镜像

# 使用环境变量或默认镜像地址
ARG BASE_IMAGE
FROM ${BASE_IMAGE:-ghcr.io/gdtiti/grok-api:latest}

# 设置 HuggingFace Space 特定的环境变量
ENV HOST=0.0.0.0
ENV PORT=7860

# 确保必要的目录存在（如果基础镜像中没有）
RUN mkdir -p data/temp/image data/temp/video 2>/dev/null || true

# 健康检查（使用 HuggingFace Space 的端口）
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:7860/health || exit 1

# 暴露 HuggingFace Space 标准端口
EXPOSE 8000

CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]