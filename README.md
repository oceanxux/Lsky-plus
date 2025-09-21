```mak
cd home && mkdir data && touch docker-compose.yaml && touch .env
```

```yml
services:
  lsky-pro:
    image: lsky-pro:latest
    container_name: lsky-pro
    ports:
      - "9999:80" # 修改port mapping
    env_file: .env
    environment:
      - APP_NAME=兰空图床
      - APP_URL=http://localhost:9999 # 改为你自己的域名
      - APP_LICENSE_KEY=xxxx-xxxx-xxxx-xxxx # 随便填
      - ADMIN_USERNAME=admin # 不设置则默认为 admin
      - ADMIN_EMAIL=admin@example.com # 不设置则默认为 admin@example.com
      - ADMIN_PASSWORD=admin123 # 不设置则默认为 admin123
    volumes:
      - data:/var/www/html
    restart: unless-stopped
    network_mode: bridge

volumes:
  data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./data
```

[官网](https://www.lsky.pro) &middot;
[文档](https://docs.lsky.pro) &middot;
[社区](https://bbs.lskypro.com) &middot;
[演示](https://v2.lskypro.com) &middot;
[QQ 群组](https://qm.qq.com/cgi-bin/qm/qr?k=Fqnm6yKh8lyWc3wG9o4EjiG5raYmtBFY&jump_from=webapi) &middot;
[Telegram 群组](https://t.me/lsky_pro)
