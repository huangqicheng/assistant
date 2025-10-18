#!/bin/bash

# 配置MySQL允许远程连接的脚本
# 此脚本将指导您完成允许远程访问MySQL数据库的步骤

# 步骤1: 备份MySQL配置文件
echo "【步骤1/5】备份MySQL配置文件..."
sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.bak
if [ $? -eq 0 ]; then
    echo "  ✅ 配置文件备份成功"
else
    echo "  ❌ 配置文件备份失败，请检查权限"
    exit 1
fi
read -p "  按Enter键继续..."

# 步骤2: 修改MySQL配置文件
echo "
【步骤2/5】修改MySQL配置文件..."
echo "  将bind-address从127.0.0.1改为0.0.0.0，允许所有IP连接"
sudo sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
if [ $? -eq 0 ]; then
    echo "  ✅ 配置文件修改成功"
    cat /etc/mysql/mysql.conf.d/mysqld.cnf | grep 'bind-address'
else
    echo "  ❌ 配置文件修改失败"
    exit 1
fi
read -p "  按Enter键继续..."

# 步骤3: 重启MySQL服务
echo "
【步骤3/5】重启MySQL服务..."
sudo systemctl restart mysql
if [ $? -eq 0 ]; then
    echo "  ✅ MySQL服务重启成功"
    sudo systemctl status mysql --no-pager | head -5
else
    echo "  ❌ MySQL服务重启失败"
    exit 1
fi
read -p "  按Enter键继续..."

# 步骤4: 授权root用户远程访问
echo "
【步骤4/5】授权root用户远程访问..."
read -p "  请输入MySQL root用户密码: " mysql_password

echo "  创建远程访问授权..."
sudo mysql -u root -p$mysql_password -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$mysql_password' WITH GRANT OPTION;"
if [ $? -eq 0 ]; then
    echo "  ✅ 授权成功"
else
    echo "  ❌ 授权失败，请检查密码是否正确"
    exit 1
fi

 echo "  刷新权限..."
sudo mysql -u root -p$mysql_password -e "FLUSH PRIVILEGES;"
if [ $? -eq 0 ]; then
    echo "  ✅ 权限刷新成功"
else
    echo "  ❌ 权限刷新失败"
    exit 1
fi
read -p "  按Enter键继续..."

# 步骤5: 配置防火墙开放3306端口
echo "
【步骤5/5】配置防火墙开放3306端口..."
sudo ufw allow 3306
sudo ufw reload
if [ $? -eq 0 ]; then
    echo "  ✅ 防火墙配置成功"
    sudo ufw status | grep 3306
else
    echo "  ❌ 防火墙配置失败"
    exit 1
fi

# 完成配置
echo "
🎉 MySQL远程连接配置完成！
"
echo "重要提示:
1. 请确保您的MySQL服务器已设置强密码
2. 对于生产环境，建议限制允许访问的IP地址范围
3. 您现在可以使用服务器IP地址从远程连接MySQL数据库"