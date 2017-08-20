<!-- TOC -->

- [空数据卷启动container](#空数据卷启动container)
- [停止container生成备份](#停止container生成备份)
    - [斟酌是否删除container](#斟酌是否删除container)
- [从备份gz生成数据卷容器](#从备份gz生成数据卷容器)
- [数据卷启动container](#数据卷启动container)

<!-- /TOC -->

# 空数据卷启动container
```
docker run -d --name dokuwiki -p 80:80 mprasil/dokuwiki
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
docker run -d --name dokuwiki -p 80:80 --volumes-from dokuwiki-backup mprasil/dokuwiki
docker rm dokuwiki-backup
```
