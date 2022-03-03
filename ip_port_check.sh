#!/bin/bash

source /etc/profile
PATH=/usr/local/mysql/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

USERNAME="****"
PASSWORD="****"
HOSTNAME="127.0.0.1"
PORT="3306"
DBNAME="sspanel"
TABLENAME="ss_node"

for line in `cat iplist.txt | grep -v ^# |grep -v ^$`
do  
    ip=`echo $line | awk 'BEGIN{FS="|"} {print $1}'`
    port=`echo $line | awk 'BEGIN{FS="|"} {print $2}'`
    echo "(sleep 1;) | telnet $ip $port"
    (sleep 1;) | telnet $ip $port > telnet_result.txt
    result=`cat telnet_result.txt | grep -B 1 \] | grep [0-9] | awk '{print $3}' | cut -d '.' -f 1,2,3,4`
    echo "$result"
    if [ -n "$result" ]; then
        echo "$ip|$port|" >> telnet_checked.txt
    else
	newport=`expr $port + 1`
        echo $(date +"%y-%m-%d") "$ip:$port not pass! " >> telnet_fail.txt
	echo "$ip|$newport|" >> telnet_checked.txt
		
	if [ "$ip" = "18.183.*.*" ]; then
		update_sql="update ${TABLENAME} set server='****1.com;$newport;2;ws;;path=/hls/cctv5phd.m3u8|host=****1.com' where id =5"
		mysql -h${HOSTNAME} -P${PORT} -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${update_sql}"
	fi
		
	if [ "$ip" = "3.113.*.*" ]; then
		update_sql="update ${TABLENAME} set server='****2.com;$newport;2;ws;;path=/hls/cctv5phd.m3u8|host=****2.com' where id =6"
		mysql -h${HOSTNAME} -P${PORT} -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${update_sql}"
	fi
    fi
done
	mv  telnet_checked.txt  iplist.txt
	echo "telnet checked over!"
