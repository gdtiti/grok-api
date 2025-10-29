#!/bin/bash

# Container Registry 诊断和修复脚本
# 用于检查和修复包名称冲突问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Container Registry 诊断工具${NC}"
echo "=================================="

# 获取仓库信息
get_repo_info() {
    echo -e "${BLUE}📋 获取仓库信息...${NC}"

    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        REPO_OWNER=$(gh repo view --json owner --jq '.owner.login' 2>/dev/null || echo "")
        REPO_NAME=$(gh repo view --json name --jq '.name' 2>/dev/null || echo "")

        if [[ -n "$REPO_OWNER" && -n "$REPO_NAME" ]]; then
            echo -e "${GREEN}✅ 当前仓库: $REPO_OWNER/$REPO_NAME${NC}"
            FULL_REPO_NAME="$REPO_OWNER/$REPO_NAME"
        else
            echo -e "${YELLOW}⚠️ 无法自动获取仓库信息${NC}"
            read -p "请输入仓库全名 (如: username/reponame): " FULL_REPO_NAME
        fi
    else
        echo -e "${YELLOW}⚠️ GitHub CLI 未安装或未登录${NC}"
        read -p "请输入仓库全名 (如: username/reponame): " FULL_REPO_NAME
    fi
}

# 检查包状态
check_package_status() {
    echo -e "\n${BLUE}📦 检查包状态...${NC}"

    if [[ -z "$FULL_REPO_NAME" ]]; then
        echo -e "${RED}❌ 仓库名称未设置${NC}"
        return 1
    fi

    # 提取所有者名称
    OWNER=$(echo "$FULL_REPO_NAME" | cut -d'/' -f1)

    echo -e "${BLUE}🔍 检查包: $FULL_REPO_NAME${NC}"

    # 使用 GitHub API 检查包是否存在
    if command -v gh &> /dev/null; then
        echo -e "${BLUE}🔍 使用 GitHub API 检查包状态...${NC}"

        # 检查包是否存在
        PACKAGE_STATUS=$(gh api "https://api.github.com/users/$OWNER/packages?package_type=container" 2>/dev/null || echo "")

        if echo "$PACKAGE_STATUS" | grep -q "\"name\":\"$REPO_NAME\""; then
            echo -e "${RED}❌ 包 '$REPO_NAME' 已存在但可能处于删除状态或权限不足${NC}"

            # 获取包的详细信息
            PACKAGE_INFO=$(gh api "https://api.github.com/users/$OWNER/packages/container/$REPO_NAME" 2>/dev/null || echo "")
            if [[ -n "$PACKAGE_INFO" ]]; then
                echo -e "${YELLOW}📋 包详细信息:${NC}"
                echo "$PACKAGE_INFO" | jq '.' 2>/dev/null || echo "$PACKAGE_INFO"
            fi

            return 1
        else
            echo -e "${GREEN}✅ 包 '$REPO_NAME' 不存在，可以创建${NC}"
            return 0
        fi
    else
        echo -e "${YELLOW}⚠️ GitHub CLI 不可用，无法检查包状态${NC}"
        return 2
    fi
}

# 提供解决方案
provide_solutions() {
    echo -e "\n${BLUE}🔧 解决方案${NC}"
    echo "============="

    echo -e "${YELLOW}方案 1: 使用不同的包名称${NC}"
    echo "修改工作流中的 IMAGE_NAME 环境变量，添加后缀："
    echo "  IMAGE_NAME: \${{ github.repository }}-v2"
    echo "  或者: \${{ github.repository }}-api"

    echo -e "\n${YELLOW}方案 2: 手动清理包（如果可能）${NC}"
    echo "1. 访问: https://github.com/$OWNER/packages/container/$REPO_NAME"
    echo "2. 如果包存在，尝试完全删除"
    echo "3. 删除后等待几分钟让系统同步"

    echo -e "\n${YELLOW}方案 3: 联系 GitHub 支持${NC}"
    echo "如果包无法删除，可以联系 GitHub 支持团队："
    echo "https://support.github.com/"

    echo -e "\n${YELLOW}方案 4: 使用不同的 Container Registry${NC}"
    echo "可以考虑使用："
    echo "  - Docker Hub"
    echo "  - Azure Container Registry"
    echo "  - AWS ECR"
    echo "  - 其他私有 registry"
}

# 自动修复工作流
fix_workflow() {
    echo -e "\n${BLUE}🔧 自动修复工作流${NC}"
    echo "=================="

    echo -e "${YELLOW}选择修复方式:${NC}"
    echo "1) 添加后缀 '-v2' 到包名"
    echo "2) 添加后缀 '-api' 到包名"
    echo "3) 自定义后缀"
    echo "4) 跳过修复"

    read -p "请选择 (1-4): " choice

    WORKFLOW_FILE=".github/workflows/docker.yml"

    case $choice in
        1)
            SUFFIX="-v2"
            echo -e "${GREEN}✅ 选择后缀: $SUFFIX${NC}"
            ;;
        2)
            SUFFIX="-api"
            echo -e "${GREEN}✅ 选择后缀: $SUFFIX${NC}"
            ;;
        3)
            read -p "请输入自定义后缀 (如: -new): " SUFFIX
            if [[ -z "$SUFFIX" ]]; then
                echo -e "${RED}❌ 后缀不能为空${NC}"
                return 1
            fi
            echo -e "${GREEN}✅ 自定义后缀: $SUFFIX${NC}"
            ;;
        4)
            echo -e "${YELLOW}⚠️ 跳过自动修复${NC}"
            return 0
            ;;
        *)
            echo -e "${RED}❌ 无效选择${NC}"
            return 1
            ;;
    esac

    # 备份原文件
    if [[ -f "$WORKFLOW_FILE" ]]; then
        cp "$WORKFLOW_FILE" "$WORKFLOW_FILE.backup"
        echo -e "${GREEN}✅ 已备份原文件到 $WORKFLOW_FILE.backup${NC}"

        # 修改 IMAGE_NAME
        sed -i.bak "s|IMAGE_NAME: \${{ github.repository }}|IMAGE_NAME: \${{ github.repository }}$SUFFIX|g" "$WORKFLOW_FILE"

        echo -e "${GREEN}✅ 已修改工作流文件${NC}"
        echo -e "${BLUE}📋 新的包名将是: \${{ github.repository }}$SUFFIX${NC}"

        # 清理临时文件
        rm -f "$WORKFLOW_FILE.bak"

    else
        echo -e "${RED}❌ 工作流文件不存在: $WORKFLOW_FILE${NC}"
        return 1
    fi
}

# 生成报告
generate_report() {
    echo -e "\n${BLUE}📊 诊断报告${NC}"
    echo "============="

    echo -e "${YELLOW}问题分析:${NC}"
    echo "- 你之前删除了同名的 Container Registry 包"
    echo "- GitHub 仍然保留包名称的记录"
    echo "- 现在无法重新创建同名包"

    echo -e "\n${YELLOW}推荐操作:${NC}"
    echo "1. 使用方案 1 (修改包名) - 最快解决"
    echo "2. 等待 24-48 小时后重试 - 有时系统会自动清理"
    echo "3. 联系 GitHub 支持彻底清理包记录"

    echo -e "\n${YELLOW}预防措施:${NC}"
    echo "- 删除包前确认不再需要"
    echo "- 使用版本化包名 (如 myapp-v1, myapp-v2)"
    echo "- 保留包的版本历史"
}

# 主函数
main() {
    get_repo_info
    check_package_status
    provide_solutions

    echo -e "\n${YELLOW}是否要自动修复工作流文件? (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        fix_workflow
    fi

    generate_report

    echo -e "\n${GREEN}✅ 诊断完成${NC}"
    echo -e "${BLUE}如果问题仍然存在，请参考上述解决方案${NC}"
}

# 运行主函数
main "$@"