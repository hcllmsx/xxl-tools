# enable_root_ssh.sh

# 二次确认函数
function confirm_enable_root_ssh_key() {
    clear
    echo "===================================="
    echo "      开启root用户使用密钥登录      "
    echo "===================================="

    # 检查是否已经存在公钥
    if [[ -f ~/.ssh/authorized_keys ]]; then
        echo "root用户已经存在公钥。"
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
                echo "旧密钥将作废，且重新生成密钥。"
                read -p "你确定要继续吗？(y/n): " confirm
                if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
                    echo "操作已取消。"
                    key_management_menu
                fi
                ;;
            *)
                echo "无效的选项，操作已取消。"
                key_management_menu
                ;;
        esac
    fi

    # 生成SSH密钥对
    echo "生成SSH密钥对..."
    ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""

    # 将公钥添加到authorized_keys
    echo "将公钥添加到authorized_keys..."
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

    # 设置正确的权限
    echo "设置正确的权限..."
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/id_rsa
    chmod 644 /root/.ssh/id_rsa.pub

    # 启用root用户通过SSH密钥登录，并禁用密码登录
    echo "启用root用户通过SSH密钥登录，并禁用密码登录..."
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

    # 重启SSH服务
    echo "重启SSH服务..."
    systemctl restart sshd

    # 输出私钥内容
    echo "以下是你的私钥内容，请妥善保存："
    cat /root/.ssh/id_rsa

    echo "密钥只显示一次，需要手动复制上面的密钥内容，并保存成 id_rsa 文件。"
    read -p "按回车键返回上一级菜单..."
    key_management_menu
}