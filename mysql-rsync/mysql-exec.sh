#!/bin/bash
EXEC_FLAG=$1
CONFIG_MYSQL_HOST=$2
CONFIG_MYSQL_USER=$3
CONFIG_MYSQL_PASSWORD=$4
CONFIG_MYSQL_DATABASE=$5
VERSION_NUMBER=$6
FILE_PATH=$7

UNIXTIME=`date "+%s"`


function_update()
{
    if [ -f "${FILE_PATH}/update.sql" ]; then
        command -v mysql >/dev/null 2>&1 ||  (apt-get update && apt-get install -y mysql-client)

        SQLHASH=`md5sum ${FILE_PATH}/update.sql|cut -d ' ' -f1`
        if [ ! -f "${FILE_PATH}/.update.history.log" ]; then
            touch ${FILE_PATH}/.update.history.log
        fi
        if [ -z `cat ${FILE_PATH}/.update.history.log|grep $SQLHASH` ]; then
            mysql -h"${CONFIG_MYSQL_HOST}" -u"${CONFIG_MYSQL_USER}" -p"${CONFIG_MYSQL_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${CONFIG_MYSQL_DATABASE} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci"
            mysql -h"${CONFIG_MYSQL_HOST}" -u"${CONFIG_MYSQL_USER}" -p"${CONFIG_MYSQL_PASSWORD}" -D${CONFIG_MYSQL_DATABASE} < ${FILE_PATH}/update.sql
            rm -f ${FILE_PATH}/update.sql
            echo "$SQLHASH" >> "${FILE_PATH}/.update.history.log"
        fi
    else
        echo "The file ${FILE_PATH}/update.sql is not found!"
        exit 1
    fi    
}

function_backup()
{
    command -v mysqldump >/dev/null 2>&1 ||  (apt-get update && apt-get install -y mysql-client)
    mysqldump -h"${CONFIG_MYSQL_HOST}" -u"${CONFIG_MYSQL_USER}" -p"${CONFIG_MYSQL_PASSWORD}" --skip-lock-tables --add-drop-database --add-drop-table --databases ${CONFIG_MYSQL_DATABASE} > ${FILE_PATH}/latest.sql
    if [ -n "$VERSION_NUMBER" ]; then
        /bin/cp ${FILE_PATH}/latest.sql ${FILE_PATH}/${VERSION_NUMBER}_latest.sql
        /bin/cp ${FILE_PATH}/latest.sql ${FILE_PATH}/${VERSION_NUMBER}_`date "+%Y%m%d%H%M%S"`.sql
    fi
    [[ -f /work/sh/rsync.sh ]] && /bin/bash /work/sh/rsync.sh
}

case "$EXEC_FLAG" in
    update)
        function_update
        ;;
    backup)
        function_backup
        ;;  
    *)
        printf "Usage: bash $0 {update|backup}"
esac
exit