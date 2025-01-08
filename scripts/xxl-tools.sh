#!/bin/bash

# 脚本版本号
VERSION="v0.0.4"

# 加载模块函数
function load_module() {
    local module_name=$1
    local module_path="./modules/$module_name.sh"

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
    echo "               $VERSION              "
    echo "===================================="
    echo "1. 开启root用户使用密钥登录"
    echo "2. 退出"
    echo "===================================="
    read -p "请输入选项编号: " choice

    case $choice in
        1)
            load_module "enable_root_ssh"
            confirm_enable_root_ssh_key
            ;;
        2)
            echo "退出脚本。"
            exit 0
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