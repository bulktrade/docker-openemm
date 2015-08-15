#!/bin/bash

#set -m
#set -e

if [ -f /home/openemm/.NOT_CONFIGURED ]; then
	/setup-openemm.sh
    rm /home/openemm/.NOT_CONFIGURED
fi

echo "" > /home/openemm/conf/bav/bav.conf-local
COUNTER="1"
for ADDRESS in $MAIL_ADDRESSES; do
	echo "${ADDRESS}@${OPEN_EMM_HOSTNAME} alias:ext_${COUNTER}@${OPEN_EMM_HOSTNAME}" >> /home/openemm/conf/bav/bav.conf-local
	COUNTER=$[$COUNTER+1]
done

echo -n -e "\n=> Start OpenEMM ..."
echo -e "\n-----------------------------------"

su openemm -c 'sh /home/openemm/bin/openemm.sh start'
tail -f /home/openemm/logs/* /home/openemm/var/log/*
su openemm -c 'sh /home/openemm/bin/openemm.sh stop'
