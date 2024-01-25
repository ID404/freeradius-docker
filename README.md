# 用途
启用TOTP认证的freeradius服务器。在freeradius的基本上部署google的TOTP 二步认证

镜像默认允许所有的客户端连接，radius密钥为123456 若需要修改请进入镜像修改 `/etc/freeradius/3.0/clients.conf`
以下为单个客户端的配置，可以在此基础上修改或者增加其它客户端IP，注意user修改为不一样的名字
```
client user {
	secret = 123456
	ipaddr = 0.0.0.0/0
}
```

# 构建docker 镜像

* 通过 `cd ~;git clone https://github.com/id404/freeradius.git` 将仓库下载至本地
* 执行 `./build` 进行镜像构建


# 启动镜像

* 方式一：通过执行 `./start-docker.sh` 镜像默认对外暴露1812/udp端口
  或者通过以下命令启动
  
  ```
  docker run -p 1812:1812/udp -h freeradius --name freeradius -d id404/freeradius
  ```
* 方式二：通过执行 `docker compose up -d` 通过docker compose 部署
  ```yaml
  version: '3'
  services:
    freeradius:
      image: id404/freeradius
      container_name: freeradius
      hostname: freeradius
      ports:
        - "1812:1812/udp"
      restart: unless-stopped
  ```

# 添加用户
* 通过 `./add-user $username` 添加用户，请将$usernmae更改为对应的用户名。用户密码输入完毕后要求使用google authenticatior等二步验证工具扫描二维码。扫描二维码后要求输入google authenticatior的密码进行验证。
* 验证密码后要求回答三个问题，按需设置 ，我一般是y y n y
  
  ```
  Do you want me to update your "/home/test/.google_authenticator" file? (y/n) y

  Do you want to disallow multiple uses of the same authentication
  token? This restricts you to one login about every 30s, but it increases
  your chances to notice or even prevent man-in-the-middle attacks (y/n) y
  
  By default, a new token is generated every 30 seconds by the mobile app.
  In order to compensate for possible time-skew between the client and the server,
  we allow an extra token before and after the current time. This allows for a
  time skew of up to 30 seconds between authentication server and client. If you
  experience problems with poor time synchronization, you can increase the window
  from its default size of 3 permitted codes (one previous code, the current
  code, the next code) to 17 permitted codes (the 8 previous codes, the current
  code, and the 8 next codes). This will permit for a time skew of up to 4 minutes
  between client and server.
  Do you want to do so? (y/n) n
  
  If the computer that you are logging into isn't hardened against brute-force
  login attempts, you can enable rate-limiting for the authentication module.
  By default, this limits attackers to no more than 3 login attempts every 30s.
  Do you want to enable rate-limiting? (y/n) y
  ```
  
  
# 数据持久化
待解决 ，目前发现持久化后无法添加用户


~docker run 命令~

```bash
docker run -d --name freeradius -h freeradius -p 1812:1812/udp --restart unless-stopped \
  -v ./data/config/clients.conf:/etc/freeradius/3.0/clients.conf \
  -v ./data/userdata/home:/home \
  -v ./data/userdata/passwd:/etc/passwd \
  -v ./data/userdata/shadow:/etc/shadow \
  -v ./data/userdata/gshadow:/etc/gshadow \
  id404/freeradius
```

~docker compose文件内容~
```
version: '3'
services:
  freeradius:
    image: id404/freeradius
    container_name: freeradius
    hostname: freeradius
    ports:
      - "1812:1812/udp"
    restart: unless-stopped
    volumes:
      - ./data/config/clients.conf:/etc/freeradius/3.0/clients.conf
      - ./data/userdata/home:/home
      - ./data/userdata/passwd:/etc/passwd
      - ./data/userdata/shadow:/etc/shadow
      - ./data/userdata/gshadow:/etc/gshadow
```

# 取消TOTP认证

