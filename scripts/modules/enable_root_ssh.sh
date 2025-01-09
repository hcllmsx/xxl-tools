# enable_root_ssh.sh

# 二次确认函数
function confirm_enable_root_ssh_key() {
    clear
    echo "===================================="
    echo "      开启root用户使用密钥登录      "
    echo "===================================="

    # 检查是否已经存在公钥
    if [[ -f ~/.ssh/authorized_keys ]]; then
        echo ""
        echo -e "\e[32mroot用户已经存在公钥。\e[0m"
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
                echo "旧密钥将作废，且重新生成密钥。"
                echo ""
                sleep 2
                ;;
            *)
                echo "无效的选项，操作已取消。"
                key_management_menu
                ;;
        esac
    fi

    # 生成SSH密钥对
    echo "生成SSH密钥对..."
    ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N "" -q <<< y

    # 清空 authorized_keys 文件并添加新公钥
    echo "将新公钥添加到authorized_keys..."
    > ~/.ssh/authorized_keys
    cat /root/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

    # 设置正确的权限
    echo "设置正确的权限..."
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/id_rsa
    chmod 644 /root/.ssh/id_rsa.pub

    # 检查是否已经配置过 SSH
    if ! grep -q "^PermitRootLogin prohibit-password" /etc/ssh/sshd_config; then
        echo "启用root用户通过SSH密钥登录，并禁用密码登录..."
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        # 重启SSH服务
        systemctl restart ssh
    else
        echo "SSH配置已生效，无需重复设置。"
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
    cat /root/.ssh/id_rsa
    echo ""
    echo "密钥只显示一次，需要手动复制上面的密钥内容，并保存成以下文件："
    echo "$key_filename"
    echo ""
    read -p "按回车键返回上一级菜单..."
    key_management_menu
}