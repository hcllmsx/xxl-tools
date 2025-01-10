# key_management.sh

# 密钥登录管理菜单
function key_management_menu() {
    clear
    echo "===================================="
    echo "         密钥登录管理菜单           "
    echo "===================================="
    echo "1. 开启root用户密钥登录"
    echo "2. 查看现有公钥"
    echo "3. 删除公钥"
    echo "0. 返回主菜单"
    echo "===================================="
    read -p "请输入选项编号: " choice

    case $choice in
        1)
            load_module "enable_root_ssh"
            confirm_enable_root_ssh_key
            ;;
        2)
            view_authorized_keys
            read -p "按回车键返回上一级菜单..."
            key_management_menu
            ;;
        3)
            delete_authorized_key
            read -p "按回车键返回上一级菜单..."
            key_management_menu
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

# 查看现有公钥
function view_authorized_keys() {
    # 遍历 /home 目录下的所有用户
    for user in /home/*; do
        user=$(basename "$user")
        authorized_keys_file="/home/$user/.ssh/authorized_keys"

        if [[ -f "$authorized_keys_file" ]]; then
            echo "用户: $user"
            echo "当前 ~/.ssh/authorized_keys 文件中的公钥："
            echo "----------------------------------------"
            while IFS= read -r line; do
                if [[ "$line" =~ ^ssh- ]]; then
                    echo "公钥: $line"
                    echo "指纹: $(ssh-keygen -lf <(echo "$line"))"
                    echo "----------------------------------------"
                fi
            done < "$authorized_keys_file"
        fi
    done

    # 检查 root 用户的公钥
    if [[ -f /root/.ssh/authorized_keys ]]; then
        echo "用户: root"
        echo "当前 ~/.ssh/authorized_keys 文件中的公钥："
        echo "----------------------------------------"
        while IFS= read -r line; do
            if [[ "$line" =~ ^ssh- ]]; then
                echo "公钥: $line"
                echo "指纹: $(ssh-keygen -lf <(echo "$line"))"
                echo "----------------------------------------"
            fi
        done < /root/.ssh/authorized_keys
    fi
}

# 删除公钥
function delete_authorized_key() {
    if [[ ! -f ~/.ssh/authorized_keys ]]; then
        echo "未找到 ~/.ssh/authorized_keys 文件。"
        return
    fi

    echo "当前 ~/.ssh/authorized_keys 文件中的公钥注释："
    echo "----------------------------------------"
    while IFS= read -r line; do
        if [[ "$line" =~ ^ssh- ]]; then
            comment=$(echo "$line" | awk '{print $3}')
            echo "注释: $comment"
            echo "----------------------------------------"
        fi
    done < ~/.ssh/authorized_keys

    read -p "请输入要删除的公钥注释（用户名）: " comment
    if [[ -z "$comment" ]]; then
        echo "未输入注释，操作取消。"
        return
    fi

    # 删除指定注释的公钥
    sed -i "/$comment$/d" ~/.ssh/authorized_keys
    if [[ $? -eq 0 ]]; then
        echo "公钥删除成功！"
    else
        echo "公钥删除失败，请检查输入。"
    fi
}