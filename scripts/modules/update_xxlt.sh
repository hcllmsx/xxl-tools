# update_script.sh

# 更新路径
INSTALL_DIR="/usr/local/bin/xxl-tools"

# 更新脚本函数
function update_script() {
    read -n 1 -s -r -p "提示：更新脚本需root权限！...按任意键继续..."
    echo ""
    echo "正在更新脚本..."
    
    # 进入安装目录
    cd "$INSTALL_DIR" || { echo "无法进入安装目录。"; return; }
    
    # 下载最新脚本文件夹
    curl -sL https://github.com/hcllmsx/xxl-tools/archive/main.tar.gz | tar -xz -C "$INSTALL_DIR" --strip-components=1
    if [[ $? -ne 0 ]]; then
        echo "下载脚本失败，请检查网络连接。"
        exit 1
    fi

    # 赋予脚本执行权限
    chmod +x "$INSTALL_DIR/scripts/xxl-tools.sh"
    if [[ $? -ne 0 ]]; then
        echo "赋予执行权限失败！"
        exit 1
    fi
    
    echo "脚本更新成功！"
    echo "脚本将在 3 秒后重启..."
    sleep 3
    
    # 重启脚本
    exec "$INSTALL_DIR/scripts/xxl-tools.sh"
}