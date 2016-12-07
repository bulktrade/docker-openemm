#!/bin/bash

MAIL_HOST=${MAIL_HOST-$MAIL_PORT_25_TCP_ADDR}
MAIL_USERNAME_AND_PASSWORD=${MAIL_USERNAME_AND_PASSWORD-$MAIL_ENV_smtp_user}

OPEN_EMM_URL=${OPEN_EMM_URL-http://localhost:8080}
OPEN_EMM_HOSTNAME=${OPEN_EMM_HOSTNAME-localhost}

EOPEN_EMM_URL=$(echo $OPEN_EMM_URL | sed -e 's/\//\\\//g' -e 's/\&/\\\&/g')
EOPEN_EMM_HOSTNAME=$(echo $OPEN_EMM_HOSTNAME | sed -e 's/\//\\\//g' -e 's/\&/\\\&/g')

echo -n -e "\n=> Configure OpenEMM ..."

while [ -z "$(mysqlshow -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS mysql 2>/dev/null)" ]
do
	sleep 1
	echo -n "."
done

echo -e "\n-----------------------------------"

cd /usr/share/doc/OpenEMM-2015

if [ -z "$(mysqlshow -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS openemm 2>/dev/null)" ];
then
	echo -n -e "\n=> Create OpenEMM CMS Database: "
    mysqladmin -f -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS drop openemm_cms 2> /dev/null 1> /dev/null
    mysqladmin -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS create openemm_cms
	echo -e "[OK]"

	echo -n "=> Import OpenEMM CMS Database: "
    mysql -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS openemm_cms < openemm_cms-2015.sql
	echo -e "[OK]"

	echo -n "=> Create OpenEMM Database: "
    mysqladmin -f -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS drop openemm 2> /dev/null 1> /dev/null
    mysqladmin -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS create openemm
	echo -e "[OK]"

	cp openemm-2015_R3.sql openemm-2015.w.sql
	sed -i "s/http:\/\/localhost:8080',''/$EOPEN_EMM_URL','$EOPEN_EMM_HOSTNAME'/g" openemm-2015.w.sql
	sed -i "s/'agnitas'@'localhost'/'agnitas'@'$MYSQL_PORT_3306_TCP_ADDR'/g" openemm-2015.w.sql

	echo -n "=> Import OpenEMM Database: "
    mysql -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS openemm < openemm-2015.w.sql
	echo -e "[OK]"

	mysql -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS openemm -e 'CREATE INDEX custbind$cuid_mlid_user$idx ON customer_1_binding_tbl (customer_id, mailinglist_id, user_status, user_type);'
	mysql -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS openemm -e 'CREATE INDEX onpx$mid_cuid$idx ON onepixel_log_tbl (mailing_id, customer_id);'
	mysql -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS openemm -e 'CREATE INDEX rlog$mid_cuid_urlid$idx ON rdir_log_tbl (mailing_id, customer_id, url_id);'
else
	mysql -h $MYSQL_PORT_3306_TCP_ADDR -u admin --password=$MYSQL_ENV_MYSQL_PASS openemm -e "UPDATE company_tbl SET rdir_domain='$OPEN_EMM_URL', mailloop_domain='$OPEN_EMM_HOSTNAME';"
fi

sed -i "s/http:\/\/localhost:8080/$EOPEN_EMM_URL'/g" /home/openemm/webapps/openemm/WEB-INF/classes/cms.properties
sed -i "s/http:\/\/localhost:8080/$EOPEN_EMM_URL'/g" /home/openemm/webapps/openemm/WEB-INF/classes/emm.properties
sed -i "s/system.mail.host=localhost/system.mail.host=$MAIL_HOST'/g" /home/openemm/webapps/openemm/WEB-INF/classes/emm.properties

sed -i "s/url=\"jdbc:mysql:\/\/localhost/url=\"jdbc:mysql:\/\/$MYSQL_PORT_3306_TCP_ADDR/g" /home/openemm/conf/context.xml
sed -i "s/username=\"agnitas\"/username=\"$MYSQL_ENV_MYSQL_USER\"/g" /home/openemm/conf/context.xml
sed -i "s/password=\"openemm\"/password=\"$MYSQL_ENV_MYSQL_PASS\"/g" /home/openemm/conf/context.xml

sed -i "s/smtp.starttls/#smtp.starttls/g" /home/openemm/bin/scripts/semu.py
sed -i "s/smtp.ehlo/#smtp.ehlo/g" /home/openemm/bin/scripts/semu.py

#sed -i "s/DAEMON_OPTIONS(\`Port=smtp,Addr=127.0.0.1, Name=MTA')dnl/dnl DAEMON_OPTIONS(\`Port=smtp,Addr=127.0.0.1, Name=MTA')dnl/g" /etc/mail/sendmail.mc
#echo "INPUT_MAIL_FILTER(\`bav', \`S=unix:/home/openemm/var/run/bav.sock, F=T')dnl" >> /etc/mail/sendmail.mc

sed -i "s/'localhost', 'agnitas', 'openemm'/'$MYSQL_PORT_3306_TCP_ADDR', '$MYSQL_ENV_MYSQL_USER', '$MYSQL_ENV_MYSQL_PASS'/g" /home/openemm/bin/scripts/agn.py

su openemm -c 'sh /home/openemm/bin/sendmail-disable.sh'

touch /var/log/maillog && chmod 604 /var/log/maillog

/setup-cron.sh

echo ">>> Done <<<"
