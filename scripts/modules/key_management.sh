# key_management.sh

# 密钥登录管理菜单
function key_management_menu() {
    clear
    echo "===================================="
    echo "         密钥登录管理菜单           "
    echo "===================================="
    echo "1. 开启root用户密钥登录"
    echo "2. 查看并管理公钥"
    echo "0. 返回主菜单"
    echo "===================================="
    read -p "请输入选项编号: " choice

    case $choice in
        1)
            load_module "enable_root_ssh"
            confirm_enable_root_ssh_key
            ;;
        2)
            manage_authorized_keys
            ;;
        0)
            main_menu
            ;;
        *)
            echo "无效的选项，请重新输入！"
            sleep 1
            key_management_menu
            ;;
    esac
}

# 查看并管理公钥
function manage_authorized_keys() {
    # 遍历 /home 目录下的所有用户
    for user in /home/*; do
        user=$(basename "$user")
        authorized_keys_file="/home/$user/.ssh/authorized_keys"

        if [[ -f "$authorized_keys_file" ]]; then
            echo -e "用户: \e[33m$user\e[0m"
        else
            echo "用户: $user"
        fi
    done

    # 检查 root 用户的公钥
    if [[ -f /root/.ssh/authorized_keys ]]; then
        echo -e "用户: \e[33mroot\e[0m"
    else
        echo "用户: root"
    fi

    echo "以下是系统中所有用户的用户名"
    echo "其中已经开启了密钥登录的用户的用户名显示为黄色"
    read -p "按回车键返回上一级菜单或输入 'del' 进入删除模式: " action

    if [[ "$action" == "del" ]]; then
        read -p "请输入要删除公钥的用户名: " del_user
        if [[ -f "/home/$del_user/.ssh/authorized_keys" ]]; then
            rm -f "/home/$del_user/.ssh/authorized_keys"
            echo "用户 $del_user 的公钥已删除"
        elif [[ "$del_user" == "root" && -f "/root/.ssh/authorized_keys" ]]; then
            rm -f "/root/.ssh/authorized_keys"
            echo "用户 root 的公钥已删除"
        else
            echo "用户 $del_user 不存在或未开启密钥登录"
        fi
    fi
}
