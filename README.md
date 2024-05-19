### 一键脚本：自动安装、配置和管理服务

这是一个一键脚本，用于自动安装容器、配置反向代理、修改前端页面，并集成了服务的重启、停止、启动、升级和查看日志等功能。

**注意：** 本脚本的代码来源于 [xyhelper](https://github.com/xyhelper) 和 [frontend-winter](https://github.com/frontend-winter)，我只是将这些代码整合在一起。感谢他们的贡献！

#### 一键脚本链接

[一键脚本](https://raw.githubusercontent.com/qza666/share/main/share.sh)

#### 使用方法

1. **下载脚本**

   在服务器上下载并设置脚本的可执行权限：

   ```bash
   wget https://raw.githubusercontent.com/qza666/share/main/share.sh -O /root/share.sh
   chmod +x /root/share.sh
   ```

2. **运行脚本**

   直接执行脚本：

   ```bash
   /root/share.sh
   ```

#### 功能说明

执行脚本后，将显示一个菜单，用户可以根据需要选择不同的功能：

```
请选择要执行的功能:
1) 重启
2) 停止
3) 启动
4) 升级
5) 查看日志
6) 安装
7) 退出
请输入数字选择功能:
```

**功能详情：**

1. **重启**：重启服务容器。
2. **停止**：停止服务容器。
3. **启动**：启动服务容器。
4. **升级**：升级服务容器。
5. **查看日志**：查看服务容器的日志。
6. **安装**：安装并配置服务，包括设置反向代理和修改前端页面。
7. **退出**：退出脚本。

#### 脚本内容

```bash
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

