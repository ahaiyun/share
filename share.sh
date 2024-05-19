#!/bin/bash

# Function to display menu
show_menu() {
    echo "请选择要执行的功能:"
    echo "1) 重启"
    echo "2) 停止"
    echo "3) 启动"
    echo "4) 升级"
    echo "5) 查看日志"
    echo "6) 安装"
    echo "7) 退出"
}

# Function to perform restart
restart() {
    cd ~/chatgpt-share
    docker compose restart
}

# Function to stop the service
stop() {
    cd ~/chatgpt-share
    docker compose stop
}

# Function to start the service
start() {
    cd ~/chatgpt-share
    ./deploy.sh
}

# Function to upgrade the service
upgrade() {
    cd ~/chatgpt-share
    ./deploy.sh
}

# Function to view logs
view_logs() {
    cd ~/chatgpt-share
    docker compose logs -f
}

# Function to install the service
install() {
    echo "请输入域名:"
    read domain_name

    cd ~
    wget -qO- get.docker.com | bash && systemctl enable docker

    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

    apt install git

    apt install ntpdate -y
    ntpdate time.windows.com

    timedatectl set-timezone Asia/Shanghai

    echo "fs.inotify.max_user_instances=5120" >> /etc/sysctl.conf
    echo "fs.inotify.max_user_watches=2621440" >> /etc/sysctl.conf
    echo "fs.file-max=65535" >> /etc/sysctl.conf

    sysctl -p

    mkdir -p /etc/docker

    cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

    systemctl restart docker

    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 22/tcp

    ufw enable

    set -e
    cd ~
    git clone -b deploy  --depth=1 https://github.com/xyhelper/chatgpt-share-server.git chatgpt-share

    cd chatgpt-share

    docker compose pull
    docker compose up -d --remove-orphans

    cd /
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install caddy

    cat > /etc/caddy/Caddyfile <<EOF
$domain_name {
    reverse_proxy 127.0.0.1:8300
}
EOF

    systemctl reload caddy

    cd ~
    cd /root/chatgpt-share
    set -e

    echo "clone repository..."
    git clone https://github.com/frontend-winter/sharelist.git sharelist

    dir_name="list"
    if [ -d "$dir_name" ]; then
        rm -rf "${dir_name:?}"/*
        echo "已删除 '$dir_name' 下的所有文件。"
    else
        mkdir "$dir_name"
        chmod -R 755 "$dir_name"
        echo "已创建目录 '$dir_name' 并设置权限为 755。"
    fi
    cd sharelist
    mv dist/* ../list
    cd ..
    chmod -R 755 list

    yaml_file="./docker-compose.yml"

    check_volume="./list:/app/resource/public/list"

    if [ ! -f "$yaml_file" ]; then
        echo "文件不存在: $yaml_file"
        exit 1
    fi

    if grep -q "$check_volume" "$yaml_file"; then
        echo "映射 '$check_volume' 已存在，无需添加。"
        rm -rf sharelist
        rm -rf quick-list.sh
        echo "已完成前端页面的更换"
        exit 0
    fi

    new_volume="      - ./list:/app/resource/public/list"

    awk -v new_volume="$new_volume" '
    BEGIN {
        in_chatgpt_share_server = 0;
        in_volumes = 0;
    }
    /chatgpt-share-server:/ {
        in_chatgpt_share_server = 1;
    }
    in_chatgpt_share_server && /volumes:/ {
        in_volumes = 1;
        print;
        next;
    }
    in_volumes && /^[ ]+- / {
        print new_volume;
        in_volumes = 0;
        in_chatgpt_share_server = 0;
    }
    { print }
    ' docker-compose.yml > tmp_file && mv tmp_file docker-compose.yml

    # 添加成功后运行 Docker 命令
    if [ $? -eq 0 ]; then
        echo "映射 '$new_volume' 添加成功"
    else
        echo "映射存在"
    fi

    rm -rf sharelist
    rm -rf quick-list.sh
    docker compose pull
    docker compose up -d --remove-orphans
    cd ~
    cd chatgpt-share
    ./deploy.sh
    echo "已完成前端页面的更换"
    echo "服务启动成功，请访问 http://localhost:8300"
    echo "管理员后台地址 http://localhost:8300/xyhelper"
    echo "管理员账号: admin"
    echo "管理员密码: 123456"
    echo "请及时修改管理员密码"
}

while true; do
    show_menu
    read -p "请输入数字选择功能: " choice
    case $choice in
        1)
            restart
            ;;
        2)
            stop
            ;;
        3)
            start
            ;;
        4)
            upgrade
            ;;
        5)
            view_logs
            ;;
        6)
            install
            ;;
        7)
            echo "退出"
            exit 0
            ;;
        *)
            echo "无效的选项，请重新输入"
            ;;
    esac
done
