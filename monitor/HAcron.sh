#! /bin/sh

#每周日的8点10分
# crontab -e
# 10 8 * * 0 /bin/bash /home/ec2-user/monitor/HAcron.sh > /home/ec2-user/monitor/log/HAcron`date '+\%Y\%m\%d\%H\%M'`.log 2>&1 &
# 查看任务
# crontab -l
# 涮出任务
# crontab -e 去掉之前添加的任务
# 测试每1分钟，执行一次
# */3 * * * * /bin/bash /home/ec2-user/monitor/HAcron.sh > /home/ec2-user/monitor/log/HAcron`date '+\%Y\%m\%d\%H\%M'`.log 2>&1 &
#*/3 * * * * /bin/bash /home/ec2-user/monitor/HAcron.sh > /home/ec2-user/monitor/log/HAcronlog 2>&1 &
#查看开启激动 crond
#sudo ntsysv
# crond重启
#sudo service crond restart

basePath=/home/ec2-user/monitor
PRO_NAME=HAwatch.sh
PRO_NAME2=HAmonitor.sh

# 每周重启一次
killall -9 -I $PRO_NAME
killall -9 -I $PRO_NAME2
while true ; do
     #用ps获取$PRO_NAME进程数量
     NUM=`ps aux | grep -w ${PRO_NAME} | grep -v grep |wc -l`
     #echo $NUM
     #少于1，重启进程
     if [ "${NUM}" -lt "1" ];then
         echo "${PRO_NAME} was killed"
         LogNameDATE=`date '+%Y%m%d%H%M'`
         echo "$LogNameDATE restart ${PRO_NAME}  ${PRO_NAME}"
         nohup ${basePath}/${PRO_NAME} > ${basePath}/log/${PRO_NAME}${LogNameDATE}.log 2>&1 &
         break
    #大于1，杀掉所有进程，重启
    elif [ "${NUM}" -gt "1" ];then
        echo "more than 1 ${PRO_NAME},killall ${PRO_NAME}"
         killall -9 $PRO_NAME
        ${PRO_NAME} -d
     fi
     #kill僵尸进程
     NUM_STAT=`ps aux | grep -w ${PRO_NAME} | grep T | grep -v grep | wc -l`
     if [ "${NUM_STAT}" -gt "0" ];then
         killall -9 ${PRO_NAME}
         ${PRO_NAME} -d
    fi
 done

 exit 0