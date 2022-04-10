#!/usr/bin/env bash
# coding: utf-8
#
# author: liuchao
# date: 2022.03.21
# email: mirs_chao@163.com
# usage: deploy zabbix agent


rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum clean all
yum makecache fast
yum install zabbix-agent

cat <<-EOF >/etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=SERVERIP
ServerActive=SERVERIP
HostMetadataItem=system.uname
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOF

systemctl enable --now zabbix-agent
