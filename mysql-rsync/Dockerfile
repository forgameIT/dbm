FROM debian:jessie

MAINTAINER leung.loong <lianglong@forgame.com>
 

RUN set -x; \
	{\
		echo 'deb http://mirrors.163.com/debian/ jessie main non-free contrib';\
		echo 'deb http://mirrors.163.com/debian/ jessie-updates main non-free contrib';\
		echo 'deb http://mirrors.163.com/debian/ jessie-backports main non-free contrib';\
		echo 'deb-src http://mirrors.163.com/debian/ jessie main non-free contrib';\
		echo 'deb-src http://mirrors.163.com/debian/ jessie-updates main non-free contrib';\
		echo 'deb-src http://mirrors.163.com/debian/ jessie-backports main non-free contrib';\
		echo 'deb http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib';\
		echo 'deb-src http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib';\
	}|tee /etc/apt/sources.list;\
	\
	#安装mysql客户端、rsync、crontab
	apt-get update && apt-get install -y mysql-client rsync cron;\
    #设置时区
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;\
	mkdir -p /work/sh/ && mkdir -p /work/sql/ && mkdir -p /work/logs/;\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

COPY *.sh /work/sh/

VOLUME /work/sql

ENTRYPOINT ["/work/sh/start.sh"]