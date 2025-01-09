# update_script.sh

# 更新脚本函数
function update_script() {
    echo "正在更新脚本..."
    
    # 进入安装目录
    cd "$INSTALL_DIR" || { echo "无法进入安装目录。"; return; }
    
    # 如果当前目录不是git仓库，则克隆整个仓库
    if [ ! -d ".git" ]; then
        git clone https://github.com/hcllmsx/xxl-tools.git .
        if [[ $? -ne 0 ]]; then
            echo "更新失败，请检查网络连接，或者使用root用户执行。"
            return
        fi
    else
        # 如果已经是git仓库，则拉取最新更改
        git fetch --all
        git reset --hard origin/main
        if [[ $? -ne 0 ]]; then
            echo "拉取最新更改失败，请检查网络连接。"
            return
        fi
    fi
    
    echo "脚本更新成功！"
    echo "脚本将在 3 秒后重启..."
    sleep 3
    
    # 重启脚本
    exec "$INSTALL_DIR/scripts/xxl-tools.sh"
}