#!/bin/bash

# 脚本版本号
VERSION="v0.1.0"

# 安装路径
INSTALL_DIR="/usr/local/bin/xxl-tools"

# 加载模块函数
function load_module() {
    local module_name=$1
    local module_path="$INSTALL_DIR/scripts/modules/$module_name.sh"

    if [[ -f "$module_path" ]]; then
        source "$module_path"
    else
        echo "模块 '$module_name' 未找到！"
        exit 1
    fi
}

# 主菜单函数
function main_menu() {
    clear
    echo "===================================="
    echo "          XXL Tools 菜单            "
    echo "                  -$VERSION         "
    echo "===================================="
    echo "0. 退出脚本"
    echo "1. 更新脚本"
    echo "------------------------------------"
    echo ""
    echo "2. 密钥登录管理"
    echo ""
    echo "===================================="
    read -p "请输入选项编号: " choice

    case $choice in
        0)
            echo "退出脚本。"
            exit 0
            ;;
        1)
            load_module "update_xxlt"
            update_script
            read -p "按回车键返回主菜单..."
            main_menu
            ;;
        2)
            load_module "key_management"
            key_management_menu
            ;;
        *)
            echo "无效的选项，请重新输入！"
            sleep 1
            main_menu
            ;;
    esac
}

# 启动主菜单
main_menu