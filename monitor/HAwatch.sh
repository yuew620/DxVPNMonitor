#! /bin/sh

#nohup /home/ec2-user/monitor/HAwatcher.sh > /home/ec2-user/monitor/log/HAwatcher`date '+%Y%m%d%H%M'`.log 2>&1 &
#进程名字可修改
PRO_NAME=HAmonitor.sh
basePath=/home/ec2-user/monitor
chmod +x ${basePath}/HAmonitor.sh
#find /home/ec2-user/monitor/log/ -mmin +120 -name "*.log" -exec rm -rf {} \;
find ${basePath}/log/ -mtime +4 -name "*.log" -exec rm -rf {} \;
while true ; do
     #用ps获取$PRO_NAME进程数量
     NUM=`ps aux | grep -w ${PRO_NAME} | grep -v grep |wc -l`
     #echo $NUM
     #少于1，重启进程
     if [ "${NUM}" -lt "1" ];then
         echo "${PRO_NAME} was killed"
         LogNameDATE=`date '+%Y%m%d%H%M'`
         nohup ${basePath}/${PRO_NAME} > ${basePath}/log/${PRO_NAME}${LogNameDATE}.log 2>&1 &
    #大于1，杀掉所有进程，重启
    elif [ "${NUM}" -gt "1" ];then
        echo "more than 1 ${PRO_NAME},killall ${PRO_NAME}"
         killall -9 -I $PRO_NAME
        ${PRO_NAME} -d
     fi
     #kill僵尸进程
     NUM_STAT=`ps aux | grep -w ${PRO_NAME} | grep T | grep -v grep | wc -l`
     if [ "${NUM_STAT}" -gt "0" ];then
         echo "kill zombie ${PRO_NAME}"
         killall -9 -I ${PRO_NAME}
         ${PRO_NAME} -d
     fi

     sleep 5s

 done

 exit 0