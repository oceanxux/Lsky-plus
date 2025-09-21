#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 创建必要的目录
mkdir -p /run/php
mkdir -p /var/log

ln -snf /usr/share/zoneinfo/${TZ:-Asia/Shanghai} /etc/localtime && echo ${TZ:-Asia/Shanghai} > /etc/timezone

cd /var/www/html

if [ "${DB_CONNECTION:-sqlite}" != "sqlite" ]; then
    echo -e "${YELLOW}等待数据库服务启动...${NC}"
    until nc -z "${DB_HOST:-127.0.0.1}" "${DB_PORT:-3306}"; do
        echo -e "${YELLOW}等待数据库连接 ${DB_HOST:-127.0.0.1}:${DB_PORT:-3306}...${NC}"
        sleep 2
    done
    echo -e "${GREEN}✓ 数据库连接成功${NC}"
fi

if [ ! -f "/var/www/html/installed.lock" ]; then
    echo -e "${YELLOW}开始安装应用...${NC}"

    if [ -z "${APP_URL}" ]; then
        echo -e "${RED}错误: 必须提供 APP_URL 环境变量${NC}"
        echo -e "${RED}请在启动容器时设置: -e APP_URL=your-domain${NC}"
        exit 1
    fi
    
    if [ -z "${APP_LICENSE_KEY}" ]; then
        echo -e "${RED}错误: 必须提供 APP_LICENSE_KEY 环境变量${NC}"
        echo -e "${RED}请在启动容器时设置: -e APP_LICENSE_KEY=your-license-key${NC}"
        exit 1
    fi
    
    php artisan app:install \
        --app-name="${APP_NAME:-兰空图床}" \
        --app-url="${APP_URL:-http://localhost}" \
        --app-license-key="${APP_LICENSE_KEY}" \
        --db-connection="${DB_CONNECTION:-sqlite}" \
        --db-host="${DB_HOST:-127.0.0.1}" \
        --db-port="${DB_PORT:-3306}" \
        --db-database="${DB_DATABASE:-/var/www/html/database/database.sqlite}" \
        --db-username="${DB_USERNAME:-}" \
        --db-password="${DB_PASSWORD:-}" \
        --admin-username="${ADMIN_USERNAME:-admin}" \
        --admin-email="${ADMIN_EMAIL:-admin@example.com}" \
        --admin-password="${ADMIN_PASSWORD:-admin123}" \
        --force
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 应用安装成功${NC}"
        touch /var/www/html/installed.lock
    else
        echo -e "${RED}✗ 应用安装失败${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}正在初始化...${NC}"

# 设置目录所有者和权限
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /run/php
chmod -R 775 /var/www/html
chmod -R 755 /var/www/html/storage
chmod -R 755 /var/www/html/bootstrap/cache
chmod -R 755 /var/www/html/database
chmod -R 755 /run/php

echo -e "${GREEN}=== 应用初始化完成，启动服务... ===${NC}"
echo -e "${BLUE}数据库类型: ${DB_CONNECTION:-sqlite}${NC}"
if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then
    echo -e "${BLUE}SQLite数据库: ${DB_DATABASE:-/var/www/html/database/database.sqlite}${NC}"
else
    echo -e "${BLUE}数据库地址: ${DB_HOST:-127.0.0.1}:${DB_PORT:-3306}${NC}"
    echo -e "${BLUE}数据库名称: ${DB_DATABASE}${NC}"
fi
echo -e "${BLUE}应用地址: ${APP_URL:-http://localhost}${NC}"

exec supervisord -c /etc/supervisor/conf.d/supervisord.conf 