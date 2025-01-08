# enable_root_ssh.sh

# 二次确认函数
function confirm_enable_root_ssh_key() {
    clear
    echo "===================================="
    echo "      开启root用户使用密钥登录      "
    echo "===================================="
    echo "此操作将执行以下步骤："
    echo "1. 生成SSH密钥对。"
    echo "2. 配置SSH以禁用密码登录，仅允许密钥登录。"
    echo "3. 重启SSH服务。"
    echo "===================================="
    read -p "你确定要继续吗？(y/n): " confirm

    case $confirm in
        y|Y)
            enable_root_ssh_key
            ;;
        n|N)
            echo "操作已取消。"
            sleep 1
            main_menu
            ;;
        *)
            echo "无效的输入，请重新选择！"
            sleep 1
            confirm_enable_root_ssh_key
            ;;
    esac
}

# 开启root用户使用密钥登录的功能
function enable_root_ssh_key() {
    echo "正在开启root用户使用密钥登录..."
    # 切换到root用户
    if [ "$EUID" -ne 0 ]; then
        echo "请以root用户运行此功能"
        return
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

    echo "操作已完成。"
    read -p "按回车键返回主菜单..."
    main_menu
}