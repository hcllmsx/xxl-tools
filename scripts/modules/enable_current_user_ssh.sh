function manage_current_user_ssh_key() {
    clear
    echo "===================================="
    echo "    当前用户开启密钥登录或更新密钥    "
    echo "===================================="

    # 检查是否已经存在公钥
    if [[ -f ~/.ssh/authorized_keys ]]; then
        echo ""
        echo -e "\e[32m当前用户已经存在公钥。\e[0m"
        echo ""
        echo "1. 取消操作"
        echo "2. 重新生成密钥"
        echo "===================================="
        read -p "请输入选项编号: " choice

        case $choice in
            1)
                echo "操作已取消。"
                key_management_menu
                ;;
            2)
                echo ""
                echo -e "\e[33m旧密钥将作废，且重新生成密钥。\e[0m"
                echo ""
                sleep 2
                ;;
            *)
                echo "无效的选项，操作已取消。"
                key_management_menu
                ;;
        esac
    fi

    # 生成SSH密钥对并强制覆盖现有文件
    echo "生成SSH密钥对..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q <<< y

    # 清空 authorized_keys 文件并添加新公钥
    echo "将新公钥添加到authorized_keys..."
    > ~/.ssh/authorized_keys
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

    # 设置正确的权限
    echo "设置正确的权限..."
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/id_rsa
    chmod 644 ~/.ssh/id_rsa.pub

    # 检查是否已经配置过 SSH
    if ! grep -q "^PermitRootLogin prohibit-password" /etc/ssh/sshd_config; then
        echo "启用root用户通过SSH密钥登录，并禁用密码登录..."
        sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
        sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    else
        echo "SSH配置已生效，无需重复设置。"
    fi
    
    # 重启SSH服务
    echo "重启SSH服务..."
    if sudo systemctl restart ssh; then
        echo "SSH服务重启成功。"
    else
        echo "SSH服务重启失败，请检查系统日志或手动重启。"
    fi

    # 获取当前用户名
    username=$(whoami)

    # 获取服务器IP地址（优先使用IPv4，如果不可用则使用IPv6）
    ip_address=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d'/' -f1)
    if [[ -z "$ip_address" ]]; then
        ip_address=$(ip -6 addr show scope global | grep inet6 | awk '{print $2}' | cut -d'/' -f1)
    fi

    # 获取当前时间（时分秒）
    current_time=$(date +"%H%M%S")

    # 生成文件名
    key_filename="${username}-${ip_address}-${current_time}.pem"

    # 输出私钥内容
    echo ""
    echo "以下是你的私钥内容，请妥善保存："
    echo ""
    echo -e "\e[32m$(cat ~/.ssh/id_rsa)\e[0m"
    echo ""
    echo "密钥只显示一次，需要手动复制上面的密钥内容，并保存成以下文件："
    echo ""
    echo "$key_filename"
    echo ""
    echo "请将密钥保存到安全的地方，不要上传到互联网。"
    echo ""
    read -p "按回车键返回上一级菜单..."
    key_management_menu
}