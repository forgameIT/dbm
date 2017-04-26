#!/bin/bash
set -e

if [ "$BACKUP_TIME" = "" ]; then 
    BACKUP_TIME='0 1 * * *' #默认备份时间为每天凌晨1点
fi

[[ ! -f /etc/cron.d/cron ]] && touch /etc/cron.d/cron

if [ -n "$MYSQL_HOST" -a -n "$MYSQL_USER" -a -n "$MYSQL_PASSWORD" ]; then 
	sed -e "s/\$2/'${MYSQL_HOST}'/g" \
		-e "s/\$3/'${MYSQL_USER}'/g" \
		-e "s/\$4/'${MYSQL_PASSWORD}'/g" \
		-e "s/\$5/'${MYSQL_DATABASE}'/g" \
		-e "s/\$6/'${BACKUP_PREFIX}'/g" \
		-e "s/\$7/'\/work\/sql'/g" \
		/work/sh/mysql-exec.sh -i
	(cat /etc/cron.d/cron;echo "$BACKUP_TIME /bin/bash /work/sh/mysql-exec.sh backup >>/work/logs/backup.log 2>&1") 2>&1 | uniq > /etc/cron.d/cron 
	crontab /etc/cron.d/cron	
fi

if [ -n "$RSYNC_HOST" -a -n "$RSYNC_USER" -a -n "$RSYNC_PASSWORD" ]; then 
    echo $RSYNC_PASSWORD > /root/rsync.secrets
    chmod 600 /root/rsync.secrets
    echo "#!/bin/bash" > /work/sh/rsync.sh
    TOPATH="::${RSYNC_USER}"
	[[ -n $RSYNC_DEST ]] && TOPATH=":${RSYNC_DEST}"
    echo "rsync -avzP --password-file=/root/rsync.secrets --include='*.sql' --exclude='*' /work/sql/ ${RSYNC_USER}@${RSYNC_HOST}${TOPATH} >>/work/logs/rsync.log 2>&1" >> /work/sh/rsync.sh
    chmod +x /work/sh/rsync.sh
fi

cron -f