#!/bin/bash 

source /etc/profile

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
        echo $(date +"%y-%m-%d %H:%M:%S") "$ip:$port Fail! " >> telnet_fail.txt
	echo "$ip|$newport|" >> telnet_checked.txt
		
	if [ "$ip" = "18.183.*.*" ]; then
	update_sql="update ${TABLENAME} set server='****url.com;$newport;2;ws;;path=/hls/cctv5phd.m3u8|host=****url.com' where id =5"
	/usr/local/mysql/bin/mysql -h${HOSTNAME} -P${PORT} -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${update_sql}"
	fi			
    fi
done
	mv  telnet_checked.txt  iplist.txt
echo "telnet IP_port checked over!"
