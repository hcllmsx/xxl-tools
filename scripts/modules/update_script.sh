# update_script.sh

# 更新脚本函数
function update_script() {
    echo "正在更新脚本..."
    curl -sL -o /tmp/xxl-tools.sh https://raw.githubusercontent.com/hcllmsx/xxl-tools/main/scripts/xxl-tools.sh
    if [[ $? -ne 0 ]]; then
        echo "下载脚本失败，请检查网络连接。"
        return
    fi

    # 使用 sudo 移动文件并修改权限
    if sudo mv /tmp/xxl-tools.sh "$INSTALL_DIR/scripts/xxl-tools.sh" && sudo chmod +x "$INSTALL_DIR/scripts/xxl-tools.sh"; then
        echo "脚本更新成功！"
    else
        echo "脚本更新失败，请检查权限设置。"
    fi
}