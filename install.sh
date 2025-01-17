#!/bin/bash

# 安装路径
INSTALL_DIR="/usr/local/bin/xxl-tools"

# 创建安装目录
echo "正在创建安装目录..."
mkdir -p "$INSTALL_DIR"
if [[ $? -ne 0 ]]; then
    echo "创建目录失败，请切换至root用户下操作。"
    exit 1
fi

# 下载脚本文件夹
echo "正在下载脚本文件..."
curl -sL https://github.com/hcllmsx/xxl-tools/archive/main.tar.gz | tar -xz -C "$INSTALL_DIR" --strip-components=1
if [[ $? -ne 0 ]]; then
    echo "下载脚本失败，请检查网络连接。"
    exit 1
fi

# 赋予脚本执行权限
chmod +x "$INSTALL_DIR/scripts/xxl-tools.sh"
if [[ $? -ne 0 ]]; then
    echo "赋予执行权限失败，请切换至root用户下操作。"
    exit 1
fi

# 创建软链接
echo "正在创建软链接..."
ln -sf "$INSTALL_DIR/scripts/xxl-tools.sh" /usr/local/bin/xxlt
if [[ $? -ne 0 ]]; then
    echo "创建软链接失败，请切换至root用户下操作。"
    exit 1
fi

echo "安装成功！"
echo -e "你以后可以通过 \e[32mxxlt\e[0m 命令运行脚本。"

# 直接运行脚本
"$INSTALL_DIR/scripts/xxl-tools.sh"