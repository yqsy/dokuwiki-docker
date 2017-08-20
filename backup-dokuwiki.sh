DATE=`date +%Y%m%d%H%M%S`
docker run --rm --volumes-from dokuwiki \
        -v $(pwd):/backup \
        ubuntu \
        tar -cvzf /backup/$DATE-dokuwiki-backup.tar.gz \
        /dokuwiki/data/ /dokuwiki/lib/plugins/ /dokuwiki/conf/ /dokuwiki/lib/tpl/ /var/log/
