#!/bin/bash

# GitHub Actions 权限修复脚本
# 用于检查和修复权限问题

set -e

echo "🔧 GitHub Actions 权限修复脚本"
echo "=================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查 GitHub CLI
check_gh_cli() {
    echo -e "${BLUE}📋 检查 GitHub CLI...${NC}"
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI 未安装${NC}"
        echo "请安装 GitHub CLI: https://cli.github.com/manual/installation"
        exit 1
    fi

    if gh auth status &> /dev/null; then
        echo -e "${GREEN}✅ GitHub CLI 已登录${NC}"
    else
        echo -e "${YELLOW}⚠️ GitHub CLI 未登录${NC}"
        echo "请运行: gh auth login"
    fi
}

# 检查仓库权限
check_repo_permissions() {
    echo -e "${BLUE}📋 检查仓库权限...${NC}"

    # 获取当前仓库信息
    REPO_OWNER=$(gh repo view --json owner --jq '.owner.login' 2>/dev/null || echo "")
    REPO_NAME=$(gh repo view --json name --jq '.name' 2>/dev/null || echo "")

    if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
        echo -e "${YELLOW}⚠️ 无法获取仓库信息，请确保在 Git 仓库目录中运行${NC}"
        return
    fi

    echo -e "${GREEN}📦 仓库: $REPO_OWNER/$REPO_NAME${NC}"

    # 检查仓库权限
    echo -e "${BLUE}🔍 检查 Actions 权限...${NC}"

    # 这里我们只能提示用户去检查，因为 gh CLI 可能没有直接获取权限设置的命令
    echo -e "${YELLOW}请手动检查以下设置:${NC}"
    echo "1. 访问: https://github.com/$REPO_OWNER/$REPO_NAME/settings/actions"
    echo "2. 确保 'Workflow permissions' 设置为 'Read and write permissions'"
    echo "3. 勾选 'Allow GitHub Actions to create and approve pull requests'"
}

# 检查 Container Registry
check_container_registry() {
    echo -e "${BLUE}📋 检查 Container Registry...${NC}"

    # 尝试列出包
    if gh api "https://api.github.com/user/packages?package_type=container&per_page=1" &>/dev/null; then
        echo -e "${GREEN}✅ Container Registry 访问正常${NC}"
    else
        echo -e "${YELLOW}⚠️ Container Registry 可能需要额外配置${NC}"
        echo "请确保: https://github.com/settings/packages"
    fi
}

# 生成权限配置报告
generate_report() {
    echo -e "\n${BLUE}📊 权限配置报告${NC}"
    echo "=================="

    echo -e "${YELLOW}需要的权限设置:${NC}"
    echo "1. 仓库级别权限 (https://github.com/OWNER/REPO/settings/actions):"
    echo "   - Workflow permissions: Read and write permissions"
    echo "   - ✅ Allow GitHub Actions to create and approve pull requests"
    echo "   - ✅ Allow GitHub Actions to run approved pull requests from forks"

    echo -e "\n2. 工作流文件权限 (.github/workflows/docker.yml):"
    echo "   - contents: read"
    echo "   - packages: write"
    echo "   - id-token: write"
    echo "   - attestations: write"

    echo -e "\n3. HuggingFace Token (如果部署到 HF):"
    echo "   - 在仓库 Settings > Secrets 中添加 HF_TOKEN"
    echo "   - Token 权限: write"
}

# 修复建议
provide_fixes() {
    echo -e "\n${BLUE}🔧 修复建议${NC}"
    echo "==============="

    echo -e "${YELLOW}如果仍然遇到权限错误，请尝试以下步骤:${NC}"

    echo -e "\n1. ${GREEN}重新生成 GitHub Token${NC}"
    echo "   - 访问: https://github.com/settings/tokens"
    echo "   - 点击 'Generate new token (classic)'"
    echo "   - 选择权限: repo, write:packages, read:packages"
    echo "   - 在仓库 Secrets 中添加为 ACTIONS_TOKEN"

    echo -e "\n2. ${GREEN}使用个人 Token 替代 GITHUB_TOKEN${NC}"
    echo "   - 修改工作流文件中的登录配置"
    echo "   - 将 secrets.GITHUB_TOKEN 改为 secrets.ACTIONS_TOKEN"

    echo -e "\n3. ${GREEN}检查组织限制${NC}"
    echo "   - 如果是组织仓库，检查组织级别的权限设置"
    echo "   - 联系组织管理员确认权限"

    echo -e "\n4. ${GREEN}重新运行工作流${NC}"
    echo "   - 修复权限后，重新触发工作流"
    echo "   - 查看详细的错误日志"
}

# 主函数
main() {
    echo -e "${GREEN}开始检查权限配置...${NC}\n"

    check_gh_cli
    check_repo_permissions
    check_container_registry
    generate_report
    provide_fixes

    echo -e "\n${GREEN}✅ 权限检查完成${NC}"
    echo -e "${YELLOW}如果问题仍然存在，请参考 TROUBLESHOOTING.md 文档${NC}"
}

# 运行主函数
main "$@"