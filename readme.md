<!-- TOC -->

- [空数据卷启动container](#空数据卷启动container)
- [停止container生成备份](#停止container生成备份)
    - [斟酌是否删除container](#斟酌是否删除container)
- [从备份gz生成数据卷容器](#从备份gz生成数据卷容器)
- [数据卷启动container](#数据卷启动container)
- [在反向代理时注意参数](#在反向代理时注意参数)
- [反向代理](#反向代理)
    - [安装docker-gen](#安装docker-gen)
    - [生成nginx配置文件](#生成nginx配置文件)
    - [开启反向代理](#开启反向代理)

<!-- /TOC -->

# 空数据卷启动container
```
docker run -d --restart=always --name dokuwiki -p 80:80 mprasil/dokuwiki
```

# 停止container生成备份
```
docker stop dokuwiki

DATE=`date +%Y%m%d%H%M%S`
docker run --rm --volumes-from dokuwiki \
        -v $(pwd):/backup \
        ubuntu \
        tar -cvzf /backup/$DATE-dokuwiki-backup.tar.gz \
        /dokuwiki/data/ /dokuwiki/lib/plugins/ /dokuwiki/conf/ /dokuwiki/lib/tpl/ /var/log/
```

## 斟酌是否删除container
```
docker rm dokuwiki
docker volume rm $(docker volume ls -qf dangling=true)
```

# 从备份gz生成数据卷容器
```
docker run \
  -v /dokuwiki/data/ \
  -v /dokuwiki/lib/plugins/ \
  -v /dokuwiki/conf/ \
  -v /dokuwiki/lib/tpl/ \
  -v /var/log/ \
--name dokuwiki-backup ubuntu:14.04

docker run --rm --volumes-from dokuwiki-backup \
  -v $(pwd):/backup \
  ubuntu:14.04 \
  bash -c "cd / && tar -xvzf /backup/这里填写备份压缩包"
```

# 数据卷启动container
```
docker run -d --restart=always --name dokuwiki -p 80:80 --volumes-from dokuwiki-backup mprasil/dokuwiki
docker rm dokuwiki-backup
```

# 在反向代理时注意参数
去掉`-p 80:80`
```
-e VIRTUAL_HOST=yqsywiki.xyz --expose 80
```

# 反向代理

## 安装docker-gen
```
wget https://github.com/jwilder/docker-gen/releases/download/0.7.3/docker-gen-linux-amd64-0.7.3.tar.gz
tar xvzf docker-gen-linux-amd64-0.7.3.tar.gz
cp docker-gen /usr/local/bin
```

## 生成nginx配置文件
```
wget https://raw.githubusercontent.com/yqsy/dokuwiki-docker/master/nginx.tmpl

docker-gen nginx.tmpl > nginx.conf
```

## 开启反向代理
```
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

docker run -d --restart=always --name my-proxy \
    -v $DIR/nginx.conf:/etc/nginx/nginx.conf \
    -v $DIR/log:/var/log/nginx/ \
    -p 80:80 \
    nginx
```

