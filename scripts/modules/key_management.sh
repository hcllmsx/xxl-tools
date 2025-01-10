# key_management.sh

# 密钥登录管理菜单
function key_management_menu() {
    clear
    echo "===================================="
    echo "         密钥登录管理菜单           "
    echo "===================================="
    echo "1. 开启密钥登录或更新密钥"
    echo "2. 查看并管理公钥"
    echo "0. 返回主菜单"
    echo "===================================="
    read -p "请输入选项编号: " choice

    case $choice in
        1)
            load_module "enable_current_user_ssh"
            manage_current_user_ssh_key
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
    # 检查是否有 root 权限
    if [ "$(id -u)" -ne 0 ]; then
        echo "此功能需要 root 权限！"
        read -n 1 -s -r -p "按任意键返回上级菜单..."
        echo
        key_management_menu
        return
    fi

    # 遍历 /home 目录下的所有用户
    for user in /home/*; do
        user=$(basename "$user")
        authorized_keys_file="/home/$user/.ssh/authorized_keys"

        if [[ -f "$authorized_keys_file" ]]; then
            echo -e "用户: \e[33m$user\e[0m"
            # 显示公钥指纹
            ssh-keygen -lf "$authorized_keys_file" | awk '{print "公钥指纹: " $2}'
            echo "------------------------------------"
        else
            echo "用户: $user"
            echo "------------------------------------"
        fi
    done

    # 检查 root 用户的公钥
    if [[ -f /root/.ssh/authorized_keys ]]; then
        echo -e "用户: \e[33mroot\e[0m"
        # 显示公钥指纹
        ssh-keygen -lf "/root/.ssh/authorized_keys" | awk '{print "公钥指纹: " $2}'
    else
        echo "用户: root"
    fi

    echo "===================================="  # 添加分隔线
    echo "以上是系统中所有用户的用户名"
    echo -e "其中已经开启了密钥登录的用户的用户名显示为\e[33m黄色\e[0m"
    read -p "按回车键返回上一级菜单或输入 'del' 进入删除模式: " action

    if [[ "$action" == "del" ]]; then
        read -p "请输入要删除公钥的用户名: " del_user
        if [[ -f "/home/$del_user/.ssh/authorized_keys" ]]; then
            rm -f "/home/$del_user/.ssh/authorized_keys"
            echo ""
            read -n 1 -s -r -p "用户 $del_user 的公钥已删除..."
            echo
            key_management_menu
        elif [[ "$del_user" == "root" && -f "/root/.ssh/authorized_keys" ]]; then
            rm -f "/root/.ssh/authorized_keys"
            echo ""
            read -n 1 -s -r -p "用户 root 的公钥已删除..."
            echo
            key_management_menu
        else
            echo ""
            read -n 1 -s -r -p "用户 $del_user 不存在或未开启密钥登录，或你的输入有误..."
            echo
            key_management_menu
        fi
    elif [[ -z "$action" ]]; then
        key_management_menu
    else
        key_management_menu
    fi
}
