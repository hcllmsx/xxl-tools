#!/bin/bash

# 脚本版本号
VERSION="v0.0.2"

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

# 自安装函数
function self_install() {
    local script_name="xxlt"
    local install_path="/usr/local/bin/$script_name"

    # 检查是否已经安装
    if [[ -f "$install_path" ]]; then
        echo "脚本已安装，可以直接通过 '$script_name' 命令运行。"
        return
    fi

    # 下载脚本并保存到系统路径
    echo "正在安装脚本到系统路径..."
    curl -s -o "$install_path" "https://raw.githubusercontent.com/hcllmsx/xxl-tools/main/xxl-tools.sh"
    if [[ $? -ne 0 ]]; then
        echo "下载脚本失败，请检查网络连接。"
        exit 1
    fi

    # 赋予执行权限
    chmod +x "$install_path"
    if [[ $? -ne 0 ]]; then
        echo "赋予执行权限失败，请检查权限设置。"
        exit 1
    fi

    echo "安装成功！现在可以通过 '$script_name' 命令运行脚本。"
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

# 检查是否通过 curl 直接运行
if [[ -t 0 ]]; then
    # 如果是通过终端直接运行，则执行主菜单
    main_menu
else
    # 如果是通过 curl 直接运行，则执行自安装
    self_install
fi