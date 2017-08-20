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
  bash -c "cd / && tar -xvzf /$1"
  