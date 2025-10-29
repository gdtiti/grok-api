#!/usr/bin/env python3
"""
HuggingFace Space 部署脚本

此脚本用于将构建的 Docker 镜像发布到 HuggingFace Space
"""

import os
import sys
import argparse
import subprocess
from pathlib import Path


def run_command(cmd, check=True):
    """执行命令并返回结果"""
    print(f"执行命令: {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True, check=check)
    if result.stdout:
        print(f"输出: {result.stdout.strip()}")
    if result.stderr:
        print(f"错误: {result.stderr.strip()}")
    return result


def login_to_huggingface(token=None):
    """登录到 HuggingFace"""
    if token:
        # 使用提供的 token 登录
        os.environ['HF_TOKEN'] = token
        run_command(['huggingface-cli', 'login', '--token', token])
    else:
        # 检查是否已登录
        result = run_command(['huggingface-cli', 'whoami'], check=False)
        if result.returncode != 0:
            print("未登录到 HuggingFace，请先运行 'huggingface-cli login' 或提供 token")
            sys.exit(1)


def build_hf_docker_image(registry, repository, version, platform):
    """构建 HuggingFace Space 专用的 Docker 镜像"""
    tag = f"{registry}/{repository}:hf-{platform}-{version}"

    print(f"构建 HuggingFace Space 镜像: {tag}")

    cmd = [
        'docker', 'build',
        '-f', 'hf/Dockerfile',
        '-t', tag,
        '.'
    ]

    run_command(cmd)
    return tag


def push_docker_image(tag):
    """推送 Docker 镜像"""
    print(f"推送镜像: {tag}")
    run_command(['docker', 'push', tag])


def update_hf_space(space_name, image_tag):
    """更新 HuggingFace Space"""
    print(f"更新 HuggingFace Space: {space_name}")

    # 使用 huggingface-cli 更新 space
    cmd = [
        'huggingface-cli', 'space', 'run',
        space_name,
        '--docker-image', image_tag
    ]

    # 如果 huggingface-cli ��支持直接更新 Docker 镜像，则使用其他方法
    result = run_command(cmd, check=False)
    if result.returncode != 0:
        print("huggingface-cli 不支持直接更新 Docker 镜像，请手动更新 Space 配置")
        print(f"请将以下镜像地址配置到 Space 中: {image_tag}")
        return False

    return True


def main():
    parser = argparse.ArgumentParser(description='部署到 HuggingFace Space')
    parser.add_argument('--registry', default='ghcr.io', help='Docker 镜像仓库地址')
    parser.add_argument('--repository', required=True, help='镜像仓库名称 (如: gdtiti/grok2api)')
    parser.add_argument('--version', required=True, help='版本标签')
    parser.add_argument('--space-name', help='HuggingFace Space 名称 (如: username/grok2api-space)')
    parser.add_argument('--hf-token', help='HuggingFace 访问 token')
    parser.add_argument('--platform', default='amd64', choices=['amd64', 'arm64'], help='目标平台')
    parser.add_argument('--push-only', action='store_true', help='仅推送镜像，不更新 Space')
    parser.add_argument('--dry-run', action='store_true', help='仅显示将要执行的命令，不实际执行')

    args = parser.parse_args()

    # 检查必要工具
    required_tools = ['docker', 'huggingface-cli']
    for tool in required_tools:
        result = subprocess.run([tool, '--version'], capture_output=True)
        if result.returncode != 0:
            print(f"错误: 未找到 {tool}，请先安装")
            sys.exit(1)

    # 登录 HuggingFace
    if not args.dry_run:
        login_to_huggingface(args.hf_token)

    # 构建镜像
    image_tag = build_hf_docker_image(args.registry, args.repository, args.version, args.platform)

    # 推送镜像
    if not args.dry_run:
        push_docker_image(image_tag)

    # 更新 Space（如果指定且不是仅推送模式）
    if args.space_name and not args.push_only and not args.dry_run:
        success = update_hf_space(args.space_name, image_tag)
        if success:
            print(f"✅ HuggingFace Space {args.space_name} 更新成功")
        else:
            print(f"⚠️ 请手动更新 Space {args.space_name} 的 Docker 镜像为: {image_tag}")

    print(f"\n🎉 部署完成!")
    print(f"镜像地址: {image_tag}")
    if args.space_name:
        print(f"Space 地址: https://huggingface.co/spaces/{args.space_name}")


if __name__ == '__main__':
    main()