"""URL 管理器 - 处理镜像 URL 配置"""

import os
from typing import Optional
from urllib.parse import urljoin

from app.core.logger import logger


class URLManager:
    """URL 管理器，支持镜像 URL 配置"""

    def __init__(self):
        """初始化 URL 管理器"""
        self._use_mirror = self._get_bool_env("GROK_USE_MIRROR", False)
        self._api_base_url = os.getenv("GROK_API_BASE_URL", "https://grok.com").rstrip('/')
        self._assets_base_url = os.getenv("GROK_ASSETS_BASE_URL", "https://assets.grok.com").rstrip('/')

        # 记录配置
        if self._use_mirror:
            logger.info(f"[URLManager] 镜像模式已启用")
            logger.info(f"[URLManager] API 基础 URL: {self._api_base_url}")
            logger.info(f"[URLManager] 资源基础 URL: {self._assets_base_url}")
        else:
            logger.info(f"[URLManager] 使用默认官方 URL")

    @staticmethod
    def _get_bool_env(key: str, default: bool = False) -> bool:
        """从环境变量获取布尔值"""
        value = os.getenv(key, "").lower()
        return value in ('true', '1', 'yes', 'on')

    def get_api_url(self, path: str) -> str:
        """获取 API URL（支持镜像）"""
        path = path.lstrip('/')
        return f"{self._api_base_url}/{path}"

    def get_assets_url(self, path: str) -> str:
        """获取静态资源 URL（支持镜像）"""
        path = path.lstrip('/')
        return f"{self._assets_base_url}/{path}"

    def get_imagine_url(self, post_id: str) -> str:
        """获取 imagine 页面 URL"""
        return f"{self._api_base_url}/imagine/{post_id}"

    def get_referer_url(self) -> str:
        """获取基础 referer URL"""
        return f"{self._api_base_url}/"

    def is_mirror_enabled(self) -> bool:
        """检查是否启用了镜像"""
        return self._use_mirror

    def get_config_info(self) -> dict:
        """获取配置信息（用于调试）"""
        return {
            "use_mirror": self._use_mirror,
            "api_base_url": self._api_base_url,
            "assets_base_url": self._assets_base_url
        }


# 全局 URL 管理器实例
url_manager = URLManager()


# 便捷函数，保持向后兼容
def get_grok_api_url(path: str) -> str:
    """获取 Grok API URL"""
    return url_manager.get_api_url(path)


def get_grok_assets_url(path: str) -> str:
    """获取 Grok 资源 URL"""
    return url_manager.get_assets_url(path)


def get_grok_imagine_url(post_id: str) -> str:
    """获取 Grok imagine URL"""
    return url_manager.get_imagine_url(post_id)


def get_grok_referer_url() -> str:
    """获取 Grok referer URL"""
    return url_manager.get_referer_url()


def is_mirror_enabled() -> bool:
    """检查是否启用了镜像"""
    return url_manager.is_mirror_enabled()