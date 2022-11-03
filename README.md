# DxVPNMonitor

需求背景

AWS云上，VPN与DX需要进行主备高可用的切换，需要实现一个脚本，进行主备路由的Ping检车，并根据检测的结果进行决策，并进行路由切换的动作。

一、HAmonitor的逻辑

1、VPN和DX分别做两个点对点路由，需要预先选好云上云下两个IP地址，配置单条路由。

2、一旦Ping不通，脚本会自动修改TGW的Preference路由，进行路由切换。因此需要优先吧Prefix IP地址事先设置好，这个IP地址表示IDC机房的多个地址端。脚本所在的节点需要有权限修改TGW路由，需要安装AWS CLI，配置好AKSK或者AWS credential profile

二、部署脚本的过程

0、拷贝脚本到 /home/ec2-user/下

1、chmod +777 monitor 目录下的脚本

2、执行CronTab的挂载
crontab -e
10 8 * * 0 /bin/bash /home/ec2-user/monitor/HAcron.sh > /home/ec2-user/monitor/log/HAcron`date '+\%Y\%m\%d\%H\%M'`.log 2>&1 &


三、脚本配合执行逻辑说明

1 利用Linux的Crond服务，每周执行一次HAcron.sh，在这个脚本中会先把进程清理掉，启动HAwatch.sh

2 HAwatch会监控HAmonitor的执行，守护它，如果异常退出，立即拉起它

3 HAmonitor进行Ping检查，判断是否需要切换路由，进行具体的路由切换。


