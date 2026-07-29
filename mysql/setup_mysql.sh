#!/bin/bash
# ============================================================
# FastAPI-LLM MySQL 一键部署脚本 (Linux)
# 用法: chmod +x setup_mysql.sh && sudo bash setup_mysql.sh
# ============================================================
set -e

MYSQL_ROOT_PASSWORD=""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SQL_FILE="$SCRIPT_DIR/news_db.sql"

echo "============================================"
echo " FastAPI-LLM MySQL 数据库部署脚本"
echo "============================================"
echo ""

# ---- 1. 安装 MySQL ----
if ! command -v mysql &>/dev/null; then
    echo "[1/5] 正在安装 MySQL Server..."
    sudo apt update
    sudo apt install -y mysql-server
    echo "[OK] MySQL Server 安装完成"
else
    echo "[1/5] MySQL 已安装，跳过"
fi

# ---- 2. 启动 MySQL ----
echo "[2/5] 启动 MySQL 服务..."
if command -v systemctl &>/dev/null; then
    sudo systemctl start mysql
    sudo systemctl enable mysql &>/dev/null
elif [ -f /etc/init.d/mysql ]; then
    sudo /etc/init.d/mysql start
fi
echo "[OK] MySQL 服务已启动"

# ---- 3. 设置 root 密码 ----
echo "[3/5] 配置 root 用户密码..."

# 交互式询问密码
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    read -rsp "请输入 MySQL root 密码 (输入时不显示): " MYSQL_ROOT_PASSWORD
    echo ""
    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        echo "[ERROR] 密码不能为空"
        exit 1
    fi
fi

# 尝试无密码登录并设置密码
if sudo mysql -u root -e "SELECT 1;" &>/dev/null; then
    echo "  设置 root 密码..."
    sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;"
    echo "[OK] root 密码设置成功"
else
    echo "[WARN] 无法无密码登录，可能已有密码。使用提供的密码尝试..."
fi

# ---- 4. 导入 SQL 文件 ----
echo "[4/5] 导入新闻数据库 (news_db)..."

if [ ! -f "$SQL_FILE" ]; then
    echo "[ERROR] SQL 文件不存在: $SQL_FILE"
    echo "请确保 news_db.sql 与本脚本在同一目录"
    exit 1
fi

mysql -u root -p"$MYSQL_ROOT_PASSWORD" < "$SQL_FILE" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "[OK] 数据库导入成功!"
else
    echo "[ERROR] 数据库导入失败，请检查密码和 MySQL 状态"
    exit 1
fi

# ---- 5. 验证 ----
echo "[5/5] 验证数据库..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "
USE news_db;
SELECT '--- 表列表 ---' AS '';
SHOW TABLES;
SELECT '--- 新闻分类 ---' AS '';
SELECT * FROM news_category;
SELECT '--- 新闻总数 ---' AS '';
SELECT COUNT(*) AS news_count FROM news;
SELECT '--- 测试用户 ---' AS '';
SELECT id, username, nickname FROM user;
"

echo ""
echo "============================================"
echo " 部署完成！"
echo "============================================"
echo ""
echo "连接信息:"
echo "  数据库: news_db"
echo "  用户:   root"
echo "  主机:   localhost:3306"
echo ""
echo "FastAPI .env 配置:"
echo "  DATABASE_URL=mysql+aiomysql://root:${MYSQL_ROOT_PASSWORD}@localhost:3306/news_db?charset=utf8mb4"
echo ""
echo "测试账号: admin / 123456"
