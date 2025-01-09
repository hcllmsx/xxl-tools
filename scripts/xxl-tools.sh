#!/bin/bash

# 脚本版本号
VERSION="v0.0.7"

# 加载模块函数
function load_module() {
    local module_name=$1
    local module_path="$(dirname "$0")/modules/$module_name.sh"

    if [[ -f "$module_path" ]]; then
        source "$module_path"
    else
        echo "模块 '$module_name' 未找到！"
        exit 1
    fi
}

# 更新脚本函数
function update_script() {
    echo "正在更新脚本..."
    curl -sL -o /tmp/xxl-tools.sh https://raw.githubusercontent.com/hcllmsx/xxl-tools/main/scripts/xxl-tools.sh
    if [[ $? -ne 0 ]]; then
        echo "下载脚本失败，请检查网络连接。"
        return
    fi

    mv /tmp/xxl-tools.sh "$(dirname "$0")/xxl-tools.sh"
    chmod +x "$(dirname "$0")/xxl-tools.sh"
    echo "脚本更新成功！"
    main_menu
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
    echo "2. 开启root用户使用密钥登录"
    echo ""
    echo "===================================="
    read -p "请输入选项编号: " choice

    case $choice in
        0)
            echo "退出脚本。"
            exit 0
            ;;
        1)
            update_script
            read -p "按回车键返回主菜单..."
            main_menu
            ;;
        2)
            load_module "enable_root_ssh"
            confirm_enable_root_ssh_key
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